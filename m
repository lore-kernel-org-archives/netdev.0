From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Mon, 31 Jul 2006 20:36:58 +0200
Message-ID: <44CE4DCA.8000609@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000305020700010904060704"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47296 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030272AbWGaSiu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 14:38:50 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060731113050.GA25972@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000305020700010904060704
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> On Mon, Jul 31, 2006 at 12:39:51PM +0200, Patrick McHardy wrote:
> 
>>Its actually not that much, if Herbert is fine with putting the
>>CHECKSUM_PARTIAL patch in 2.6.18 I'll do some more testing and
>>then I think these can go in as well.
> 
> 
> You guys know I'm a coward when it comes to pushing things into rc :)
> 
> So I'd rather see a patch to disable the warnings for 2.6.18 so that
> the proper fix can be tested more thoroughly.  We should remember that
> the 2.6.18 minus the warning is still going to be heaps better in this
> regard compared to 2.6.17 where all TSO packets were essentially
> discarded due to the incorrect checksum (when the NAT module is loaded).

I'm fine either way.

>>[NET]: Fix up CHECKSUM_PARTIAL patch for 2.6.18-rc3
>>
>>Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> 
> Please merge this with my earlier patch.  I'm not that fussed about
> having my changeset go in :)

Done.

>>diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_core.c
>>index 1741d55..731efbb 100644
>>--- a/net/ipv4/netfilter/ip_nat_core.c
>>+++ b/net/ipv4/netfilter/ip_nat_core.c
>>@@ -443,7 +443,9 @@ int ip_nat_icmp_reply_translation(struct
>> 
>> 	/* We're actually going to mangle it beyond trivial checksum
>> 	   adjustment, so make sure the current checksum is correct. */
>>-	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY) {
>>+
>>+	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY &&
>>+	    (*pskb)->ip_summed != CHECKSUM_PARTIAL) {
>> 		hdrlen = (*pskb)->nh.iph->ihl * 4;
>> 		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
>> 						(*pskb)->len - hdrlen, 0)))
> 
> 
> Call me picky, but I'd prefer it to actually look like
> 
> 	switch ((*pskb)->ip_summed) {
> 	case CHECKSUM_COMPLETE:
> 		if (!(u16)csum_fold(skb->csum))
> 			break;
> 		/* fall through */
> 	case CHECKSUM_NONE:
> 		hdrlen = (*pskb)->nh.iph->ihl * 4;
> 		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
> 						(*pskb)->len - hdrlen, 0)))
> 			return 0;
> 	}
> 
> just because we probably won't revisit this code path for another
> million years to add this optimisation :)

I've changed it to just use nf_ip_checksum instead (something I wanted
to do in a follow-up patch to keep this one as small as possible).
I'm also going to get rid of the remaining ip_nat_cheat_check copies
(there are quite a few of them).

> OK, this is so incredibly clever that I probably won't understand it
> until tomorrow :)
> 
> 
>>@@ -238,22 +248,30 @@ ip_nat_mangle_udp_packet(struct sk_buff 
>> 
>> 	iph = (*pskb)->nh.iph;
>> 	udph = (void *)iph + iph->ihl*4;
>>+
>>+	oldlen = (*pskb)->len - iph->ihl*4;
>> 	mangle_contents(*pskb, iph->ihl*4 + sizeof(*udph),
>> 			match_offset, match_len, rep_buffer, rep_len);
>> 
>> 	/* update the length of the UDP packet */
>>-	udph->len = htons((*pskb)->len - iph->ihl*4);
>>+	datalen = (*pskb)->len - iph->ihl*4;
>>+	udph->len = htons(datalen);
>> 
>> 	/* fix udp checksum if udp checksum was previously calculated */
>>-	if (udph->check) {
>>-		int datalen = (*pskb)->len - iph->ihl * 4;
>>+	if (!udph->check)
>>+		return 1;
> 
> 
> Just a quick thought, what if the partial checksum was zero?

Good point. I've fixed it to check for != CHECKSUM_PARTIAL here and
in the UDP NAT helper and also changed it to use -1 when the newly
calculated checksum is 0 so we don't accidentally turn off UDP
checksumming.

> I'm goint to review the rest of your patch tomorrow morning because
> I always fall sleep when looking at checksums :)

Same here, just woke up again :) New patches attached, with one
additional fix: the ip_queue patch tried to free the wrong packet
when queueing a generated segment failed.

I'm going to do some more testing now ..


--------------000305020700010904060704
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NET]: Replace CHECKSUM_HW by CHECKSUM_PARTIAL/CHECKSUM_COMPLETE

Replace CHECKSUM_HW by CHECKSUM_PARTIAL (for outgoing packets, whose
checksum still needs to be completed) and CHECKSUM_COMPLETE (for
incoming packets, device supplied full checksum).

Patch originally from Herbert Xu, updated by myself for 2.6.18-rc3.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9e8ee86180aab5a225832c9772b2ad0e8a5c6006
tree 479e926c12606667a91d483223b4416da56227d5
parent b6ff50833ad43a8ebd9b16bf53c334f7aaf33c41
author Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 20:16:10 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 20:16:10 +0200

 drivers/atm/he.c                            |    2 +-
 drivers/net/3c59x.c                         |    2 +-
 drivers/net/8139cp.c                        |    6 +++---
 drivers/net/acenic.c                        |    8 ++++----
 drivers/net/bnx2.c                          |    2 +-
 drivers/net/cassini.c                       |    4 ++--
 drivers/net/chelsio/sge.c                   |   10 +++++-----
 drivers/net/dl2k.c                          |    2 +-
 drivers/net/e1000/e1000_main.c              |    8 ++++----
 drivers/net/forcedeth.c                     |    3 ++-
 drivers/net/gianfar.c                       |    2 +-
 drivers/net/hamachi.c                       |    2 +-
 drivers/net/ibm_emac/ibm_emac_core.c        |    2 +-
 drivers/net/ioc3-eth.c                      |    2 +-
 drivers/net/ixgb/ixgb_main.c                |    2 +-
 drivers/net/mv643xx_eth.c                   |    2 +-
 drivers/net/myri10ge/myri10ge.c             |    8 ++++----
 drivers/net/ns83820.c                       |    2 +-
 drivers/net/r8169.c                         |    2 +-
 drivers/net/s2io.c                          |    2 +-
 drivers/net/sk98lin/skge.c                  |    6 +++---
 drivers/net/skge.c                          |    4 ++--
 drivers/net/sky2.c                          |    6 +++---
 drivers/net/starfire.c                      |    6 +++---
 drivers/net/sungem.c                        |    4 ++--
 drivers/net/sunhme.c                        |    6 +++---
 drivers/net/tg3.c                           |    6 +++---
 drivers/net/typhoon.c                       |    2 +-
 drivers/net/via-rhine.c                     |    2 +-
 drivers/net/via-velocity.c                  |    2 +-
 include/linux/netdevice.h                   |    4 ++--
 include/linux/skbuff.h                      |   17 +++++++++--------
 net/core/datagram.c                         |    4 ++--
 net/core/dev.c                              |   12 ++++++------
 net/core/netpoll.c                          |    2 +-
 net/core/skbuff.c                           |   14 +++++++-------
 net/ipv4/icmp.c                             |    2 +-
 net/ipv4/igmp.c                             |    2 +-
 net/ipv4/ip_fragment.c                      |    2 +-
 net/ipv4/ip_gre.c                           |    4 ++--
 net/ipv4/ip_output.c                        |    6 +++---
 net/ipv4/ipvs/ip_vs_proto_tcp.c             |    8 ++++----
 net/ipv4/ipvs/ip_vs_proto_udp.c             |    8 ++++----
 net/ipv4/netfilter.c                        |    2 +-
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c |    3 +--
 net/ipv4/netfilter/ip_conntrack_proto_udp.c |    3 +--
 net/ipv4/netfilter/ip_nat_standalone.c      |    5 +++--
 net/ipv4/netfilter/ip_queue.c               |    6 +++---
 net/ipv4/netfilter/ipt_ECN.c                |    9 +++++----
 net/ipv4/netfilter/ipt_TCPMSS.c             |    5 +++--
 net/ipv4/tcp.c                              |    8 ++++----
 net/ipv4/tcp_ipv4.c                         |    6 +++---
 net/ipv4/tcp_output.c                       |   18 ++++++++----------
 net/ipv4/udp.c                              |    6 +++---
 net/ipv4/xfrm4_output.c                     |    4 ++--
 net/ipv6/exthdrs.c                          |    2 +-
 net/ipv6/icmp.c                             |    2 +-
 net/ipv6/ip6_output.c                       |    2 +-
 net/ipv6/netfilter.c                        |    2 +-
 net/ipv6/netfilter/ip6_queue.c              |    6 +++---
 net/ipv6/netfilter/nf_conntrack_reasm.c     |    6 +++---
 net/ipv6/raw.c                              |    2 +-
 net/ipv6/reassembly.c                       |    6 +++---
 net/ipv6/tcp_ipv6.c                         |    6 +++---
 net/ipv6/udp.c                              |    2 +-
 net/ipv6/xfrm6_output.c                     |    4 ++--
 net/netfilter/nf_conntrack_proto_tcp.c      |    3 +--
 net/netfilter/nf_conntrack_proto_udp.c      |    3 +--
 net/netfilter/nfnetlink_queue.c             |    6 +++---
 net/packet/af_packet.c                      |    2 +-
 net/sched/sch_netem.c                       |    4 ++--
 net/sunrpc/socklib.c                        |    2 +-
 72 files changed, 168 insertions(+), 169 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index d369130..7891237 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1912,7 +1912,7 @@ #endif
 				skb->tail = skb->data + skb->len;
 #ifdef USE_CHECKSUM_HW
 				if (vcc->vpi == 0 && vcc->vci >= ATM_NOT_RSV_VCI) {
-					skb->ip_summed = CHECKSUM_HW;
+					skb->ip_summed = CHECKSUM_COMPLETE;
 					skb->csum = TCP_CKSUM(skb->data,
 							he_vcc->pdu_len);
 				}
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 80e8ca0..29dede2 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2077,7 +2077,7 @@ boomerang_start_xmit(struct sk_buff *skb
 
 	vp->tx_ring[entry].next = 0;
 #if DO_ZEROCOPY
-	if (skb->ip_summed != CHECKSUM_HW)
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
 			vp->tx_ring[entry].status = cpu_to_le32(skb->len | TxIntrUploaded);
 	else
 			vp->tx_ring[entry].status = cpu_to_le32(skb->len | TxIntrUploaded | AddTCPChksum | AddUDPChksum);
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 1428bb7..a48b211 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -813,7 +813,7 @@ #endif
 
 		if (mss)
 			flags |= LargeSend | ((mss & MSSMask) << MSSShift);
-		else if (skb->ip_summed == CHECKSUM_HW) {
+		else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			const struct iphdr *ip = skb->nh.iph;
 			if (ip->protocol == IPPROTO_TCP)
 				flags |= IPCS | TCPCS;
@@ -867,7 +867,7 @@ #endif
 			if (mss)
 				ctrl |= LargeSend |
 					((mss & MSSMask) << MSSShift);
-			else if (skb->ip_summed == CHECKSUM_HW) {
+			else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 				if (ip->protocol == IPPROTO_TCP)
 					ctrl |= IPCS | TCPCS;
 				else if (ip->protocol == IPPROTO_UDP)
@@ -898,7 +898,7 @@ #endif
 		txd->addr = cpu_to_le64(first_mapping);
 		wmb();
 
-		if (skb->ip_summed == CHECKSUM_HW) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			if (ip->protocol == IPPROTO_TCP)
 				txd->opts1 = cpu_to_le32(first_eor | first_len |
 							 FirstFrag | DescOwn |
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 1c01e9b..8265486 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2040,7 +2040,7 @@ static void ace_rx_int(struct net_device
 		 */
 		if (bd_flags & BD_FLG_TCP_UDP_SUM) {
 			skb->csum = htons(csum);
-			skb->ip_summed = CHECKSUM_HW;
+			skb->ip_summed = CHECKSUM_COMPLETE;
 		} else {
 			skb->ip_summed = CHECKSUM_NONE;
 		}
@@ -2511,7 +2511,7 @@ restart:
 
 		mapping = ace_map_tx_skb(ap, skb, skb, idx);
 		flagsize = (skb->len << 16) | (BD_FLG_END);
-		if (skb->ip_summed == CHECKSUM_HW)
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
 #if ACENIC_DO_VLAN
 		if (vlan_tx_tag_present(skb)) {
@@ -2534,7 +2534,7 @@ #endif
 
 		mapping = ace_map_tx_skb(ap, skb, NULL, idx);
 		flagsize = (skb_headlen(skb) << 16);
-		if (skb->ip_summed == CHECKSUM_HW)
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
 #if ACENIC_DO_VLAN
 		if (vlan_tx_tag_present(skb)) {
@@ -2560,7 +2560,7 @@ #endif
 					       PCI_DMA_TODEVICE);
 
 			flagsize = (frag->size << 16);
-			if (skb->ip_summed == CHECKSUM_HW)
+			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				flagsize |= BD_FLG_TCP_UDP_SUM;
 			idx = (idx + 1) % ACE_TX_RING_ENTRIES(ap);
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index db73de0..5a1a7ec 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4418,7 +4418,7 @@ bnx2_start_xmit(struct sk_buff *skb, str
 	ring_prod = TX_RING_IDX(prod);
 
 	vlan_tag_flags = 0;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		vlan_tag_flags |= TX_BD_FLAGS_TCP_UDP_CKSUM;
 	}
 
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index a31544c..558fdb8 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2167,7 +2167,7 @@ end_copy_pkt:
 			cas_page_unmap(addr);
 	}
 	skb->csum = ntohs(i ^ 0xffff);
-	skb->ip_summed = CHECKSUM_HW;
+	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->protocol = eth_type_trans(skb, cp->dev);
 	return len;
 }
@@ -2821,7 +2821,7 @@ static inline int cas_xmit_tx_ringN(stru
 	}
 
 	ctrl = 0;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u64 csum_start_off, csum_stuff_off;
 
 		csum_start_off = (u64) (skb->h.raw - skb->data);
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 61b3754..ddd0bdb 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1470,9 +1470,9 @@ #endif
 		}
 
 		if (!(adapter->flags & UDP_CSUM_CAPABLE) &&
-		    skb->ip_summed == CHECKSUM_HW &&
+		    skb->ip_summed == CHECKSUM_PARTIAL &&
 		    skb->nh.iph->protocol == IPPROTO_UDP)
-			if (unlikely(skb_checksum_help(skb, 0))) {
+			if (unlikely(skb_checksum_help(skb))) {
 				dev_kfree_skb_any(skb);
 				return NETDEV_TX_OK;
 			}
@@ -1495,11 +1495,11 @@ #endif
 		cpl = (struct cpl_tx_pkt *)__skb_push(skb, sizeof(*cpl));
 		cpl->opcode = CPL_TX_PKT;
 		cpl->ip_csum_dis = 1;    /* SW calculates IP csum */
-		cpl->l4_csum_dis = skb->ip_summed == CHECKSUM_HW ? 0 : 1;
+		cpl->l4_csum_dis = skb->ip_summed == CHECKSUM_PARTIAL ? 0 : 1;
 		/* the length field isn't used so don't bother setting it */
 
-		st->tx_cso += (skb->ip_summed == CHECKSUM_HW);
-		sge->stats.tx_do_cksum += (skb->ip_summed == CHECKSUM_HW);
+		st->tx_cso += (skb->ip_summed == CHECKSUM_PARTIAL);
+		sge->stats.tx_do_cksum += (skb->ip_summed == CHECKSUM_PARTIAL);
 		sge->stats.tx_reg_pkts++;
 	}
 	cpl->iff = dev->if_port;
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 402961e..b74e676 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -611,7 +611,7 @@ start_xmit (struct sk_buff *skb, struct 
 	txdesc = &np->tx_ring[entry];
 
 #if 0
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		txdesc->status |=
 		    cpu_to_le64 (TCPChecksumEnable | UDPChecksumEnable |
 				 IPChecksumEnable);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index da62db8..8e053e4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2600,7 +2600,7 @@ e1000_tx_csum(struct e1000_adapter *adap
 	unsigned int i;
 	uint8_t css;
 
-	if (likely(skb->ip_summed == CHECKSUM_HW)) {
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		css = skb->h.raw - skb->data;
 
 		i = tx_ring->next_to_use;
@@ -2927,11 +2927,11 @@ #ifdef NETIF_F_TSO
 	}
 
 	/* reserve a descriptor for the offload context */
-	if ((mss) || (skb->ip_summed == CHECKSUM_HW))
+	if ((mss) || (skb->ip_summed == CHECKSUM_PARTIAL))
 		count++;
 	count++;
 #else
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		count++;
 #endif
 
@@ -3608,7 +3608,7 @@ e1000_rx_checksum(struct e1000_adapter *
 		 */
 		csum = ntohl(csum ^ 0xFFFF);
 		skb->csum = csum;
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 	adapter->hw_csum_good++;
 }
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 11b8f1b..32cacf1 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1503,7 +1503,8 @@ #ifdef NETIF_F_TSO
 		tx_flags_extra = NV_TX2_TSO | (skb_shinfo(skb)->gso_size << NV_TX2_TSO_SHIFT);
 	else
 #endif
-	tx_flags_extra = (skb->ip_summed == CHECKSUM_HW ? (NV_TX2_CHECKSUM_L3|NV_TX2_CHECKSUM_L4) : 0);
+	tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
+			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
 	/* vlan tag */
 	if (np->vlangrp && vlan_tx_tag_present(skb)) {
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ebbbd6c..ba96091 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -947,7 +947,7 @@ static int gfar_start_xmit(struct sk_buf
 
 	/* Set up checksumming */
 	if (likely((dev->features & NETIF_F_IP_CSUM)
-			&& (CHECKSUM_HW == skb->ip_summed))) {
+			&& (CHECKSUM_PARTIAL == skb->ip_summed))) {
 		fcb = gfar_add_fcb(skb, txbdp);
 		status |= TXBD_TOE;
 		gfar_tx_checksum(skb, fcb);
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 409c6aa..763373a 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1648,7 +1648,7 @@ #ifdef RX_CHECKSUM
 						* could do the pseudo myself and return
 						* CHECKSUM_UNNECESSARY
 						*/
-						skb->ip_summed = CHECKSUM_HW;
+						skb->ip_summed = CHECKSUM_COMPLETE;
 					}
 				}	
 			}
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 82468e2..57e214d 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -1036,7 +1036,7 @@ static inline u16 emac_tx_csum(struct oc
 			       struct sk_buff *skb)
 {
 #if defined(CONFIG_IBM_EMAC_TAH)
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		++dev->stats.tx_packets_csum;
 		return EMAC_TX_CTRL_TAH_CSUM;
 	}
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 68d8af7..65f897d 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1387,7 +1387,7 @@ #ifdef CONFIG_SGI_IOC3_ETH_HW_TX_CSUM
 	 * MAC header which should not be summed and the TCP/UDP pseudo headers
 	 * manually.
 	 */
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		int proto = ntohs(skb->nh.iph->protocol);
 		unsigned int csoff;
 		struct iphdr *ih = skb->nh.iph;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 7bbd447..9405b44 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1232,7 +1232,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapte
 	unsigned int i;
 	uint8_t css, cso;
 
-	if(likely(skb->ip_summed == CHECKSUM_HW)) {
+	if(likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		css = skb->h.raw - skb->data;
 		cso = (skb->h.raw + skb->csum) - skb->data;
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 760c61b..2b5fd6b 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1145,7 +1145,7 @@ static void eth_tx_submit_descs_for_skb(
 	desc->byte_cnt = length;
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		BUG_ON(skb->protocol != ETH_P_IP);
 
 		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c3e52c8..c332ca3 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -934,7 +934,7 @@ static inline void myri10ge_vlan_ip_csum
 	    (vh->h_vlan_encapsulated_proto == htons(ETH_P_IP) ||
 	     vh->h_vlan_encapsulated_proto == htons(ETH_P_IPV6))) {
 		skb->csum = hw_csum;
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 }
 
@@ -977,7 +977,7 @@ myri10ge_rx_done(struct myri10ge_priv *m
 		if ((skb->protocol == ntohs(ETH_P_IP)) ||
 		    (skb->protocol == ntohs(ETH_P_IPV6))) {
 			skb->csum = ntohs((u16) csum);
-			skb->ip_summed = CHECKSUM_HW;
+			skb->ip_summed = CHECKSUM_COMPLETE;
 		} else
 			myri10ge_vlan_ip_csum(skb, ntohs((u16) csum));
 	}
@@ -1901,13 +1901,13 @@ #endif				/*NETIF_F_TSO */
 	pseudo_hdr_offset = 0;
 	odd_flag = 0;
 	flags = (MXGEFW_FLAGS_NO_TSO | MXGEFW_FLAGS_FIRST);
-	if (likely(skb->ip_summed == CHECKSUM_HW)) {
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		cksum_offset = (skb->h.raw - skb->data);
 		pseudo_hdr_offset = (skb->h.raw + skb->csum) - skb->data;
 		/* If the headers are excessively large, then we must
 		 * fall back to a software checksum */
 		if (unlikely(cksum_offset > 255 || pseudo_hdr_offset > 127)) {
-			if (skb_checksum_help(skb, 0))
+			if (skb_checksum_help(skb))
 				goto drop;
 			cksum_offset = 0;
 			pseudo_hdr_offset = 0;
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 0e76859..5143f5d 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1153,7 +1153,7 @@ again:
 	if (!nr_frags)
 		frag = NULL;
 	extsts = 0;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		extsts |= EXTSTS_IPPKT;
 		if (IPPROTO_TCP == skb->nh.iph->protocol)
 			extsts |= EXTSTS_TCPPKT;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4c2f575..d9b960a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2169,7 +2169,7 @@ static inline u32 rtl8169_tso_csum(struc
 		if (mss)
 			return LargeSend | ((mss & MSSMask) << MSSShift);
 	}
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const struct iphdr *ip = skb->nh.iph;
 
 		if (ip->protocol == IPPROTO_TCP)
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e1fe3a0..51ac031 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3871,7 +3871,7 @@ #ifdef NETIF_F_TSO
 		txdp->Control_1 |= TXD_TCP_LSO_MSS(mss);
 	}
 #endif
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		txdp->Control_2 |=
 		    (TXD_TX_CKO_IPV4_EN | TXD_TX_CKO_TCP_EN |
 		     TXD_TX_CKO_UDP_EN);
diff --git a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
index ee62845..eb3b351 100644
--- a/drivers/net/sk98lin/skge.c
+++ b/drivers/net/sk98lin/skge.c
@@ -1559,7 +1559,7 @@ #endif
 	pTxd->VDataHigh = (SK_U32) (PhysAddr >> 32);
 	pTxd->pMBuf     = pMessage;
 
-	if (pMessage->ip_summed == CHECKSUM_HW) {
+	if (pMessage->ip_summed == CHECKSUM_PARTIAL) {
 		u16 hdrlen = pMessage->h.raw - pMessage->data;
 		u16 offset = hdrlen + pMessage->csum;
 
@@ -1678,7 +1678,7 @@ #endif
 	/* 
 	** Does the HW need to evaluate checksum for TCP or UDP packets? 
 	*/
-	if (pMessage->ip_summed == CHECKSUM_HW) {
+	if (pMessage->ip_summed == CHECKSUM_PARTIAL) {
 		u16 hdrlen = pMessage->h.raw - pMessage->data;
 		u16 offset = hdrlen + pMessage->csum;
 
@@ -2158,7 +2158,7 @@ #endif
 
 #ifdef USE_SK_RX_CHECKSUM
 		pMsg->csum = pRxd->TcpSums & 0xffff;
-		pMsg->ip_summed = CHECKSUM_HW;
+		pMsg->ip_summed = CHECKSUM_COMPLETE;
 #else
 		pMsg->ip_summed = CHECKSUM_NONE;
 #endif
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 7de9a07..7b0331c 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2336,7 +2336,7 @@ static int skge_xmit_frame(struct sk_buf
 	td->dma_lo = map;
 	td->dma_hi = map >> 32;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		int offset = skb->h.raw - skb->data;
 
 		/* This seems backwards, but it is what the sk98lin
@@ -2640,7 +2640,7 @@ static inline struct sk_buff *skge_rx_ge
 	skb->dev = skge->netdev;
 	if (skge->rx_csum) {
 		skb->csum = csum;
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 
 	skb->protocol = eth_type_trans(skb, skge->netdev);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index de91609..e9568fc 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1164,7 +1164,7 @@ static unsigned tx_le_req(const struct s
 	if (skb_is_gso(skb))
 		++count;
 
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		++count;
 
 	return count;
@@ -1273,7 +1273,7 @@ #ifdef SKY2_VLAN_TAG_USED
 #endif
 
 	/* Handle TCP checksum offload */
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u16 hdr = skb->h.raw - skb->data;
 		u16 offset = hdr + skb->csum;
 
@@ -2001,7 +2001,7 @@ #ifdef SKY2_VLAN_TAG_USED
 #endif
 		case OP_RXCHKS:
 			skb = sky2->rx_ring[sky2->rx_next].skb;
-			skb->ip_summed = CHECKSUM_HW;
+			skb->ip_summed = CHECKSUM_COMPLETE;
 			skb->csum = le16_to_cpu(status);
 			break;
 
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index c0a62b0..2607aa5 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1230,7 +1230,7 @@ static int start_tx(struct sk_buff *skb,
 	}
 
 #if defined(ZEROCOPY) && defined(HAS_BROKEN_FIRMWARE)
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (skb_padto(skb, (skb->len + PADDING_MASK) & ~PADDING_MASK))
 			return NETDEV_TX_OK;
 	}
@@ -1252,7 +1252,7 @@ #endif /* ZEROCOPY && HAS_BROKEN_FIRMWAR
 				status |= TxDescIntr;
 				np->reap_tx = 0;
 			}
-			if (skb->ip_summed == CHECKSUM_HW) {
+			if (skb->ip_summed == CHECKSUM_PARTIAL) {
 				status |= TxCalTCP;
 				np->stats.tx_compressed++;
 			}
@@ -1499,7 +1499,7 @@ #endif
 		 * Until then, the printk stays. :-) -Ion
 		 */
 		else if (le16_to_cpu(desc->status2) & 0x0040) {
-			skb->ip_summed = CHECKSUM_HW;
+			skb->ip_summed = CHECKSUM_COMPLETE;
 			skb->csum = le16_to_cpu(desc->csum);
 			printk(KERN_DEBUG "%s: checksum_hw, status2 = %#x\n", dev->name, le16_to_cpu(desc->status2));
 		}
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index b70bbd7..ca9bae6 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -855,7 +855,7 @@ static int gem_rx(struct gem *gp, int wo
 		}
 
 		skb->csum = ntohs((status & RXDCTRL_TCPCSUM) ^ 0xffff);
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 		skb->protocol = eth_type_trans(skb, gp->dev);
 
 		netif_receive_skb(skb);
@@ -1026,7 +1026,7 @@ static int gem_start_xmit(struct sk_buff
 	unsigned long flags;
 
 	ctrl = 0;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u64 csum_start_off, csum_stuff_off;
 
 		csum_start_off = (u64) (skb->h.raw - skb->data);
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index c6f5bc3..17981da 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1207,7 +1207,7 @@ static void happy_meal_transceiver_check
  * flags, thus:
  *
  * 	skb->csum = rxd->rx_flags & 0xffff;
- * 	skb->ip_summed = CHECKSUM_HW;
+ * 	skb->ip_summed = CHECKSUM_COMPLETE;
  *
  * before sending off the skb to the protocols, and we are good as gold.
  */
@@ -2074,7 +2074,7 @@ static void happy_meal_rx(struct happy_m
 
 		/* This card is _fucking_ hot... */
 		skb->csum = ntohs(csum ^ 0xffff);
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 
 		RXD(("len=%d csum=%4x]", len, csum));
 		skb->protocol = eth_type_trans(skb, dev);
@@ -2268,7 +2268,7 @@ static int happy_meal_start_xmit(struct 
  	u32 tx_flags;
 
 	tx_flags = TXFLAG_OWN;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u32 csum_start_off, csum_stuff_off;
 
 		csum_start_off = (u32) (skb->h.raw - skb->data);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1b8138f..4ac610c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3841,11 +3841,11 @@ #if TG3_TSO_SUPPORT != 0
 		skb->h.th->check = 0;
 
 	}
-	else if (skb->ip_summed == CHECKSUM_HW)
+	else if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 #else
 	mss = 0;
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 #endif
 #if TG3_VLAN_TAG_USED
@@ -3973,7 +3973,7 @@ static int tg3_start_xmit_dma_bug(struct
 
 	entry = tp->tx_prod;
 	base_flags = 0;
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 #if TG3_TSO_SUPPORT != 0
 	mss = 0;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 4103c37..c6e601d 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -830,7 +830,7 @@ typhoon_start_tx(struct sk_buff *skb, st
 	first_txd->addrHi = (u64)((unsigned long) skb) >> 32;
 	first_txd->processFlags = 0;
 
-	if(skb->ip_summed == CHECKSUM_HW) {
+	if(skb->ip_summed == CHECKSUM_PARTIAL) {
 		/* The 3XP will figure out if this is UDP/TCP */
 		first_txd->processFlags |= TYPHOON_TX_PF_TCP_CHKSUM;
 		first_txd->processFlags |= TYPHOON_TX_PF_UDP_CHKSUM;
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index d3d0ec9..1394ca1 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1185,7 +1185,7 @@ static int rhine_start_tx(struct sk_buff
 	rp->tx_skbuff[entry] = skb;
 
 	if ((rp->quirks & rqRhineI) &&
-	    (((unsigned long)skb->data & 3) || skb_shinfo(skb)->nr_frags != 0 || skb->ip_summed == CHECKSUM_HW)) {
+	    (((unsigned long)skb->data & 3) || skb_shinfo(skb)->nr_frags != 0 || skb->ip_summed == CHECKSUM_PARTIAL)) {
 		/* Must use alignment buffer. */
 		if (skb->len > PKT_BUF_SZ) {
 			/* packet too long, drop it */
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index aa9cd92..f1e0c74 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2002,7 +2002,7 @@ #endif
 	 *	Handle hardware checksum
 	 */
 	if ((vptr->flags & VELOCITY_FLAGS_TX_CSUM)
-				 && (skb->ip_summed == CHECKSUM_HW)) {
+				 && (skb->ip_summed == CHECKSUM_PARTIAL)) {
 		struct iphdr *ip = skb->nh.iph;
 		if (ip->protocol == IPPROTO_TCP)
 			td_ptr->tdesc1.TCR |= TCR0_TCPCK;
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
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4307e76..b3bd0b1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -34,8 +34,9 @@ #define HAVE_ALLOC_SKB		/* For the drive
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
 
 #define CHECKSUM_NONE 0
-#define CHECKSUM_HW 1
+#define CHECKSUM_PARTIAL 1
 #define CHECKSUM_UNNECESSARY 2
+#define CHECKSUM_COMPLETE 3
 
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
@@ -56,17 +57,17 @@ #define SKB_MAX_ALLOC		(SKB_MAX_ORDER(0,
  *	      Apparently with secret goal to sell you new device, when you
  *	      will add new protocol to your host. F.e. IPv6. 8)
  *
- *	HW: the most generic way. Device supplied checksum of _all_
+ *	COMPLETE: the most generic way. Device supplied checksum of _all_
  *	    the packet as seen by netif_rx in skb->csum.
  *	    NOTE: Even if device supports only some protocols, but
- *	    is able to produce some skb->csum, it MUST use HW,
+ *	    is able to produce some skb->csum, it MUST use COMPLETE,
  *	    not UNNECESSARY.
  *
  * B. Checksumming on output.
  *
  *	NONE: skb is checksummed by protocol or csum is not required.
  *
- *	HW: device is required to csum packet as seen by hard_start_xmit
+ *	PARTIAL: device is required to csum packet as seen by hard_start_xmit
  *	from skb->h.raw to the end and to record the checksum
  *	at skb->h.raw+skb->csum.
  *
@@ -1219,14 +1220,14 @@ static inline int skb_linearize_cow(stru
  *	@len: length of data pulled
  *
  *	After doing a pull on a received packet, you need to call this to
- *	update the CHECKSUM_HW checksum, or set ip_summed to CHECKSUM_NONE
- *	so that it can be recomputed from scratch.
+ *	update the CHECKSUM_COMPLETE checksum, or set ip_summed to
+ *	CHECKSUM_NONE so that it can be recomputed from scratch.
  */
 
 static inline void skb_postpull_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
 {
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
 }
 
@@ -1245,7 +1246,7 @@ static inline int pskb_trim_rcsum(struct
 {
 	if (likely(len >= skb->len))
 		return 0;
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->ip_summed = CHECKSUM_NONE;
 	return __pskb_trim(skb, len);
 }
diff --git a/net/core/datagram.c b/net/core/datagram.c
index aecddcc..f558c61 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -417,7 +417,7 @@ unsigned int __skb_checksum_complete(str
 
 	sum = (u16)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum));
 	if (likely(!sum)) {
-		if (unlikely(skb->ip_summed == CHECKSUM_HW))
+		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
@@ -462,7 +462,7 @@ int skb_copy_and_csum_datagram_iovec(str
 			goto fault;
 		if ((unsigned short)csum_fold(csum))
 			goto csum_error;
-		if (unlikely(skb->ip_summed == CHECKSUM_HW))
+		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
 		iov->iov_len -= chunk;
 		iov->iov_base += chunk;
diff --git a/net/core/dev.c b/net/core/dev.c
index 4d2b516..528c5f3 100644
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
@@ -1445,11 +1445,11 @@ int dev_queue_xmit(struct sk_buff *skb)
 	/* If packet is not checksummed and device does not support
 	 * checksumming for this protocol, complete checksumming here.
 	 */
-	if (skb->ip_summed == CHECKSUM_HW &&
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    (!(dev->features & NETIF_F_GEN_CSUM) &&
 	     (!(dev->features & NETIF_F_IP_CSUM) ||
 	      skb->protocol != htons(ETH_P_IP))))
-	      	if (skb_checksum_help(skb, 0))
+	      	if (skb_checksum_help(skb))
 	      		goto out_kfree_skb;
 
 gso:
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 471da45..ead5920 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -110,7 +110,7 @@ static int checksum_udp(struct sk_buff *
 
 	psum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
 
-	if (skb->ip_summed == CHECKSUM_HW &&
+	if (skb->ip_summed == CHECKSUM_COMPLETE &&
 	    !(u16)csum_fold(csum_add(psum, skb->csum)))
 		return 0;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 476aa39..3a12ff1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1373,7 +1373,7 @@ void skb_copy_and_csum_dev(const struct 
 	unsigned int csum;
 	long csstart;
 
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		csstart = skb->h.raw - skb->data;
 	else
 		csstart = skb_headlen(skb);
@@ -1387,7 +1387,7 @@ void skb_copy_and_csum_dev(const struct 
 		csum = skb_copy_and_csum_bits(skb, csstart, to + csstart,
 					      skb->len - csstart, 0);
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		long csstuff = csstart + skb->csum;
 
 		*((unsigned short *)(to + csstuff)) = csum_fold(csum);
@@ -1874,10 +1874,10 @@ int skb_append_datato_frags(struct sock 
  *	@len: length of data pulled
  *
  *	This function performs an skb_pull on the packet and updates
- *	update the CHECKSUM_HW checksum.  It should be used on receive
- *	path processing instead of skb_pull unless you know that the
- *	checksum difference is zero (e.g., a valid IP header) or you
- *	are setting ip_summed to CHECKSUM_NONE.
+ *	update the CHECKSUM_COMPLETE checksum.  It should be used on
+ *	receive path processing instead of skb_pull unless you know
+ *	that the checksum difference is zero (e.g., a valid IP header)
+ *	or you are setting ip_summed to CHECKSUM_NONE.
  */
 unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len)
 {
@@ -1970,7 +1970,7 @@ struct sk_buff *skb_segment(struct sk_bu
 		frag = skb_shinfo(nskb)->frags;
 		k = 0;
 
-		nskb->ip_summed = CHECKSUM_HW;
+		nskb->ip_summed = CHECKSUM_PARTIAL;
 		nskb->csum = skb->csum;
 		memcpy(skb_put(nskb, hsize), skb->data + offset, hsize);
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4c86ac3..40a60bb 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -928,7 +928,7 @@ int icmp_rcv(struct sk_buff *skb)
 	ICMP_INC_STATS_BH(ICMP_MIB_INMSGS);
 
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (!(u16)csum_fold(skb->csum))
 			break;
 		/* fall through */
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 9f4b752..f84c4d0 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -931,7 +931,7 @@ int igmp_rcv(struct sk_buff *skb)
 		goto drop;
 
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (!(u16)csum_fold(skb->csum))
 			break;
 		/* fall through */
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b84b53a..8d7f107 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -665,7 +665,7 @@ static struct sk_buff *ip_frag_reasm(str
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
 			head->ip_summed = CHECKSUM_NONE;
-		else if (head->ip_summed == CHECKSUM_HW)
+		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
 		atomic_sub(fp->truesize, &ip_frag_mem);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0f9b3a3..e66f6ff 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -576,7 +576,7 @@ static int ipgre_rcv(struct sk_buff *skb
 
 		if (flags&GRE_CSUM) {
 			switch (skb->ip_summed) {
-			case CHECKSUM_HW:
+			case CHECKSUM_COMPLETE:
 				csum = (u16)csum_fold(skb->csum);
 				if (!csum)
 					break;
@@ -584,7 +584,7 @@ static int ipgre_rcv(struct sk_buff *skb
 			case CHECKSUM_NONE:
 				skb->csum = 0;
 				csum = __skb_checksum_complete(skb);
-				skb->ip_summed = CHECKSUM_HW;
+				skb->ip_summed = CHECKSUM_COMPLETE;
 			}
 			offset += 4;
 		}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7c9f9a6..543eb6d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -677,7 +677,7 @@ ip_generic_getfrag(void *from, char *to,
 {
 	struct iovec *iov = from;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (memcpy_fromiovecend(to, iov, offset, len) < 0)
 			return -EFAULT;
 	} else {
@@ -733,7 +733,7 @@ static inline int ip_ufo_append_data(str
 		/* initialize protocol header pointer */
 		skb->h.raw = skb->data + fragheaderlen;
 
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 		sk->sk_sndmsg_off = 0;
 	}
@@ -841,7 +841,7 @@ int ip_append_data(struct sock *sk,
 	    length + fragheaderlen <= mtu &&
 	    rt->u.dst.dev->features & NETIF_F_ALL_CSUM &&
 	    !exthdrlen)
-		csummode = CHECKSUM_HW;
+		csummode = CHECKSUM_PARTIAL;
 
 	inet->cork.length += length;
 	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index bc28b11..820e831 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -151,7 +151,7 @@ tcp_snat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(tcph, cp->daddr, cp->vaddr,
 				     cp->dport, cp->vport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
+		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
 			(*pskb)->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -204,7 +204,7 @@ tcp_dnat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(tcph, cp->vaddr, cp->daddr,
 				     cp->vport, cp->dport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
+		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
 			(*pskb)->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -229,7 +229,7 @@ tcp_csum_check(struct sk_buff *skb, stru
 	switch (skb->ip_summed) {
 	case CHECKSUM_NONE:
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (csum_tcpudp_magic(skb->nh.iph->saddr, skb->nh.iph->daddr,
 				      skb->len - tcphoff,
 				      skb->nh.iph->protocol, skb->csum)) {
@@ -239,7 +239,7 @@ tcp_csum_check(struct sk_buff *skb, stru
 		}
 		break;
 	default:
-		/* CHECKSUM_UNNECESSARY */
+		/* No need to checksum. */
 		break;
 	}
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 89d9175..90c8166 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -161,7 +161,7 @@ udp_snat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(udph, cp->daddr, cp->vaddr,
 				     cp->dport, cp->vport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
+		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
 			(*pskb)->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -216,7 +216,7 @@ udp_dnat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(udph, cp->vaddr, cp->daddr,
 				     cp->vport, cp->dport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
+		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
 			(*pskb)->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -250,7 +250,7 @@ udp_csum_check(struct sk_buff *skb, stru
 		case CHECKSUM_NONE:
 			skb->csum = skb_checksum(skb, udphoff,
 						 skb->len - udphoff, 0);
-		case CHECKSUM_HW:
+		case CHECKSUM_COMPLETE:
 			if (csum_tcpudp_magic(skb->nh.iph->saddr,
 					      skb->nh.iph->daddr,
 					      skb->len - udphoff,
@@ -262,7 +262,7 @@ udp_csum_check(struct sk_buff *skb, stru
 			}
 			break;
 		default:
-			/* CHECKSUM_UNNECESSARY */
+			/* No need to checksum. */
 			break;
 		}
 	}
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 6a9e34b..f88347d 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -168,7 +168,7 @@ unsigned int nf_ip_checksum(struct sk_bu
 	unsigned int csum = 0;
 
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (hook != NF_IP_PRE_ROUTING && hook != NF_IP_LOCAL_IN)
 			break;
 		if ((protocol == 0 && !(u16)csum_fold(skb->csum)) ||
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
index fb920e7..9de81ff 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -865,8 +865,7 @@ static int tcp_error(struct sk_buff *skb
   
 	/* Checksum invalid? Ignore.
 	 * We skip checking packets on the outgoing path
-	 * because the semantic of CHECKSUM_HW is different there 
-	 * and moreover root might send raw packets.
+	 * because it is assumed to be correct.
 	 */
 	/* FIXME: Source route IP option packets --RR */
 	if (ip_conntrack_checksum && hooknum == NF_IP_PRE_ROUTING &&
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_udp.c b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
index 9b2c16b..e58e52f 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_udp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
@@ -117,8 +117,7 @@ static int udp_error(struct sk_buff *skb
 
 	/* Checksum invalid? Ignore.
 	 * We skip checking packets on the outgoing path
-	 * because the semantic of CHECKSUM_HW is different there 
-	 * and moreover root might send raw packets.
+	 * because the checksum is assumed to be correct.
 	 * FIXME: Source route IP option packets --RR */
 	if (ip_conntrack_checksum && hooknum == NF_IP_PRE_ROUTING &&
 	    nf_ip_checksum(skb, hooknum, iph->ihl * 4, IPPROTO_UDP)) {
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index 17de077..f4f00c8 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -111,8 +111,9 @@ ip_nat_fn(unsigned int hooknum,
 		       & htons(IP_MF|IP_OFFSET)));
 
 	/* If we had a hardware checksum before, it's now invalid */
-	if ((*pskb)->ip_summed == CHECKSUM_HW)
-		if (skb_checksum_help(*pskb, (out == NULL)))
+	if ((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
+	    (*pskb)->ip_summed == CHECKSUM_COMPLETE)
+		if (skb_checksum_help(*pskb))
 			return NF_DROP;
 
 	ct = ip_conntrack_get(*pskb, &ctinfo);
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 198ac36..276a964 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -208,9 +208,9 @@ ipq_build_packet_message(struct ipq_queu
 		break;
 	
 	case IPQ_COPY_PACKET:
-		if (entry->skb->ip_summed == CHECKSUM_HW &&
-		    (*errp = skb_checksum_help(entry->skb,
-		                               entry->info->outdev == NULL))) {
+		if ((entry->skb->ip_summed == CHECKSUM_PARTIAL ||
+		     entry->skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    (*errp = skb_checksum_help(entry->skb))) {
 			read_unlock_bh(&queue_lock);
 			return NULL;
 		}
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 4adf5c9..4ec43f9 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -49,7 +49,7 @@ set_ect_ip(struct sk_buff **pskb, const 
 
 /* Return 0 if there was an error. */
 static inline int
-set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo, int inward)
+set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
 {
 	struct tcphdr _tcph, *tcph;
 	u_int16_t diffs[2];
@@ -70,8 +70,9 @@ set_ect_tcp(struct sk_buff **pskb, const
 		return 0;
 	tcph = (void *)(*pskb)->nh.iph + (*pskb)->nh.iph->ihl*4;
 
-	if ((*pskb)->ip_summed == CHECKSUM_HW &&
-	    skb_checksum_help(*pskb, inward))
+	if (((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
+	     (*pskb)->ip_summed == CHECKSUM_COMPLETE) &&
+	    skb_checksum_help(*pskb))
 		return 0;
 
 	diffs[0] = ((u_int16_t *)tcph)[6];
@@ -106,7 +107,7 @@ target(struct sk_buff **pskb,
 
 	if (einfo->operation & (IPT_ECN_OP_SET_ECE | IPT_ECN_OP_SET_CWR)
 	    && (*pskb)->nh.iph->protocol == IPPROTO_TCP)
-		if (!set_ect_tcp(pskb, einfo, (out == NULL)))
+		if (!set_ect_tcp(pskb, einfo))
 			return NF_DROP;
 
 	return IPT_CONTINUE;
diff --git a/net/ipv4/netfilter/ipt_TCPMSS.c b/net/ipv4/netfilter/ipt_TCPMSS.c
index ef2fe5b..c998dc0 100644
--- a/net/ipv4/netfilter/ipt_TCPMSS.c
+++ b/net/ipv4/netfilter/ipt_TCPMSS.c
@@ -62,8 +62,9 @@ ipt_tcpmss_target(struct sk_buff **pskb,
 	if (!skb_make_writable(pskb, (*pskb)->len))
 		return NF_DROP;
 
-	if ((*pskb)->ip_summed == CHECKSUM_HW &&
-	    skb_checksum_help(*pskb, out == NULL))
+	if (((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
+	     (*pskb)->ip_summed == CHECKSUM_COMPLETE) &&
+	    skb_checksum_help(*pskb))
 		return NF_DROP;
 
 	iph = (*pskb)->nh.iph;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f6a2d92..c452373 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -568,7 +568,7 @@ new_segment:
 		skb->truesize += copy;
 		sk->sk_wmem_queued += copy;
 		sk->sk_forward_alloc -= copy;
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
 		skb_shinfo(skb)->gso_segs = 0;
@@ -723,7 +723,7 @@ new_segment:
 				 * Check whether we can use HW checksum.
 				 */
 				if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
-					skb->ip_summed = CHECKSUM_HW;
+					skb->ip_summed = CHECKSUM_PARTIAL;
 
 				skb_entail(sk, tp, skb);
 				copy = size_goal;
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
index f6f39e8..be056d1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -485,7 +485,7 @@ void tcp_v4_send_check(struct sock *sk, 
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcphdr *th = skb->h.th;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		th->check = ~tcp_v4_check(th, len, inet->saddr, inet->daddr, 0);
 		skb->csum = offsetof(struct tcphdr, check);
 	} else {
@@ -510,7 +510,7 @@ int tcp_v4_gso_send_check(struct sk_buff
 	th->check = 0;
 	th->check = ~tcp_v4_check(th, skb->len, iph->saddr, iph->daddr, 0);
 	skb->csum = offsetof(struct tcphdr, check);
-	skb->ip_summed = CHECKSUM_HW;
+	skb->ip_summed = CHECKSUM_PARTIAL;
 	return 0;
 }
 
@@ -972,7 +972,7 @@ #endif
 
 static int tcp_v4_checksum_init(struct sk_buff *skb)
 {
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (!tcp_v4_check(skb->h.th, skb->len, skb->nh.iph->saddr,
 				  skb->nh.iph->daddr, skb->csum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5c08ea2..e89cb52 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -575,7 +575,7 @@ int tcp_fragment(struct sock *sk, struct
 	TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
 	TCP_SKB_CB(skb)->sacked &= ~TCPCB_AT_TAIL;
 
-	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_HW) {
+	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_PARTIAL) {
 		/* Copy and checksum data tail into the new buffer. */
 		buff->csum = csum_partial_copy_nocheck(skb->data + len, skb_put(buff, nsize),
 						       nsize, 0);
@@ -584,7 +584,7 @@ int tcp_fragment(struct sock *sk, struct
 
 		skb->csum = csum_block_sub(skb->csum, buff->csum, len);
 	} else {
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb_split(skb, buff, len);
 	}
 
@@ -687,7 +687,7 @@ int tcp_trim_head(struct sock *sk, struc
 		__pskb_trim_head(skb, len - skb_headlen(skb));
 
 	TCP_SKB_CB(skb)->seq += len;
-	skb->ip_summed = CHECKSUM_HW;
+	skb->ip_summed = CHECKSUM_PARTIAL;
 
 	skb->truesize	     -= len;
 	sk->sk_wmem_queued   -= len;
@@ -1060,7 +1060,7 @@ static int tso_fragment(struct sock *sk,
 	/* This packet was never sent out yet, so no SACK bits. */
 	TCP_SKB_CB(buff)->sacked = 0;
 
-	buff->ip_summed = skb->ip_summed = CHECKSUM_HW;
+	buff->ip_summed = skb->ip_summed = CHECKSUM_PARTIAL;
 	skb_split(skb, buff, len);
 
 	/* Fix up tso_factor for both original and new SKB.  */
@@ -1204,8 +1204,7 @@ static int tcp_mtu_probe(struct sock *sk
 	TCP_SKB_CB(nskb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(nskb)->sacked = 0;
 	nskb->csum = 0;
-	if (skb->ip_summed == CHECKSUM_HW)
-		nskb->ip_summed = CHECKSUM_HW;
+	nskb->ip_summed = skb->ip_summed;
 
 	len = 0;
 	while (len < probe_size) {
@@ -1229,7 +1228,7 @@ static int tcp_mtu_probe(struct sock *sk
 			                           ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
 			if (!skb_shinfo(skb)->nr_frags) {
 				skb_pull(skb, copy);
-				if (skb->ip_summed != CHECKSUM_HW)
+				if (skb->ip_summed != CHECKSUM_PARTIAL)
 					skb->csum = csum_partial(skb->data, skb->len, 0);
 			} else {
 				__pskb_trim_head(skb, copy);
@@ -1570,10 +1569,9 @@ static void tcp_retrans_try_collapse(str
 
 		memcpy(skb_put(skb, next_skb_size), next_skb->data, next_skb_size);
 
-		if (next_skb->ip_summed == CHECKSUM_HW)
-			skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = next_skb->ip_summed;
 
-		if (skb->ip_summed != CHECKSUM_HW)
+		if (skb->ip_summed != CHECKSUM_PARTIAL)
 			skb->csum = csum_block_add(skb->csum, next_skb->csum, skb_size);
 
 		/* Update sequence range on original skb. */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f136cec..25d5534 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -429,7 +429,7 @@ static int udp_push_pending_frames(struc
 		/*
 		 * Only one fragment on the socket.
 		 */
-		if (skb->ip_summed == CHECKSUM_HW) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			skb->csum = offsetof(struct udphdr, check);
 			uh->check = ~csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst,
 					up->len, IPPROTO_UDP, 0);
@@ -448,7 +448,7 @@ static int udp_push_pending_frames(struc
 		 * fragments on the socket so that all csums of sk_buffs
 		 * should be together.
 		 */
-		if (skb->ip_summed == CHECKSUM_HW) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			int offset = (unsigned char *)uh - skb->data;
 			skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
 
@@ -1087,7 +1087,7 @@ static void udp_checksum_init(struct sk_
 {
 	if (uh->check == 0) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else if (skb->ip_summed == CHECKSUM_HW) {
+	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (!udp_check(uh, ulen, saddr, daddr, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index d16f863..4a96a9e 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -48,8 +48,8 @@ static int xfrm4_output_one(struct sk_bu
 	struct xfrm_state *x = dst->xfrm;
 	int err;
 	
-	if (skb->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(skb, 0);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
 		if (err)
 			goto error_nolock;
 	}
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 9d0ee7f..fe3f737 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -294,7 +294,7 @@ looped_back:
 		hdr = (struct ipv6_rt_hdr *) skb2->h.raw;
 	}
 
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->ip_summed = CHECKSUM_NONE;
 
 	i = n - --hdr->segments_left;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 1044b6f..3e795c4 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -604,7 +604,7 @@ static int icmpv6_rcv(struct sk_buff **p
 
 	/* Perform checksum. */
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (!csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_ICMPV6,
 				     skb->csum))
 			break;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3bc74ce..56a0093 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -821,7 +821,7 @@ static inline int ip6_ufo_append_data(st
 		/* initialize protocol header pointer */
 		skb->h.raw = skb->data + fragheaderlen;
 
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 		sk->sk_sndmsg_off = 0;
 	}
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 395a417..580b1ab 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -87,7 +87,7 @@ unsigned int nf_ip6_checksum(struct sk_b
 	unsigned int csum = 0;
 
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (hook != NF_IP6_PRE_ROUTING && hook != NF_IP6_LOCAL_IN)
 			break;
 		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 968a14b..c01c126 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -206,9 +206,9 @@ ipq_build_packet_message(struct ipq_queu
 		break;
 	
 	case IPQ_COPY_PACKET:
-		if (entry->skb->ip_summed == CHECKSUM_HW &&
-		    (*errp = skb_checksum_help(entry->skb,
-		                               entry->info->outdev == NULL))) {
+		if ((entry->skb->ip_summed == CHECKSUM_PARTIAL ||
+		     entry->skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    (*errp = skb_checksum_help(entry->skb))) {
 			read_unlock_bh(&queue_lock);
 			return NULL;
 		}
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 00d5583..7a4e4c2 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -408,7 +408,7 @@ static int nf_ct_frag6_queue(struct nf_c
  		return -1;
 	}
 
- 	if (skb->ip_summed == CHECKSUM_HW)
+ 	if (skb->ip_summed == CHECKSUM_COMPLETE)
  		skb->csum = csum_sub(skb->csum,
  				     csum_partial(skb->nh.raw,
 						  (u8*)(fhdr + 1) - skb->nh.raw,
@@ -640,7 +640,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_que
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
 			head->ip_summed = CHECKSUM_NONE;
-		else if (head->ip_summed == CHECKSUM_HW)
+		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
 		atomic_sub(fp->truesize, &nf_ct_frag6_mem);
@@ -652,7 +652,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_que
 	head->nh.ipv6h->payload_len = htons(payload_len);
 
 	/* Yes, and fold redundant checksum back. 8) */
-	if (head->ip_summed == CHECKSUM_HW)
+	if (head->ip_summed == CHECKSUM_COMPLETE)
 		head->csum = csum_partial(head->nh.raw, head->h.raw-head->nh.raw, head->csum);
 
 	fq->fragments = NULL;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d57e61c..1fdc6ed 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -334,7 +334,7 @@ int rawv6_rcv(struct sock *sk, struct sk
 	if (!rp->checksum)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		skb_postpull_rcsum(skb, skb->nh.raw,
 		                   skb->h.raw - skb->nh.raw);
 		if (!csum_ipv6_magic(&skb->nh.ipv6h->saddr,
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 4e299c6..a8623d2 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -433,7 +433,7 @@ static void ip6_frag_queue(struct frag_q
  		return;
 	}
 
- 	if (skb->ip_summed == CHECKSUM_HW)
+ 	if (skb->ip_summed == CHECKSUM_COMPLETE)
  		skb->csum = csum_sub(skb->csum,
  				     csum_partial(skb->nh.raw, (u8*)(fhdr+1)-skb->nh.raw, 0));
 
@@ -647,7 +647,7 @@ static int ip6_frag_reasm(struct frag_qu
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
 			head->ip_summed = CHECKSUM_NONE;
-		else if (head->ip_summed == CHECKSUM_HW)
+		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
 		atomic_sub(fp->truesize, &ip6_frag_mem);
@@ -662,7 +662,7 @@ static int ip6_frag_reasm(struct frag_qu
 	*skb_in = head;
 
 	/* Yes, and fold redundant checksum back. 8) */
-	if (head->ip_summed == CHECKSUM_HW)
+	if (head->ip_summed == CHECKSUM_COMPLETE)
 		head->csum = csum_partial(head->nh.raw, head->h.raw-head->nh.raw, head->csum);
 
 	IP6_INC_STATS_BH(IPSTATS_MIB_REASMOKS);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 923989d..f32bddf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -542,7 +542,7 @@ static void tcp_v6_send_check(struct soc
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcphdr *th = skb->h.th;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		th->check = ~csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,  0);
 		skb->csum = offsetof(struct tcphdr, check);
 	} else {
@@ -567,7 +567,7 @@ static int tcp_v6_gso_send_check(struct 
 	th->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
 				     IPPROTO_TCP, 0);
 	skb->csum = offsetof(struct tcphdr, check);
-	skb->ip_summed = CHECKSUM_HW;
+	skb->ip_summed = CHECKSUM_PARTIAL;
 	return 0;
 }
 
@@ -1026,7 +1026,7 @@ out:
 
 static int tcp_v6_checksum_init(struct sk_buff *skb)
 {
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (!tcp_v6_check(skb->h.th,skb->len,&skb->nh.ipv6h->saddr,
 				  &skb->nh.ipv6h->daddr,skb->csum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index ccc57f4..a23faf3 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -475,7 +475,7 @@ static int udpv6_rcv(struct sk_buff **ps
 		uh = skb->h.uh;
 	}
 
-	if (skb->ip_summed == CHECKSUM_HW &&
+	if (skb->ip_summed == CHECKSUM_COMPLETE &&
 	    !csum_ipv6_magic(saddr, daddr, ulen, IPPROTO_UDP, skb->csum))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 0eea60e..e0ebb2c 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -41,8 +41,8 @@ static int xfrm6_output_one(struct sk_bu
 	struct xfrm_state *x = dst->xfrm;
 	int err;
 	
-	if (skb->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(skb, 0);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
 		if (err)
 			goto error_nolock;
 	}
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index af8adcb..308d2ab 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -823,8 +823,7 @@ static int tcp_error(struct sk_buff *skb
   
 	/* Checksum invalid? Ignore.
 	 * We skip checking packets on the outgoing path
-	 * because the semantic of CHECKSUM_HW is different there 
-	 * and moreover root might send raw packets.
+	 * because the checksum is assumed to be correct.
 	 */
 	/* FIXME: Source route IP option packets --RR */
 	if (nf_conntrack_checksum &&
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index ae07ebe..d36e031 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -131,8 +131,7 @@ static int udp_error(struct sk_buff *skb
 
 	/* Checksum invalid? Ignore.
 	 * We skip checking packets on the outgoing path
-	 * because the semantic of CHECKSUM_HW is different there
-	 * and moreover root might send raw packets.
+	 * because the checksum is assumed to be correct.
 	 * FIXME: Source route IP option packets --RR */
 	if (nf_conntrack_checksum &&
 	    ((pf == PF_INET && hooknum == NF_IP_PRE_ROUTING) ||
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 49ef41e..eddfbe4 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -377,9 +377,9 @@ #endif
 		break;
 	
 	case NFQNL_COPY_PACKET:
-		if (entskb->ip_summed == CHECKSUM_HW &&
-		    (*errp = skb_checksum_help(entskb,
-		                               outdev == NULL))) {
+		if ((entskb->ip_summed == CHECKSUM_PARTIAL ||
+		     entskb->ip_summed == CHECKSUM_COMPLETE) &&
+		    (*errp = skb_checksum_help(entskb))) {
 			spin_unlock_bh(&queue->lock);
 			return NULL;
 		}
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f9cef36..0492e83 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -586,7 +586,7 @@ static int tpacket_rcv(struct sk_buff *s
 		else if (skb->pkt_type == PACKET_OUTGOING) {
 			/* Special case: outgoing packets have ll header at head */
 			skb_pull(skb, skb->nh.raw - skb->data);
-			if (skb->ip_summed == CHECKSUM_HW)
+			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				status |= TP_STATUS_CSUMNOTREADY;
 		}
 	}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a08ec4c..45939ba 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -192,8 +192,8 @@ static int netem_enqueue(struct sk_buff 
 	 */
 	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
 		if (!(skb = skb_unshare(skb, GFP_ATOMIC))
-		    || (skb->ip_summed == CHECKSUM_HW
-			&& skb_checksum_help(skb, 0))) {
+		    || (skb->ip_summed == CHECKSUM_PARTIAL
+			&& skb_checksum_help(skb))) {
 			sch->qstats.drops++;
 			return NET_XMIT_DROP;
 		}
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index eb330d4..6f17527 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -168,7 +168,7 @@ int csum_partial_copy_to_xdr(struct xdr_
 		return -1;
 	if ((unsigned short)csum_fold(desc.csum))
 		return -1;
-	if (unlikely(skb->ip_summed == CHECKSUM_HW))
+	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 		netdev_rx_csum_fault(skb->dev);
 	return 0;
 no_checksum:

--------------000305020700010904060704
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NETFILTER]: Get rid of HW checksum invalidation

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit cb08da5c018d0b982bfc59572e3cf5f4c64c99db
tree 06fb5ddac5b638b19f1c1a98311ac93c98996089
parent 9e8ee86180aab5a225832c9772b2ad0e8a5c6006
author Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 20:30:58 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 20:30:58 +0200

 include/linux/netfilter.h                  |    6 +++
 include/linux/netfilter_ipv4/ip_nat_core.h |    8 ++--
 net/ipv4/netfilter/ip_nat_core.c           |   32 ++++++++-------
 net/ipv4/netfilter/ip_nat_helper.c         |   59 +++++++++++++++++++---------
 net/ipv4/netfilter/ip_nat_proto_gre.c      |    5 +-
 net/ipv4/netfilter/ip_nat_proto_icmp.c     |    8 ++--
 net/ipv4/netfilter/ip_nat_proto_tcp.c      |    7 +--
 net/ipv4/netfilter/ip_nat_proto_udp.c      |   15 +++++--
 net/ipv4/netfilter/ip_nat_standalone.c     |   10 +----
 net/ipv4/netfilter/ipt_ECN.c               |   19 +++------
 net/ipv4/netfilter/ipt_REJECT.c            |    1 
 net/ipv4/netfilter/ipt_TCPMSS.c            |   39 ++++++++-----------
 net/netfilter/core.c                       |   23 +++++++++++
 13 files changed, 135 insertions(+), 97 deletions(-)

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
index 1741d55..411e63f 100644
--- a/net/ipv4/netfilter/ip_nat_core.c
+++ b/net/ipv4/netfilter/ip_nat_core.c
@@ -423,10 +423,10 @@ unsigned int ip_nat_packet(struct ip_con
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
@@ -434,7 +434,9 @@ int ip_nat_icmp_reply_translation(struct
 	} *inside;
 	struct ip_conntrack_tuple inner, target;
 	int hdrlen = (*pskb)->nh.iph->ihl * 4;
+	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	unsigned long statusbit;
+	enum ip_nat_manip_type manip = HOOK2MANIP(hooknum);
 
 	if (!skb_make_writable(pskb, hdrlen + sizeof(*inside)))
 		return 0;
@@ -443,12 +445,8 @@ int ip_nat_icmp_reply_translation(struct
 
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
@@ -487,12 +485,14 @@ int ip_nat_icmp_reply_translation(struct
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
index cbcaa45..7584172 100644
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

--------------000305020700010904060704
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
commit e4288dc06646aee0f112fd4aa7a9cca4f3a96e82
tree efc1e2e9d79a45488f2227933294430ea204644a
parent cb08da5c018d0b982bfc59572e3cf5f4c64c99db
author Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 20:31:29 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 31 Jul 2006 20:31:29 +0200

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
index 662a869..df1f4e5 100644
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
+			kfree_skb(segs);
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

--------------000305020700010904060704--
