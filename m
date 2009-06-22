From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/07: fix some sparse endianess warnings
Date: Mon, 22 Jun 2009 14:53:54 +0200 (MEST)
Message-ID: <20090622125354.6531.87618.sendpatchset@x2.localnet>
References: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit f9ffc31251c2caa11962c9b74ce650e2167fa8d1
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 22 14:15:02 2009 +0200

    netfilter: fix some sparse endianess warnings
    
    net/netfilter/xt_NFQUEUE.c:46:9: warning: incorrect type in assignment (different base types)
    net/netfilter/xt_NFQUEUE.c:46:9:    expected unsigned int [unsigned] [usertype] ipaddr
    net/netfilter/xt_NFQUEUE.c:46:9:    got restricted unsigned int
    net/netfilter/xt_NFQUEUE.c:68:10: warning: incorrect type in assignment (different base types)
    net/netfilter/xt_NFQUEUE.c:68:10:    expected unsigned int [unsigned] <noident>
    net/netfilter/xt_NFQUEUE.c:68:10:    got restricted unsigned int
    net/netfilter/xt_NFQUEUE.c:69:10: warning: incorrect type in assignment (different base types)
    net/netfilter/xt_NFQUEUE.c:69:10:    expected unsigned int [unsigned] <noident>
    net/netfilter/xt_NFQUEUE.c:69:10:    got restricted unsigned int
    net/netfilter/xt_NFQUEUE.c:70:10: warning: incorrect type in assignment (different base types)
    net/netfilter/xt_NFQUEUE.c:70:10:    expected unsigned int [unsigned] <noident>
    net/netfilter/xt_NFQUEUE.c:70:10:    got restricted unsigned int
    net/netfilter/xt_NFQUEUE.c:71:10: warning: incorrect type in assignment (different base types)
    net/netfilter/xt_NFQUEUE.c:71:10:    expected unsigned int [unsigned] <noident>
    net/netfilter/xt_NFQUEUE.c:71:10:    got restricted unsigned int
    
    net/netfilter/xt_cluster.c:20:55: warning: incorrect type in return expression (different base types)
    net/netfilter/xt_cluster.c:20:55:    expected unsigned int
    net/netfilter/xt_cluster.c:20:55:    got restricted unsigned int const [usertype] ip
    net/netfilter/xt_cluster.c:20:55: warning: incorrect type in return expression (different base types)
    net/netfilter/xt_cluster.c:20:55:    expected unsigned int
    net/netfilter/xt_cluster.c:20:55:    got restricted unsigned int const [usertype] ip
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 498b451..f28f6a5 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -40,12 +40,12 @@ nfqueue_tg(struct sk_buff *skb, const struct xt_target_param *par)
 static u32 hash_v4(const struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	u32 ipaddr;
+	__be32 ipaddr;
 
 	/* packets in either direction go into same queue */
 	ipaddr = iph->saddr ^ iph->daddr;
 
-	return jhash_2words(ipaddr, iph->protocol, jhash_initval);
+	return jhash_2words((__force u32)ipaddr, iph->protocol, jhash_initval);
 }
 
 static unsigned int
@@ -63,14 +63,14 @@ nfqueue_tg4_v1(struct sk_buff *skb, const struct xt_target_param *par)
 static u32 hash_v6(const struct sk_buff *skb)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
-	u32 addr[4];
+	__be32 addr[4];
 
 	addr[0] = ip6h->saddr.s6_addr32[0] ^ ip6h->daddr.s6_addr32[0];
 	addr[1] = ip6h->saddr.s6_addr32[1] ^ ip6h->daddr.s6_addr32[1];
 	addr[2] = ip6h->saddr.s6_addr32[2] ^ ip6h->daddr.s6_addr32[2];
 	addr[3] = ip6h->saddr.s6_addr32[3] ^ ip6h->daddr.s6_addr32[3];
 
-	return jhash2(addr, ARRAY_SIZE(addr), jhash_initval);
+	return jhash2((__force u32 *)addr, ARRAY_SIZE(addr), jhash_initval);
 }
 
 static unsigned int
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 69a639f..225ee3e 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -15,14 +15,14 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter/xt_cluster.h>
 
-static inline u_int32_t nf_ct_orig_ipv4_src(const struct nf_conn *ct)
+static inline u32 nf_ct_orig_ipv4_src(const struct nf_conn *ct)
 {
-	return ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
+	return (__force u32)ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
 }
 
-static inline const void *nf_ct_orig_ipv6_src(const struct nf_conn *ct)
+static inline const u32 *nf_ct_orig_ipv6_src(const struct nf_conn *ct)
 {
-	return ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip6;
+	return (__force u32 *)ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip6;
 }
 
 static inline u_int32_t
