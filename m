From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: add netnotifier event for upper device change
Date: Sat, 25 May 2013 16:12:10 +0200
Message-ID: <1369491130-7412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	alexander.h.duyck@intel.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:52945 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756598Ab3EYOMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 10:12:16 -0400
Received: by mail-wg0-f50.google.com with SMTP id k13so3419264wgh.29
        for <netdev@vger.kernel.org>; Sat, 25 May 2013 07:12:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when upper device is changed, event is not propagated via RT Netlink
to userspace. Userspace might never now about the change. Fix this by
adding upper-device-change notifier event.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h | 1 +
 net/core/dev.c            | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0ebd63a..ea7b6bc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1593,6 +1593,7 @@ struct packet_offload {
 #define NETDEV_RELEASE		0x0012
 #define NETDEV_NOTIFY_PEERS	0x0013
 #define NETDEV_JOIN		0x0014
+#define NETDEV_CHANGEUPPER	0x0015
 
 extern int register_netdevice_notifier(struct notifier_block *nb);
 extern int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 7229bc3..50c02de 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4411,7 +4411,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	else
 		list_add_tail_rcu(&upper->list, &dev->upper_dev_list);
 	dev_hold(upper_dev);
-
+	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
 	return 0;
 }
 
@@ -4471,6 +4471,7 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 	list_del_rcu(&upper->list);
 	dev_put(upper_dev);
 	kfree_rcu(upper, rcu);
+	call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev);
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
-- 
1.8.1.4
