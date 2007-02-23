From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] sky2: allow multicast pause frames
Date: Fri, 23 Feb 2007 15:10:44 -0800
Message-ID: <20070223231353.272040000@linux-foundation.org>
References: <20070223231042.860031000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40965 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933264AbXBWXRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 18:17:24 -0500
Content-Disposition: inline; filename=sky2-pause-mc-addr.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 802 standard allows pause frames to be either unicast or multicast.
Switches seem to send unicast frames, but on a direct link, other boards send
multicast pause.  Unless the filter bit is set, these pause frames get
dropped.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

--- linux-2.6.16.y.orig/drivers/net/sky2.c	2007-02-23 14:44:52.000000000 -0800
+++ linux-2.6.16.y/drivers/net/sky2.c	2007-02-23 14:44:54.000000000 -0800
@@ -2686,6 +2686,14 @@
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
@@ -2694,6 +2702,7 @@
 	struct dev_mc_list *list = dev->mc_list;
 	u16 reg;
 	u8 filter[8];
+	static const u8 pause_mc_addr[ETH_ALEN] = { 0x1, 0x80, 0xc2, 0x0, 0x0, 0x1 };
 
 	memset(filter, 0, sizeof(filter));
 
@@ -2704,16 +2713,17 @@
 		reg &= ~(GM_RXCR_UCF_ENA | GM_RXCR_MCF_ENA);
 	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count > 16)	/* all multicast */
 		memset(filter, 0xff, sizeof(filter));
-	else if (dev->mc_count == 0)	/* no multicast */
+	else if (dev->mc_count == 0 && !sky2->rx_pause)	/* no multicast */
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
 		int i;
 		reg |= GM_RXCR_MCF_ENA;
 
-		for (i = 0; list && i < dev->mc_count; i++, list = list->next) {
-			u32 bit = ether_crc(ETH_ALEN, list->dmi_addr) & 0x3f;
-			filter[bit / 8] |= 1 << (bit % 8);
-		}
+		if (sky2->rx_pause)
+			sky2_add_filter(filter, pause_mc_addr);
+
+		for (i = 0; list && i < dev->mc_count; i++, list = list->next)
+			sky2_add_filter(filter, list->dmi_addr);
 	}
 
 	gma_write16(hw, port, GM_MC_ADDR_H1,

--
Stephen Hemminger <shemminger@linux-foundation.org>

