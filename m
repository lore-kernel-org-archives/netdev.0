From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/2] macvlan: don't change macvlan address alone for passthru mode
Date: Mon, 26 May 2014 20:10:32 +0800
Message-ID: <1401106233-11320-2-git-send-email-dingtianhong@huawei.com>
References: <1401106233-11320-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:14466 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbaEZML2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 08:11:28 -0400
In-Reply-To: <1401106233-11320-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvlan dev should have the same address like lowerdev when in the passthru
mode, change the upperdev address alone will break the work mechanism, so don't
change the upper dev address for passthru mode.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c | 28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index a665e90..7bd9082 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -494,35 +494,45 @@ hash_del:
 	return 0;
 }
 
-static int macvlan_set_mac_address(struct net_device *dev, void *p)
+static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
-	struct sockaddr *addr = p;
 	int err;
 
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
 	if (!(dev->flags & IFF_UP)) {
 		/* Just copy in the new address */
-		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+		ether_addr_copy(dev->dev_addr, addr);
 	} else {
 		/* Rehash and update the device filters */
-		if (macvlan_addr_busy(vlan->port, addr->sa_data))
+		if (macvlan_addr_busy(vlan->port, addr))
 			return -EBUSY;
 
-		err = dev_uc_add(lowerdev, addr->sa_data);
+		err = dev_uc_add(lowerdev, addr);
 		if (err)
 			return err;
 
 		dev_uc_del(lowerdev, dev->dev_addr);
 
-		macvlan_hash_change_addr(vlan, addr->sa_data);
+		macvlan_hash_change_addr(vlan, addr);
 	}
 	return 0;
 }
 
+static int macvlan_set_mac_address(struct net_device *dev, void *p)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (vlan->mode == MACVLAN_MODE_PASSTHRU)
+		return -EPERM;
+
+	return macvlan_sync_address(dev, addr->sa_data);
+}
+
 static void macvlan_change_rx_flags(struct net_device *dev, int change)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-- 
1.8.0
