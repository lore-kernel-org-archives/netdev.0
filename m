From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net/usb: convert to use netdev_for_each_mc_addr
Date: Thu, 18 Feb 2010 15:02:26 +0100
Message-ID: <20100218140226.GI2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756228Ab0BROCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 09:02:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

also removed needless checks in smsc95xx

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/usb/asix.c     |   12 ++++--------
 drivers/net/usb/catc.c     |    5 +----
 drivers/net/usb/mcs7830.c  |    6 ++----
 drivers/net/usb/smsc95xx.c |   26 ++++++++------------------
 4 files changed, 15 insertions(+), 34 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index f605204..20e3460 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -555,20 +555,18 @@ static void asix_set_multicast(struct net_device *net)
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list = net->mc_list;
+		struct dev_mc_list *mc_list;
 		u32 crc_bits;
-		int i;
 
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < netdev_mc_count(net); i++) {
+		netdev_for_each_mc_addr(mc_list, net) {
 			crc_bits =
 			    ether_crc(ETH_ALEN,
 				      mc_list->dmi_addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |=
 			    1 << (crc_bits & 7);
-			mc_list = mc_list->next;
 		}
 
 		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
@@ -769,20 +767,18 @@ static void ax88172_set_multicast(struct net_device *net)
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list = net->mc_list;
+		struct dev_mc_list *mc_list;
 		u32 crc_bits;
-		int i;
 
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < netdev_mc_count(net); i++) {
+		netdev_for_each_mc_addr(mc_list, net) {
 			crc_bits =
 			    ether_crc(ETH_ALEN,
 				      mc_list->dmi_addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |=
 			    1 << (crc_bits & 7);
-			mc_list = mc_list->next;
 		}
 
 		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 5a13660..96f1ebe 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -632,7 +632,6 @@ static void catc_set_multicast_list(struct net_device *netdev)
 	struct dev_mc_list *mc;
 	u8 broadcast[6];
 	u8 rx = RxEnable | RxPolarity | RxMultiCast;
-	int i;
 
 	memset(broadcast, 0xff, 6);
 	memset(catc->multicast, 0, 64);
@@ -648,9 +647,7 @@ static void catc_set_multicast_list(struct net_device *netdev)
 	if (netdev->flags & IFF_ALLMULTI) {
 		memset(catc->multicast, 0xff, 64);
 	} else {
-		for (i = 0, mc = netdev->mc_list;
-		     mc && i < netdev_mc_count(netdev);
-		     i++, mc = mc->next) {
+		netdev_for_each_mc_addr(mc, netdev) {
 			u32 crc = ether_crc_le(6, mc->dmi_addr);
 			if (!catc->is_f5u011) {
 				catc->multicast[(crc >> 3) & 0x3f] |= 1 << (crc & 7);
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 3466513..7097821 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -452,15 +452,13 @@ static void mcs7830_data_set_multicast(struct net_device *net)
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list = net->mc_list;
+		struct dev_mc_list *mc_list;
 		u32 crc_bits;
-		int i;
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < netdev_mc_count(net); i++) {
+		netdev_for_each_mc_addr(mc_list, net) {
 			crc_bits = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |= 1 << (crc_bits & 7);
-			mc_list = mc_list->next;
 		}
 	}
 }
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 1ada51e..df9179a 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -384,30 +384,20 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 		pdata->mac_cr |= MAC_CR_MCPAS_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
 	} else if (!netdev_mc_empty(dev->net)) {
-		struct dev_mc_list *mc_list = dev->net->mc_list;
-		int count = 0;
+		struct dev_mc_list *mc_list;
 
 		pdata->mac_cr |= MAC_CR_HPFILT_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_MCPAS_);
 
-		while (mc_list) {
-			count++;
-			if (mc_list->dmi_addrlen == ETH_ALEN) {
-				u32 bitnum = smsc95xx_hash(mc_list->dmi_addr);
-				u32 mask = 0x01 << (bitnum & 0x1F);
-				if (bitnum & 0x20)
-					hash_hi |= mask;
-				else
-					hash_lo |= mask;
-			} else {
-				netdev_warn(dev->net, "dmi_addrlen != 6\n");
-			}
-			mc_list = mc_list->next;
+		netdev_for_each_mc_addr(mc_list, netdev) {
+			u32 bitnum = smsc95xx_hash(mc_list->dmi_addr);
+			u32 mask = 0x01 << (bitnum & 0x1F);
+			if (bitnum & 0x20)
+				hash_hi |= mask;
+			else
+				hash_lo |= mask;
 		}
 
-		if (count != ((u32) netdev_mc_count(dev->net)))
-			netdev_warn(dev->net, "mc_count != dev->mc_count\n");
-
 		netif_dbg(dev, drv, dev->net, "HASHH=0x%08X, HASHL=0x%08X\n",
 				   hash_hi, hash_lo);
 	} else {
-- 
1.6.6

