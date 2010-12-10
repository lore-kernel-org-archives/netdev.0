From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] iproute2: add dynamic index and name hashes
Date: Fri, 10 Dec 2010 16:59:24 +0200
Message-ID: <1291993164-8793-1-git-send-email-opurdila@ixiacom.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:9376 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754899Ab0LJO7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 09:59:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hashes sizes start with 16 entries and grow up to 2^20
entries. The hashes double when the entries in the LL map is greater
then the hash size.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 lib/ll_map.c |  125 +++++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 103 insertions(+), 22 deletions(-)

diff --git a/lib/ll_map.c b/lib/ll_map.c
index b8b49aa..9831322 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -26,7 +26,8 @@ extern unsigned int if_nametoindex (const char *);
 
 struct idxmap
 {
-	struct idxmap * next;
+	struct idxmap *idx_next;
+	struct idxmap *name_next;
 	unsigned	index;
 	int		type;
 	int		alen;
@@ -35,31 +36,100 @@ struct idxmap
 	char		name[16];
 };
 
-static struct idxmap *idxmap[16];
+struct idxmap_head {
+	struct idxmap *next;
+};
+
+static int hbits = 4, entries;
+static struct idxmap_head *idx_hash, *name_hash;
+
+static unsigned int name_hashfn(const char *name)
+{
+	const unsigned char *c = (const unsigned char *)name;
+	unsigned int hash = 0;
+
+	while (*c)
+		hash = 31*hash + *c++;
+
+	return hash;
+}
+
+static inline unsigned int htrunc(unsigned int value, int bits)
+{
+	return value % (1<<bits);
+}
+
+void grow_hashes(void)
+{
+	struct idxmap_head *new_idx_hash, *new_name_hash;
+	struct idxmap *next, *im;
+	int hidx, hname, i, new_size = 1<<(hbits+1);
+
+	if (hbits == 20)
+		return;
+
+	new_idx_hash = malloc(new_size * sizeof(struct idxmap_head));
+	new_name_hash = malloc(new_size * sizeof(struct idxmap_head));
+
+	if (!new_idx_hash || !new_name_hash)
+		return;
+
+	for (i = 0; i < (hbits<<1); i++)
+		for (im = idx_hash[i].next;
+		     im != NULL && (next = im->idx_next, 1); im = next) {
+			hidx = htrunc(im->index, hbits + 1);
+			im->idx_next = new_idx_hash[hidx].next;
+			new_idx_hash[hidx].next = im;
+
+			hname = htrunc(name_hashfn(im->name), hbits + 1);
+			im->name_next = new_name_hash[hname].next;
+			new_name_hash[hname].next = im;
+		}
+
+	free(idx_hash);
+	idx_hash = new_idx_hash;
+
+	free(name_hash);
+	name_hash = new_name_hash;
+
+	hbits = hbits + 1;
+}
 
 int ll_remember_index(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n, void *arg)
 {
-	int h;
+	int hidx, hname;
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
-	struct idxmap *im, **imp;
+	struct idxmap *im;
 	struct rtattr *tb[IFLA_MAX+1];
 
+	if (!idx_hash) {
+		idx_hash = malloc((1<<hbits) * sizeof(struct idxmap_head));
+		if (!idx_hash)
+			return -1;
+	}
+
+	if (!name_hash) {
+		name_hash = malloc((1<<hbits) * sizeof(struct idxmap_head));
+		if (!name_hash)
+			return -1;
+	}
+
 	if (n->nlmsg_type != RTM_NEWLINK)
 		return 0;
 
 	if (n->nlmsg_len < NLMSG_LENGTH(sizeof(ifi)))
 		return -1;
 
-
 	memset(tb, 0, sizeof(tb));
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), IFLA_PAYLOAD(n));
 	if (tb[IFLA_IFNAME] == NULL)
 		return 0;
 
-	h = ifi->ifi_index&0xF;
+	hidx = htrunc(ifi->ifi_index, hbits);
+	hname = htrunc(name_hashfn(RTA_DATA(tb[IFLA_IFNAME])), hbits);
 
-	for (imp=&idxmap[h]; (im=*imp)!=NULL; imp = &im->next)
+	for (im = idx_hash[hidx].next; im != NULL; im = im->idx_next)
 		if (im->index == ifi->ifi_index)
 			break;
 
@@ -67,9 +137,15 @@ int ll_remember_index(const struct sockaddr_nl *who,
 		im = malloc(sizeof(*im));
 		if (im == NULL)
 			return 0;
-		im->next = *imp;
+
+		entries++;
 		im->index = ifi->ifi_index;
-		*imp = im;
+
+		im->idx_next = idx_hash[hidx].next;
+		idx_hash[hidx].next = im;
+
+		im->name_next = name_hash[hname].next;
+		name_hash[hname].next = im;
 	}
 
 	im->type = ifi->ifi_type;
@@ -85,6 +161,10 @@ int ll_remember_index(const struct sockaddr_nl *who,
 		memset(im->addr, 0, sizeof(im->addr));
 	}
 	strcpy(im->name, RTA_DATA(tb[IFLA_IFNAME]));
+
+	if (entries > (1<<hbits))
+		grow_hashes();
+
 	return 0;
 }
 
@@ -94,7 +174,7 @@ const char *ll_idx_n2a(unsigned idx, char *buf)
 
 	if (idx == 0)
 		return "*";
-	for (im = idxmap[idx&0xF]; im; im = im->next)
+	for (im = idx_hash[htrunc(idx, hbits)].next; im; im = im->idx_next)
 		if (im->index == idx)
 			return im->name;
 	snprintf(buf, 16, "if%d", idx);
@@ -115,7 +195,7 @@ int ll_index_to_type(unsigned idx)
 
 	if (idx == 0)
 		return -1;
-	for (im = idxmap[idx&0xF]; im; im = im->next)
+	for (im = idx_hash[htrunc(idx, hbits)].next; im; im = im->idx_next)
 		if (im->index == idx)
 			return im->type;
 	return -1;
@@ -128,7 +208,7 @@ unsigned ll_index_to_flags(unsigned idx)
 	if (idx == 0)
 		return 0;
 
-	for (im = idxmap[idx&0xF]; im; im = im->next)
+	for (im = idx_hash[htrunc(idx, hbits)].next; im; im = im->idx_next)
 		if (im->index == idx)
 			return im->flags;
 	return 0;
@@ -142,7 +222,7 @@ unsigned ll_index_to_addr(unsigned idx, unsigned char *addr,
 	if (idx == 0)
 		return 0;
 
-	for (im = idxmap[idx&0xF]; im; im = im->next) {
+	for (im = idx_hash[htrunc(idx, hbits)].next; im; im = im->idx_next) {
 		if (im->index == idx) {
 			if (alen > sizeof(im->addr))
 				alen = sizeof(im->addr);
@@ -155,25 +235,26 @@ unsigned ll_index_to_addr(unsigned idx, unsigned char *addr,
 	return 0;
 }
 
+
 unsigned ll_name_to_index(const char *name)
 {
 	static char ncache[16];
 	static int icache;
 	struct idxmap *im;
-	int i;
+	int hname;
 	unsigned idx;
 
 	if (name == NULL)
 		return 0;
 	if (icache && strcmp(name, ncache) == 0)
 		return icache;
-	for (i=0; i<16; i++) {
-		for (im = idxmap[i]; im; im = im->next) {
-			if (strcmp(im->name, name) == 0) {
-				icache = im->index;
-				strcpy(ncache, name);
-				return im->index;
-			}
+
+	hname = htrunc(name_hashfn(name), hbits);
+	for (im = name_hash[hname].next; im; im = im->name_next) {
+		if (strcmp(im->name, name) == 0) {
+			icache = im->index;
+			strcpy(ncache, name);
+			return im->index;
 		}
 	}
 
@@ -190,7 +271,7 @@ int ll_init_map(struct rtnl_handle *rth)
 		exit(1);
 	}
 
-	if (rtnl_dump_filter(rth, ll_remember_index, &idxmap, NULL, NULL) < 0) {
+	if (rtnl_dump_filter(rth, ll_remember_index, NULL, NULL, NULL) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		exit(1);
 	}
-- 
1.7.1

