From: pablo@netfilter.org
Subject: [PATCH 1/5] netfilter: ipset: fix interface comparision in hash-netiface sets
Date: Fri, 29 Jun 2012 17:37:31 +0200
Message-ID: <1340984255-738-2-git-send-email-pablo@netfilter.org>
References: <1340984255-738-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38957 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756075Ab2F2Pht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 11:37:49 -0400
In-Reply-To: <1340984255-738-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

ifname_compare() assumes that skb->dev is zero-padded,
e.g 'eth1\0\0\0\0\0...'. This isn't always the case. e1000 driver does

strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);

in e1000_probe(), so once device is registered dev->name memory contains
'eth1\0:0:3\0\0\0' (or something like that), which makes eth1 compare
fail.

Use plain strcmp() instead.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_netiface.c |   32 ++++------------------------
 1 file changed, 4 insertions(+), 28 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index ee86394..d5d3607 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -38,30 +38,6 @@ struct iface_node {
 
 #define iface_data(n)	(rb_entry(n, struct iface_node, node)->iface)
 
-static inline long
-ifname_compare(const char *_a, const char *_b)
-{
-	const long *a = (const long *)_a;
-	const long *b = (const long *)_b;
-
-	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
-	if (a[0] != b[0])
-		return a[0] - b[0];
-	if (IFNAMSIZ > sizeof(long)) {
-		if (a[1] != b[1])
-			return a[1] - b[1];
-	}
-	if (IFNAMSIZ > 2 * sizeof(long)) {
-		if (a[2] != b[2])
-			return a[2] - b[2];
-	}
-	if (IFNAMSIZ > 3 * sizeof(long)) {
-		if (a[3] != b[3])
-			return a[3] - b[3];
-	}
-	return 0;
-}
-
 static void
 rbtree_destroy(struct rb_root *root)
 {
@@ -99,7 +75,7 @@ iface_test(struct rb_root *root, const char **iface)
 
 	while (n) {
 		const char *d = iface_data(n);
-		long res = ifname_compare(*iface, d);
+		int res = strcmp(*iface, d);
 
 		if (res < 0)
 			n = n->rb_left;
@@ -121,7 +97,7 @@ iface_add(struct rb_root *root, const char **iface)
 
 	while (*n) {
 		char *ifname = iface_data(*n);
-		long res = ifname_compare(*iface, ifname);
+		int res = strcmp(*iface, ifname);
 
 		p = *n;
 		if (res < 0)
@@ -366,7 +342,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_netiface4_elem data = { .cidr = HOST_MASK };
 	u32 ip = 0, ip_to, last;
 	u32 timeout = h->timeout;
-	char iface[IFNAMSIZ] = {};
+	char iface[IFNAMSIZ];
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -663,7 +639,7 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface6_elem data = { .cidr = HOST_MASK };
 	u32 timeout = h->timeout;
-	char iface[IFNAMSIZ] = {};
+	char iface[IFNAMSIZ];
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-- 
1.7.10
