From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: allow notifier subscribers to forbid device from closing
Date: Wed, 31 Aug 2011 17:15:31 +0200
Message-ID: <1314803731-1222-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755849Ab1HaPPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:15:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some situations, like when the device is used as slave device in
bond/br/etc it is not nice if someone closes the device. This allows
it's masters to forbid this closure.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   34 ++++++++++++++++++++++++++++------
 net/core/rtnetlink.c      |    1 +
 3 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dad7e4d..b8047d3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1559,6 +1559,7 @@ struct packet_type {
 #define NETDEV_RELEASE		0x0012
 #define NETDEV_NOTIFY_PEERS	0x0013
 #define NETDEV_JOIN		0x0014
+#define NETDEV_PRE_DOWN		0x0015
 
 extern int register_netdevice_notifier(struct notifier_block *nb);
 extern int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 11b0fc7..d252a7e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1253,11 +1253,24 @@ static int __dev_close_many(struct list_head *head)
 	return 0;
 }
 
+static int __dev_pre_close(struct net_device *dev)
+{
+	int err;
+
+	err = call_netdevice_notifiers(NETDEV_PRE_DOWN, dev);
+	if (err)
+		return notifier_to_errno(err);
+	return 0;
+}
+
 static int __dev_close(struct net_device *dev)
 {
 	int retval;
 	LIST_HEAD(single);
 
+	retval = __dev_pre_close(dev);
+	if (retval)
+		return retval;
 	list_add(&dev->unreg_list, &single);
 	retval = __dev_close_many(&single);
 	list_del(&single);
@@ -1269,9 +1282,12 @@ static int dev_close_many(struct list_head *head)
 	struct net_device *dev, *tmp;
 	LIST_HEAD(tmp_list);
 
-	list_for_each_entry_safe(dev, tmp, head, unreg_list)
+	list_for_each_entry_safe(dev, tmp, head, unreg_list) {
 		if (!(dev->flags & IFF_UP))
 			list_move(&dev->unreg_list, &tmp_list);
+		else
+			__dev_pre_close(dev);
+	}
 
 	__dev_close_many(head);
 
@@ -1289,21 +1305,26 @@ static int dev_close_many(struct list_head *head)
  *	dev_close - shutdown an interface.
  *	@dev: device to shutdown
  *
- *	This function moves an active device into down state. A
- *	%NETDEV_GOING_DOWN is sent to the netdev notifier chain. The device
- *	is then deactivated and finally a %NETDEV_DOWN is sent to the notifier
- *	chain.
+ *	This function moves an active device into down state.
+ *	A %NETDEV_PRE_DOWN and %NETDEV_GOING_DOWN is sent to the netdev
+ *	notifier chain. The device is then deactivated and finally
+ *	a %NETDEV_DOWN is sent to the notifier chain.
  */
 int dev_close(struct net_device *dev)
 {
+	int retval = 0;
+
 	if (dev->flags & IFF_UP) {
 		LIST_HEAD(single);
 
+		retval = __dev_pre_close(dev);
+		if (retval)
+			return retval;
 		list_add(&dev->unreg_list, &single);
 		dev_close_many(&single);
 		list_del(&single);
 	}
-	return 0;
+	return retval;
 }
 EXPORT_SYMBOL(dev_close);
 
@@ -1397,6 +1418,7 @@ rollback:
 				break;
 
 			if (dev->flags & IFF_UP) {
+				nb->notifier_call(nb, NETDEV_PRE_DOWN, dev);
 				nb->notifier_call(nb, NETDEV_GOING_DOWN, dev);
 				nb->notifier_call(nb, NETDEV_DOWN, dev);
 			}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 39f8dd6..34f5b32 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1997,6 +1997,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_UP:
 	case NETDEV_DOWN:
 	case NETDEV_PRE_UP:
+	case NETDEV_PRE_DOWN:
 	case NETDEV_POST_INIT:
 	case NETDEV_REGISTER:
 	case NETDEV_CHANGE:
-- 
1.7.6
