From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 1/8] bonding: add miimon netlink support
Date: Thu, 07 Nov 2013 01:42:54 -0800
Message-ID: <20131107094254.15846.53456.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37360 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754077Ab3KGJtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:49:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_MIIMON to allow get/set of bonding parameter
miimon via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   32 ++++++++++++++++++----
 drivers/net/bonding/bond_options.c |   42 +++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   53 +++++++-----------------------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 80 insertions(+), 49 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 40e7b1c..38dd2f1 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -1,6 +1,7 @@
 /*
  * drivers/net/bond/bond_netlink.c - Netlink interface for bonding
  * Copyright (c) 2013 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2013 Scott Feldman <sfeldma@cumulusnetworks.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -23,6 +24,7 @@
 static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_MODE]		= { .type = NLA_U8 },
 	[IFLA_BOND_ACTIVE_SLAVE]	= { .type = NLA_U32 },
+	[IFLA_BOND_MIIMON]		= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -42,14 +44,17 @@ static int bond_changelink(struct net_device *bond_dev,
 	struct bonding *bond = netdev_priv(bond_dev);
 	int err;
 
-	if (data && data[IFLA_BOND_MODE]) {
+	if (!data)
+		return 0;
+
+	if (data[IFLA_BOND_MODE]) {
 		int mode = nla_get_u8(data[IFLA_BOND_MODE]);
 
 		err = bond_option_mode_set(bond, mode);
 		if (err)
 			return err;
 	}
-	if (data && data[IFLA_BOND_ACTIVE_SLAVE]) {
+	if (data[IFLA_BOND_ACTIVE_SLAVE]) {
 		int ifindex = nla_get_u32(data[IFLA_BOND_ACTIVE_SLAVE]);
 		struct net_device *slave_dev;
 
@@ -65,6 +70,13 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_MIIMON]) {
+		int miimon = nla_get_u32(data[IFLA_BOND_MIIMON]);
+
+		err = bond_option_miimon_set(bond, miimon);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -83,7 +95,9 @@ static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
 static size_t bond_get_size(const struct net_device *bond_dev)
 {
 	return nla_total_size(sizeof(u8)) +	/* IFLA_BOND_MODE */
-		nla_total_size(sizeof(u32));	/* IFLA_BOND_ACTIVE_SLAVE */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ACTIVE_SLAVE */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIIMON */
+		0;
 }
 
 static int bond_fill_info(struct sk_buff *skb,
@@ -92,10 +106,16 @@ static int bond_fill_info(struct sk_buff *skb,
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct net_device *slave_dev = bond_option_active_slave_get(bond);
 
-	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode) ||
-	    (slave_dev &&
-	     nla_put_u32(skb, IFLA_BOND_ACTIVE_SLAVE, slave_dev->ifindex)))
+	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
 		goto nla_put_failure;
+
+	if (slave_dev &&
+	     nla_put_u32(skb, IFLA_BOND_ACTIVE_SLAVE, slave_dev->ifindex))
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, IFLA_BOND_MIIMON, bond->params.miimon))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 9a5223c..eaafab9 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1,6 +1,7 @@
 /*
  * drivers/net/bond/bond_options.c - bonding options
  * Copyright (c) 2013 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2013 Scott Feldman <sfeldma@cumulusnetworks.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -140,3 +141,44 @@ int bond_option_active_slave_set(struct bonding *bond,
 	unblock_netpoll_tx();
 	return ret;
 }
+
+int bond_option_miimon_set(struct bonding *bond, int miimon)
+{
+	if (miimon < 0) {
+		pr_err("%s: Invalid miimon value %d not in range %d-%d; rejected.\n",
+		       bond->dev->name, miimon, 0, INT_MAX);
+		return -EINVAL;
+	}
+	pr_info("%s: Setting MII monitoring interval to %d.\n",
+		bond->dev->name, miimon);
+	bond->params.miimon = miimon;
+	if (bond->params.updelay)
+		pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value.\n",
+			bond->dev->name,
+			bond->params.updelay * bond->params.miimon);
+	if (bond->params.downdelay)
+		pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value.\n",
+			bond->dev->name,
+			bond->params.downdelay * bond->params.miimon);
+	if (miimon && bond->params.arp_interval) {
+		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
+			bond->dev->name);
+		bond->params.arp_interval = 0;
+		if (bond->params.arp_validate)
+			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
+	}
+	if (bond->dev->flags & IFF_UP) {
+		/* If the interface is up, we may need to fire off
+		 * the MII timer. If the interface is down, the
+		 * timer will get fired off when the open function
+		 * is called.
+		 */
+		if (!miimon) {
+			cancel_delayed_work_sync(&bond->mii_work);
+		} else {
+			cancel_delayed_work_sync(&bond->arp_work);
+			queue_delayed_work(bond->wq, &bond->mii_work, 0);
+		}
+	}
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 47749c9..2fb9777 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -981,55 +981,22 @@ static ssize_t bonding_store_miimon(struct device *d,
 				    struct device_attribute *attr,
 				    const char *buf, size_t count)
 {
-	int new_value, ret = count;
+	int new_value, ret;
 	struct bonding *bond = to_bond(d);
 
-	if (!rtnl_trylock())
-		return restart_syscall();
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no miimon value specified.\n",
 		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (new_value < 0) {
-		pr_err("%s: Invalid miimon value %d not in range %d-%d; rejected.\n",
-		       bond->dev->name, new_value, 0, INT_MAX);
-		ret = -EINVAL;
-		goto out;
-	}
-	pr_info("%s: Setting MII monitoring interval to %d.\n",
-		bond->dev->name, new_value);
-	bond->params.miimon = new_value;
-	if (bond->params.updelay)
-		pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value.\n",
-			bond->dev->name,
-			bond->params.updelay * bond->params.miimon);
-	if (bond->params.downdelay)
-		pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value.\n",
-			bond->dev->name,
-			bond->params.downdelay * bond->params.miimon);
-	if (new_value && bond->params.arp_interval) {
-		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
-			bond->dev->name);
-		bond->params.arp_interval = 0;
-		if (bond->params.arp_validate)
-			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
-	}
-	if (bond->dev->flags & IFF_UP) {
-		/* If the interface is up, we may need to fire off
-		 * the MII timer. If the interface is down, the
-		 * timer will get fired off when the open function
-		 * is called.
-		 */
-		if (!new_value) {
-			cancel_delayed_work_sync(&bond->mii_work);
-		} else {
-			cancel_delayed_work_sync(&bond->arp_work);
-			queue_delayed_work(bond->wq, &bond->mii_work, 0);
-		}
+		return -EINVAL;
 	}
-out:
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_miimon_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
 	rtnl_unlock();
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 046a605..91d7eae 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -428,6 +428,7 @@ int bond_netlink_init(void);
 void bond_netlink_fini(void);
 int bond_option_mode_set(struct bonding *bond, int mode);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
+int bond_option_miimon_set(struct bonding *bond, int miimon);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b78566f..b38472b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -331,6 +331,7 @@ enum {
 	IFLA_BOND_UNSPEC,
 	IFLA_BOND_MODE,
 	IFLA_BOND_ACTIVE_SLAVE,
+	IFLA_BOND_MIIMON,
 	__IFLA_BOND_MAX,
 };
 
