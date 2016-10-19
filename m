From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 1/6] net: use core MTU range checking in USB NIC drivers
Date: Tue, 18 Oct 2016 22:33:28 -0400
Message-ID: <20161019023333.15760-2-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        Hayes Wang <hayeswang@realtek.com>,
        Oliver Neukum <oneukum@suse.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51294 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932716AbcJSCdn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 22:33:43 -0400
In-Reply-To: <20161019023333.15760-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Remove stale new_mtu <= 0 check in usbnet.c
- Set appropriate max_mtu for different r8152 driven variants
- Set max_mtu in lan78xx driver

CC: netdev@vger.kernel.org
CC: Woojung Huh <woojung.huh@microchip.com>
CC: Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
CC: Hayes Wang <hayeswang@realtek.com>
CC: Oliver Neukum <oneukum@suse.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/usb/lan78xx.c |  8 +++-----
 drivers/net/usb/r8152.c   | 15 ++++++++++++---
 drivers/net/usb/usbnet.c  |  2 --
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 13f033c..c4e748e 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1980,11 +1980,6 @@ static int lan78xx_change_mtu(struct net_device *netdev, int new_mtu)
 	int old_rx_urb_size = dev->rx_urb_size;
 	int ret;
 
-	if (new_mtu > MAX_SINGLE_PACKET_SIZE)
-		return -EINVAL;
-
-	if (new_mtu <= 0)
-		return -EINVAL;
 	/* no second zero-length packet read wanted after mtu-sized packets */
 	if ((ll_mtu % dev->maxpacket) == 0)
 		return -EDOM;
@@ -3388,6 +3383,9 @@ static int lan78xx_probe(struct usb_interface *intf,
 	if (netdev->mtu > (dev->hard_mtu - netdev->hard_header_len))
 		netdev->mtu = dev->hard_mtu - netdev->hard_header_len;
 
+	/* MTU range: 68 - 9000 */
+	netdev->max_mtu = MAX_SINGLE_PACKET_SIZE;
+
 	dev->ep_blkin = (intf->cur_altsetting)->endpoint + 0;
 	dev->ep_blkout = (intf->cur_altsetting)->endpoint + 1;
 	dev->ep_intr = (intf->cur_altsetting)->endpoint + 2;
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8d6e13c..4213c28 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4119,9 +4119,6 @@ static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
 		break;
 	}
 
-	if (new_mtu < 68 || new_mtu > RTL8153_MAX_MTU)
-		return -EINVAL;
-
 	ret = usb_autopm_get_interface(tp->intf);
 	if (ret < 0)
 		return ret;
@@ -4311,6 +4308,18 @@ static int rtl8152_probe(struct usb_interface *intf,
 	netdev->ethtool_ops = &ops;
 	netif_set_gso_max_size(netdev, RTL_LIMITED_TSO_SIZE);
 
+	/* MTU range: 68 - 1500 or 9194 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	switch (tp->version) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		netdev->max_mtu = ETH_DATA_LEN;
+		break;
+	default:
+		netdev->max_mtu = RTL8153_MAX_MTU;
+		break;
+	}
+
 	tp->mii.dev = netdev;
 	tp->mii.mdio_read = read_mii_word;
 	tp->mii.mdio_write = write_mii_word;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index d5071e3..52ec271 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -384,8 +384,6 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
 	int		old_hard_mtu = dev->hard_mtu;
 	int		old_rx_urb_size = dev->rx_urb_size;
 
-	if (new_mtu <= 0)
-		return -EINVAL;
 	// no second zero-length packet read wanted after mtu-sized packets
 	if ((ll_mtu % dev->maxpacket) == 0)
 		return -EDOM;
-- 
2.10.0
