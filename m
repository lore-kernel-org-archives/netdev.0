From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: fix nf_conn_nat->masq_index visibility
Date: Tue, 30 Sep 2014 13:27:50 +0200
Message-ID: <2670668.vq09CjLWH3@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent change introduced the NF_NAT_MASQUERADE_IPV4/6 symbols and now
builds the masquerading code based on this symbol rather than the
IP_NF_TARGET_MASQUERADE symbol, however the nf_nat.h header file
still uses the old symbol, which leads to a build error when that
is disabled:

nf_nat_masquerade_ipv4.c: In function 'nf_nat_masquerade_ipv4':
nf_nat_masquerade_ipv4.c:59:5: error: 'struct nf_conn_nat' has no member named 'masq_index'

This changes the header file to do the respective change, and move
to using the IS_ENABLED() macro in the process, to improve readability
of the check

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 8dd33cc93ec92 ("netfilter: nf_nat: generalize IPv4 masquerading support for nf_tables")
---
found while doing ARM randconfig tests

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index a71dd333ac68..68f0953c86c3 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -32,10 +32,8 @@ struct nf_conn_nat {
 	struct hlist_node bysource;
 	struct nf_conn *ct;
 	union nf_conntrack_nat_help help;
-#if defined(CONFIG_IP_NF_TARGET_MASQUERADE) || \
-    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE) || \
-    defined(CONFIG_IP6_NF_TARGET_MASQUERADE) || \
-    defined(CONFIG_IP6_NF_TARGET_MASQUERADE_MODULE)
+#if IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV4) || \
+    IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV6)
 	int masq_index;
 #endif
 };
@@ -56,7 +54,7 @@ int nf_nat_used_tuple(const struct nf_conntrack_tuple *tuple,
 
 static inline struct nf_conn_nat *nfct_nat(const struct nf_conn *ct)
 {
-#if defined(CONFIG_NF_NAT) || defined(CONFIG_NF_NAT_MODULE)
+#if IS_ENABLED(CONFIG_NF_NAT)
 	return nf_ct_ext_find(ct, NF_CT_EXT_NAT);
 #else
 	return NULL;
@@ -68,8 +66,8 @@ static inline bool nf_nat_oif_changed(unsigned int hooknum,
 				      struct nf_conn_nat *nat,
 				      const struct net_device *out)
 {
-#if IS_ENABLED(CONFIG_IP_NF_TARGET_MASQUERADE) || \
-    IS_ENABLED(CONFIG_IP6_NF_TARGET_MASQUERADE)
+#if IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV4) || \
+    IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV6)
 	return nat->masq_index && hooknum == NF_INET_POST_ROUTING &&
 	       CTINFO2DIR(ctinfo) == IP_CT_DIR_ORIGINAL &&
 	       nat->masq_index != out->ifindex;
