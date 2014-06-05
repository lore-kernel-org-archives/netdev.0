From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/4] net: dev: revert the mac address when notifier failed
Date: Thu, 5 Jun 2014 14:50:27 +0800
Message-ID: <1401951028-9800-4-git-send-email-dingtianhong@huawei.com>
References: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:25961 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaFEGvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 02:51:25 -0400
In-Reply-To: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When set a new mac address to a netdev, the dev should propagate
to the upperdev or lowerdev and make sure the new mac address could
work well with other devs, otherwise the new mac address shouldn't
be set and revert the old mac address.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/core/dev.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4008a51..fc07b8f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5562,6 +5562,7 @@ EXPORT_SYMBOL(dev_set_group);
 int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	struct sockaddr old_sa;
 	int err;
 
 	if (!ops->ndo_set_mac_address)
@@ -5572,13 +5573,27 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 		return -ENODEV;
 	if (ether_addr_equal_64bits(dev->dev_addr, sa->sa_data))
 		return 0;
+
+	old_sa.sa_family = dev->type;
+	ether_addr_copy(old_sa.sa_data, dev->dev_addr);
+
 	err = ops->ndo_set_mac_address(dev, sa);
 	if (err)
 		return err;
-	dev->addr_assign_type = NET_ADDR_SET;
-	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
-	add_device_randomness(dev->dev_addr, dev->addr_len);
-	return 0;
+
+	err = call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	err = notifier_to_errno(err);
+	if (err) {
+		/* setting mac address back and notify everyone again,
+		 *  so that they have a chance to revert changes.
+		 */
+		ops->ndo_set_mac_address(dev, &old_sa);
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	} else {
+		dev->addr_assign_type = NET_ADDR_SET;
+		add_device_randomness(dev->dev_addr, dev->addr_len);
+	}
+	return err;
 }
 EXPORT_SYMBOL(dev_set_mac_address);
 
-- 
1.8.0
