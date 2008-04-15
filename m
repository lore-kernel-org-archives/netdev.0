From: Tomasz Lemiech <szpajder@staszic.waw.pl>
Subject: [PATCH] [TULIP] Fix for MTU problems with 802.1q tagged frames
Date: Tue, 15 Apr 2008 23:18:06 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804152315530.2254@boss.staszic.waw.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tulip-users@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from boss.staszic.waw.pl ([85.232.234.98]:51408 "EHLO
	boss.staszic.waw.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932330AbYDOVZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 17:25:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes MTU problem, which occurs when using 802.1q VLANs.
We should allow receiving frames of up to 1518 bytes in length,
instead of 1514.

Based on patch written by Ben McKeegan for 2.4.x kernels. It is
archived at http://www.candelatech.com/~greear/vlan/howto.html#tulip .
I've adjusted a few things to make it apply on 2.6.x kernels.

Tested on D-Link DFE-570TX quad-fastethernet card.

Signed-off-by: Tomasz Lemiech <szpajder@staszic.waw.pl>
---

 drivers/net/tulip/interrupt.c |   81 ++++++++++++++++++++------------
 drivers/net/tulip/tulip.h     |   32 ++++++++++++
 2 files changed, 83 insertions(+), 30 deletions(-)

diff -urp a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
--- a/drivers/net/tulip/interrupt.c	2008-04-13 14:43:47.000000000 +0200
+++ b/drivers/net/tulip/interrupt.c	2008-04-13 14:51:20.000000000 +0200
@@ -141,6 +141,7 @@ int tulip_poll(struct napi_struct *napi,
                /* If we own the next entry, it is a new packet. Send it up. */
                while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
                        s32 status = le32_to_cpu(tp->rx_ring[entry].status);
+		       short pkt_len;
 
                        if (tp->dirty_rx + RX_RING_SIZE == tp->cur_rx)
                                break;
@@ -152,8 +153,28 @@ int tulip_poll(struct napi_struct *napi,
 		       if (++work_done >= budget)
                                goto not_done;
 
-                       if ((status & 0x38008300) != 0x0300) {
-                               if ((status & 0x38000300) != 0x0300) {
+		/*
+		  Omit the four octet CRC from the length.
+		  (May not be considered valid until we have
+		  checked status for RxLengthOver2047 bits)
+		*/
+		       pkt_len = ((status >> 16) & 0x7ff) - 4;
+
+		/*
+		  Maximum pkt_len is 1518 (1514 + vlan header)
+		  Anything higher than this is always invalid
+		  regardless of RxLengthOver2047 bits
+		*/
+
+		       if ((status & (RxLengthOver2047 |
+				RxDescCRCError |
+				RxDescCollisionSeen |
+				RxDescRunt |
+				RxDescDescErr |
+				RxWholePkt))        != RxWholePkt
+			    || pkt_len > 1518) {
+			       if ((status & (RxLengthOver2047 |
+					RxWholePkt))         != RxWholePkt) {
                                 /* Ingore earlier buffers. */
                                        if ((status & 0xffff) != 0x7fff) {
                                                if (tulip_debug > 1)
@@ -162,30 +183,21 @@ int tulip_poll(struct napi_struct *napi,
                                                               dev->name, status);
                                                tp->stats.rx_length_errors++;
                                        }
-                               } else if (status & RxDescFatalErr) {
+                               } else {
                                 /* There was a fatal error. */
                                        if (tulip_debug > 2)
                                                printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
                                                       dev->name, status);
                                        tp->stats.rx_errors++; /* end of a packet.*/
-                                       if (status & 0x0890) tp->stats.rx_length_errors++;
+				       if (pkt_len > 1518 ||
+					   status & RxDescRunt) tp->stats.rx_length_errors++;
                                        if (status & 0x0004) tp->stats.rx_frame_errors++;
                                        if (status & 0x0002) tp->stats.rx_crc_errors++;
                                        if (status & 0x0001) tp->stats.rx_fifo_errors++;
                                }
                        } else {
-                               /* Omit the four octet CRC from the length. */
-                               short pkt_len = ((status >> 16) & 0x7ff) - 4;
                                struct sk_buff *skb;
 
-#ifndef final_version
-                               if (pkt_len > 1518) {
-                                       printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
-                                              dev->name, pkt_len, pkt_len);
-                                       pkt_len = 1518;
-                                       tp->stats.rx_length_errors++;
-                               }
-#endif
                                /* Check if the packet is long enough to accept without copying
                                   to a minimally-sized skbuff. */
                                if (pkt_len < tulip_rx_copybreak
@@ -358,14 +370,35 @@ static int tulip_rx(struct net_device *d
 	/* If we own the next entry, it is a new packet. Send it up. */
 	while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
 		s32 status = le32_to_cpu(tp->rx_ring[entry].status);
+		short pkt_len;
 
 		if (tulip_debug > 5)
 			printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
 				   dev->name, entry, status);
 		if (--rx_work_limit < 0)
 			break;
-		if ((status & 0x38008300) != 0x0300) {
-			if ((status & 0x38000300) != 0x0300) {
+
+		/*
+		  Omit the four octet CRC from the length.
+		  (May not be considered valid until we have
+		  checked status for RxLengthOver2047 bits)
+		*/
+		pkt_len = ((status >> 16) & 0x7ff) - 4;
+		/*
+		  Maximum pkt_len is 1518 (1514 + vlan header)
+		  Anything higher than this is always invalid
+		  regardless of RxLengthOver2047 bits
+		*/
+
+		if ((status & (RxLengthOver2047 |
+			       RxDescCRCError |
+			       RxDescCollisionSeen |
+			       RxDescRunt |
+			       RxDescDescErr |
+			       RxWholePkt))        != RxWholePkt
+		     || pkt_len > 1518) {
+			if ((status & (RxLengthOver2047 |
+			     RxWholePkt))         != RxWholePkt) {
 				/* Ingore earlier buffers. */
 				if ((status & 0xffff) != 0x7fff) {
 					if (tulip_debug > 1)
@@ -374,31 +407,21 @@ static int tulip_rx(struct net_device *d
 							   dev->name, status);
 					tp->stats.rx_length_errors++;
 				}
-			} else if (status & RxDescFatalErr) {
+			} else {
 				/* There was a fatal error. */
 				if (tulip_debug > 2)
 					printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
 						   dev->name, status);
 				tp->stats.rx_errors++; /* end of a packet.*/
-				if (status & 0x0890) tp->stats.rx_length_errors++;
+				if (pkt_len > 1518 ||
+				    status & RxDescRunt) tp->stats.rx_length_errors++;
 				if (status & 0x0004) tp->stats.rx_frame_errors++;
 				if (status & 0x0002) tp->stats.rx_crc_errors++;
 				if (status & 0x0001) tp->stats.rx_fifo_errors++;
 			}
 		} else {
-			/* Omit the four octet CRC from the length. */
-			short pkt_len = ((status >> 16) & 0x7ff) - 4;
 			struct sk_buff *skb;
 
-#ifndef final_version
-			if (pkt_len > 1518) {
-				printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
-					   dev->name, pkt_len, pkt_len);
-				pkt_len = 1518;
-				tp->stats.rx_length_errors++;
-			}
-#endif
-
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < tulip_rx_copybreak
diff -urp a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
--- a/drivers/net/tulip/tulip.h	2008-04-13 14:43:47.000000000 +0200
+++ b/drivers/net/tulip/tulip.h	2008-04-13 14:48:29.000000000 +0200
@@ -200,8 +200,38 @@ enum desc_status_bits {
 	DescStartPkt = 0x20000000,
 	DescEndRing  = 0x02000000,
 	DescUseLink  = 0x01000000,
-	RxDescFatalErr = 0x008000,
+
+	/*
+	  Error summary flag is logical or of 'CRC Error',
+	  'Collision Seen', 'Frame Too Long', 'Runt' and
+	  'Descriptor Error' flags generated within tulip chip.
+	*/
+	RxDescErrorSummary = 0x8000,
+	RxDescCRCError = 0x0002,
+	RxDescCollisionSeen = 0x0040,
+
+	/*
+	  'Frame Too Long' flag is set if packet length including CRC
+	  exceeds 1518.  However, a full sized VLAN tagged frame is
+	  1522 bytes including CRC.
+
+	  The tulip chip does not block oversized frames, and if this
+	  flag is set on a receive descriptor it does not indicate
+	  the frame has been truncated.  The receive descriptor also
+	  includes the actual length.  Therefore we can safety ignore
+	  this flag and check the length ourselves.
+	*/
+	RxDescFrameTooLong = 0x0080,
+	RxDescRunt = 0x0800,
+	RxDescDescErr = 0x4000,
 	RxWholePkt   = 0x00000300,
+	/*
+	  Top three bits of 14 bit frame length (status bits 27-29)
+	    should never be set as that would make frame over 2047 bytes.
+	  The Receive Watchdog flag (bit 4) may indicate the length is
+	    over 2048 and the length field is invalid.
+	*/
+	RxLengthOver2047 = 0x38000010
 };
 
 

-- 
Tomasz Lemiech
RLU#189399
TL1942-RIPE
