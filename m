From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER]: Get rid of HW checksum invalidation
Date: Sat, 05 Aug 2006 09:25:28 +0200
Message-ID: <44D447E8.5030005@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070709030500000306010106"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24212 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422682AbWHEHZ3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:25:29 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070709030500000306010106
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------070709030500000306010106
Content-Type: text/plain;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NETFILTER]: Get rid of HW checksum invalidation

Update hardware checksums incrementally to avoid breaking GSO.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d4bf859dbf0158d8ac0dc7d9d88d68c6882233df
tree 901cd99e90a5f1d1390455ab7833021eb73772e2
parent b49dd1802f397fb8d5272a34ba47fe9636fe2411
author Patrick McHardy <kaber@trash.net> Sat, 05 Aug 2006 09:16:22 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 05 Aug 2006 09:16:22 +0200

 include/linux/netfilter.h                  |    6 +++
 include/linux/netfilter_ipv4/ip_nat.h      |    4 --
 include/linux/netfilter_ipv4/ip_nat_core.h |    8 ++--
 net/ipv4/netfilter/ip_nat_core.c           |   52 +++++++++----------------
 net/ipv4/netfilter/ip_nat_helper.c         |   59 +++++++++++++++++++---------
 net/ipv4/netfilter/ip_nat_proto_gre.c      |    5 +-
 net/ipv4/netfilter/ip_nat_proto_icmp.c     |    8 ++--
 net/ipv4/netfilter/ip_nat_proto_tcp.c      |    7 +--
 net/ipv4/netfilter/ip_nat_proto_udp.c      |   15 +++++--
 net/ipv4/netfilter/ip_nat_standalone.c     |   10 +----
 net/ipv4/netfilter/ipt_ECN.c               |   19 +++------
 net/ipv4/netfilter/ipt_REJECT.c            |    1 
 net/ipv4/netfilter/ipt_TCPMSS.c            |   39 ++++++++-----------
 net/netfilter/core.c                       |   22 ++++++++++
 14 files changed, 138 insertions(+), 117 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 10168e2..b7e67d1 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -282,6 +282,12 @@ extern void nf_invalidate_cache(int pf);
    Returns true or false. */
 extern int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len);
 
+extern u_int16_t nf_csum_update(u_int32_t oldval, u_int32_t newval,
+				u_int32_t csum);
+extern u_int16_t nf_proto_csum_update(struct sk_buff *skb,
+				      u_int32_t oldval, u_int32_t newval,
+				      u_int16_t csum, int pseudohdr);
+
 struct nf_afinfo {
 	unsigned short	family;
 	unsigned int	(*checksum)(struct sk_buff *skb, unsigned int hook,
diff --git a/include/linux/netfilter_ipv4/ip_nat.h b/include/linux/netfilter_ipv4/ip_nat.h
index e9f5ed1..98f8407 100644
--- a/include/linux/netfilter_ipv4/ip_nat.h
+++ b/include/linux/netfilter_ipv4/ip_nat.h
@@ -72,10 +72,6 @@ extern unsigned int ip_nat_setup_info(st
 extern int ip_nat_used_tuple(const struct ip_conntrack_tuple *tuple,
 			     const struct ip_conntrack *ignored_conntrack);
 
-/* Calculate relative checksum. */
-extern u_int16_t ip_nat_cheat_check(u_int32_t oldvalinv,
-				    u_int32_t newval,
-				    u_int16_t oldcheck);
 #else  /* !__KERNEL__: iptables wants this to compile. */
 #define ip_nat_multi_range ip_nat_multi_range_compat
 #endif /*__KERNEL__*/
diff --git a/include/linux/netfilter_ipv4/ip_nat_core.h b/include/linux/netfilter_ipv4/ip_nat_core.h
index 30db23f..60566f9 100644
--- a/include/linux/netfilter_ipv4/ip_nat_core.h
+++ b/include/linux/netfilter_ipv4/ip_nat_core.h
@@ -11,8 +11,8 @@ extern unsigned int ip_nat_packet(struct
 			       unsigned int hooknum,
 			       struct sk_buff **pskb);
 
-extern int ip_nat_icmp_reply_translation(struct sk_buff **pskb,
-					 struct ip_conntrack *ct,
-					 enum ip_nat_manip_type manip,
-					 enum ip_conntrack_dir dir);
+extern int ip_nat_icmp_reply_translation(struct ip_conntrack *ct,
+					 enum ip_conntrack_info ctinfo,
+					 unsigned int hooknum,
+					 struct sk_buff **pskb);
 #endif /* _IP_NAT_CORE_H */
diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_core.c
index 1741d55..4c540d0 100644
--- a/net/ipv4/netfilter/ip_nat_core.c
+++ b/net/ipv4/netfilter/ip_nat_core.c
@@ -101,18 +101,6 @@ static void ip_nat_cleanup_conntrack(str
 	write_unlock_bh(&ip_nat_lock);
 }
 
-/* We do checksum mangling, so if they were wrong before they're still
- * wrong.  Also works for incomplete packets (eg. ICMP dest
- * unreachables.) */
-u_int16_t
-ip_nat_cheat_check(u_int32_t oldvalinv, u_int32_t newval, u_int16_t oldcheck)
-{
-	u_int32_t diffs[] = { oldvalinv, newval };
-	return csum_fold(csum_partial((char *)diffs, sizeof(diffs),
-				      oldcheck^0xFFFF));
-}
-EXPORT_SYMBOL(ip_nat_cheat_check);
-
 /* Is this tuple already taken? (not by us) */
 int
 ip_nat_used_tuple(const struct ip_conntrack_tuple *tuple,
@@ -378,12 +366,12 @@ manip_pkt(u_int16_t proto,
 	iph = (void *)(*pskb)->data + iphdroff;
 
 	if (maniptype == IP_NAT_MANIP_SRC) {
-		iph->check = ip_nat_cheat_check(~iph->saddr, target->src.ip,
-						iph->check);
+		iph->check = nf_csum_update(~iph->saddr, target->src.ip,
+					    iph->check);
 		iph->saddr = target->src.ip;
 	} else {
-		iph->check = ip_nat_cheat_check(~iph->daddr, target->dst.ip,
-						iph->check);
+		iph->check = nf_csum_update(~iph->daddr, target->dst.ip,
+					    iph->check);
 		iph->daddr = target->dst.ip;
 	}
 	return 1;
@@ -423,10 +411,10 @@ unsigned int ip_nat_packet(struct ip_con
 EXPORT_SYMBOL_GPL(ip_nat_packet);
 
 /* Dir is direction ICMP is coming from (opposite to packet it contains) */
-int ip_nat_icmp_reply_translation(struct sk_buff **pskb,
-				  struct ip_conntrack *ct,
-				  enum ip_nat_manip_type manip,
-				  enum ip_conntrack_dir dir)
+int ip_nat_icmp_reply_translation(struct ip_conntrack *ct,
+				  enum ip_conntrack_info ctinfo,
+				  unsigned int hooknum,
+				  struct sk_buff **pskb)
 {
 	struct {
 		struct icmphdr icmp;
@@ -434,7 +422,9 @@ int ip_nat_icmp_reply_translation(struct
 	} *inside;
 	struct ip_conntrack_tuple inner, target;
 	int hdrlen = (*pskb)->nh.iph->ihl * 4;
+	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	unsigned long statusbit;
+	enum ip_nat_manip_type manip = HOOK2MANIP(hooknum);
 
 	if (!skb_make_writable(pskb, hdrlen + sizeof(*inside)))
 		return 0;
@@ -443,12 +433,8 @@ int ip_nat_icmp_reply_translation(struct
 
 	/* We're actually going to mangle it beyond trivial checksum
 	   adjustment, so make sure the current checksum is correct. */
-	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY) {
-		hdrlen = (*pskb)->nh.iph->ihl * 4;
-		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
-						(*pskb)->len - hdrlen, 0)))
-			return 0;
-	}
+	if (nf_ip_checksum(*pskb, hooknum, hdrlen, 0))
+		return 0;
 
 	/* Must be RELATED */
 	IP_NF_ASSERT((*pskb)->nfctinfo == IP_CT_RELATED ||
@@ -487,12 +473,14 @@ int ip_nat_icmp_reply_translation(struct
 		       !manip))
 		return 0;
 
-	/* Reloading "inside" here since manip_pkt inner. */
-	inside = (void *)(*pskb)->data + (*pskb)->nh.iph->ihl*4;
-	inside->icmp.checksum = 0;
-	inside->icmp.checksum = csum_fold(skb_checksum(*pskb, hdrlen,
-						       (*pskb)->len - hdrlen,
-						       0));
+	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
+		/* Reloading "inside" here since manip_pkt inner. */
+		inside = (void *)(*pskb)->data + (*pskb)->nh.iph->ihl*4;
+		inside->icmp.checksum = 0;
+		inside->icmp.checksum = csum_fold(skb_checksum(*pskb, hdrlen,
+							       (*pskb)->len - hdrlen,
+							       0));
+	}
 
 	/* Change outer to look the reply to an incoming packet
 	 * (proto 0 means don't invert per-proto part). */
diff --git a/net/ipv4/netfilter/ip_nat_helper.c b/net/ipv4/netfilter/ip_nat_helper.c
index cbcaa45..021c3da 100644
--- a/net/ipv4/netfilter/ip_nat_helper.c
+++ b/net/ipv4/netfilter/ip_nat_helper.c
@@ -165,7 +165,7 @@ ip_nat_mangle_tcp_packet(struct sk_buff 
 {
 	struct iphdr *iph;
 	struct tcphdr *tcph;
-	int datalen;
+	int oldlen, datalen;
 
 	if (!skb_make_writable(pskb, (*pskb)->len))
 		return 0;
@@ -180,13 +180,22 @@ ip_nat_mangle_tcp_packet(struct sk_buff 
 	iph = (*pskb)->nh.iph;
 	tcph = (void *)iph + iph->ihl*4;
 
+	oldlen = (*pskb)->len - iph->ihl*4;
 	mangle_contents(*pskb, iph->ihl*4 + tcph->doff*4,
 			match_offset, match_len, rep_buffer, rep_len);
 
 	datalen = (*pskb)->len - iph->ihl*4;
-	tcph->check = 0;
-	tcph->check = tcp_v4_check(tcph, datalen, iph->saddr, iph->daddr,
-				   csum_partial((char *)tcph, datalen, 0));
+	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
+		tcph->check = 0;
+		tcph->check = tcp_v4_check(tcph, datalen,
+					   iph->saddr, iph->daddr,
+					   csum_partial((char *)tcph,
+					   		datalen, 0));
+	} else
+		tcph->check = nf_proto_csum_update(*pskb,
+						   htons(oldlen) ^ 0xFFFF,
+						   htons(datalen),
+						   tcph->check, 1);
 
 	if (rep_len != match_len) {
 		set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
@@ -221,6 +230,7 @@ ip_nat_mangle_udp_packet(struct sk_buff 
 {
 	struct iphdr *iph;
 	struct udphdr *udph;
+	int datalen, oldlen;
 
 	/* UDP helpers might accidentally mangle the wrong packet */
 	iph = (*pskb)->nh.iph;
@@ -238,22 +248,32 @@ ip_nat_mangle_udp_packet(struct sk_buff 
 
 	iph = (*pskb)->nh.iph;
 	udph = (void *)iph + iph->ihl*4;
+
+	oldlen = (*pskb)->len - iph->ihl*4;
 	mangle_contents(*pskb, iph->ihl*4 + sizeof(*udph),
 			match_offset, match_len, rep_buffer, rep_len);
 
 	/* update the length of the UDP packet */
-	udph->len = htons((*pskb)->len - iph->ihl*4);
+	datalen = (*pskb)->len - iph->ihl*4;
+	udph->len = htons(datalen);
 
 	/* fix udp checksum if udp checksum was previously calculated */
-	if (udph->check) {
-		int datalen = (*pskb)->len - iph->ihl * 4;
+	if (!udph->check && (*pskb)->ip_summed != CHECKSUM_PARTIAL)
+		return 1;
+
+	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
 		udph->check = 0;
 		udph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
 		                                datalen, IPPROTO_UDP,
 		                                csum_partial((char *)udph,
 		                                             datalen, 0));
-	}
-
+		if (!udph->check)
+			udph->check = -1;
+	} else
+		udph->check = nf_proto_csum_update(*pskb,
+						   htons(oldlen) ^ 0xFFFF,
+						   htons(datalen),
+						   udph->check, 1);
 	return 1;
 }
 EXPORT_SYMBOL(ip_nat_mangle_udp_packet);
@@ -293,11 +313,14 @@ sack_adjust(struct sk_buff *skb,
 			ntohl(sack->start_seq), new_start_seq,
 			ntohl(sack->end_seq), new_end_seq);
 
-		tcph->check = 
-			ip_nat_cheat_check(~sack->start_seq, new_start_seq,
-					   ip_nat_cheat_check(~sack->end_seq, 
-						   	      new_end_seq,
-							      tcph->check));
+		tcph->check = nf_proto_csum_update(skb,
+						   ~sack->start_seq,
+						   new_start_seq,
+						   tcph->check, 0);
+		tcph->check = nf_proto_csum_update(skb,
+						   ~sack->end_seq,
+						   new_end_seq,
+						   tcph->check, 0);
 		sack->start_seq = new_start_seq;
 		sack->end_seq = new_end_seq;
 		sackoff += sizeof(*sack);
@@ -381,10 +404,10 @@ ip_nat_seq_adjust(struct sk_buff **pskb,
 		newack = ntohl(tcph->ack_seq) - other_way->offset_before;
 	newack = htonl(newack);
 
-	tcph->check = ip_nat_cheat_check(~tcph->seq, newseq,
-					 ip_nat_cheat_check(~tcph->ack_seq, 
-					 		    newack, 
-							    tcph->check));
+	tcph->check = nf_proto_csum_update(*pskb, ~tcph->seq, newseq,
+					   tcph->check, 0);
+	tcph->check = nf_proto_csum_update(*pskb, ~tcph->ack_seq, newack,
+					   tcph->check, 0);
 
 	DEBUGP("Adjusting sequence number from %u->%u, ack from %u->%u\n",
 		ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
diff --git a/net/ipv4/netfilter/ip_nat_proto_gre.c b/net/ipv4/netfilter/ip_nat_proto_gre.c
index 38acfdf..70a6537 100644
--- a/net/ipv4/netfilter/ip_nat_proto_gre.c
+++ b/net/ipv4/netfilter/ip_nat_proto_gre.c
@@ -130,9 +130,10 @@ gre_manip_pkt(struct sk_buff **pskb,
 			if (greh->csum) {
 				/* FIXME: Never tested this code... */
 				*(gre_csum(greh)) = 
-					ip_nat_cheat_check(~*(gre_key(greh)),
+					nf_proto_csum_update(*pskb,
+							~*(gre_key(greh)),
 							tuple->dst.u.gre.key,
-							*(gre_csum(greh)));
+							*(gre_csum(greh)), 0);
 			}
 			*(gre_key(greh)) = tuple->dst.u.gre.key;
 			break;
diff --git a/net/ipv4/netfilter/ip_nat_proto_icmp.c b/net/ipv4/netfilter/ip_nat_proto_icmp.c
index 31a3f4c..ec50cc2 100644
--- a/net/ipv4/netfilter/ip_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_icmp.c
@@ -66,10 +66,10 @@ icmp_manip_pkt(struct sk_buff **pskb,
 		return 0;
 
 	hdr = (struct icmphdr *)((*pskb)->data + hdroff);
-
-	hdr->checksum = ip_nat_cheat_check(hdr->un.echo.id ^ 0xFFFF,
-					    tuple->src.u.icmp.id,
-					    hdr->checksum);
+	hdr->checksum = nf_proto_csum_update(*pskb,
+					     hdr->un.echo.id ^ 0xFFFF,
+					     tuple->src.u.icmp.id,
+					     hdr->checksum, 0);
 	hdr->un.echo.id = tuple->src.u.icmp.id;
 	return 1;
 }
diff --git a/net/ipv4/netfilter/ip_nat_proto_tcp.c b/net/ipv4/netfilter/ip_nat_proto_tcp.c
index a3d1407..72a6307 100644
--- a/net/ipv4/netfilter/ip_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_tcp.c
@@ -129,10 +129,9 @@ tcp_manip_pkt(struct sk_buff **pskb,
 	if (hdrsize < sizeof(*hdr))
 		return 1;
 
-	hdr->check = ip_nat_cheat_check(~oldip, newip,
-					ip_nat_cheat_check(oldport ^ 0xFFFF,
-							   newport,
-							   hdr->check));
+	hdr->check = nf_proto_csum_update(*pskb, ~oldip, newip, hdr->check, 1);
+	hdr->check = nf_proto_csum_update(*pskb, oldport ^ 0xFFFF, newport,
+					  hdr->check, 0);
 	return 1;
 }
 
diff --git a/net/ipv4/netfilter/ip_nat_proto_udp.c b/net/ipv4/netfilter/ip_nat_proto_udp.c
index ec6053f..5da196a 100644
--- a/net/ipv4/netfilter/ip_nat_proto_udp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_udp.c
@@ -113,11 +113,16 @@ udp_manip_pkt(struct sk_buff **pskb,
 		newport = tuple->dst.u.udp.port;
 		portptr = &hdr->dest;
 	}
-	if (hdr->check) /* 0 is a special case meaning no checksum */
-		hdr->check = ip_nat_cheat_check(~oldip, newip,
-					ip_nat_cheat_check(*portptr ^ 0xFFFF,
-							   newport,
-							   hdr->check));
+
+	if (hdr->check || (*pskb)->ip_summed == CHECKSUM_PARTIAL) {
+		hdr->check = nf_proto_csum_update(*pskb, ~oldip, newip,
+						  hdr->check, 1);
+		hdr->check = nf_proto_csum_update(*pskb,
+						  *portptr ^ 0xFFFF, newport,
+						  hdr->check, 0);
+		if (!hdr->check)
+			hdr->check = -1;
+	}
 	*portptr = newport;
 	return 1;
 }
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index f4f00c8..f3b7783 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -110,12 +110,6 @@ ip_nat_fn(unsigned int hooknum,
 	IP_NF_ASSERT(!((*pskb)->nh.iph->frag_off
 		       & htons(IP_MF|IP_OFFSET)));
 
-	/* If we had a hardware checksum before, it's now invalid */
-	if ((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
-	    (*pskb)->ip_summed == CHECKSUM_COMPLETE)
-		if (skb_checksum_help(*pskb))
-			return NF_DROP;
-
 	ct = ip_conntrack_get(*pskb, &ctinfo);
 	/* Can't track?  It's not due to stress, or conntrack would
 	   have dropped it.  Hence it's the user's responsibilty to
@@ -146,8 +140,8 @@ ip_nat_fn(unsigned int hooknum,
 	case IP_CT_RELATED:
 	case IP_CT_RELATED+IP_CT_IS_REPLY:
 		if ((*pskb)->nh.iph->protocol == IPPROTO_ICMP) {
-			if (!ip_nat_icmp_reply_translation(pskb, ct, maniptype,
-							   CTINFO2DIR(ctinfo)))
+			if (!ip_nat_icmp_reply_translation(ct, ctinfo,
+							   hooknum, pskb))
 				return NF_DROP;
 			else
 				return NF_ACCEPT;
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 4ec43f9..35916c7 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -52,7 +52,7 @@ static inline int
 set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
 {
 	struct tcphdr _tcph, *tcph;
-	u_int16_t diffs[2];
+	u_int16_t oldval;
 
 	/* Not enought header? */
 	tcph = skb_header_pointer(*pskb, (*pskb)->nh.iph->ihl*4,
@@ -70,23 +70,16 @@ set_ect_tcp(struct sk_buff **pskb, const
 		return 0;
 	tcph = (void *)(*pskb)->nh.iph + (*pskb)->nh.iph->ihl*4;
 
-	if (((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
-	     (*pskb)->ip_summed == CHECKSUM_COMPLETE) &&
-	    skb_checksum_help(*pskb))
-		return 0;
-
-	diffs[0] = ((u_int16_t *)tcph)[6];
+	oldval = ((u_int16_t *)tcph)[6];
 	if (einfo->operation & IPT_ECN_OP_SET_ECE)
 		tcph->ece = einfo->proto.tcp.ece;
 	if (einfo->operation & IPT_ECN_OP_SET_CWR)
 		tcph->cwr = einfo->proto.tcp.cwr;
-	diffs[1] = ((u_int16_t *)tcph)[6];
-	diffs[0] = diffs[0] ^ 0xFFFF;
 
-	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY)
-		tcph->check = csum_fold(csum_partial((char *)diffs,
-						     sizeof(diffs),
-						     tcph->check^0xFFFF));
+	tcph->check = nf_proto_csum_update((*pskb),
+					   oldval ^ 0xFFFF,
+					   ((u_int16_t *)tcph)[6],
+					   tcph->check, 0);
 	return 1;
 }
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 7f905bf..95c6662 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -185,6 +185,7 @@ static void send_reset(struct sk_buff *o
 	tcph->urg_ptr = 0;
 
 	/* Adjust TCP checksum */
+	nskb->ip_summed = CHECKSUM_NONE;
 	tcph->check = 0;
 	tcph->check = tcp_v4_check(tcph, sizeof(struct tcphdr),
 				   nskb->nh.iph->saddr,
diff --git a/net/ipv4/netfilter/ipt_TCPMSS.c b/net/ipv4/netfilter/ipt_TCPMSS.c
index c998dc0..0fce85e 100644
--- a/net/ipv4/netfilter/ipt_TCPMSS.c
+++ b/net/ipv4/netfilter/ipt_TCPMSS.c
@@ -27,14 +27,6 @@ #else
 #define DEBUGP(format, args...)
 #endif
 
-static u_int16_t
-cheat_check(u_int32_t oldvalinv, u_int32_t newval, u_int16_t oldcheck)
-{
-	u_int32_t diffs[] = { oldvalinv, newval };
-	return csum_fold(csum_partial((char *)diffs, sizeof(diffs),
-                                      oldcheck^0xFFFF));
-}
-
 static inline unsigned int
 optlen(const u_int8_t *opt, unsigned int offset)
 {
@@ -62,11 +54,6 @@ ipt_tcpmss_target(struct sk_buff **pskb,
 	if (!skb_make_writable(pskb, (*pskb)->len))
 		return NF_DROP;
 
-	if (((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
-	     (*pskb)->ip_summed == CHECKSUM_COMPLETE) &&
-	    skb_checksum_help(*pskb))
-		return NF_DROP;
-
 	iph = (*pskb)->nh.iph;
 	tcplen = (*pskb)->len - iph->ihl*4;
 
@@ -120,9 +107,10 @@ ipt_tcpmss_target(struct sk_buff **pskb,
 			opt[i+2] = (newmss & 0xff00) >> 8;
 			opt[i+3] = (newmss & 0x00ff);
 
-			tcph->check = cheat_check(htons(oldmss)^0xFFFF,
-						  htons(newmss),
-						  tcph->check);
+			tcph->check = nf_proto_csum_update(*pskb,
+							   htons(oldmss)^0xFFFF,
+							   htons(newmss),
+							   tcph->check, 0);
 
 			DEBUGP(KERN_INFO "ipt_tcpmss_target: %u.%u.%u.%u:%hu"
 			       "->%u.%u.%u.%u:%hu changed TCP MSS option"
@@ -162,8 +150,10 @@ ipt_tcpmss_target(struct sk_buff **pskb,
  	opt = (u_int8_t *)tcph + sizeof(struct tcphdr);
 	memmove(opt + TCPOLEN_MSS, opt, tcplen - sizeof(struct tcphdr));
 
-	tcph->check = cheat_check(htons(tcplen) ^ 0xFFFF,
-				  htons(tcplen + TCPOLEN_MSS), tcph->check);
+	tcph->check = nf_proto_csum_update(*pskb,
+					   htons(tcplen) ^ 0xFFFF,
+				           htons(tcplen + TCPOLEN_MSS),
+					   tcph->check, 1);
 	tcplen += TCPOLEN_MSS;
 
 	opt[0] = TCPOPT_MSS;
@@ -171,16 +161,19 @@ ipt_tcpmss_target(struct sk_buff **pskb,
 	opt[2] = (newmss & 0xff00) >> 8;
 	opt[3] = (newmss & 0x00ff);
 
-	tcph->check = cheat_check(~0, *((u_int32_t *)opt), tcph->check);
+	tcph->check = nf_proto_csum_update(*pskb, ~0, *((u_int32_t *)opt),
+					   tcph->check, 0);
 
 	oldval = ((u_int16_t *)tcph)[6];
 	tcph->doff += TCPOLEN_MSS/4;
-	tcph->check = cheat_check(oldval ^ 0xFFFF,
-				  ((u_int16_t *)tcph)[6], tcph->check);
+	tcph->check = nf_proto_csum_update(*pskb,
+					   oldval ^ 0xFFFF,
+					   ((u_int16_t *)tcph)[6],
+					   tcph->check, 0);
 
 	newtotlen = htons(ntohs(iph->tot_len) + TCPOLEN_MSS);
-	iph->check = cheat_check(iph->tot_len ^ 0xFFFF,
-				 newtotlen, iph->check);
+	iph->check = nf_csum_update(iph->tot_len ^ 0xFFFF,
+				    newtotlen, iph->check);
 	iph->tot_len = newtotlen;
 
 	DEBUGP(KERN_INFO "ipt_tcpmss_target: %u.%u.%u.%u:%hu"
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 5d29d5e..27f639f 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -222,6 +222,28 @@ copy_skb:
 }
 EXPORT_SYMBOL(skb_make_writable);
 
+u_int16_t nf_csum_update(u_int32_t oldval, u_int32_t newval, u_int32_t csum)
+{
+	u_int32_t diff[] = { oldval, newval };
+
+	return csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum));
+}
+EXPORT_SYMBOL(nf_csum_update);
+
+u_int16_t nf_proto_csum_update(struct sk_buff *skb,
+			       u_int32_t oldval, u_int32_t newval,
+			       u_int16_t csum, int pseudohdr)
+{
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		csum = nf_csum_update(oldval, newval, csum);
+		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
+			skb->csum = nf_csum_update(oldval, newval, skb->csum);
+	} else if (pseudohdr)
+		csum = ~nf_csum_update(oldval, newval, ~csum);
+
+	return csum;
+}
+EXPORT_SYMBOL(nf_proto_csum_update);
 
 /* This does not belong here, but locally generated errors need it if connection
    tracking in use: without this, connection may not be in hash table, and hence

--------------070709030500000306010106--
