From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Support for multicast addresses
Date: Fri,  1 Dec 2006 00:58:07 +0000 (GMT)
Message-ID: <20061201005807.C04067B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:41860 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1031660AbWLAA6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 19:58:03 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Cc: benoit.papillault@free.fr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Support for multicast adresses is implemented by supporting the
set_multicast_list() function of the network device. Address
filtering is supported by a group hash table in the device.

This is based on earlier work by Benoit Papillaut. Fixes multicast packet
reception and ipv6 connectivity:
http://bugzilla.kernel.org/show_bug.cgi?id=7424
http://bugzilla.kernel.org/show_bug.cgi?id=7425

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_chip.c   |   13 +++++++++++++
 zd_chip.h   |   43 ++++++++++++++++++++++++++++++++++++++++++-
 zd_mac.c    |   44 +++++++++++++++++++++++++++++++++++++++++++-
 zd_mac.h    |    3 +++
 zd_netdev.c |    2 +-
 5 files changed, 102 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1673,3 +1673,16 @@ int zd_rfwritev_cr_locked(struct zd_chip
 
 	return 0;
 }
+
+int zd_chip_set_multicast_hash(struct zd_chip *chip,
+	                       struct zd_mc_hash *hash)
+{
+	struct zd_ioreq32 ioreqs[] = {
+		{ CR_GROUP_HASH_P1, hash->low },
+		{ CR_GROUP_HASH_P2, hash->high },
+	};
+
+	dev_dbg_f(zd_chip_dev(chip), "hash l 0x%08x h 0x%08x\n",
+		ioreqs[0].value, ioreqs[1].value);
+	return zd_iowrite32a(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -390,10 +390,19 @@
 #define CR_BSSID_P1			CTL_REG(0x0618)
 #define CR_BSSID_P2			CTL_REG(0x061C)
 #define CR_BCN_PLCP_CFG			CTL_REG(0x0620)
+
+/* Group hash table for filtering incoming packets.
+ *
+ * The group hash table is 64 bit large and split over two parts. The first
+ * part is the lower part. The upper 6 bits of the last byte of the target
+ * address are used as index. Packets are received if the hash table bit is
+ * set. This is used for multicast handling, but for broadcasts (address
+ * ff:ff:ff:ff:ff:ff) the highest bit in the second table must also be set.
+ */
 #define CR_GROUP_HASH_P1		CTL_REG(0x0624)
 #define CR_GROUP_HASH_P2		CTL_REG(0x0628)
-#define CR_RX_TIMEOUT			CTL_REG(0x062C)
 
+#define CR_RX_TIMEOUT			CTL_REG(0x062C)
 /* Basic rates supported by the BSS. When producing ACK or CTS messages, the
  * device will use a rate in this table that is less than or equal to the rate
  * of the incoming frame which prompted the response */
@@ -864,4 +873,36 @@ u8 zd_rx_strength_percent(u8 rssi);
 
 u16 zd_rx_rate(const void *rx_frame, const struct rx_status *status);
 
+struct zd_mc_hash {
+	u32 low;
+	u32 high;
+};
+
+static inline void zd_mc_clear(struct zd_mc_hash *hash)
+{
+	hash->low = 0;
+	/* The interfaces must always received broadcasts.
+	 * The hash of the broadcast address ff:ff:ff:ff:ff:ff is 63.
+	 */
+	hash->high = 0x80000000;
+}
+
+static inline void zd_mc_add_all(struct zd_mc_hash *hash)
+{
+	hash->low = hash->high = 0xffffffff;
+}
+
+static inline void zd_mc_add_addr(struct zd_mc_hash *hash, u8 *addr)
+{
+	unsigned int i = addr[5] >> 2;
+	if (i < 32) {
+		hash->low |= 1 << i;
+	} else {
+		hash->high |= 1 << (i-32);
+	}
+}
+
+int zd_chip_set_multicast_hash(struct zd_chip *chip,
+	                       struct zd_mc_hash *hash);
+
 #endif /* _ZD_CHIP_H */
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -39,6 +39,8 @@ static void housekeeping_init(struct zd_
 static void housekeeping_enable(struct zd_mac *mac);
 static void housekeeping_disable(struct zd_mac *mac);
 
+static void set_multicast_hash_handler(void *mac_ptr);
+
 int zd_mac_init(struct zd_mac *mac,
 	        struct net_device *netdev,
 	        struct usb_interface *intf)
@@ -55,6 +57,8 @@ int zd_mac_init(struct zd_mac *mac,
 	softmac_init(ieee80211_priv(netdev));
 	zd_chip_init(&mac->chip, netdev, intf);
 	housekeeping_init(mac);
+	INIT_WORK(&mac->set_multicast_hash_work, set_multicast_hash_handler,
+		  mac);
 	return 0;
 }
 
@@ -136,6 +140,7 @@ out:
 
 void zd_mac_clear(struct zd_mac *mac)
 {
+	flush_workqueue(zd_workqueue);
 	zd_chip_clear(&mac->chip);
 	ZD_ASSERT(!spin_is_locked(&mac->lock));
 	ZD_MEMCLEAR(mac, sizeof(struct zd_mac));
@@ -256,6 +261,42 @@ int zd_mac_set_mac_address(struct net_de
 	return 0;
 }
 
+static void set_multicast_hash_handler(void *mac_ptr)
+{
+	struct zd_mac *mac = mac_ptr;
+	struct zd_mc_hash hash;
+
+	spin_lock_irq(&mac->lock);
+	hash = mac->multicast_hash;
+	spin_unlock_irq(&mac->lock);
+
+	zd_chip_set_multicast_hash(&mac->chip, &hash);
+}
+
+void zd_mac_set_multicast_list(struct net_device *dev)
+{
+	struct zd_mc_hash hash;
+	struct zd_mac *mac = zd_netdev_mac(dev);
+	struct dev_mc_list *mc;
+	unsigned long flags;
+
+	if (dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) {
+		zd_mc_add_all(&hash);
+	} else {
+		zd_mc_clear(&hash);
+		for (mc = dev->mc_list; mc; mc = mc->next) {
+			dev_dbg_f(zd_mac_dev(mac), "mc addr " MAC_FMT "\n",
+				  MAC_ARG(mc->dmi_addr));
+			zd_mc_add_addr(&hash, mc->dmi_addr);
+		}
+	}
+
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->multicast_hash = hash;
+	spin_unlock_irqrestore(&mac->lock, flags);
+	queue_work(zd_workqueue, &mac->set_multicast_hash_work);
+}
+
 int zd_mac_set_regdomain(struct zd_mac *mac, u8 regdomain)
 {
 	int r;
@@ -930,7 +971,8 @@ static int is_data_packet_for_us(struct 
 	}
 
 	return memcmp(hdr->addr1, netdev->dev_addr, ETH_ALEN) == 0 ||
-	       is_multicast_ether_addr(hdr->addr1) ||
+	       (is_multicast_ether_addr(hdr->addr1) &&
+		memcmp(hdr->addr3, netdev->dev_addr, ETH_ALEN) != 0) ||
 	       (netdev->flags & IFF_PROMISC);
 }
 
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -133,6 +133,8 @@ struct zd_mac {
 	struct iw_statistics iw_stats;
 
 	struct housekeeping housekeeping;
+	struct work_struct set_multicast_hash_work;
+	struct zd_mc_hash multicast_hash;
 	struct work_struct set_rts_cts_work;
 	struct work_struct set_basic_rates_work;
 
@@ -189,6 +191,7 @@ int zd_mac_init_hw(struct zd_mac *mac, u
 int zd_mac_open(struct net_device *netdev);
 int zd_mac_stop(struct net_device *netdev);
 int zd_mac_set_mac_address(struct net_device *dev, void *p);
+void zd_mac_set_multicast_list(struct net_device *netdev);
 
 int zd_mac_rx(struct zd_mac *mac, const u8 *buffer, unsigned int length);
 
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -242,7 +242,7 @@ struct net_device *zd_netdev_alloc(struc
 	netdev->open = zd_mac_open;
 	netdev->stop = zd_mac_stop;
 	/* netdev->get_stats = */
-	/* netdev->set_multicast_list = */
+	netdev->set_multicast_list = zd_mac_set_multicast_list;
 	netdev->set_mac_address = zd_mac_set_mac_address;
 	netdev->wireless_handlers = &iw_handler_def;
 	/* netdev->ethtool_ops = */
