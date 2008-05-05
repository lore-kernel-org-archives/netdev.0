From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] arcnet: use netstats in net_device structure
Date: Tue, 06 May 2008 01:28:16 +0300
Message-ID: <481F8A00.5030904@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020404050105020306070906"
Cc: apenwarr@worldvisions.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:50920 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754342AbYEEW2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 18:28:31 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jt9AY-0007kx-6c
	for netdev@vger.kernel.org; Mon, 05 May 2008 22:28:26 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 22:28:26 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 22:28:26 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020404050105020306070906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Kill arcnet_get_stats function, because by default it is used
identical internal_stats function from net/core/dev.c

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------020404050105020306070906
Content-Type: text/x-patch;
 name="arcnet_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="arcnet_netstats.patch"

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index e0a18e7..7fcbbf6 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -102,7 +102,7 @@ static void rx(struct net_device *dev, int bufnum,
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (skb == NULL) {
 		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_put(skb, length + ARC_HDR_SIZE);
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index bdc4c0b..9b1f2b5 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -105,7 +105,6 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 			 unsigned short type, const void *daddr,
 			 const void *saddr, unsigned len);
 static int arcnet_rebuild_header(struct sk_buff *skb);
-static struct net_device_stats *arcnet_get_stats(struct net_device *dev);
 static int go_tx(struct net_device *dev);
 
 static int debug = ARCNET_DEBUG;
@@ -347,7 +346,6 @@ static void arcdev_setup(struct net_device *dev)
 	dev->stop = arcnet_close;
 	dev->hard_start_xmit = arcnet_send_packet;
 	dev->tx_timeout = arcnet_timeout;
-	dev->get_stats = arcnet_get_stats;
 }
 
 struct net_device *alloc_arcdev(char *name)
@@ -583,8 +581,8 @@ static int arcnet_rebuild_header(struct sk_buff *skb)
 	} else {
 		BUGMSG(D_NORMAL,
 		       "I don't understand ethernet protocol %Xh addresses!\n", type);
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 	}
 
 	/* if we couldn't resolve the address... give up. */
@@ -645,7 +643,7 @@ static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 		    !proto->ack_tx) {
 			/* done right away and we don't want to acknowledge
 			   the package later - forget about it now */
-			lp->stats.tx_bytes += skb->len;
+			dev->stats.tx_bytes += skb->len;
 			freeskb = 1;
 		} else {
 			/* do it the 'split' way */
@@ -709,7 +707,7 @@ static int go_tx(struct net_device *dev)
 	/* start sending */
 	ACOMMAND(TXcmd | (lp->cur_tx << 3));
 
-	lp->stats.tx_packets++;
+	dev->stats.tx_packets++;
 	lp->lasttrans_dest = lp->lastload_dest;
 	lp->lastload_dest = 0;
 	lp->excnak_pending = 0;
@@ -732,11 +730,11 @@ static void arcnet_timeout(struct net_device *dev)
 		msg = " - missed IRQ?";
 	} else {
 		msg = "";
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_aborted_errors++;
 		lp->timed_out = 1;
 		ACOMMAND(NOTXcmd | (lp->cur_tx << 3));
 	}
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	/* make sure we didn't miss a TX or a EXC NAK IRQ */
 	AINTMASK(0);
@@ -865,8 +863,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 						       "transmit was not acknowledged! "
 						       "(status=%Xh, dest=%02Xh)\n",
 						       status, lp->lasttrans_dest);
-						lp->stats.tx_errors++;
-						lp->stats.tx_carrier_errors++;
+						dev->stats.tx_errors++;
+						dev->stats.tx_carrier_errors++;
 					} else {
 						BUGMSG(D_DURING,
 						       "broadcast was not acknowledged; that's normal "
@@ -905,7 +903,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 				if (txbuf != -1) {
 					if (lp->outgoing.proto->continue_tx(dev, txbuf)) {
 						/* that was the last segment */
-						lp->stats.tx_bytes += lp->outgoing.skb->len;
+						dev->stats.tx_bytes += lp->outgoing.skb->len;
 						if(!lp->outgoing.proto->ack_tx)
 						  {
 						    dev_kfree_skb_irq(lp->outgoing.skb);
@@ -930,7 +928,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		}
 		if (status & lp->intmask & RECONflag) {
 			ACOMMAND(CFLAGScmd | CONFIGclear);
-			lp->stats.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 
 			BUGMSG(D_RECON, "Network reconfiguration detected (status=%Xh)\n",
 			       status);
@@ -1038,8 +1036,8 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 	       "(%d+4 bytes)\n",
 	       bufnum, pkt.hard.source, pkt.hard.dest, length);
 
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += length + ARC_HDR_SIZE;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += length + ARC_HDR_SIZE;
 
 	/* call the right receiver for the protocol */
 	if (arc_proto_map[soft->proto]->is_ip) {
@@ -1067,18 +1065,6 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 }
 
 
-
-/* 
- * Get the current statistics.  This may be called with the card open or
- * closed.
- */
-static struct net_device_stats *arcnet_get_stats(struct net_device *dev)
-{
-	struct arcnet_local *lp = dev->priv;
-	return &lp->stats;
-}
-
-
 static void null_rx(struct net_device *dev, int bufnum,
 		    struct archdr *pkthdr, int length)
 {
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 02cb8f1..a8520ee 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -119,7 +119,7 @@ static void rx(struct net_device *dev, int bufnum,
 	skb = alloc_skb(length + ARC_HDR_SIZE + sizeof(int), GFP_ATOMIC);
 	if (skb == NULL) {
 		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_put(skb, length + ARC_HDR_SIZE + sizeof(int));
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index dab185b..eabdaa1 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -88,7 +88,6 @@ MODULE_LICENSE("GPL");
  */
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
@@ -112,8 +111,8 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 		return htons(ETH_P_ARP);
 
 	default:
-		lp->stats.rx_errors++;
-		lp->stats.rx_crc_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_crc_errors++;
 		return 0;
 	}
 
@@ -140,7 +139,7 @@ static void rx(struct net_device *dev, int bufnum,
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (skb == NULL) {
 		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_put(skb, length + ARC_HDR_SIZE);
@@ -169,7 +168,6 @@ static void rx(struct net_device *dev, int bufnum,
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
@@ -185,8 +183,8 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	default:
 		BUGMSG(D_NORMAL, "RFC1051: I don't understand protocol %d (%Xh)\n",
 		       type, type);
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 		return 0;
 	}
 
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 6d6d95c..cdc537a 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -92,7 +92,6 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
-	struct arcnet_local *lp = dev->priv;
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
@@ -121,8 +120,8 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 	case ARC_P_NOVELL_EC:
 		return htons(ETH_P_802_3);
 	default:
-		lp->stats.rx_errors++;
-		lp->stats.rx_crc_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_crc_errors++;
 		return 0;
 	}
 
@@ -172,8 +171,8 @@ static void rx(struct net_device *dev, int bufnum,
 			 in->sequence, soft->split_flag, soft->sequence);
 			lp->rfc1201.aborted_seq = soft->sequence;
 			dev_kfree_skb_irq(in->skb);
-			lp->stats.rx_errors++;
-			lp->stats.rx_missed_errors++;
+			dev->stats.rx_errors++;
+			dev->stats.rx_missed_errors++;
 			in->skb = NULL;
 		}
 		in->sequence = soft->sequence;
@@ -181,7 +180,7 @@ static void rx(struct net_device *dev, int bufnum,
 		skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 		if (skb == NULL) {
 			BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			return;
 		}
 		skb_put(skb, length + ARC_HDR_SIZE);
@@ -213,7 +212,7 @@ static void rx(struct net_device *dev, int bufnum,
 					BUGMSG(D_EXTRA,
 					       "ARP source address was 00h, set to %02Xh.\n",
 					       saddr);
-					lp->stats.rx_crc_errors++;
+					dev->stats.rx_crc_errors++;
 					*cptr = saddr;
 				} else {
 					BUGMSG(D_DURING, "ARP source address (%Xh) is fine.\n",
@@ -222,8 +221,8 @@ static void rx(struct net_device *dev, int bufnum,
 			} else {
 				BUGMSG(D_NORMAL, "funny-shaped ARP packet. (%Xh, %Xh)\n",
 				       arp->ar_hln, arp->ar_pln);
-				lp->stats.rx_errors++;
-				lp->stats.rx_crc_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_crc_errors++;
 			}
 		}
 		BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
@@ -258,8 +257,8 @@ static void rx(struct net_device *dev, int bufnum,
 			       soft->split_flag);
 			dev_kfree_skb_irq(in->skb);
 			in->skb = NULL;
-			lp->stats.rx_errors++;
-			lp->stats.rx_missed_errors++;
+			dev->stats.rx_errors++;
+			dev->stats.rx_missed_errors++;
 			in->lastpacket = in->numpackets = 0;
 		}
 		if (soft->split_flag & 1) {	/* first packet in split */
@@ -270,8 +269,8 @@ static void rx(struct net_device *dev, int bufnum,
 				       "(splitflag=%d, seq=%d)\n",
 				       in->sequence, soft->split_flag,
 				       soft->sequence);
-				lp->stats.rx_errors++;
-				lp->stats.rx_missed_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_missed_errors++;
 				dev_kfree_skb_irq(in->skb);
 			}
 			in->sequence = soft->sequence;
@@ -282,8 +281,8 @@ static void rx(struct net_device *dev, int bufnum,
 				BUGMSG(D_EXTRA, "incoming packet more than 16 segments; dropping. (splitflag=%d)\n",
 				       soft->split_flag);
 				lp->rfc1201.aborted_seq = soft->sequence;
-				lp->stats.rx_errors++;
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_length_errors++;
 				return;
 			}
 			in->skb = skb = alloc_skb(508 * in->numpackets + ARC_HDR_SIZE,
@@ -291,7 +290,7 @@ static void rx(struct net_device *dev, int bufnum,
 			if (skb == NULL) {
 				BUGMSG(D_NORMAL, "(split) memory squeeze, dropping packet.\n");
 				lp->rfc1201.aborted_seq = soft->sequence;
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				return;
 			}
 			skb->dev = dev;
@@ -315,8 +314,8 @@ static void rx(struct net_device *dev, int bufnum,
 					       "first! (splitflag=%d, seq=%d, aborted=%d)\n",
 					soft->split_flag, soft->sequence,
 					       lp->rfc1201.aborted_seq);
-					lp->stats.rx_errors++;
-					lp->stats.rx_missed_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_missed_errors++;
 				}
 				return;
 			}
@@ -326,8 +325,8 @@ static void rx(struct net_device *dev, int bufnum,
 				if (packetnum <= in->lastpacket - 1) {
 					BUGMSG(D_EXTRA, "duplicate splitpacket ignored! (splitflag=%d)\n",
 					       soft->split_flag);
-					lp->stats.rx_errors++;
-					lp->stats.rx_frame_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_frame_errors++;
 					return;
 				}
 				/* "bad" duplicate, kill reassembly */
@@ -337,8 +336,8 @@ static void rx(struct net_device *dev, int bufnum,
 				lp->rfc1201.aborted_seq = soft->sequence;
 				dev_kfree_skb_irq(in->skb);
 				in->skb = NULL;
-				lp->stats.rx_errors++;
-				lp->stats.rx_missed_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_missed_errors++;
 				in->lastpacket = in->numpackets = 0;
 				return;
 			}
@@ -406,8 +405,8 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	default:
 		BUGMSG(D_NORMAL, "RFC1201: I don't understand protocol %d (%Xh)\n",
 		       type, type);
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 		return 0;
 	}
 
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index a191607..ef0d6b7 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -235,8 +235,6 @@ struct Outgoing {
 
 
 struct arcnet_local {
-	struct net_device_stats stats;
-
 	uint8_t config,		/* current value of CONFIG register */
 		timeout,	/* Extended timeout for COM20020 */
 		backplane,	/* Backplane flag for COM20020 */

--------------020404050105020306070906--

