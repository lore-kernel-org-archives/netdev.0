From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] skge: fix transmitter flow control
Date: Fri, 23 Feb 2007 14:03:00 -0800
Message-ID: <20070223140300.1c93a375@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36393 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933228AbXBWWDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 17:03:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like the skge driver inherited another bug from the sk98lin code.
If I send from 1000mbit port to a machine on 100mbit port, the switch should
be doing hardware flow control, but no pause frames show up in the statistics.

This is the analog of the recent sky2 fixes. The device needs to listen
for multicast pause frames and then not discard them.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |   43 ++++++++++++++++++++++++++++++++-----------
 drivers/net/skge.h |    3 +--
 2 files changed, 33 insertions(+), 13 deletions(-)

--- sky2-dev.orig/drivers/net/skge.c	2007-02-23 13:17:25.000000000 -0800
+++ sky2-dev/drivers/net/skge.c	2007-02-23 13:53:05.000000000 -0800
@@ -2767,6 +2767,17 @@
 	return err;
 }
 
+static const u8 pause_mc_addr[ETH_ALEN] = { 0x1, 0x80, 0xc2, 0x0, 0x0, 0x1 };
+
+static void genesis_add_filter(u8 filter[8], const u8 *addr)
+{
+	u32 crc, bit;
+
+	crc = ether_crc_le(ETH_ALEN, addr);
+	bit = ~crc & 0x3f;
+	filter[bit/8] |= 1 << (bit%8);
+}
+
 static void genesis_set_multicast(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
@@ -2788,24 +2799,33 @@
 		memset(filter, 0xff, sizeof(filter));
 	else {
 		memset(filter, 0, sizeof(filter));
-		for (i = 0; list && i < count; i++, list = list->next) {
-			u32 crc, bit;
-			crc = ether_crc_le(ETH_ALEN, list->dmi_addr);
-			bit = ~crc & 0x3f;
-			filter[bit/8] |= 1 << (bit%8);
-		}
+
+		if (skge->flow_status == FLOW_STAT_REM_SEND
+		    || skge->flow_status == FLOW_STAT_SYMMETRIC)
+			genesis_add_filter(filter, pause_mc_addr);
+
+		for (i = 0; list && i < count; i++, list = list->next)
+			genesis_add_filter(filter, list->dmi_addr);
 	}
 
 	xm_write32(hw, port, XM_MODE, mode);
 	xm_outhash(hw, port, XM_HSM, filter);
 }
 
+static void yukon_add_filter(u8 filter[8], const u8 *addr)
+{
+	 u32 bit = ether_crc(ETH_ALEN, addr) & 0x3f;
+	 filter[bit/8] |= 1 << (bit%8);
+}
+
 static void yukon_set_multicast(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 	struct dev_mc_list *list = dev->mc_list;
+	int rx_pause = (skge->flow_status == FLOW_STAT_REM_SEND
+			|| skge->flow_status == FLOW_STAT_SYMMETRIC);
 	u16 reg;
 	u8 filter[8];
 
@@ -2818,16 +2838,17 @@
 		reg &= ~(GM_RXCR_UCF_ENA | GM_RXCR_MCF_ENA);
 	else if (dev->flags & IFF_ALLMULTI)	/* all multicast */
 		memset(filter, 0xff, sizeof(filter));
-	else if (dev->mc_count == 0)		/* no multicast */
+	else if (dev->mc_count == 0 && !rx_pause)/* no multicast */
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
 		int i;
 		reg |= GM_RXCR_MCF_ENA;
 
-		for (i = 0; list && i < dev->mc_count; i++, list = list->next) {
-			u32 bit = ether_crc(ETH_ALEN, list->dmi_addr) & 0x3f;
-			filter[bit/8] |= 1 << (bit%8);
-		}
+		if (rx_pause)
+			yukon_add_filter(filter, pause_mc_addr);
+
+		for (i = 0; list && i < dev->mc_count; i++, list = list->next)
+			yukon_add_filter(filter, list->dmi_addr);
 	}
 
 
--- sky2-dev.orig/drivers/net/skge.h	2007-02-23 13:30:36.000000000 -0800
+++ sky2-dev/drivers/net/skge.h	2007-02-23 13:31:11.000000000 -0800
@@ -1849,8 +1849,7 @@
 			  GMR_FS_JABBER,
 /* Rx GMAC FIFO Flush Mask (default) */
 	RX_FF_FL_DEF_MSK = GMR_FS_CRC_ERR | GMR_FS_RX_FF_OV |GMR_FS_MII_ERR |
-			   GMR_FS_BAD_FC | GMR_FS_GOOD_FC | GMR_FS_UN_SIZE |
-			   GMR_FS_JABBER,
+			   GMR_FS_BAD_FC |  GMR_FS_UN_SIZE | GMR_FS_JABBER,
 };
 
 /*	RX_GMF_CTRL_T	32 bit	Rx GMAC FIFO Control/Test */
