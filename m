From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 07/14] net: nmlan_cs: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:32 +0200
Message-ID: <20170407081739.5243-8-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34524 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755221AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
_mace_private, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/amd/nmclan_cs.c | 49 ++++++++++++++++++------------------
 1 file changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index b556c926557a..9c152d85840d 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -359,7 +359,6 @@ typedef struct _mace_statistics {
 
 typedef struct _mace_private {
 	struct pcmcia_device	*p_dev;
-    struct net_device_stats linux_stats; /* Linux statistics counters */
     mace_statistics mace_stats; /* MACE chip statistics counters */
 
     /* restore_multicast_list() state variables */
@@ -879,7 +878,7 @@ static netdev_tx_t mace_start_xmit(struct sk_buff *skb,
        service a transmit interrupt while we are in here.
     */
 
-    lp->linux_stats.tx_bytes += skb->len;
+    dev->stats.tx_bytes += skb->len;
     lp->tx_free_frames--;
 
     /* WARNING: Write the _exact_ number of bytes written in the header! */
@@ -967,7 +966,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 
       fifofc = inb(ioaddr + AM2150_MACE_BASE + MACE_FIFOFC);
       if ((fifofc & MACE_FIFOFC_XMTFC)==0) {
-	lp->linux_stats.tx_errors++;
+	dev->stats.tx_errors++;
 	outb(0xFF, ioaddr + AM2150_XMT_SKIP);
       }
 
@@ -1016,7 +1015,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 
       } /* if (xmtfs & MACE_XMTFS_XMTSV) */
 
-      lp->linux_stats.tx_packets++;
+      dev->stats.tx_packets++;
       lp->tx_free_frames++;
       netif_wake_queue(dev);
     } /* if (status & MACE_IR_XMTINT) */
@@ -1077,7 +1076,7 @@ static int mace_rx(struct net_device *dev, unsigned char RxCnt)
 	  " 0x%X.\n", dev->name, rx_framecnt, rx_status);
 
     if (rx_status & MACE_RCVFS_RCVSTS) { /* Error, update stats. */
-      lp->linux_stats.rx_errors++;
+      dev->stats.rx_errors++;
       if (rx_status & MACE_RCVFS_OFLO) {
         lp->mace_stats.oflo++;
       }
@@ -1114,14 +1113,14 @@ static int mace_rx(struct net_device *dev, unsigned char RxCnt)
 	
 	netif_rx(skb); /* Send the packet to the upper (protocol) layers. */
 
-	lp->linux_stats.rx_packets++;
-	lp->linux_stats.rx_bytes += pkt_len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += pkt_len;
 	outb(0xFF, ioaddr + AM2150_RCV_NEXT); /* skip to next frame */
 	continue;
       } else {
 	pr_debug("%s: couldn't allocate a sk_buff of size"
 	      " %d.\n", dev->name, pkt_len);
-	lp->linux_stats.rx_dropped++;
+	dev->stats.rx_dropped++;
       }
     }
     outb(0xFF, ioaddr + AM2150_RCV_NEXT); /* skip to next frame */
@@ -1231,13 +1230,13 @@ static void update_stats(unsigned int ioaddr, struct net_device *dev)
   lp->mace_stats.rntpc += mace_read(lp, ioaddr, MACE_RNTPC);
   lp->mace_stats.mpc += mace_read(lp, ioaddr, MACE_MPC);
   /* At this point, mace_stats is fully updated for this call.
-     We may now update the linux_stats. */
+     We may now update the netdev stats. */
 
-  /* The MACE has no equivalent for linux_stats field which are commented
+  /* The MACE has no equivalent for netdev stats field which are commented
      out. */
 
-  /* lp->linux_stats.multicast; */
-  lp->linux_stats.collisions = 
+  /* dev->stats.multicast; */
+  dev->stats.collisions =
     lp->mace_stats.rcvcco * 256 + lp->mace_stats.rcvcc;
     /* Collision: The MACE may retry sending a packet 15 times
        before giving up.  The retry count is in XMTRC.
@@ -1245,22 +1244,22 @@ static void update_stats(unsigned int ioaddr, struct net_device *dev)
        If so, why doesn't the RCVCC record these collisions? */
 
   /* detailed rx_errors: */
-  lp->linux_stats.rx_length_errors = 
+  dev->stats.rx_length_errors =
     lp->mace_stats.rntpco * 256 + lp->mace_stats.rntpc;
-  /* lp->linux_stats.rx_over_errors */
-  lp->linux_stats.rx_crc_errors = lp->mace_stats.fcs;
-  lp->linux_stats.rx_frame_errors = lp->mace_stats.fram;
-  lp->linux_stats.rx_fifo_errors = lp->mace_stats.oflo;
-  lp->linux_stats.rx_missed_errors = 
+  /* dev->stats.rx_over_errors */
+  dev->stats.rx_crc_errors = lp->mace_stats.fcs;
+  dev->stats.rx_frame_errors = lp->mace_stats.fram;
+  dev->stats.rx_fifo_errors = lp->mace_stats.oflo;
+  dev->stats.rx_missed_errors =
     lp->mace_stats.mpco * 256 + lp->mace_stats.mpc;
 
   /* detailed tx_errors */
-  lp->linux_stats.tx_aborted_errors = lp->mace_stats.rtry;
-  lp->linux_stats.tx_carrier_errors = lp->mace_stats.lcar;
+  dev->stats.tx_aborted_errors = lp->mace_stats.rtry;
+  dev->stats.tx_carrier_errors = lp->mace_stats.lcar;
     /* LCAR usually results from bad cabling. */
-  lp->linux_stats.tx_fifo_errors = lp->mace_stats.uflo;
-  lp->linux_stats.tx_heartbeat_errors = lp->mace_stats.cerr;
-  /* lp->linux_stats.tx_window_errors; */
+  dev->stats.tx_fifo_errors = lp->mace_stats.uflo;
+  dev->stats.tx_heartbeat_errors = lp->mace_stats.cerr;
+  /* dev->stats.tx_window_errors; */
 } /* update_stats */
 
 /* ----------------------------------------------------------------------------
@@ -1274,10 +1273,10 @@ static struct net_device_stats *mace_get_stats(struct net_device *dev)
   update_stats(dev->base_addr, dev);
 
   pr_debug("%s: updating the statistics.\n", dev->name);
-  pr_linux_stats(&lp->linux_stats);
+  pr_linux_stats(&dev->stats);
   pr_mace_stats(&lp->mace_stats);
 
-  return &lp->linux_stats;
+  return &dev->stats;
 } /* net_device_stats */
 
 /* ----------------------------------------------------------------------------
-- 
2.12.2
