From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 4/10] Staging: otus: convert to netdev_ops
Date: Sun, 29 Mar 2009 19:26:25 +0400
Message-ID: <20090329152625.GD11056@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:46969 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756199AbZC2P0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 11:26:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/staging/otus/usbdrv.c |   47 +++++++++++++++++++++++++---------------
 1 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/otus/usbdrv.c b/drivers/staging/otus/usbdrv.c
index 565a839..540cbbb 100644
--- a/drivers/staging/otus/usbdrv.c
+++ b/drivers/staging/otus/usbdrv.c
@@ -822,6 +822,21 @@ int zfLnxVapXmitFrame(struct sk_buff *skb, struct net_device *dev)
     return 0;
 }
 
+static const struct net_device_ops vap_netdev_ops = {
+	.ndo_open		= zfLnxVapOpen,
+	.ndo_stop		= zfLnxVapClose,
+	.ndo_start_xmit		= zfLnxVapXmitFrame,
+	.ndo_get_stats		= usbdrv_get_stats,
+	.ndo_change_mtu		= usbdrv_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef ZM_HOSTAPD_SUPPORT
+	.ndo_do_ioctl		= usbdrv_ioctl,
+#else
+	.ndo_do_ioctl		= NULL,
+#endif
+};
+
 int zfLnxRegisterVapDev(struct net_device* parentDev, u16_t vapId)
 {
     /* Allocate net device structure */
@@ -846,16 +861,7 @@ int zfLnxRegisterVapDev(struct net_device* parentDev, u16_t vapId)
     vap[vapId].dev->ml_priv = parentDev->ml_priv;
 
     //dev->hard_start_xmit = &zd1212_wds_xmit_frame;
-    vap[vapId].dev->hard_start_xmit = &zfLnxVapXmitFrame;
-    vap[vapId].dev->open = &zfLnxVapOpen;
-    vap[vapId].dev->stop = &zfLnxVapClose;
-    vap[vapId].dev->get_stats = &usbdrv_get_stats;
-    vap[vapId].dev->change_mtu = &usbdrv_change_mtu;
-#ifdef ZM_HOSTAPD_SUPPORT
-    vap[vapId].dev->do_ioctl = usbdrv_ioctl;
-#else
-    vap[vapId].dev->do_ioctl = NULL;
-#endif
+    vap[vapId].dev->netdev_ops = &vap_netdev_ops;
     vap[vapId].dev->destructor = free_netdev;
 
     vap[vapId].dev->tx_queue_len = 0;
@@ -1068,6 +1074,18 @@ void zfLnxUnlinkAllUrbs(struct usbdrv_private *macp)
     usb_unlink_urb(macp->RegInUrb);
 }
 
+static const struct net_device_ops otus_netdev_ops = {
+	.ndo_open		= usbdrv_open,
+	.ndo_stop		= usbdrv_close,
+	.ndo_start_xmit		= usbdrv_xmit_frame,
+	.ndo_change_mtu		= usbdrv_change_mtu,
+	.ndo_get_stats		= usbdrv_get_stats,
+	.ndo_set_multicast_list	= usbdrv_set_multi,
+	.ndo_set_mac_address	= usbdrv_set_mac,
+	.ndo_do_ioctl		= usbdrv_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 u8_t zfLnxInitSetup(struct net_device *dev, struct usbdrv_private *macp)
 {
     //unsigned char addr[6];
@@ -1092,14 +1110,7 @@ u8_t zfLnxInitSetup(struct net_device *dev, struct usbdrv_private *macp)
     dev->wireless_handlers = (struct iw_handler_def *)&p80211wext_handler_def;
 #endif
 
-    dev->open = usbdrv_open;
-    dev->hard_start_xmit = usbdrv_xmit_frame;
-    dev->stop = usbdrv_close;
-    dev->change_mtu = &usbdrv_change_mtu;
-    dev->get_stats = usbdrv_get_stats;
-    dev->set_multicast_list = usbdrv_set_multi;
-    dev->set_mac_address = usbdrv_set_mac;
-    dev->do_ioctl = usbdrv_ioctl;
+    dev->netdev_ops = &otus_netdev_ops;
 
     dev->flags |= IFF_MULTICAST;
 
