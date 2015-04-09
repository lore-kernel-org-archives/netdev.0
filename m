From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2-next 2/2] netns: allow to dump and monitor nsid
Date: Thu, 9 Apr 2015 11:36:01 +0300
Message-ID: <20150409083601.GA1085@angus-think.wlc.globallogic.com>
References: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com>
 <1428568214-8673-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:33523 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbbDIIsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 04:48:10 -0400
Received: by layy10 with SMTP id y10so84397816lay.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 01:48:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428568214-8673-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 09, 2015 at 10:30:14AM +0200, Nicolas Dichtel wrote:

Hi,

> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index 45e234a4d98c..7806335733cf 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -14,10 +14,12 @@
>  #include <errno.h>
>  #include <unistd.h>
>  #include <ctype.h>
> +#include <linux/limits.h>
>  
>  #include <linux/net_namespace.h>
>  
>  #include "utils.h"
> +#include "hlist.h"
>  #include "ip_common.h"
>  #include "namespace.h"
>  
> @@ -31,9 +33,13 @@ static int usage(void)
>  	fprintf(stderr, "       ip netns pids NAME\n");
>  	fprintf(stderr, "       ip [-all] netns exec [NAME] cmd ...\n");
>  	fprintf(stderr, "       ip netns monitor\n");
> +	fprintf(stderr, "       ip netns list-id\n");
>  	exit(-1);
>  }
>  
> +/* This socket is used to get nsid */
> +static struct rtnl_handle rtnsh = { .fd = -1 };
> +
>  #ifdef HAVE_NETNSID
>  static int get_netnsid_from_name(const char *name)
>  {
> @@ -57,7 +63,7 @@ static int get_netnsid_from_name(const char *name)
>  		return fd;
>  
>  	addattr32(&req.n, 1024, NETNSA_FD, fd);
> -	if (rtnl_talk(&rth, &req.n, 0, 0, &answer.n) < 0) {
> +	if (rtnl_talk(&rtnsh, &req.n, 0, 0, &answer.n) < 0) {
>  		close(fd);
>  		return -2;
>  	}
> @@ -86,6 +92,194 @@ static int get_netnsid_from_name(const char *name)
>  }
>  #endif /* HAVE_NETNSID */
>  
> +struct nsid_cache {
> +	struct hlist_node	nsid_hash;
> +	struct hlist_node	name_hash;
> +	int			nsid;
> +	char			name[NAME_MAX];
> +};
> +
> +#define NSIDMAP_SIZE		128
> +#define NSID_HASH_NSID(nsid)	(nsid & (NSIDMAP_SIZE - 1))
> +#define NSID_HASH_NAME(name)	(namehash(name) & (NSIDMAP_SIZE - 1))
> +
> +static struct hlist_head	nsid_head[NSIDMAP_SIZE];
> +static struct hlist_head	name_head[NSIDMAP_SIZE];
> +
> +static struct nsid_cache *netns_map_get_by_nsid(int nsid)
> +{
> +	uint32_t h = NSID_HASH_NSID(nsid);
> +	struct hlist_node *n;
> +
> +	hlist_for_each(n, &nsid_head[h]) {
> +		struct nsid_cache *c = container_of(n, struct nsid_cache,
> +						    nsid_hash);
> +		if (c->nsid == nsid)
> +			return c;
> +	}
> +
> +	return NULL;
> +}
> +
> +static int netns_map_add(int nsid, char *name)
> +{
> +	struct nsid_cache *c;
> +	uint32_t h;
> +
> +	if (netns_map_get_by_nsid(nsid) != NULL)
> +		return -EEXIST;
> +
> +	c = malloc(sizeof(*c));
> +	if (c == NULL) {
> +		perror("malloc");
> +		return -ENOMEM;
> +	}
> +	c->nsid = nsid;
> +	strcpy(c->name, name);
> +
> +	h = NSID_HASH_NSID(nsid);
> +	hlist_add_head(&c->nsid_hash, &nsid_head[h]);
> +
> +	h = NSID_HASH_NAME(name);
> +	hlist_add_head(&c->name_hash, &name_head[h]);
> +
> +	return 0;
> +}
> +
> +static void netns_map_del(struct nsid_cache *c)
> +{
> +	hlist_del(&c->name_hash);
> +	hlist_del(&c->nsid_hash);
> +	free(c);
> +}
> +
> +void netns_map_init(void)
> +{
> +	static int initialized;
> +	struct dirent *entry;
> +	DIR *dir;
> +	int nsid;
> +
> +	if (initialized)
> +		return;
> +
> +	if (rtnl_open(&rtnsh, 0) < 0) {
> +		fprintf(stderr, "Cannot open rtnetlink\n");
> +		exit(1);
> +	}
> +
> +	dir = opendir(NETNS_RUN_DIR);
> +	if (!dir)
> +		return;
> +
> +	while ((entry = readdir(dir)) != NULL) {
> +		if (strcmp(entry->d_name, ".") == 0)
> +			continue;
> +		if (strcmp(entry->d_name, "..") == 0)
> +			continue;
> +		nsid = get_netnsid_from_name(entry->d_name);
> +
> +		if (nsid >= 0)
> +			netns_map_add(nsid, entry->d_name);
> +	}

May be lib/namespace.c -> netns_foreach will be useful here  ?

> +	closedir(dir);
> +	initialized = 1;
> +}
> +
> +static int netns_get_name(int nsid, char *name)
> +{
> +	struct dirent *entry;
> +	DIR *dir;
> +	int id;
> +
> +	dir = opendir(NETNS_RUN_DIR);
> +	if (!dir)
> +		return -ENOENT;
> +
> +	while ((entry = readdir(dir)) != NULL) {
> +		if (strcmp(entry->d_name, ".") == 0)
> +			continue;
> +		if (strcmp(entry->d_name, "..") == 0)
> +			continue;
> +		id = get_netnsid_from_name(entry->d_name);
> +
> +		if (nsid == id) {
> +			strcpy(name, entry->d_name);
> +			closedir(dir);
> +			return 0;
> +		}
> +	}

And may be here too ?

> +	closedir(dir);
> +	return -ENOENT;
> +}
> +

Regards,
Vadim Kochan
