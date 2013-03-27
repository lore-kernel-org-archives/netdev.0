From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Wed, 27 Mar 2013 10:47:46 -0700
Message-ID: <20130327104746.0ec9dcb5@nehalam.linuxnetplumber.net>
References: <CD78B3C3.76D3%blourdel@juniper.net>
	<874nfwri6o.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:51196 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab3C0Rr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:47:59 -0400
Received: by mail-pa0-f50.google.com with SMTP id bg2so2263466pad.37
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 10:47:59 -0700 (PDT)
In-Reply-To: <874nfwri6o.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you need to do lots of operations the --batch mode will be significantly faster.
One command start and one link map.

I have an updated version of link map hash (index and name). Could you test this patch
which applies to latest version in git.

diff --git a/lib/ll_map.c b/lib/ll_map.c
index e9ae129..bf5b0bc 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -12,6 +12,7 @@
 
 #include <stdio.h>
 #include <stdlib.h>
+#include <stddef.h>
 #include <unistd.h>
 #include <syslog.h>
 #include <fcntl.h>
@@ -23,9 +24,44 @@
 #include "libnetlink.h"
 #include "ll_map.h"
 
-struct ll_cache
+
+struct hlist_head {
+	struct hlist_node *first;
+};
+
+struct hlist_node {
+	struct hlist_node *next, **pprev;
+};
+
+static inline void hlist_del(struct hlist_node *n)
+{
+	struct hlist_node *next = n->next;
+	struct hlist_node **pprev = n->pprev;
+	*pprev = next;
+	if (next)
+		next->pprev = pprev;
+}
+
+static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
 {
-	struct ll_cache   *idx_next;
+	struct hlist_node *first = h->first;
+	n->next = first;
+	if (first)
+		first->pprev = &n->next;
+	h->first = n;
+	n->pprev = &h->first;
+}
+
+#define hlist_for_each(pos, head) \
+	for (pos = (head)->first; pos ; pos = pos->next)
+
+#define container_of(ptr, type, member) ({			\
+	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
+	(type *)( (char *)__mptr - offsetof(type,member) );})
+
+struct ll_cache {
+	struct hlist_node idx_hash;
+	struct hlist_node name_hash;
 	unsigned	flags;
 	int		index;
 	unsigned short	type;
@@ -33,49 +69,107 @@ struct ll_cache
 };
 
 #define IDXMAP_SIZE	1024
-static struct ll_cache *idx_head[IDXMAP_SIZE];
+static struct hlist_head idx_head[IDXMAP_SIZE];
+static struct hlist_head name_head[IDXMAP_SIZE];
 
-static inline struct ll_cache *idxhead(int idx)
+static struct ll_cache *ll_get_by_index(unsigned index)
 {
-	return idx_head[idx & (IDXMAP_SIZE - 1)];
+	struct hlist_node *n;
+	unsigned h = index & (IDXMAP_SIZE - 1);
+
+	hlist_for_each(n, &idx_head[h]) {
+		struct ll_cache *im
+			= container_of(n, struct ll_cache, idx_hash);
+		if (im->index == index)
+			return im;
+	}
+
+	return NULL;
+}
+
+static unsigned namehash(const char *str)
+{
+	unsigned hash = 5381;
+
+	while (*str)
+		hash = ((hash << 5) + hash) + *str++; /* hash * 33 + c */
+
+	return hash;
+}
+
+static struct ll_cache *ll_get_by_name(const char *name)
+{
+	struct hlist_node *n;
+	unsigned h = namehash(name) & (IDXMAP_SIZE - 1);
+
+	hlist_for_each(n, &name_head[h]) {
+		struct ll_cache *im
+			= container_of(n, struct ll_cache, name_hash);
+
+		if (strncmp(im->name, name, IFNAMSIZ) == 0)
+			return im;
+	}
+
+	return NULL;
 }
 
 int ll_remember_index(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n, void *arg)
 {
-	int h;
+	unsigned int h;
+	const char *ifname;
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
-	struct ll_cache *im, **imp;
+	struct ll_cache *im;
 	struct rtattr *tb[IFLA_MAX+1];
 
-	if (n->nlmsg_type != RTM_NEWLINK)
+	if (n->nlmsg_type != RTM_NEWLINK && n->nlmsg_type != RTM_DELLINK)
 		return 0;
 
 	if (n->nlmsg_len < NLMSG_LENGTH(sizeof(ifi)))
 		return -1;
 
+	im = ll_get_by_index(ifi->ifi_index);
+	if (n->nlmsg_type == RTM_DELLINK) {
+		if (im) {
+			hlist_del(&im->name_hash);
+			hlist_del(&im->idx_hash);
+			free(im);
+		}
+		return 0;
+	}
+
 	memset(tb, 0, sizeof(tb));
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), IFLA_PAYLOAD(n));
-	if (tb[IFLA_IFNAME] == NULL)
+	ifname = rta_getattr_str(tb[IFLA_IFNAME]);
+	if (ifname == NULL)
 		return 0;
 
-	h = ifi->ifi_index & (IDXMAP_SIZE - 1);
-	for (imp = &idx_head[h]; (im=*imp)!=NULL; imp = &im->idx_next)
-		if (im->index == ifi->ifi_index)
-			break;
-
-	if (im == NULL) {
-		im = malloc(sizeof(*im));
-		if (im == NULL)
-			return 0;
-		im->idx_next = *imp;
-		im->index = ifi->ifi_index;
-		*imp = im;
+	if (im) {
+		/* change to existing entry */
+		if (strcmp(im->name, ifname) != 0) {
+			hlist_del(&im->name_hash);
+			h = namehash(ifname) & (IDXMAP_SIZE - 1);
+			hlist_add_head(&im->name_hash, &name_head[h]);
+		}
+
+		im->flags = ifi->ifi_flags;
+		return 0;
 	}
 
+	im = malloc(sizeof(*im));
+	if (im == NULL)
+		return 0;
+	im->index = ifi->ifi_index;
+	strcpy(im->name, ifname);
 	im->type = ifi->ifi_type;
 	im->flags = ifi->ifi_flags;
-	strcpy(im->name, RTA_DATA(tb[IFLA_IFNAME]));
+
+	h = ifi->ifi_index & (IDXMAP_SIZE - 1);
+	hlist_add_head(&im->idx_hash, &idx_head[h]);
+
+	h = namehash(ifname) & (IDXMAP_SIZE - 1);
+	hlist_add_head(&im->name_hash, &name_head[h]);
+
 	return 0;
 }
 
@@ -86,15 +180,14 @@ const char *ll_idx_n2a(unsigned idx, char *buf)
 	if (idx == 0)
 		return "*";
 
-	for (im = idxhead(idx); im; im = im->idx_next)
-		if (im->index == idx)
-			return im->name;
+	im = ll_get_by_index(idx);
+	if (im)
+		return im->name;
 
 	snprintf(buf, IFNAMSIZ, "if%d", idx);
 	return buf;
 }
 
-
 const char *ll_index_to_name(unsigned idx)
 {
 	static char nbuf[IFNAMSIZ];
@@ -108,10 +201,9 @@ int ll_index_to_type(unsigned idx)
 
 	if (idx == 0)
 		return -1;
-	for (im = idxhead(idx); im; im = im->idx_next)
-		if (im->index == idx)
-			return im->type;
-	return -1;
+
+	im = ll_get_by_index(idx);
+	return im ? im->type : -1;
 }
 
 unsigned ll_index_to_flags(unsigned idx)
@@ -121,35 +213,21 @@ unsigned ll_index_to_flags(unsigned idx)
 	if (idx == 0)
 		return 0;
 
-	for (im = idxhead(idx); im; im = im->idx_next)
-		if (im->index == idx)
-			return im->flags;
-	return 0;
+	im = ll_get_by_index(idx);
+	return im ? im->flags : -1;
 }
 
 unsigned ll_name_to_index(const char *name)
 {
-	static char ncache[IFNAMSIZ];
-	static int icache;
-	struct ll_cache *im;
-	int i;
+	const struct ll_cache *im;
 	unsigned idx;
 
 	if (name == NULL)
 		return 0;
 
-	if (icache && strcmp(name, ncache) == 0)
-		return icache;
-
-	for (i=0; i<IDXMAP_SIZE; i++) {
-		for (im = idx_head[i]; im; im = im->idx_next) {
-			if (strcmp(im->name, name) == 0) {
-				icache = im->index;
-				strcpy(ncache, name);
-				return im->index;
-			}
-		}
-	}
+	im = ll_get_by_name(name);
+	if (im)
+		return im->index;
 
 	idx = if_nametoindex(name);
 	if (idx == 0)
