From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] e1000e: enhance frame fragment detection
Date: Tue, 19 Jan 2010 16:15:59 -0800
Message-ID: <20100120001558.25175.87922.stgit@localhost.localdomain>
References: <20100120001511.25175.55030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:50320
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932108Ab0ATAQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 19:16:22 -0500
In-Reply-To: <20100120001511.25175.55030.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Originally patched by Neil Horman <nhorman@tuxdriver.com>

e1000e could with a jumbo frame enabled interface, and packet split disabled,
receive a packet that would overflow a single rx buffer.  While in practice
very hard to craft a packet that could abuse this, it is possible.

this is related to CVE-2009-4538

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h  |    1 +
 drivers/net/e1000e/netdev.c |   25 +++++++++++++++++++++----
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index d6ee28f..d236efa 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -421,6 +421,7 @@ struct e1000_info {
 /* CRC Stripping defines */
 #define FLAG2_CRC_STRIPPING               (1 << 0)
 #define FLAG2_HAS_PHY_WAKEUP              (1 << 1)
+#define FLAG2_IS_DISCARDING               (1 << 2)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c45965a..da5838e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -450,13 +450,23 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		length = le16_to_cpu(rx_desc->length);
 
-		/* !EOP means multiple descriptors were used to store a single
-		 * packet, also make sure the frame isn't just CRC only */
-		if (!(status & E1000_RXD_STAT_EOP) || (length <= 4)) {
+		/*
+		 * !EOP means multiple descriptors were used to store a single
+		 * packet, if that's the case we need to toss it.  In fact, we
+		 * need to toss every packet with the EOP bit clear and the
+		 * next frame that _does_ have the EOP bit set, as it is by
+		 * definition only a frame fragment
+		 */
+		if (unlikely(!(status & E1000_RXD_STAT_EOP)))
+			adapter->flags2 |= FLAG2_IS_DISCARDING;
+
+		if (adapter->flags2 & FLAG2_IS_DISCARDING) {
 			/* All receives must fit into a single buffer */
 			e_dbg("Receive packet consumed multiple buffers\n");
 			/* recycle */
 			buffer_info->skb = skb;
+			if (status & E1000_RXD_STAT_EOP)
+				adapter->flags2 &= ~FLAG2_IS_DISCARDING;
 			goto next_desc;
 		}
 
@@ -745,10 +755,16 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 				 PCI_DMA_FROMDEVICE);
 		buffer_info->dma = 0;
 
-		if (!(staterr & E1000_RXD_STAT_EOP)) {
+		/* see !EOP comment in other rx routine */
+		if (!(staterr & E1000_RXD_STAT_EOP))
+			adapter->flags2 |= FLAG2_IS_DISCARDING;
+
+		if (adapter->flags2 & FLAG2_IS_DISCARDING) {
 			e_dbg("Packet Split buffers didn't pick up the full "
 			      "packet\n");
 			dev_kfree_skb_irq(skb);
+			if (staterr & E1000_RXD_STAT_EOP)
+				adapter->flags2 &= ~FLAG2_IS_DISCARDING;
 			goto next_desc;
 		}
 
@@ -1118,6 +1134,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
+	adapter->flags2 &= ~FLAG2_IS_DISCARDING;
 
 	writel(0, adapter->hw.hw_addr + rx_ring->head);
 	writel(0, adapter->hw.hw_addr + rx_ring->tail);

