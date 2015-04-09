From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2-next 2/2] netns: allow to dump and monitor nsid
Date: Thu, 9 Apr 2015 11:48:05 +0300
Message-ID: <20150409084805.GA2492@angus-think.wlc.globallogic.com>
References: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com>
 <1428568214-8673-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:35222 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbbDIJAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 05:00:13 -0400
Received: by labbd9 with SMTP id bd9so73187144lab.2
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 02:00:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428568214-8673-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 09, 2015 at 10:30:14AM +0200, Nicolas Dichtel wrote:
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

I am not sure but may be lib/names.c can be used here for caching
netns (name,id) entries here ?
I tried to make it generic when added mapping class id -> name for tc util.

Regards,
Vadim Kochan
