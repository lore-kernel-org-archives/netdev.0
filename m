From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] net: make dev_set_mtu() honor notification return code
Date: Fri, 10 Jan 2014 13:48:17 +0100
Message-ID: <1389358097-5396-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbaAJMwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 07:52:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, after changing the MTU for a device, dev_set_mtu() calls
NETDEV_CHANGEMTU notification, however doesn't verify it's return code -
which can be NOTIFY_BAD - i.e. some of the net notifier blocks refused this
change, and continues nevertheless.

To fix this, verify the return code, and if it's an error - then revert the
MTU to the original one, and pass the error code.

CC: Jiri Pirko <jiri@resnulli.us>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/core/dev.c | 29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ce01847..1c570ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5287,6 +5287,17 @@ int dev_change_flags(struct net_device *dev, unsigned int flags)
 }
 EXPORT_SYMBOL(dev_change_flags);
 
+static int __dev_set_mtu(struct net_device *dev, int new_mtu)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (ops->ndo_change_mtu)
+		return ops->ndo_change_mtu(dev, new_mtu);
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 /**
  *	dev_set_mtu - Change maximum transfer unit
  *	@dev: device
@@ -5296,8 +5307,7 @@ EXPORT_SYMBOL(dev_change_flags);
  */
 int dev_set_mtu(struct net_device *dev, int new_mtu)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
-	int err;
+	int err, orig_mtu;
 
 	if (new_mtu == dev->mtu)
 		return 0;
@@ -5309,14 +5319,15 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 	if (!netif_device_present(dev))
 		return -ENODEV;
 
-	err = 0;
-	if (ops->ndo_change_mtu)
-		err = ops->ndo_change_mtu(dev, new_mtu);
-	else
-		dev->mtu = new_mtu;
+	orig_mtu = dev->mtu;
+	err = __dev_set_mtu(dev, new_mtu);
 
-	if (!err)
-		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
+	if (!err) {
+		err = call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
+		err = notifier_to_errno(err);
+		if (err)
+			__dev_set_mtu(dev, orig_mtu);
+	}
 	return err;
 }
 EXPORT_SYMBOL(dev_set_mtu);
-- 
1.8.4
