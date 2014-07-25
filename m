From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 3/3] vlan: fail early when creating netdev named config
Date: Fri, 25 Jul 2014 15:25:10 -0700
Message-ID: <1406327110-17227-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1406327110-17227-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stephane.chazelas@gmail.com, f.fainelli@gmail.com,
	davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:40035 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761155AbaGYWZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 18:25:33 -0400
Received: by mail-pd0-f180.google.com with SMTP id y13so6324323pdi.11
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 15:25:32 -0700 (PDT)
In-Reply-To: <1406327110-17227-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly, vlan will create  /proc/net/vlan/<dev>, so when we
create dev with name "config", it will confict with
/proc/net/vlan/config.

Reported-by: Stephane Chazelas <stephane.chazelas@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/8021q/vlan.c     | 21 +++++++++++++--------
 net/8021q/vlanproc.c |  2 ++
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index cba9c21..64c6bed 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -325,23 +325,24 @@ static void vlan_transfer_features(struct net_device *dev,
 	netdev_update_features(vlandev);
 }
 
-static void __vlan_device_event(struct net_device *dev, unsigned long event)
+static int __vlan_device_event(struct net_device *dev, unsigned long event)
 {
+	int err = 0;
+
 	switch (event) {
 	case NETDEV_CHANGENAME:
 		vlan_proc_rem_dev(dev);
-		if (vlan_proc_add_dev(dev) < 0)
-			pr_warn("failed to change proc name for %s\n",
-				dev->name);
+		err = vlan_proc_add_dev(dev);
 		break;
 	case NETDEV_REGISTER:
-		if (vlan_proc_add_dev(dev) < 0)
-			pr_warn("failed to add proc entry for %s\n", dev->name);
+		err = vlan_proc_add_dev(dev);
 		break;
 	case NETDEV_UNREGISTER:
 		vlan_proc_rem_dev(dev);
 		break;
 	}
+
+	return err;
 }
 
 static int vlan_device_event(struct notifier_block *unused, unsigned long event,
@@ -356,8 +357,12 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	bool last = false;
 	LIST_HEAD(list);
 
-	if (is_vlan_dev(dev))
-		__vlan_device_event(dev, event);
+	if (is_vlan_dev(dev)) {
+		int err = __vlan_device_event(dev, event);
+
+		if (err)
+			return notifier_from_errno(err);
+	}
 
 	if ((event == NETDEV_UP) &&
 	    (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 1d0e8921..ae63cf7 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -171,6 +171,8 @@ int vlan_proc_add_dev(struct net_device *vlandev)
 	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 	struct vlan_net *vn = net_generic(dev_net(vlandev), vlan_net_id);
 
+	if (!strcmp(vlandev->name, name_conf))
+		return -EINVAL;
 	vlan->dent =
 		proc_create_data(vlandev->name, S_IFREG|S_IRUSR|S_IWUSR,
 				 vn->proc_vlan_dir, &vlandev_fops, vlandev);
-- 
1.8.3.1
