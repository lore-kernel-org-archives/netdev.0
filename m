From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Mon, 31 Jul 2006 12:39:51 +0200
Message-ID: <44CDDDF7.70004@trash.net>
References: <44CD8415.2020403@davidcoulson.net>	<44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040509000103080002010304"
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56226 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751476AbWGaKlk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 06:41:40 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <44CD9013.7020401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040509000103080002010304
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> David Miller wrote:
> 
>>I would like to see this fixed for 2.6.18, no later.
>>
>>Either that or disable the bug trap, but taking this route
>>is severely discouraged. :)
> 
> 
> I'm actually updateing my patch for this on top of Herbert's
> CHECKSUM_PARTIAL patch right now. Unfortunately I targeted 2.6.19,
> so the fixes are on top of a few cleanups (which unconvered a few
> unrelated bugs as well). I'll post it when I'm done so we can
> decide how to proceed.

These are the patches (some variantions tested, but not all) on
top of Herbert's CHECKSUM_PARTIAL patch. The first one fixes up
the CHECKSUM_PARTIAL patch for 2.6.18-rc3, the second one fixes
checksumming in all of netfilter besides ip_queue, the third one
fixes ip_queue.

Its actually not that much, if Herbert is fine with putting the
CHECKSUM_PARTIAL patch in 2.6.18 I'll do some more testing and
then I think these can go in as well.


--------------040509000103080002010304
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NET]: Fix up CHECKSUM_PARTIAL patch for 2.6.18-rc3

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 17a40f32fc339e9f6feeb042db58d30c8caf2fad
tree 479e926c12606667a91d483223b4416da56227d5
parent 296b866d72ee7a8a577908323f2a7e8e92f4001f
author Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 09:23:27 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 09:23:27 +0200

 include/linux/netdevice.h |    4 ++--
 net/core/dev.c            |    8 ++++----
 net/ipv4/tcp.c            |    4 ++--
 net/ipv4/tcp_ipv4.c       |    2 +-
 net/ipv6/tcp_ipv6.c       |    2 +-
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 75f02d8..b5b9a33 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -973,7 +973,7 @@ extern void		dev_mcast_init(void);
 extern int		netdev_max_backlog;
 extern int		weight_p;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
-extern int skb_checksum_help(struct sk_buff *skb, int inward);
+extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
@@ -1009,7 +1009,7 @@ static inline int netif_needs_gso(struct
 {
 	return skb_is_gso(skb) &&
 	       (!skb_gso_ok(skb, dev->features) ||
-		unlikely(skb->ip_summed != CHECKSUM_HW));
+		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
 }
 
 #endif /* __KERNEL__ */
diff --git a/net/core/dev.c b/net/core/dev.c
index 90fb267..528c5f3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1157,12 +1157,12 @@ EXPORT_SYMBOL(netif_device_attach);
  * Invalidate hardware checksum when packet is to be mangled, and
  * complete checksum manually on outgoing path.
  */
-int skb_checksum_help(struct sk_buff *skb, int inward)
+int skb_checksum_help(struct sk_buff *skb)
 {
 	unsigned int csum;
 	int ret = 0, offset = skb->h.raw - skb->data;
 
-	if (inward)
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		goto out_set_summed;
 
 	if (unlikely(skb_shinfo(skb)->gso_size)) {
@@ -1219,7 +1219,7 @@ struct sk_buff *skb_gso_segment(struct s
 	skb->mac_len = skb->nh.raw - skb->data;
 	__skb_pull(skb, skb->mac_len);
 
-	if (unlikely(skb->ip_summed != CHECKSUM_HW)) {
+	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
 		static int warned;
 
 		WARN_ON(!warned);
@@ -1233,7 +1233,7 @@ struct sk_buff *skb_gso_segment(struct s
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type) & 15], list) {
 		if (ptype->type == type && !ptype->dev && ptype->gso_segment) {
-			if (unlikely(skb->ip_summed != CHECKSUM_HW)) {
+			if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
 				err = ptype->gso_send_check(skb);
 				segs = ERR_PTR(err);
 				if (err || skb_gso_ok(skb, features))
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 40ada0b..c452373 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2204,7 +2204,7 @@ struct sk_buff *tcp_tso_segment(struct s
 		th->fin = th->psh = 0;
 
 		th->check = ~csum_fold(th->check + delta);
-		if (skb->ip_summed != CHECKSUM_HW)
+		if (skb->ip_summed != CHECKSUM_PARTIAL)
 			th->check = csum_fold(csum_partial(skb->h.raw, thlen,
 							   skb->csum));
 
@@ -2218,7 +2218,7 @@ struct sk_buff *tcp_tso_segment(struct s
 
 	delta = htonl(oldlen + (skb->tail - skb->h.raw) + skb->data_len);
 	th->check = ~csum_fold(th->check + delta);
-	if (skb->ip_summed != CHECKSUM_HW)
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		th->check = csum_fold(csum_partial(skb->h.raw, thlen,
 						   skb->csum));
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 114830f..be056d1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -510,7 +510,7 @@ int tcp_v4_gso_send_check(struct sk_buff
 	th->check = 0;
 	th->check = ~tcp_v4_check(th, skb->len, iph->saddr, iph->daddr, 0);
 	skb->csum = offsetof(struct tcphdr, check);
-	skb->ip_summed = CHECKSUM_HW;
+	skb->ip_summed = CHECKSUM_PARTIAL;
 	return 0;
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 341c4a4..f32bddf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -567,7 +567,7 @@ static int tcp_v6_gso_send_check(struct 
 	th->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
 				     IPPROTO_TCP, 0);
 	skb->csum = offsetof(struct tcphdr, check);
-	skb->ip_summed = CHECKSUM_HW;
+	skb->ip_summed = CHECKSUM_PARTIAL;
 	return 0;
 }
 

--------------040509000103080002010304
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NETFILTER]: Get rid of HW checksum invalidation

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2d1b6c7500cd7b71a795976fe8eb3d2fd47cd39a
tree a0df4f11d6991df2f5be9d7c050b3c0c2303e968
parent 17a40f32fc339e9f6feeb042db58d30c8caf2fad
author Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 12:28:11 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 12:28:11 +0200

 include/linux/netfilter.h              |    6 +++
 net/ipv4/netfilter/ip_nat_core.c       |   18 ++++++----
 net/ipv4/netfilter/ip_nat_helper.c     |   57 ++++++++++++++++++++++----------
 net/ipv4/netfilter/ip_nat_proto_gre.c  |    5 ++-
 net/ipv4/netfilter/ip_nat_proto_icmp.c |    8 ++--
 net/ipv4/netfilter/ip_nat_proto_tcp.c  |    7 ++--
 net/ipv4/netfilter/ip_nat_proto_udp.c  |   13 ++++---
 net/ipv4/netfilter/ip_nat_standalone.c |    6 ---
 net/ipv4/netfilter/ipt_ECN.c           |   19 +++--------
 net/ipv4/netfilter/ipt_REJECT.c        |    1 +
 net/ipv4/netfilter/ipt_TCPMSS.c        |   39 +++++++++-------------
 net/netfilter/core.c                   |   23 +++++++++++++
 12 files changed, 120 insertions(+), 82 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 10168e2..e1d50f6 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -282,6 +282,12 @@ extern void nf_invalidate_cache(int pf);
    Returns true or false. */
 extern int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len);
 
+extern u_int16_t nf_csum_update(u_int32_t oldval, u_int32_t newval,
+				u_int16_t csum);
+extern u_int16_t nf_proto_csum_update(struct sk_buff *skb,
+				      u_int32_t oldval, u_int32_t newval,
+				      u_int16_t csum, int pseudohdr);
+
 struct nf_afinfo {
 	unsigned short	family;
 	unsigned int	(*checksum)(struct sk_buff *skb, unsigned int hook,
diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_core.c
index 1741d55..731efbb 100644
--- a/net/ipv4/netfilter/ip_nat_core.c
+++ b/net/ipv4/netfilter/ip_nat_core.c
@@ -443,7 +443,9 @@ int ip_nat_icmp_reply_translation(struct
 
 	/* We're actually going to mangle it beyond trivial checksum
 	   adjustment, so make sure the current checksum is correct. */
-	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY) {
+
+	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY &&
+	    (*pskb)->ip_summed != CHECKSUM_PARTIAL) {
 		hdrlen = (*pskb)->nh.iph->ihl * 4;
 		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
 						(*pskb)->len - hdrlen, 0)))
@@ -487,12 +489,14 @@ int ip_nat_icmp_reply_translation(struct
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
index cbcaa45..dd0ddd4 100644
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
@@ -238,22 +248,30 @@ ip_nat_mangle_udp_packet(struct sk_buff 
 
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
+	if (!udph->check)
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
+	} else
+		udph->check = nf_proto_csum_update(*pskb,
+						   htons(oldlen) ^ 0xFFFF,
+						   htons(datalen),
+						   udph->check, 1);
 	return 1;
 }
 EXPORT_SYMBOL(ip_nat_mangle_udp_packet);
@@ -293,11 +311,14 @@ sack_adjust(struct sk_buff *skb,
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
@@ -381,10 +402,10 @@ ip_nat_seq_adjust(struct sk_buff **pskb,
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
index ec6053f..638999c 100644
--- a/net/ipv4/netfilter/ip_nat_proto_udp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_udp.c
@@ -113,11 +113,14 @@ udp_manip_pkt(struct sk_buff **pskb,
 		newport = tuple->dst.u.udp.port;
 		portptr = &hdr->dest;
 	}
-	if (hdr->check) /* 0 is a special case meaning no checksum */
-		hdr->check = ip_nat_cheat_check(~oldip, newip,
-					ip_nat_cheat_check(*portptr ^ 0xFFFF,
-							   newport,
-							   hdr->check));
+
+	if (hdr->check) {
+		hdr->check = nf_proto_csum_update(*pskb, ~oldip, newip,
+						  hdr->check, 1);
+		hdr->check = nf_proto_csum_update(*pskb,
+						  *portptr ^ 0xFFFF, newport,
+						  hdr->check, 0);
+	}
 	*portptr = newport;
 	return 1;
 }
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index f4f00c8..bcb22c7 100644
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
index 269bc20..67a06fa 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -184,6 +184,7 @@ static void send_reset(struct sk_buff *o
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
index 5d29d5e..a7c42c8 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -222,6 +222,29 @@ copy_skb:
 }
 EXPORT_SYMBOL(skb_make_writable);
 
+u_int16_t nf_csum_update(u_int32_t oldval, u_int32_t newval, u_int16_t csum)
+{
+	u_int32_t diff[] = { oldval, newval };
+
+	return csum_fold(csum_partial((char *)diff, sizeof(diff),
+				      csum ^ 0xFFFF));
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

--------------040509000103080002010304
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

[NETFILTER]: nf_queue: handle GSO packets

Handle GSO packets in nf_queue by segmenting them before queueing to
avoid breaking GSO in case they get mangled.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ab7d6d33680e994b1e4a559853b0447061c849ca
tree f86dd158fc30ffa300a45e6dd3418da065f00f93
parent 2d1b6c7500cd7b71a795976fe8eb3d2fd47cd39a
author Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 12:29:44 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 12:29:44 +0200

 net/netfilter/core.c         |    2 +
 net/netfilter/nf_internals.h |    2 +
 net/netfilter/nf_queue.c     |   76 ++++++++++++++++++++++++++++++++----------
 3 files changed, 60 insertions(+), 20 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a7c42c8..dc46232 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -182,7 +182,7 @@ next_hook:
 		ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK)  == NF_QUEUE) {
 		NFDEBUG("nf_hook: Verdict = QUEUE.\n");
-		if (!nf_queue(pskb, elem, pf, hook, indev, outdev, okfn,
+		if (!nf_queue(*pskb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;
 	}
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 86e392b..42fd72a 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -23,7 +23,7 @@ extern unsigned int nf_iterate(struct li
 				int hook_thresh);
 
 /* nf_queue.c */
-extern int nf_queue(struct sk_buff **skb, 
+extern int nf_queue(struct sk_buff *skb,
 		    struct list_head *elem, 
 		    int pf, unsigned int hook,
 		    struct net_device *indev,
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 662a869..e9b46dc 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -74,13 +74,13 @@ EXPORT_SYMBOL_GPL(nf_unregister_queue_ha
  * Any packet that leaves via this function must come back 
  * through nf_reinject().
  */
-int nf_queue(struct sk_buff **skb, 
-	     struct list_head *elem, 
-	     int pf, unsigned int hook,
-	     struct net_device *indev,
-	     struct net_device *outdev,
-	     int (*okfn)(struct sk_buff *),
-	     unsigned int queuenum)
+static int __nf_queue(struct sk_buff *skb,
+		      struct list_head *elem,
+		      int pf, unsigned int hook,
+		      struct net_device *indev,
+		      struct net_device *outdev,
+		      int (*okfn)(struct sk_buff *),
+		      unsigned int queuenum)
 {
 	int status;
 	struct nf_info *info;
@@ -94,14 +94,14 @@ #endif
 	read_lock(&queue_handler_lock);
 	if (!queue_handler[pf]) {
 		read_unlock(&queue_handler_lock);
-		kfree_skb(*skb);
+		kfree_skb(skb);
 		return 1;
 	}
 
 	afinfo = nf_get_afinfo(pf);
 	if (!afinfo) {
 		read_unlock(&queue_handler_lock);
-		kfree_skb(*skb);
+		kfree_skb(skb);
 		return 1;
 	}
 
@@ -109,9 +109,9 @@ #endif
 	if (!info) {
 		if (net_ratelimit())
 			printk(KERN_ERR "OOM queueing packet %p\n",
-			       *skb);
+			       skb);
 		read_unlock(&queue_handler_lock);
-		kfree_skb(*skb);
+		kfree_skb(skb);
 		return 1;
 	}
 
@@ -130,15 +130,15 @@ #endif
 	if (outdev) dev_hold(outdev);
 
 #ifdef CONFIG_BRIDGE_NETFILTER
-	if ((*skb)->nf_bridge) {
-		physindev = (*skb)->nf_bridge->physindev;
+	if (skb->nf_bridge) {
+		physindev = skb->nf_bridge->physindev;
 		if (physindev) dev_hold(physindev);
-		physoutdev = (*skb)->nf_bridge->physoutdev;
+		physoutdev = skb->nf_bridge->physoutdev;
 		if (physoutdev) dev_hold(physoutdev);
 	}
 #endif
-	afinfo->saveroute(*skb, info);
-	status = queue_handler[pf]->outfn(*skb, info, queuenum,
+	afinfo->saveroute(skb, info);
+	status = queue_handler[pf]->outfn(skb, info, queuenum,
 					  queue_handler[pf]->data);
 
 	read_unlock(&queue_handler_lock);
@@ -153,7 +153,7 @@ #ifdef CONFIG_BRIDGE_NETFILTER
 #endif
 		module_put(info->elem->owner);
 		kfree(info);
-		kfree_skb(*skb);
+		kfree_skb(skb);
 
 		return 1;
 	}
@@ -161,6 +161,46 @@ #endif
 	return 1;
 }
 
+int nf_queue(struct sk_buff *skb,
+	     struct list_head *elem,
+	     int pf, unsigned int hook,
+	     struct net_device *indev,
+	     struct net_device *outdev,
+	     int (*okfn)(struct sk_buff *),
+	     unsigned int queuenum)
+{
+	struct sk_buff *segs;
+
+	if (!skb_is_gso(skb))
+		return __nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
+				  queuenum);
+
+	switch (pf) {
+	case AF_INET:
+		skb->protocol = htons(ETH_P_IP);
+		break;
+	case AF_INET6:
+		skb->protocol = htons(ETH_P_IPV6);
+		break;
+	}
+
+	segs = skb_gso_segment(skb, 0);
+	kfree_skb(skb);
+	if (unlikely(IS_ERR(segs)))
+		return 1;
+
+	do {
+		struct sk_buff *nskb = segs->next;
+
+		segs->next = NULL;
+		if (!__nf_queue(segs, elem, pf, hook, indev, outdev, okfn,
+				queuenum))
+			kfree_skb(nskb);
+		segs = nskb;
+	} while (segs);
+	return 1;
+}
+
 void nf_reinject(struct sk_buff *skb, struct nf_info *info,
 		 unsigned int verdict)
 {
@@ -224,7 +264,7 @@ #endif
 	case NF_STOLEN:
 		break;
 	case NF_QUEUE:
-		if (!nf_queue(&skb, elem, info->pf, info->hook, 
+		if (!nf_queue(skb, elem, info->pf, info->hook,
 			      info->indev, info->outdev, info->okfn,
 			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;

--------------040509000103080002010304--
