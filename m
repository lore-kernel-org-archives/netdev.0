From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 1/4] net: add ndo to get id of physical port of the device
Date: Thu, 25 Jul 2013 15:03:02 +0200
Message-ID: <1374757385-10875-2-git-send-email-jiri@resnulli.us>
References: <1374757385-10875-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:45778 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755805Ab3GYNDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:03:16 -0400
Received: by mail-ee0-f43.google.com with SMTP id l10so920425eei.30
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 06:03:14 -0700 (PDT)
In-Reply-To: <1374757385-10875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a ndo for getting physical port of the device. Driver
which is aware of being virtual function of some physical port should
implement this ndo. This is applicable not only for IOV, but for other
solutions (NPAR, multichannel) as well. Basically if there is possible
to have multiple netdevs on the single hw port.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h | 20 ++++++++++++++++++++
 net/core/dev.c            | 18 ++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3ca60b0..875f869 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -728,6 +728,16 @@ struct netdev_fcoe_hbainfo {
 };
 #endif
 
+#define MAX_PHYS_PORT_ID_LEN 32
+
+/* This structure holds a unique identifier to identify the
+ * physical port used by a netdevice.
+ */
+struct netdev_phys_port_id {
+	unsigned char id[MAX_PHYS_PORT_ID_LEN];
+	unsigned char id_len;
+};
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -932,6 +942,12 @@ struct netdev_fcoe_hbainfo {
  *	that determine carrier state from physical hardware properties (eg
  *	network cables) or protocol-dependent mechanisms (eg
  *	USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
+ *
+ * int (*ndo_get_phys_port_id)(struct net_device *dev,
+ *			       struct netdev_phys_port_id *ppid);
+ *	Called to get ID of physical port of this device. If driver does
+ *	not implement this, it is assumed that the hw is not able to have
+ *	multiple net devices on single physical port.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1060,6 +1076,8 @@ struct net_device_ops {
 						      struct nlmsghdr *nlh);
 	int			(*ndo_change_carrier)(struct net_device *dev,
 						      bool new_carrier);
+	int			(*ndo_get_phys_port_id)(struct net_device *dev,
+							struct netdev_phys_port_id *ppid);
 };
 
 /*
@@ -2315,6 +2333,8 @@ extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
 extern int		dev_change_carrier(struct net_device *,
 					   bool new_carrier);
+extern int		dev_get_phys_port_id(struct net_device *dev,
+					     struct netdev_phys_port_id *ppid);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev,
 					    struct netdev_queue *txq);
diff --git a/net/core/dev.c b/net/core/dev.c
index dfd9f5d..58eb802 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4989,6 +4989,24 @@ int dev_change_carrier(struct net_device *dev, bool new_carrier)
 EXPORT_SYMBOL(dev_change_carrier);
 
 /**
+ *	dev_get_phys_port_id - Get device physical port ID
+ *	@dev: device
+ *	@ppid: port ID
+ *
+ *	Get device physical port ID
+ */
+int dev_get_phys_port_id(struct net_device *dev,
+			 struct netdev_phys_port_id *ppid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_get_phys_port_id)
+		return -EOPNOTSUPP;
+	return ops->ndo_get_phys_port_id(dev, ppid);
+}
+EXPORT_SYMBOL(dev_get_phys_port_id);
+
+/**
  *	dev_new_index	-	allocate an ifindex
  *	@net: the applicable net namespace
  *
-- 
1.8.1.4
