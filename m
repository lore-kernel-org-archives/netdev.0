From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 20/25] bonding: convert active_slave to use the new option API
Date: Wed, 22 Jan 2014 14:53:35 +0100
Message-ID: <1390398820-5355-21-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755979AbaAVNyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:13 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDsCl2001429
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:12 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so active_slave would use
the new bonding option API. Also some trivial/style fixes.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    |  4 +++-
 drivers/net/bonding/bond_netlink.c |  9 +++++----
 drivers/net/bonding/bond_options.c | 30 +++++++++++++++++++++++-------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 24 ++----------------------
 drivers/net/bonding/bonding.h      |  1 -
 6 files changed, 36 insertions(+), 35 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 59edf18..2ca949f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3123,6 +3123,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	struct ifslave k_sinfo;
 	struct ifslave __user *u_sinfo = NULL;
 	struct mii_ioctl_data *mii = NULL;
+	struct bond_opt_value newval;
 	struct net *net;
 	int res = 0;
 
@@ -3218,7 +3219,8 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		break;
 	case BOND_CHANGE_ACTIVE_OLD:
 	case SIOCBONDCHANGEACTIVE:
-		res = bond_option_active_slave_set(bond, slave_dev);
+		bond_opt_initstr(&newval, slave_dev->name);
+		res = __bond_opt_set(bond, BOND_OPT_ACTIVE_SLAVE, &newval);
 		break;
 	default:
 		res = -EOPNOTSUPP;
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 2175e19..dba1f2e 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -116,16 +116,17 @@ static int bond_changelink(struct net_device *bond_dev,
 	if (data[IFLA_BOND_ACTIVE_SLAVE]) {
 		int ifindex = nla_get_u32(data[IFLA_BOND_ACTIVE_SLAVE]);
 		struct net_device *slave_dev;
+		char *active_slave = "";
 
-		if (ifindex == 0) {
-			slave_dev = NULL;
-		} else {
+		if (ifindex != 0) {
 			slave_dev = __dev_get_by_index(dev_net(bond_dev),
 						       ifindex);
 			if (!slave_dev)
 				return -ENODEV;
+			active_slave = slave_dev->name;
 		}
-		err = bond_option_active_slave_set(bond, slave_dev);
+		bond_opt_initstr(&newval, active_slave);
+		err = __bond_opt_set(bond, BOND_OPT_ACTIVE_SLAVE, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 18b1cc0..2315104d 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -244,6 +244,16 @@ static struct bond_option bond_opts[] = {
 		.values = bond_use_carrier_tbl,
 		.set = bond_option_use_carrier_set
 	},
+	[BOND_OPT_ACTIVE_SLAVE] = {
+		.id = BOND_OPT_ACTIVE_SLAVE,
+		.name = "active_slave",
+		.desc = "Currently active slave",
+		.flags = BOND_OPTFLAG_RAWVAL,
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_ACTIVEBACKUP) |
+						BIT(BOND_MODE_TLB) |
+						BIT(BOND_MODE_ALB)),
+		.set = bond_option_active_slave_set
+	},
 	{ }
 };
 
@@ -556,10 +566,21 @@ struct net_device *bond_option_active_slave_get(struct bonding *bond)
 }
 
 int bond_option_active_slave_set(struct bonding *bond,
-				 struct net_device *slave_dev)
+				 struct bond_opt_value *newval)
 {
+	char ifname[IFNAMSIZ] = { 0, };
+	struct net_device *slave_dev;
 	int ret = 0;
 
+	sscanf(newval->string, "%15s", ifname); /* IFNAMSIZ */
+	if (!strlen(ifname) || newval->string[0] == '\n') {
+		slave_dev = NULL;
+	} else {
+		slave_dev = __dev_get_by_name(dev_net(bond->dev), ifname);
+		if (!slave_dev)
+			return -ENODEV;
+	}
+
 	if (slave_dev) {
 		if (!netif_is_bond_slave(slave_dev)) {
 			pr_err("Device %s is not bonding slave.\n",
@@ -574,12 +595,6 @@ int bond_option_active_slave_set(struct bonding *bond,
 		}
 	}
 
-	if (!USES_PRIMARY(bond->params.mode)) {
-		pr_err("%s: Unable to change active slave; %s is in mode %d\n",
-		       bond->dev->name, bond->dev->name, bond->params.mode);
-		return -EINVAL;
-	}
-
 	block_netpoll_tx();
 	write_lock_bh(&bond->curr_slave_lock);
 
@@ -616,6 +631,7 @@ int bond_option_active_slave_set(struct bonding *bond,
 
 	write_unlock_bh(&bond->curr_slave_lock);
 	unblock_netpoll_tx();
+
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 229f5c1..1f486a7 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -56,6 +56,7 @@ enum {
 	BOND_OPT_PRIMARY,
 	BOND_OPT_PRIMARY_RESELECT,
 	BOND_OPT_USE_CARRIER,
+	BOND_OPT_ACTIVE_SLAVE,
 	BOND_OPT_LAST
 };
 
@@ -150,4 +151,6 @@ int bond_option_primary_reselect_set(struct bonding *bond,
 				     struct bond_opt_value *newval);
 int bond_option_use_carrier_set(struct bonding *bond,
 				struct bond_opt_value *newval);
+int bond_option_active_slave_set(struct bonding *bond,
+				 struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0040482..181a59d 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -809,34 +809,14 @@ static ssize_t bonding_store_active_slave(struct device *d,
 					  struct device_attribute *attr,
 					  const char *buf, size_t count)
 {
-	int ret;
 	struct bonding *bond = to_bond(d);
-	char ifname[IFNAMSIZ];
-	struct net_device *dev;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	sscanf(buf, "%15s", ifname); /* IFNAMSIZ */
-	if (!strlen(ifname) || buf[0] == '\n') {
-		dev = NULL;
-	} else {
-		dev = __dev_get_by_name(dev_net(bond->dev), ifname);
-		if (!dev) {
-			ret = -ENODEV;
-			goto out;
-		}
-	}
+	int ret;
 
-	ret = bond_option_active_slave_set(bond, dev);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ACTIVE_SLAVE, (char *)buf);
 	if (!ret)
 		ret = count;
 
- out:
-	rtnl_unlock();
-
 	return ret;
-
 }
 static DEVICE_ATTR(active_slave, S_IRUGO | S_IWUSR,
 		   bonding_show_active_slave, bonding_store_active_slave);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 51f3b0a..4ac79e1 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -452,7 +452,6 @@ void bond_setup(struct net_device *bond_dev);
 unsigned int bond_get_num_tx_queues(void);
 int bond_netlink_init(void);
 void bond_netlink_fini(void);
-int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
-- 
1.8.4.2
