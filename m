From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 27 Apr 2007 20:42:39 -0400
Message-ID: <20070428004239.GA19791@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:38349 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757971AbXD1Aml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 20:42:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As mentioned previously, the big batch queued for 2.6.22 is coming
after the dust settles.


Stable@kernel.org folks:  the sis900 patch should be in 2.6.21.x


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/sis900.c      |    9 +++++----
 drivers/usb/net/pegasus.c |   10 ----------
 drivers/usb/net/pegasus.h |    3 +--
 3 files changed, 6 insertions(+), 16 deletions(-)

Dan Williams (1):
      usb-net/pegasus: simplify carrier detection

Neil Horman (1):
      sis900: Allocate rx replacement buffer before rx operation

diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index dea0126..2cb2e15 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1753,6 +1753,7 @@ static int sis900_rx(struct net_device *net_dev)
 			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
 		} else {
 			struct sk_buff * skb;
+			struct sk_buff * rx_skb;
 
 			pci_unmap_single(sis_priv->pci_dev,
 				sis_priv->rx_ring[entry].bufptr, RX_BUF_SIZE,
@@ -1786,10 +1787,10 @@ static int sis900_rx(struct net_device *net_dev)
 			}
 
 			/* give the socket buffer to upper layers */
-			skb = sis_priv->rx_skbuff[entry];
-			skb_put(skb, rx_size);
-			skb->protocol = eth_type_trans(skb, net_dev);
-			netif_rx(skb);
+			rx_skb = sis_priv->rx_skbuff[entry];
+			skb_put(rx_skb, rx_size);
+			rx_skb->protocol = eth_type_trans(rx_skb, net_dev);
+			netif_rx(rx_skb);
 
 			/* some network statistics */
 			if ((rx_status & BCAST) == MCAST)
diff --git a/drivers/usb/net/pegasus.c b/drivers/usb/net/pegasus.c
index 1ad4ee5..a05fd97 100644
--- a/drivers/usb/net/pegasus.c
+++ b/drivers/usb/net/pegasus.c
@@ -847,16 +847,6 @@ static void intr_callback(struct urb *urb)
 		 * d[0].NO_CARRIER kicks in only with failed TX.
 		 * ... so monitoring with MII may be safest.
 		 */
-		if (pegasus->features & TRUST_LINK_STATUS) {
-			if (d[5] & LINK_STATUS)
-				netif_carrier_on(net);
-			else
-				netif_carrier_off(net);
-		} else {
-			/* Never set carrier _on_ based on ! NO_CARRIER */
-			if (d[0] & NO_CARRIER)
-				netif_carrier_off(net);	
-		}
 
 		/* bytes 3-4 == rx_lostpkt, reg 2E/2F */
 		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
diff --git a/drivers/usb/net/pegasus.h b/drivers/usb/net/pegasus.h
index c7aadb4..c746782 100644
--- a/drivers/usb/net/pegasus.h
+++ b/drivers/usb/net/pegasus.h
@@ -11,7 +11,6 @@
 
 #define	PEGASUS_II		0x80000000
 #define	HAS_HOME_PNA		0x40000000
-#define	TRUST_LINK_STATUS	0x20000000
 
 #define	PEGASUS_MTU		1536
 #define	RX_SKBS			4
@@ -204,7 +203,7 @@ PEGASUS_DEV( "AEI USB Fast Ethernet Adapter", VENDOR_AEILAB, 0x1701,
 PEGASUS_DEV( "Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121,
-		DEFAULT_GPIO_RESET | PEGASUS_II | TRUST_LINK_STATUS )
+		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,
