From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 11/45] arcnet: convert to internal stats
Date: Fri, 09 Jan 2009 15:01:08 -0800
Message-ID: <20090109230137.528612086@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42175 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920AbZAIXRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:55 -0500
Content-Disposition: inline; filename=arcnet-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pre-existing network_device_stats inside network_device rather than own
private structure.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/arcnet/arc-rawmode.c |    2 -
 drivers/net/arcnet/arcnet.c      |   38 +++++++++----------------------
 drivers/net/arcnet/capmode.c     |    2 -
 drivers/net/arcnet/rfc1051.c     |   12 ++++-----
 drivers/net/arcnet/rfc1201.c     |   47 +++++++++++++++++++--------------------
 include/linux/arcdevice.h        |    2 -
 6 files changed, 42 insertions(+), 61 deletions(-)

--- a/drivers/net/arcnet/arc-rawmode.c	2009-01-09 09:40:52.000000000 -0800
+++ b/drivers/net/arcnet/arc-rawmode.c	2009-01-09 09:41:04.000000000 -0800
@@ -102,7 +102,7 @@ static void rx(struct net_device *dev, i
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (skb == NULL) {
 		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_put(skb, length + ARC_HDR_SIZE);
--- a/drivers/net/arcnet/arcnet.c	2009-01-09 09:40:52.000000000 -0800
+++ b/drivers/net/arcnet/arcnet.c	2009-01-09 09:41:04.000000000 -0800
@@ -105,7 +105,6 @@ static int arcnet_header(struct sk_buff 
 			 unsigned short type, const void *daddr,
 			 const void *saddr, unsigned len);
 static int arcnet_rebuild_header(struct sk_buff *skb);
-static struct net_device_stats *arcnet_get_stats(struct net_device *dev);
 static int go_tx(struct net_device *dev);
 
 static int debug = ARCNET_DEBUG;
@@ -347,7 +346,6 @@ static void arcdev_setup(struct net_devi
 	dev->stop = arcnet_close;
 	dev->hard_start_xmit = arcnet_send_packet;
 	dev->tx_timeout = arcnet_timeout;
-	dev->get_stats = arcnet_get_stats;
 }
 
 struct net_device *alloc_arcdev(char *name)
@@ -583,8 +581,8 @@ static int arcnet_rebuild_header(struct 
 	} else {
 		BUGMSG(D_NORMAL,
 		       "I don't understand ethernet protocol %Xh addresses!\n", type);
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 	}
 
 	/* if we couldn't resolve the address... give up. */
@@ -645,7 +643,7 @@ static int arcnet_send_packet(struct sk_
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
@@ -732,11 +730,11 @@ static void arcnet_timeout(struct net_de
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
@@ -865,8 +863,8 @@ irqreturn_t arcnet_interrupt(int irq, vo
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
@@ -905,7 +903,7 @@ irqreturn_t arcnet_interrupt(int irq, vo
 				if (txbuf != -1) {
 					if (lp->outgoing.proto->continue_tx(dev, txbuf)) {
 						/* that was the last segment */
-						lp->stats.tx_bytes += lp->outgoing.skb->len;
+						dev->stats.tx_bytes += lp->outgoing.skb->len;
 						if(!lp->outgoing.proto->ack_tx)
 						  {
 						    dev_kfree_skb_irq(lp->outgoing.skb);
@@ -930,7 +928,7 @@ irqreturn_t arcnet_interrupt(int irq, vo
 		}
 		if (status & lp->intmask & RECONflag) {
 			ACOMMAND(CFLAGScmd | CONFIGclear);
-			lp->stats.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 
 			BUGMSG(D_RECON, "Network reconfiguration detected (status=%Xh)\n",
 			       status);
@@ -1038,8 +1036,8 @@ static void arcnet_rx(struct net_device 
 	       "(%d+4 bytes)\n",
 	       bufnum, pkt.hard.source, pkt.hard.dest, length);
 
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += length + ARC_HDR_SIZE;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += length + ARC_HDR_SIZE;
 
 	/* call the right receiver for the protocol */
 	if (arc_proto_map[soft->proto]->is_ip) {
@@ -1067,18 +1065,6 @@ static void arcnet_rx(struct net_device 
 }
 
 
-
-/* 
- * Get the current statistics.  This may be called with the card open or
- * closed.
- */
-static struct net_device_stats *arcnet_get_stats(struct net_device *dev)
-{
-	struct arcnet_local *lp = netdev_priv(dev);
-	return &lp->stats;
-}
-
-
 static void null_rx(struct net_device *dev, int bufnum,
 		    struct archdr *pkthdr, int length)
 {
--- a/drivers/net/arcnet/capmode.c	2009-01-09 09:40:52.000000000 -0800
+++ b/drivers/net/arcnet/capmode.c	2009-01-09 09:41:04.000000000 -0800
@@ -119,7 +119,7 @@ static void rx(struct net_device *dev, i
 	skb = alloc_skb(length + ARC_HDR_SIZE + sizeof(int), GFP_ATOMIC);
 	if (skb == NULL) {
 		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_put(skb, length + ARC_HDR_SIZE + sizeof(int));
--- a/drivers/net/arcnet/rfc1051.c	2009-01-09 09:40:52.000000000 -0800
+++ b/drivers/net/arcnet/rfc1051.c	2009-01-09 09:44:53.000000000 -0800
@@ -88,7 +88,6 @@ MODULE_LICENSE("GPL");
  */
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
@@ -112,8 +111,8 @@ static __be16 type_trans(struct sk_buff 
 		return htons(ETH_P_ARP);
 
 	default:
-		lp->stats.rx_errors++;
-		lp->stats.rx_crc_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_crc_errors++;
 		return 0;
 	}
 
@@ -140,7 +139,7 @@ static void rx(struct net_device *dev, i
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (skb == NULL) {
 		BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_put(skb, length + ARC_HDR_SIZE);
@@ -168,7 +167,6 @@ static void rx(struct net_device *dev, i
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
@@ -184,8 +182,8 @@ static int build_header(struct sk_buff *
 	default:
 		BUGMSG(D_NORMAL, "RFC1051: I don't understand protocol %d (%Xh)\n",
 		       type, type);
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 		return 0;
 	}
 
--- a/drivers/net/arcnet/rfc1201.c	2009-01-09 09:40:52.000000000 -0800
+++ b/drivers/net/arcnet/rfc1201.c	2009-01-09 09:41:04.000000000 -0800
@@ -92,7 +92,6 @@ static __be16 type_trans(struct sk_buff 
 {
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
-	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
@@ -121,8 +120,8 @@ static __be16 type_trans(struct sk_buff 
 	case ARC_P_NOVELL_EC:
 		return htons(ETH_P_802_3);
 	default:
-		lp->stats.rx_errors++;
-		lp->stats.rx_crc_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_crc_errors++;
 		return 0;
 	}
 
@@ -172,8 +171,8 @@ static void rx(struct net_device *dev, i
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
@@ -181,7 +180,7 @@ static void rx(struct net_device *dev, i
 		skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 		if (skb == NULL) {
 			BUGMSG(D_NORMAL, "Memory squeeze, dropping packet.\n");
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			return;
 		}
 		skb_put(skb, length + ARC_HDR_SIZE);
@@ -213,7 +212,7 @@ static void rx(struct net_device *dev, i
 					BUGMSG(D_EXTRA,
 					       "ARP source address was 00h, set to %02Xh.\n",
 					       saddr);
-					lp->stats.rx_crc_errors++;
+					dev->stats.rx_crc_errors++;
 					*cptr = saddr;
 				} else {
 					BUGMSG(D_DURING, "ARP source address (%Xh) is fine.\n",
@@ -222,8 +221,8 @@ static void rx(struct net_device *dev, i
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
@@ -257,8 +256,8 @@ static void rx(struct net_device *dev, i
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
@@ -269,8 +268,8 @@ static void rx(struct net_device *dev, i
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
@@ -281,8 +280,8 @@ static void rx(struct net_device *dev, i
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
@@ -290,7 +289,7 @@ static void rx(struct net_device *dev, i
 			if (skb == NULL) {
 				BUGMSG(D_NORMAL, "(split) memory squeeze, dropping packet.\n");
 				lp->rfc1201.aborted_seq = soft->sequence;
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				return;
 			}
 			skb->dev = dev;
@@ -314,8 +313,8 @@ static void rx(struct net_device *dev, i
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
@@ -325,8 +324,8 @@ static void rx(struct net_device *dev, i
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
@@ -336,8 +335,8 @@ static void rx(struct net_device *dev, i
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
@@ -404,8 +403,8 @@ static int build_header(struct sk_buff *
 	default:
 		BUGMSG(D_NORMAL, "RFC1201: I don't understand protocol %d (%Xh)\n",
 		       type, type);
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 		return 0;
 	}
 
--- a/include/linux/arcdevice.h	2009-01-09 09:40:52.000000000 -0800
+++ b/include/linux/arcdevice.h	2009-01-09 09:41:04.000000000 -0800
@@ -235,8 +235,6 @@ struct Outgoing {
 
 
 struct arcnet_local {
-	struct net_device_stats stats;
-
 	uint8_t config,		/* current value of CONFIG register */
 		timeout,	/* Extended timeout for COM20020 */
 		backplane,	/* Backplane flag for COM20020 */


