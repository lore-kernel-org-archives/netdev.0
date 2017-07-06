From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] bonding: avoid NETDEV_CHANGEMTU event when unregistering slave
Date: Thu,  6 Jul 2017 15:01:57 -0700
Message-ID: <1499378517-5042-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: hongjun.li@6wind.com, nicolas.dichtel@6wind.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35234 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752812AbdGFWCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 18:02:13 -0400
Received: by mail-pg0-f67.google.com with SMTP id d193so1665623pgc.2
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 15:02:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Hongjun/Nicolas summarized in their original patch:

"
When a device changes from one netns to another, it's first unregistered,
then the netns reference is updated and the dev is registered in the new
netns. Thus, when a slave moves to another netns, it is first
unregistered. This triggers a NETDEV_UNREGISTER event which is caught by
the bonding driver. The driver calls bond_release(), which calls
dev_set_mtu() and thus triggers NETDEV_CHANGEMTU (the device is still in
the old netns).
"

This is a very special case, because the device is being unregistered
no one should still care about the NETDEV_CHANGEMTU event triggered
at this point, we can avoid broadcasting this event on this path,
and avoid touching inetdev_event()/addrconf_notify() path.

It requires to export __dev_set_mtu() to bonding driver.

Reported-by: Hongjun Li <hongjun.li@6wind.com>
Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/bonding/bond_main.c | 15 +++++++++------
 include/linux/netdevice.h       |  1 +
 net/core/dev.c                  |  3 ++-
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8ab6bdb..2971af1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1820,7 +1820,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
  */
 static int __bond_release_one(struct net_device *bond_dev,
 			      struct net_device *slave_dev,
-			      bool all)
+			      bool all, bool unregister)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
@@ -1965,7 +1965,10 @@ static int __bond_release_one(struct net_device *bond_dev,
 		dev_set_mac_address(slave_dev, (struct sockaddr *)&ss);
 	}
 
-	dev_set_mtu(slave_dev, slave->original_mtu);
+	if (unregister)
+		__dev_set_mtu(slave_dev, slave->original_mtu);
+	else
+		dev_set_mtu(slave_dev, slave->original_mtu);
 
 	slave_dev->priv_flags &= ~IFF_BONDING;
 
@@ -1977,7 +1980,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 /* A wrapper used because of ndo_del_link */
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	return __bond_release_one(bond_dev, slave_dev, false);
+	return __bond_release_one(bond_dev, slave_dev, false, false);
 }
 
 /* First release a slave and then destroy the bond if no more slaves are left.
@@ -1989,7 +1992,7 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 	struct bonding *bond = netdev_priv(bond_dev);
 	int ret;
 
-	ret = bond_release(bond_dev, slave_dev);
+	ret = __bond_release_one(bond_dev, slave_dev, false, true);
 	if (ret == 0 && !bond_has_slaves(bond)) {
 		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
 		netdev_info(bond_dev, "Destroying bond %s\n",
@@ -3060,7 +3063,7 @@ static int bond_slave_netdev_event(unsigned long event,
 		if (bond_dev->type != ARPHRD_ETHER)
 			bond_release_and_destroy(bond_dev, slave_dev);
 		else
-			bond_release(bond_dev, slave_dev);
+			__bond_release_one(bond_dev, slave_dev, false, true);
 		break;
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
@@ -4257,7 +4260,7 @@ static void bond_uninit(struct net_device *bond_dev)
 
 	/* Release the bonded slaves */
 	bond_for_each_slave(bond, slave, iter)
-		__bond_release_one(bond_dev, slave->dev, true);
+		__bond_release_one(bond_dev, slave->dev, true, true);
 	netdev_info(bond_dev, "Released all slaves\n");
 
 	arr = rtnl_dereference(bond->slave_arr);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4ed952c..e4030db 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3287,6 +3287,7 @@ void __dev_notify_flags(struct net_device *, unsigned int old_flags,
 int dev_change_name(struct net_device *, const char *);
 int dev_set_alias(struct net_device *, const char *, size_t);
 int dev_change_net_namespace(struct net_device *, struct net *, const char *);
+int __dev_set_mtu(struct net_device *, int);
 int dev_set_mtu(struct net_device *, int);
 void dev_set_group(struct net_device *, int);
 int dev_set_mac_address(struct net_device *, struct sockaddr *);
diff --git a/net/core/dev.c b/net/core/dev.c
index 416137c..e567de8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6688,7 +6688,7 @@ int dev_change_flags(struct net_device *dev, unsigned int flags)
 }
 EXPORT_SYMBOL(dev_change_flags);
 
-static int __dev_set_mtu(struct net_device *dev, int new_mtu)
+int __dev_set_mtu(struct net_device *dev, int new_mtu)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
@@ -6698,6 +6698,7 @@ static int __dev_set_mtu(struct net_device *dev, int new_mtu)
 	dev->mtu = new_mtu;
 	return 0;
 }
+EXPORT_SYMBOL(__dev_set_mtu);
 
 /**
  *	dev_set_mtu - Change maximum transfer unit
-- 
2.5.5
