From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/10] [NETFILTER]: Do not copy skb in skb_make_writable
Date: Sun, 14 Oct 2007 12:27:45 +0800
Message-ID: <E1Igv4r-00030s-00@gondolin.me.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1423 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751271AbXJNE2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:28:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Do not copy skb in skb_make_writable

Now that all callers of netfilter can guarantee that the skb is not shared,
we no longer have to copy the skb in skb_make_writable.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netfilter.h              |    2 -
 net/ipv4/netfilter/ip_queue.c          |    2 -
 net/ipv4/netfilter/ipt_ECN.c           |    4 +--
 net/ipv4/netfilter/ipt_TOS.c           |    2 -
 net/ipv4/netfilter/ipt_TTL.c           |    2 -
 net/ipv4/netfilter/nf_nat_core.c       |    4 +--
 net/ipv4/netfilter/nf_nat_helper.c     |    8 +++---
 net/ipv4/netfilter/nf_nat_proto_gre.c  |    2 -
 net/ipv4/netfilter/nf_nat_proto_icmp.c |    2 -
 net/ipv4/netfilter/nf_nat_proto_tcp.c  |    2 -
 net/ipv4/netfilter/nf_nat_proto_udp.c  |    2 -
 net/ipv4/netfilter/nf_nat_snmp_basic.c |    2 -
 net/ipv6/netfilter/ip6_queue.c         |    2 -
 net/ipv6/netfilter/ip6t_HL.c           |    2 -
 net/netfilter/core.c                   |   38 ++++++++++++---------------------
 net/netfilter/nfnetlink_queue.c        |    2 -
 net/netfilter/xt_DSCP.c                |    4 +--
 net/netfilter/xt_TCPMSS.c              |    2 -
 18 files changed, 37 insertions(+), 47 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 1dd075e..2505348 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -287,7 +287,7 @@ extern void nf_invalidate_cache(int pf);
 /* Call this before modifying an existing packet: ensures it is
    modifiable and linear to the point you care about (writable_len).
    Returns true or false. */
-extern int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len);
+extern int skb_make_writable(struct sk_buff *skb, unsigned int writable_len);
 
 static inline void nf_csum_replace4(__sum16 *sum, __be32 from, __be32 to)
 {
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 23cbfc7..62d8867 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -365,7 +365,7 @@ ipq_mangle_ipv4(ipq_verdict_msg_t *v, struct ipq_queue_entry *e)
 		}
 		skb_put(e->skb, diff);
 	}
-	if (!skb_make_writable(&e->skb, v->data_len))
+	if (!skb_make_writable(e->skb, v->data_len))
 		return -ENOMEM;
 	skb_copy_to_linear_data(e->skb, v->payload, v->data_len);
 	e->skb->ip_summed = CHECKSUM_NONE;
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index f1253bd..92744be 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -32,7 +32,7 @@ set_ect_ip(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
 
 	if ((iph->tos & IPT_ECN_IP_MASK) != (einfo->ip_ect & IPT_ECN_IP_MASK)) {
 		__u8 oldtos;
-		if (!skb_make_writable(pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(*pskb, sizeof(struct iphdr)))
 			return false;
 		iph = ip_hdr(*pskb);
 		oldtos = iph->tos;
@@ -62,7 +62,7 @@ set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
 	     tcph->cwr == einfo->proto.tcp.cwr))
 		return true;
 
-	if (!skb_make_writable(pskb, ip_hdrlen(*pskb) + sizeof(*tcph)))
+	if (!skb_make_writable(*pskb, ip_hdrlen(*pskb) + sizeof(*tcph)))
 		return false;
 	tcph = (void *)ip_hdr(*pskb) + ip_hdrlen(*pskb);
 
diff --git a/net/ipv4/netfilter/ipt_TOS.c b/net/ipv4/netfilter/ipt_TOS.c
index 25f5d0b..87b689a 100644
--- a/net/ipv4/netfilter/ipt_TOS.c
+++ b/net/ipv4/netfilter/ipt_TOS.c
@@ -33,7 +33,7 @@ target(struct sk_buff **pskb,
 
 	if ((iph->tos & IPTOS_TOS_MASK) != tosinfo->tos) {
 		__u8 oldtos;
-		if (!skb_make_writable(pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(*pskb, sizeof(struct iphdr)))
 			return NF_DROP;
 		iph = ip_hdr(*pskb);
 		oldtos = iph->tos;
diff --git a/net/ipv4/netfilter/ipt_TTL.c b/net/ipv4/netfilter/ipt_TTL.c
index 2b54e7b..3dd4676 100644
--- a/net/ipv4/netfilter/ipt_TTL.c
+++ b/net/ipv4/netfilter/ipt_TTL.c
@@ -29,7 +29,7 @@ ipt_ttl_target(struct sk_buff **pskb,
 	const struct ipt_TTL_info *info = targinfo;
 	int new_ttl;
 
-	if (!skb_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(*pskb, (*pskb)->len))
 		return NF_DROP;
 
 	iph = ip_hdr(*pskb);
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 7221aa2..3b5eb7c 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -357,7 +357,7 @@ manip_pkt(u_int16_t proto,
 	struct iphdr *iph;
 	struct nf_nat_protocol *p;
 
-	if (!skb_make_writable(pskb, iphdroff + sizeof(*iph)))
+	if (!skb_make_writable(*pskb, iphdroff + sizeof(*iph)))
 		return 0;
 
 	iph = (void *)(*pskb)->data + iphdroff;
@@ -431,7 +431,7 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 	unsigned long statusbit;
 	enum nf_nat_manip_type manip = HOOK2MANIP(hooknum);
 
-	if (!skb_make_writable(pskb, hdrlen + sizeof(*inside)))
+	if (!skb_make_writable(*pskb, hdrlen + sizeof(*inside)))
 		return 0;
 
 	inside = (void *)(*pskb)->data + ip_hdrlen(*pskb);
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 93d8a0a..6e81f76 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -152,7 +152,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff **pskb,
 	struct tcphdr *tcph;
 	int oldlen, datalen;
 
-	if (!skb_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(*pskb, (*pskb)->len))
 		return 0;
 
 	if (rep_len > match_len &&
@@ -234,7 +234,7 @@ nf_nat_mangle_udp_packet(struct sk_buff **pskb,
 			       match_offset + match_len)
 		return 0;
 
-	if (!skb_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(*pskb, (*pskb)->len))
 		return 0;
 
 	if (rep_len > match_len &&
@@ -341,7 +341,7 @@ nf_nat_sack_adjust(struct sk_buff **pskb,
 	optoff = ip_hdrlen(*pskb) + sizeof(struct tcphdr);
 	optend = ip_hdrlen(*pskb) + tcph->doff * 4;
 
-	if (!skb_make_writable(pskb, optend))
+	if (!skb_make_writable(*pskb, optend))
 		return 0;
 
 	dir = CTINFO2DIR(ctinfo);
@@ -390,7 +390,7 @@ nf_nat_seq_adjust(struct sk_buff **pskb,
 	this_way = &nat->seq[dir];
 	other_way = &nat->seq[!dir];
 
-	if (!skb_make_writable(pskb, ip_hdrlen(*pskb) + sizeof(*tcph)))
+	if (!skb_make_writable(*pskb, ip_hdrlen(*pskb) + sizeof(*tcph)))
 		return 0;
 
 	tcph = (void *)(*pskb)->data + ip_hdrlen(*pskb);
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index d562290..e7a2aaf 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -109,7 +109,7 @@ gre_manip_pkt(struct sk_buff **pskb, unsigned int iphdroff,
 
 	/* pgreh includes two optional 32bit fields which are not required
 	 * to be there.  That's where the magic '8' comes from */
-	if (!skb_make_writable(pskb, hdroff + sizeof(*pgreh) - 8))
+	if (!skb_make_writable(*pskb, hdroff + sizeof(*pgreh) - 8))
 		return 0;
 
 	greh = (void *)(*pskb)->data + hdroff;
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index 898d737..4087f4f 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -61,7 +61,7 @@ icmp_manip_pkt(struct sk_buff **pskb,
 	struct icmphdr *hdr;
 	unsigned int hdroff = iphdroff + iph->ihl*4;
 
-	if (!skb_make_writable(pskb, hdroff + sizeof(*hdr)))
+	if (!skb_make_writable(*pskb, hdroff + sizeof(*hdr)))
 		return 0;
 
 	hdr = (struct icmphdr *)((*pskb)->data + hdroff);
diff --git a/net/ipv4/netfilter/nf_nat_proto_tcp.c b/net/ipv4/netfilter/nf_nat_proto_tcp.c
index 5bbbb2a..e544125 100644
--- a/net/ipv4/netfilter/nf_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_tcp.c
@@ -106,7 +106,7 @@ tcp_manip_pkt(struct sk_buff **pskb,
 	if ((*pskb)->len >= hdroff + sizeof(struct tcphdr))
 		hdrsize = sizeof(struct tcphdr);
 
-	if (!skb_make_writable(pskb, hdroff + hdrsize))
+	if (!skb_make_writable(*pskb, hdroff + hdrsize))
 		return 0;
 
 	iph = (struct iphdr *)((*pskb)->data + iphdroff);
diff --git a/net/ipv4/netfilter/nf_nat_proto_udp.c b/net/ipv4/netfilter/nf_nat_proto_udp.c
index a0af4fd..ebe9b42 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udp.c
@@ -97,7 +97,7 @@ udp_manip_pkt(struct sk_buff **pskb,
 	__be32 oldip, newip;
 	__be16 *portptr, newport;
 
-	if (!skb_make_writable(pskb, hdroff + sizeof(*hdr)))
+	if (!skb_make_writable(*pskb, hdroff + sizeof(*hdr)))
 		return 0;
 
 	iph = (struct iphdr *)((*pskb)->data + iphdroff);
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 6bfcd3a..87011fe 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1258,7 +1258,7 @@ static int help(struct sk_buff **pskb, unsigned int protoff,
 		 return NF_DROP;
 	}
 
-	if (!skb_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(*pskb, (*pskb)->len))
 		return NF_DROP;
 
 	spin_lock_bh(&snmp_lock);
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 0473145..d7080dd 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -362,7 +362,7 @@ ipq_mangle_ipv6(ipq_verdict_msg_t *v, struct ipq_queue_entry *e)
 		}
 		skb_put(e->skb, diff);
 	}
-	if (!skb_make_writable(&e->skb, v->data_len))
+	if (!skb_make_writable(e->skb, v->data_len))
 		return -ENOMEM;
 	skb_copy_to_linear_data(e->skb, v->payload, v->data_len);
 	e->skb->ip_summed = CHECKSUM_NONE;
diff --git a/net/ipv6/netfilter/ip6t_HL.c b/net/ipv6/netfilter/ip6t_HL.c
index ad4d943..f76197f 100644
--- a/net/ipv6/netfilter/ip6t_HL.c
+++ b/net/ipv6/netfilter/ip6t_HL.c
@@ -29,7 +29,7 @@ static unsigned int ip6t_hl_target(struct sk_buff **pskb,
 	const struct ip6t_HL_info *info = targinfo;
 	int new_hl;
 
-	if (!skb_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(*pskb, (*pskb)->len))
 		return NF_DROP;
 
 	ip6h = ipv6_hdr(*pskb);
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a523fa4..2c9e8e3 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -196,34 +196,24 @@ unlock:
 EXPORT_SYMBOL(nf_hook_slow);
 
 
-int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len)
+int skb_make_writable(struct sk_buff *skb, unsigned int writable_len)
 {
-	struct sk_buff *nskb;
-
-	if (writable_len > (*pskb)->len)
+	if (writable_len > skb->len)
 		return 0;
 
 	/* Not exclusive use of packet?  Must copy. */
-	if (skb_cloned(*pskb) && !skb_clone_writable(*pskb, writable_len))
-		goto copy_skb;
-	if (skb_shared(*pskb))
-		goto copy_skb;
-
-	return pskb_may_pull(*pskb, writable_len);
-
-copy_skb:
-	nskb = skb_copy(*pskb, GFP_ATOMIC);
-	if (!nskb)
-		return 0;
-	BUG_ON(skb_is_nonlinear(nskb));
-
-	/* Rest of kernel will get very unhappy if we pass it a
-	   suddenly-orphaned skbuff */
-	if ((*pskb)->sk)
-		skb_set_owner_w(nskb, (*pskb)->sk);
-	kfree_skb(*pskb);
-	*pskb = nskb;
-	return 1;
+	if (!skb_cloned(skb)) {
+		if (writable_len <= skb_headlen(skb))
+			return 1;
+	} else if (skb_clone_writable(skb, writable_len))
+		return 1;
+
+	if (writable_len <= skb_headlen(skb))
+		writable_len = 0;
+	else
+		writable_len -= skb_headlen(skb);
+
+	return !!__pskb_pull_tail(skb, writable_len);
 }
 EXPORT_SYMBOL(skb_make_writable);
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 49f0480..6ba98ac 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -644,7 +644,7 @@ nfqnl_mangle(void *data, int data_len, struct nfqnl_queue_entry *e)
 		}
 		skb_put(e->skb, diff);
 	}
-	if (!skb_make_writable(&e->skb, data_len))
+	if (!skb_make_writable(e->skb, data_len))
 		return -ENOMEM;
 	skb_copy_to_linear_data(e->skb, data, data_len);
 	e->skb->ip_summed = CHECKSUM_NONE;
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index 798ab73..1706616 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -36,7 +36,7 @@ static unsigned int target(struct sk_buff **pskb,
 	u_int8_t dscp = ipv4_get_dsfield(ip_hdr(*pskb)) >> XT_DSCP_SHIFT;
 
 	if (dscp != dinfo->dscp) {
-		if (!skb_make_writable(pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(*pskb, sizeof(struct iphdr)))
 			return NF_DROP;
 
 		ipv4_change_dsfield(ip_hdr(*pskb), (__u8)(~XT_DSCP_MASK),
@@ -57,7 +57,7 @@ static unsigned int target6(struct sk_buff **pskb,
 	u_int8_t dscp = ipv6_get_dsfield(ipv6_hdr(*pskb)) >> XT_DSCP_SHIFT;
 
 	if (dscp != dinfo->dscp) {
-		if (!skb_make_writable(pskb, sizeof(struct ipv6hdr)))
+		if (!skb_make_writable(*pskb, sizeof(struct ipv6hdr)))
 			return NF_DROP;
 
 		ipv6_change_dsfield(ipv6_hdr(*pskb), (__u8)(~XT_DSCP_MASK),
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index d40f7e4..31b6f9d 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -50,7 +50,7 @@ tcpmss_mangle_packet(struct sk_buff **pskb,
 	u16 newmss;
 	u8 *opt;
 
-	if (!skb_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(*pskb, (*pskb)->len))
 		return -1;
 
 	tcplen = (*pskb)->len - tcphoff;
