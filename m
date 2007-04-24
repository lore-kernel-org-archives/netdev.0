From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 24 Apr 2007 13:53:49 -0400
Message-ID: <20070424175349.GA5902@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422942AbXDXRxy@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/depca.c                   |    3 +-
 drivers/net/hamradio/baycom_ser_fdx.c |    6 +++-
 drivers/net/sis900.c                  |   44 +++++++++++++++------------------
 drivers/usb/net/pegasus.c             |   17 +++++++++---
 drivers/usb/net/pegasus.h             |    3 +-
 5 files changed, 40 insertions(+), 33 deletions(-)

Andrea Righi (1):
      [netdrvr] depca: handle platform_device_add() failure

Andrew Morton (1):
      drivers/net/hamradio/baycom_ser_fdx build fix

Dan Williams (1):
      usb-net/pegasus: fix pegasus carrier detection

Neil Horman (1):
      sis900: Allocate rx replacement buffer before rx operation

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 5113eef..f3807aa 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1491,8 +1491,9 @@ static void __init depca_platform_probe (void)
 		depca_io_ports[i].device = pldev;
 
 		if (platform_device_add(pldev)) {
-			platform_device_put(pldev);
 			depca_io_ports[i].device = NULL;
+			pldev->dev.platform_data = NULL;
+			platform_device_put(pldev);
 			continue;
 		}
 
diff --git a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
index 59214e7..30baf6e 100644
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -75,12 +75,14 @@
 #include <linux/ioport.h>
 #include <linux/string.h>
 #include <linux/init.h>
-#include <asm/uaccess.h>
-#include <asm/io.h>
 #include <linux/hdlcdrv.h>
 #include <linux/baycom.h>
 #include <linux/jiffies.h>
 
+#include <asm/uaccess.h>
+#include <asm/io.h>
+#include <asm/irq.h>
+
 /* --------------------------------------------------------------------- */
 
 #define BAYCOM_DEBUG
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index b3750f2..b2a3b19 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1755,6 +1755,24 @@ static int sis900_rx(struct net_device *net_dev)
 		} else {
 			struct sk_buff * skb;
 
+			pci_unmap_single(sis_priv->pci_dev,
+				sis_priv->rx_ring[entry].bufptr, RX_BUF_SIZE,
+				PCI_DMA_FROMDEVICE);
+
+			/* refill the Rx buffer, what if there is not enought
+			 * memory for new socket buffer ?? */
+			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+				/*
+				 * Not enough memory to refill the buffer
+				 * so we need to recycle the old one so
+				 * as to avoid creating a memory hole
+				 * in the rx ring
+				 */
+				skb = sis_priv->rx_skbuff[entry];
+				sis_priv->stats.rx_dropped++;
+				goto refill_rx_ring;
+			}	
+
 			/* This situation should never happen, but due to
 			   some unknow bugs, it is possible that
 			   we are working on NULL sk_buff :-( */
@@ -1768,9 +1786,6 @@ static int sis900_rx(struct net_device *net_dev)
 				break;
 			}
 
-			pci_unmap_single(sis_priv->pci_dev,
-				sis_priv->rx_ring[entry].bufptr, RX_BUF_SIZE,
-				PCI_DMA_FROMDEVICE);
 			/* give the socket buffer to upper layers */
 			skb = sis_priv->rx_skbuff[entry];
 			skb_put(skb, rx_size);
@@ -1783,33 +1798,14 @@ static int sis900_rx(struct net_device *net_dev)
 			net_dev->last_rx = jiffies;
 			sis_priv->stats.rx_bytes += rx_size;
 			sis_priv->stats.rx_packets++;
-
-			/* refill the Rx buffer, what if there is not enought
-			 * memory for new socket buffer ?? */
-			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
-				/* not enough memory for skbuff, this makes a
-				 * "hole" on the buffer ring, it is not clear
-				 * how the hardware will react to this kind
-				 * of degenerated buffer */
-				if (netif_msg_rx_status(sis_priv))
-					printk(KERN_INFO "%s: Memory squeeze,"
-						"deferring packet.\n",
-						net_dev->name);
-				sis_priv->rx_skbuff[entry] = NULL;
-				/* reset buffer descriptor state */
-				sis_priv->rx_ring[entry].cmdsts = 0;
-				sis_priv->rx_ring[entry].bufptr = 0;
-				sis_priv->stats.rx_dropped++;
-				sis_priv->cur_rx++;
-				break;
-			}
+			sis_priv->dirty_rx++;
+refill_rx_ring:
 			skb->dev = net_dev;
 			sis_priv->rx_skbuff[entry] = skb;
 			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
                 	sis_priv->rx_ring[entry].bufptr =
 				pci_map_single(sis_priv->pci_dev, skb->data,
 					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-			sis_priv->dirty_rx++;
 		}
 		sis_priv->cur_rx++;
 		entry = sis_priv->cur_rx % NUM_RX_DESC;
diff --git a/drivers/usb/net/pegasus.c b/drivers/usb/net/pegasus.c
index d48c024..6d12961 100644
--- a/drivers/usb/net/pegasus.c
+++ b/drivers/usb/net/pegasus.c
@@ -316,6 +316,7 @@ static int update_eth_regs_async(pegasus_t * pegasus)
 	return ret;
 }
 
+/* Returns 0 on success, error on failure */
 static int read_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 * regd)
 {
 	int i;
@@ -847,10 +848,16 @@ static void intr_callback(struct urb *urb)
 		 * d[0].NO_CARRIER kicks in only with failed TX.
 		 * ... so monitoring with MII may be safest.
 		 */
-		if (d[0] & NO_CARRIER)
-			netif_carrier_off(net);	
-		else
-			netif_carrier_on(net);
+		if (pegasus->features & TRUST_LINK_STATUS) {
+			if (d[5] & LINK_STATUS)
+				netif_carrier_on(net);
+			else
+				netif_carrier_off(net);
+		} else {
+			/* Never set carrier _on_ based on ! NO_CARRIER */
+			if (d[0] & NO_CARRIER)
+				netif_carrier_off(net);	
+		}
 
 		/* bytes 3-4 == rx_lostpkt, reg 2E/2F */
 		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
@@ -950,7 +957,7 @@ static void set_carrier(struct net_device *net)
 	pegasus_t *pegasus = netdev_priv(net);
 	u16 tmp;
 
-	if (!read_mii_word(pegasus, pegasus->phy, MII_BMSR, &tmp))
+	if (read_mii_word(pegasus, pegasus->phy, MII_BMSR, &tmp))
 		return;
 
 	if (tmp & BMSR_LSTATUS)
diff --git a/drivers/usb/net/pegasus.h b/drivers/usb/net/pegasus.h
index c746782..c7aadb4 100644
--- a/drivers/usb/net/pegasus.h
+++ b/drivers/usb/net/pegasus.h
@@ -11,6 +11,7 @@
 
 #define	PEGASUS_II		0x80000000
 #define	HAS_HOME_PNA		0x40000000
+#define	TRUST_LINK_STATUS	0x20000000
 
 #define	PEGASUS_MTU		1536
 #define	RX_SKBS			4
@@ -203,7 +204,7 @@ PEGASUS_DEV( "AEI USB Fast Ethernet Adapter", VENDOR_AEILAB, 0x1701,
 PEGASUS_DEV( "Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121,
-		DEFAULT_GPIO_RESET | PEGASUS_II )
+		DEFAULT_GPIO_RESET | PEGASUS_II | TRUST_LINK_STATUS )
 PEGASUS_DEV( "Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,
