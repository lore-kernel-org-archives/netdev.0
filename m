From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 31/39] netfilter: ipset: Optimize hash creation routine
Date: Sun, 13 Nov 2016 23:25:25 +0100
Message-ID: <1479075933-4491-32-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Exit as easly as possible on error and use RCU_INIT_POINTER()
as set is not seen at creation time.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 63 ++++++++++++++++-------------------
 1 file changed, 29 insertions(+), 34 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 34f115f874ab..de1d16fd4121 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1241,41 +1241,35 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 	struct htype *h;
 	struct htable *t;
 
+	pr_debug("Create set %s with family %s\n",
+		 set->name, set->family == NFPROTO_IPV4 ? "inet" : "inet6");
+
 #ifndef IP_SET_PROTO_UNDEF
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
 #endif
 
-#ifdef IP_SET_HASH_WITH_MARKMASK
-	markmask = 0xffffffff;
-#endif
-#ifdef IP_SET_HASH_WITH_NETMASK
-	netmask = set->family == NFPROTO_IPV4 ? 32 : 128;
-	pr_debug("Create set %s with family %s\n",
-		 set->name, set->family == NFPROTO_IPV4 ? "inet" : "inet6");
-#endif
-
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_HASHSIZE) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_MAXELEM) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
+
 #ifdef IP_SET_HASH_WITH_MARKMASK
 	/* Separated condition in order to avoid directive in argument list */
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_MARKMASK)))
 		return -IPSET_ERR_PROTOCOL;
-#endif
 
-	if (tb[IPSET_ATTR_HASHSIZE]) {
-		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
-		if (hashsize < IPSET_MIMINAL_HASHSIZE)
-			hashsize = IPSET_MIMINAL_HASHSIZE;
+	markmask = 0xffffffff;
+	if (tb[IPSET_ATTR_MARKMASK]) {
+		markmask = ntohl(nla_get_be32(tb[IPSET_ATTR_MARKMASK]));
+		if (markmask == 0)
+			return -IPSET_ERR_INVALID_MARKMASK;
 	}
-
-	if (tb[IPSET_ATTR_MAXELEM])
-		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
+#endif
 
 #ifdef IP_SET_HASH_WITH_NETMASK
+	netmask = set->family == NFPROTO_IPV4 ? 32 : 128;
 	if (tb[IPSET_ATTR_NETMASK]) {
 		netmask = nla_get_u8(tb[IPSET_ATTR_NETMASK]);
 
@@ -1285,14 +1279,15 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 			return -IPSET_ERR_INVALID_NETMASK;
 	}
 #endif
-#ifdef IP_SET_HASH_WITH_MARKMASK
-	if (tb[IPSET_ATTR_MARKMASK]) {
-		markmask = ntohl(nla_get_be32(tb[IPSET_ATTR_MARKMASK]));
 
-		if (markmask == 0)
-			return -IPSET_ERR_INVALID_MARKMASK;
+	if (tb[IPSET_ATTR_HASHSIZE]) {
+		hashsize = ip_set_get_h32(tb[IPSET_ATTR_HASHSIZE]);
+		if (hashsize < IPSET_MIMINAL_HASHSIZE)
+			hashsize = IPSET_MIMINAL_HASHSIZE;
 	}
-#endif
+
+	if (tb[IPSET_ATTR_MAXELEM])
+		maxelem = ip_set_get_h32(tb[IPSET_ATTR_MAXELEM]);
 
 	hsize = sizeof(*h);
 #ifdef IP_SET_HASH_WITH_NETS
@@ -1302,16 +1297,6 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 	if (!h)
 		return -ENOMEM;
 
-	h->maxelem = maxelem;
-#ifdef IP_SET_HASH_WITH_NETMASK
-	h->netmask = netmask;
-#endif
-#ifdef IP_SET_HASH_WITH_MARKMASK
-	h->markmask = markmask;
-#endif
-	get_random_bytes(&h->initval, sizeof(h->initval));
-	set->timeout = IPSET_NO_TIMEOUT;
-
 	hbits = htable_bits(hashsize);
 	hsize = htable_size(hbits);
 	if (hsize == 0) {
@@ -1323,8 +1308,17 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 		kfree(h);
 		return -ENOMEM;
 	}
+	h->maxelem = maxelem;
+#ifdef IP_SET_HASH_WITH_NETMASK
+	h->netmask = netmask;
+#endif
+#ifdef IP_SET_HASH_WITH_MARKMASK
+	h->markmask = markmask;
+#endif
+	get_random_bytes(&h->initval, sizeof(h->initval));
+
 	t->htable_bits = hbits;
-	rcu_assign_pointer(h->table, t);
+	RCU_INIT_POINTER(h->table, t);
 
 	set->data = h;
 #ifndef IP_SET_PROTO_UNDEF
@@ -1342,6 +1336,7 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 			__alignof__(struct IPSET_TOKEN(HTYPE, 6_elem)));
 	}
 #endif
+	set->timeout = IPSET_NO_TIMEOUT;
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 #ifndef IP_SET_PROTO_UNDEF
-- 
2.1.4

