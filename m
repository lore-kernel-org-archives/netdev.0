From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 2/3] bonding: check return value of nofitier
 when changing type
Date: Wed, 10 Mar 2010 21:29:35 +0100
Message-ID: <20100310202935.GE2834@psychotron.redhat.com>
References: <20100310202804.GC2834@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63220 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754768Ab0CJU3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 15:29:54 -0500
Content-Disposition: inline
In-Reply-To: <20100310202804.GC2834@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the possibility to refuse the bonding type change for other
subsystems (such as for example bridge, vlan, etc.)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |   11 +++++++++--
 include/linux/netdevice.h       |    2 +-
 net/core/dev.c                  |    4 ++--
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7eeb187..cbe9e35 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1480,8 +1480,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 				 bond_dev->name,
 				 bond_dev->type, slave_dev->type);
 
-			netdev_bonding_change(bond_dev,
-					      NETDEV_PRE_TYPE_CHANGE);
+			res = netdev_bonding_change(bond_dev,
+						    NETDEV_PRE_TYPE_CHANGE);
+			res = notifier_to_errno(res);
+			if (res) {
+				pr_err("%s: refused to change device type\n",
+				       bond_dev->name);
+				res = -EBUSY;
+				goto err_undo_flags;
+			}
 
 			if (slave_dev->type != ARPHRD_ETHER)
 				bond_setup_by_slave(bond_dev, slave_dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c79a88b..8cf1d50 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1975,7 +1975,7 @@ extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct
 extern int		dev_set_promiscuity(struct net_device *dev, int inc);
 extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
-extern void		netdev_bonding_change(struct net_device *dev,
+extern int		netdev_bonding_change(struct net_device *dev,
 					      unsigned long event);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
diff --git a/net/core/dev.c b/net/core/dev.c
index bcc490c..5de4a15 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1084,9 +1084,9 @@ void netdev_state_change(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_state_change);
 
-void netdev_bonding_change(struct net_device *dev, unsigned long event)
+int netdev_bonding_change(struct net_device *dev, unsigned long event)
 {
-	call_netdevice_notifiers(event, dev);
+	return call_netdevice_notifiers(event, dev);
 }
 EXPORT_SYMBOL(netdev_bonding_change);
 
-- 
1.6.6.1

