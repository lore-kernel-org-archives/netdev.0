From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][VLAN]: Proc entry is not renamed when vlan device name changes.
Date: Mon, 31 Mar 2008 17:06:15 +0400
Message-ID: <47F0E1C7.7040908@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50226 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbYCaNGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:06:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This may lead to situations, when each of two proc entries produce
data for the other's device.

Looks like a BUG, so this patch is for net-2.6. It will not apply 
to net-2.6.26 since dev->nd_net access is replaced with dev_net(dev) 
one. Should I rework the patch to fit 2.6.26?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index dbc81b9..b33410a 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -374,17 +374,35 @@ static void vlan_sync_address(struct net_device *dev,
 	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
 }
 
+static void __vlan_device_event(struct net_device *dev, unsigned long event)
+{
+	switch (event) {
+	case NETDEV_CHANGENAME:
+		vlan_proc_rem_dev(dev);
+		if (vlan_proc_add_dev(dev) < 0)
+			pr_warning("8021q: failed to change proc name for %s\n",
+					dev->name);
+		break;
+	}
+}
+
 static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			     void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct vlan_group *grp = __vlan_find_group(dev->ifindex);
+	struct vlan_group *grp;
 	int i, flgs;
 	struct net_device *vlandev;
 
 	if (dev->nd_net != &init_net)
 		return NOTIFY_DONE;
 
+	if (is_vlan_dev(dev)) {
+		__vlan_device_event(dev, event);
+		goto out;
+	}
+
+	grp = __vlan_find_group(dev->ifindex);
 	if (!grp)
 		goto out;
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 73efcc7..51271ae 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -45,4 +45,9 @@ void vlan_netlink_fini(void);
 
 extern struct rtnl_link_ops vlan_link_ops;
 
+static inline int is_vlan_dev(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_802_1Q_VLAN;
+}
+
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 146cfb0..9671aa5 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -210,11 +210,6 @@ int vlan_proc_rem_dev(struct net_device *vlandev)
  * The following few functions build the content of /proc/net/vlan/config
  */
 
-static inline int is_vlan_dev(struct net_device *dev)
-{
-	return dev->priv_flags & IFF_802_1Q_VLAN;
-}
-
 /* start read of /proc/net/vlan/config */
 static void *vlan_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(dev_base_lock)

