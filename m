From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] vlan: fix bond/team enslave of vlan challenged slave/port
Date: Sun, 14 Oct 2012 16:30:56 +0200
Message-ID: <1350225056-14144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, jstanley@rmrf.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:45465 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354Ab2JNObB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 10:31:01 -0400
Received: by mail-wi0-f170.google.com with SMTP id hm2so54925wib.1
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 07:30:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vlan_uses_dev() check for number of vlan devs rather than existence
of vlan_info. The reason is that vlan id 0 is there without appropriate
vlan dev on it by default which prevented from enslaving vlan challenged
dev.

Reported-by: Jon Stanley <jstanley@rmrf.net>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c | 2 +-
 net/8021q/vlan_core.c           | 9 ++++++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b721902..b2530b0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1519,7 +1519,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_debug("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
-		if (bond_vlan_used(bond)) {
+		if (vlan_uses_dev(bond_dev)) {
 			pr_err("%s: Error: cannot enslave VLAN challenged slave %s on VLAN enabled bond %s\n",
 			       bond_dev->name, slave_dev->name, bond_dev->name);
 			return -EPERM;
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index fbbf1fa..65e06ab 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -366,6 +366,13 @@ EXPORT_SYMBOL(vlan_vids_del_by_dev);
 
 bool vlan_uses_dev(const struct net_device *dev)
 {
-	return rtnl_dereference(dev->vlan_info) ? true : false;
+	struct vlan_info *vlan_info;
+
+	ASSERT_RTNL();
+
+	vlan_info = rtnl_dereference(dev->vlan_info);
+	if (!vlan_info)
+		return false;
+	return vlan_info->grp.nr_vlan_devs ? true : false;
 }
 EXPORT_SYMBOL(vlan_uses_dev);
-- 
1.7.11.4
