From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/2] net: add NETDEV_PRECHANGEMTU to notify before mtu change happens
Date: Thu, 16 Jan 2014 00:02:18 +0100
Message-ID: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846AbaAOXGp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 18:06:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if a device changes its mtu, first the change happens (invloving
all the side effects), and after that the NETDEV_CHANGEMTU is sent so that
other devices can catch up with the new mtu. However, if they return
NOTIFY_BAD, then the change is reverted and error returned.

This is a really long and costy operation (sometimes). To fix this, add
NETDEV_PRECHANGEMTU notification which is called prior to any change
actually happening, and if any callee returns NOTIFY_BAD - the change is
aborted. This way we're skipping all the playing with apply/revert the mtu.

CC: "David S. Miller" <davem@davemloft.net>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Eric Dumazet <edumazet@google.com>
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h | 3 ++-
 net/core/dev.c            | 5 +++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5c88ab1..6fa2c91 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1718,7 +1718,7 @@ struct pcpu_sw_netstats {
 #define NETDEV_CHANGE	0x0004	/* Notify device state change */
 #define NETDEV_REGISTER 0x0005
 #define NETDEV_UNREGISTER	0x0006
-#define NETDEV_CHANGEMTU	0x0007
+#define NETDEV_CHANGEMTU	0x0007 /* notify after mtu change happened */
 #define NETDEV_CHANGEADDR	0x0008
 #define NETDEV_GOING_DOWN	0x0009
 #define NETDEV_CHANGENAME	0x000A
@@ -1734,6 +1734,7 @@ struct pcpu_sw_netstats {
 #define NETDEV_JOIN		0x0014
 #define NETDEV_CHANGEUPPER	0x0015
 #define NETDEV_RESEND_IGMP	0x0016
+#define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 20c834e..cb78923 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5360,6 +5360,11 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 	if (!netif_device_present(dev))
 		return -ENODEV;
 
+	err = call_netdevice_notifiers(NETDEV_PRECHANGEMTU, dev);
+	err = notifier_to_errno(err);
+	if (err)
+		return err;
+
 	orig_mtu = dev->mtu;
 	err = __dev_set_mtu(dev, new_mtu);
 
-- 
1.8.4
