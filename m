From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 1/3] net: add a new NETDEV_CHANGEROOM event type
Date: Tue, 20 Aug 2013 13:45:50 +0100
Message-ID: <1377002752-4622-2-git-send-email-f.fainelli@gmail.com>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, jiri@resnulli.us, stephen@networkplumber.org,
	kaber@trash.net, davem@davemloft.net, vyasevic@redhat.com,
	johannes@sipsolutions.net, eric.dumazet@gmail.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3445 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279Ab3HTMqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 08:46:13 -0400
In-Reply-To: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The event NETDEV_CHANGEROOM event can be used by devices/subsystems
which need to adjust their needed_headroom and/or needed_tailroom
requirements dynamically. Two helper functions are introduced:

- dev_set_headroom(dev, new_headroom)
- dev_set_taioroom(dev, new_tailroom)

which will notify listeners of such a change.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h |  3 +++
 net/core/dev.c            | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 077363d..2b3e56c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1652,6 +1652,7 @@ struct packet_offload {
 #define NETDEV_JOIN		0x0014
 #define NETDEV_CHANGEUPPER	0x0015
 #define NETDEV_RESEND_IGMP	0x0016
+#define NETDEV_CHANGEROOM	0x0017 /* needed_headroom/tailroom change */
 
 extern int register_netdevice_notifier(struct notifier_block *nb);
 extern int unregister_netdevice_notifier(struct notifier_block *nb);
@@ -2329,6 +2330,8 @@ extern int		dev_change_net_namespace(struct net_device *,
 						 struct net *, const char *);
 extern int		dev_set_mtu(struct net_device *, int);
 extern void		dev_set_group(struct net_device *, int);
+extern int		dev_set_headroom(struct net_device *, unsigned short);
+extern int		dev_set_tailroom(struct net_device *, unsigned short);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
 extern int		dev_change_carrier(struct net_device *,
diff --git a/net/core/dev.c b/net/core/dev.c
index 1ed2b66..be712be 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4931,6 +4931,52 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 EXPORT_SYMBOL(dev_set_mtu);
 
 /**
+ *	dev_set_headroom - Change device needed headroom
+ *	@dev: device
+ *	@new_headroom: new headroom size
+ *
+ * 	Change the network device headroom space.
+ */
+int dev_set_headroom(struct net_device *dev, unsigned short new_headroom)
+{
+	if (dev->needed_headroom == new_headroom)
+		return 0;
+
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	dev->needed_headroom = new_headroom;
+
+	call_netdevice_notifiers(NETDEV_CHANGEROOM, dev);
+
+	return 0;
+}
+EXPORT_SYMBOL(dev_set_headroom);
+
+/**
+ *	dev_set_tailroom - Change device needed tailroom
+ *	@dev: device
+ *	@new_tailroom: new tailroom size
+ *
+ * 	Change the network device tailroom space.
+ */
+int dev_set_tailroom(struct net_device *dev, unsigned short new_tailroom)
+{
+	if (dev->needed_tailroom == new_tailroom)
+		return 0;
+
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	dev->needed_tailroom = new_tailroom;
+
+	call_netdevice_notifiers(NETDEV_CHANGEROOM, dev);
+
+	return 0;
+}
+EXPORT_SYMBOL(dev_set_tailroom);
+
+/**
  *	dev_set_group - Change group this device belongs to
  *	@dev: device
  *	@new_group: group this device should belong to
-- 
1.8.1.2
