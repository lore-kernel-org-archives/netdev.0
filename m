From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 15:20:40 -0700
Message-ID: <20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
References: <20130328150410.GA22789@sergelap>
	<CD7A1D9A.78BA%blourdel@juniper.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/V7uLMXTmcKqIf1Fa9UK+AE4"
Cc: Serge Hallyn <serge.hallyn@ubuntu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Benoit Lourdelet <blourdel@juniper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:62333 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424Ab3C1WUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 18:20:53 -0400
Received: by mail-da0-f47.google.com with SMTP id s35so6321dak.34
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 15:20:52 -0700 (PDT)
In-Reply-To: <CD7A1D9A.78BA%blourdel@juniper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/V7uLMXTmcKqIf1Fa9UK+AE4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Try the following two patches. It adds a name hash list, and uses Eric's idea
to avoid loading map on add/delete operations.




--MP_/V7uLMXTmcKqIf1Fa9UK+AE4
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-ll_map-add-name-and-index-hash.patch

>From 0025e5d63d5d1598ab622867834a3bcb9f518f9f Mon Sep 17 00:00:00 2001
From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 28 Mar 2013 14:57:28 -0700
Subject: [PATCH 1/2] ll_map: add name and index hash

Make ll_ functions faster by having a name hash, and allow
for deletion. Also, allow them to work without calling ll_init_map.
---
 include/hlist.h  |   56 ++++++++++++++++++++
 include/ll_map.h |    3 +-
 lib/ll_map.c     |  155 ++++++++++++++++++++++++++++++++++--------------------
 3 files changed, 157 insertions(+), 57 deletions(-)
 create mode 100644 include/hlist.h

diff --git a/include/hlist.h b/include/hlist.h
new file mode 100644
index 0000000..4e8de9e
--- /dev/null
+++ b/include/hlist.h
@@ -0,0 +1,56 @@
+#ifndef __HLIST_H__
+#define __HLIST_H__ 1
+/* Hash list stuff from kernel */
+
+#include <stddef.h>
+
+#define container_of(ptr, type, member) ({			\
+	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
+	(type *)( (char *)__mptr - offsetof(type,member) );})
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
+{
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
+
+#define hlist_for_each_safe(pos, n, head) \
+	for (pos = (head)->first; pos && ({ n = pos->next; 1; }); \
+	     pos = n)
+
+#define hlist_entry_safe(ptr, type, member) \
+	({ typeof(ptr) ____ptr = (ptr); \
+	   ____ptr ? hlist_entry(____ptr, type, member) : NULL; \
+	})
+
+#define hlist_for_each_entry(pos, head, member)				\
+	for (pos = hlist_entry_safe((head)->first, typeof(*(pos)), member);\
+	     pos;							\
+	     pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member))
+
+#endif /* __HLIST_H__ */
diff --git a/include/ll_map.h b/include/ll_map.h
index c4d5c6d..f1dda39 100644
--- a/include/ll_map.h
+++ b/include/ll_map.h
@@ -3,7 +3,8 @@
 
 extern int ll_remember_index(const struct sockaddr_nl *who,
 			     struct nlmsghdr *n, void *arg);
-extern int ll_init_map(struct rtnl_handle *rth);
+
+extern void ll_init_map(struct rtnl_handle *rth);
 extern unsigned ll_name_to_index(const char *name);
 extern const char *ll_index_to_name(unsigned idx);
 extern const char *ll_idx_n2a(unsigned idx, char *buf);
diff --git a/lib/ll_map.c b/lib/ll_map.c
index e9ae129..fd7db55 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -22,10 +22,11 @@
 
 #include "libnetlink.h"
 #include "ll_map.h"
+#include "hlist.h"
 
-struct ll_cache
-{
-	struct ll_cache   *idx_next;
+struct ll_cache {
+	struct hlist_node idx_hash;
+	struct hlist_node name_hash;
 	unsigned	flags;
 	int		index;
 	unsigned short	type;
@@ -33,49 +34,107 @@ struct ll_cache
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
 
@@ -86,15 +145,16 @@ const char *ll_idx_n2a(unsigned idx, char *buf)
 	if (idx == 0)
 		return "*";
 
-	for (im = idxhead(idx); im; im = im->idx_next)
-		if (im->index == idx)
-			return im->name;
+	im = ll_get_by_index(idx);
+	if (im)
+		return im->name;
+
+	if (if_indextoname(idx, buf) == NULL)
+		snprintf(buf, IFNAMSIZ, "if%d", idx);
 
-	snprintf(buf, IFNAMSIZ, "if%d", idx);
 	return buf;
 }
 
-
 const char *ll_index_to_name(unsigned idx)
 {
 	static char nbuf[IFNAMSIZ];
@@ -108,10 +168,9 @@ int ll_index_to_type(unsigned idx)
 
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
@@ -121,35 +180,21 @@ unsigned ll_index_to_flags(unsigned idx)
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
@@ -157,12 +202,12 @@ unsigned ll_name_to_index(const char *name)
 	return idx;
 }
 
-int ll_init_map(struct rtnl_handle *rth)
+void ll_init_map(struct rtnl_handle *rth)
 {
 	static int initialized;
 
 	if (initialized)
-		return 0;
+		return;
 
 	if (rtnl_wilddump_request(rth, AF_UNSPEC, RTM_GETLINK) < 0) {
 		perror("Cannot send dump request");
@@ -175,6 +220,4 @@ int ll_init_map(struct rtnl_handle *rth)
 	}
 
 	initialized = 1;
-
-	return 0;
 }
-- 
1.7.10.4


--MP_/V7uLMXTmcKqIf1Fa9UK+AE4
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0002-ip-remove-unnecessary-ll_init_map.patch

>From f0124b0f0aa0e5b9288114eb8e6ff9b4f8c33ec8 Mon Sep 17 00:00:00 2001
From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 28 Mar 2013 15:17:47 -0700
Subject: [PATCH 2/2] ip: remove unnecessary ll_init_map

Don't call ll_init_map on modify operations
Saves significant overhead with 1000's of devices.
---
 ip/ipaddress.c    |    2 --
 ip/ipaddrlabel.c  |    2 --
 ip/iplink.c       |    2 --
 ip/iproute.c      |    6 ------
 ip/xfrm_monitor.c |    2 --
 5 files changed, 14 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 149df69..5b9a438 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1365,8 +1365,6 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	if (!scoped && cmd != RTM_DELADDR)
 		req.ifa.ifa_scope = default_scope(&lcl);
 
-	ll_init_map(&rth);
-
 	if ((req.ifa.ifa_index = ll_name_to_index(d)) == 0) {
 		fprintf(stderr, "Cannot find device \"%s\"\n", d);
 		return -1;
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index eb6a48c..1789d9c 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -246,8 +246,6 @@ static int ipaddrlabel_flush(int argc, char **argv)
 
 int do_ipaddrlabel(int argc, char **argv)
 {
-	ll_init_map(&rth);
-
 	if (argc < 1) {
 		return ipaddrlabel_list(0, NULL);
 	} else if (matches(argv[0], "list") == 0 ||
diff --git a/ip/iplink.c b/ip/iplink.c
index 5c7b43c..dc98019 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -533,8 +533,6 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 		}
 	}
 
-	ll_init_map(&rth);
-
 	if (!(flags & NLM_F_CREATE)) {
 		if (!dev) {
 			fprintf(stderr, "Not enough information: \"dev\" "
diff --git a/ip/iproute.c b/ip/iproute.c
index 2c2a331..adef774 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -970,8 +970,6 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 	if (d || nhs_ok)  {
 		int idx;
 
-		ll_init_map(&rth);
-
 		if (d) {
 			if ((idx = ll_name_to_index(d)) == 0) {
 				fprintf(stderr, "Cannot find device \"%s\"\n", d);
@@ -1265,8 +1263,6 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 	if (do_ipv6 == AF_UNSPEC && filter.tb)
 		do_ipv6 = AF_INET;
 
-	ll_init_map(&rth);
-
 	if (id || od)  {
 		int idx;
 
@@ -1452,8 +1448,6 @@ static int iproute_get(int argc, char **argv)
 		exit(1);
 	}
 
-	ll_init_map(&rth);
-
 	if (idev || odev)  {
 		int idx;
 
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index bfc48f1..a1f5d53 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -408,8 +408,6 @@ int do_xfrm_monitor(int argc, char **argv)
 		return rtnl_from_file(fp, xfrm_accept_msg, (void*)stdout);
 	}
 
-	//ll_init_map(&rth);
-
 	if (rtnl_open_byproto(&rth, groups, NETLINK_XFRM) < 0)
 		exit(1);
 
-- 
1.7.10.4


--MP_/V7uLMXTmcKqIf1Fa9UK+AE4--
