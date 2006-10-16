From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/2] sky2: multicast pause frame receive
Date: Mon, 16 Oct 2006 13:50:03 -0700
Message-ID: <20061016135003.5698e718@freekitty>
References: <20061011212225.941046083@osdl.org>
	<20061011212311.715010657@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:29349 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161139AbWJPWLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 18:11:37 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061011212311.715010657@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using flow control, the PHY needs to accept multicast pause frames.
Without this fix, these frames were getting discarded by the PHY before
doing any flow control. 

This maybe related to http://bugzilla.kernel.org/show_bug.cgi?id=6839

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-10-16 08:38:24.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-16 09:48:28.000000000 -0700
@@ -2850,6 +2850,14 @@
 	return 0;
 }
 
+static void inline sky2_add_filter(u8 filter[8], const u8 *addr)
+{
+	u32 bit;
+
+	bit = ether_crc(ETH_ALEN, addr) & 63;
+	filter[bit >> 3] |= 1 << (bit & 7);
+}
+
 static void sky2_set_multicast(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
@@ -2858,7 +2866,10 @@
 	struct dev_mc_list *list = dev->mc_list;
 	u16 reg;
 	u8 filter[8];
+	int rx_pause;
+	static const u8 pause_mc_addr[ETH_ALEN] = { 0x1, 0x80, 0xc2, 0x0, 0x0, 0x1 };
 
+	rx_pause = (sky2->flow_status == FC_RX || sky2->flow_status == FC_BOTH);
 	memset(filter, 0, sizeof(filter));
 
 	reg = gma_read16(hw, port, GM_RX_CTRL);
@@ -2866,18 +2877,19 @@
 
 	if (dev->flags & IFF_PROMISC)	/* promiscuous */
 		reg &= ~(GM_RXCR_UCF_ENA | GM_RXCR_MCF_ENA);
-	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count > 16)	/* all multicast */
+	else if (dev->flags & IFF_ALLMULTI)
 		memset(filter, 0xff, sizeof(filter));
-	else if (dev->mc_count == 0)	/* no multicast */
+	else if (dev->mc_count == 0 && !rx_pause)
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
 		int i;
 		reg |= GM_RXCR_MCF_ENA;
 
-		for (i = 0; list && i < dev->mc_count; i++, list = list->next) {
-			u32 bit = ether_crc(ETH_ALEN, list->dmi_addr) & 0x3f;
-			filter[bit / 8] |= 1 << (bit % 8);
-		}
+		if (rx_pause)
+			sky2_add_filter(filter, pause_mc_addr);
+
+		for (i = 0; list && i < dev->mc_count; i++, list = list->next)
+			sky2_add_filter(filter, list->dmi_addr);
 	}
 
 	gma_write16(hw, port, GM_MC_ADDR_H1,
