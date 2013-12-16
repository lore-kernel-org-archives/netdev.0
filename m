From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 3/5] bonding: add fail_over_mac attribute netlink
 support
Date: Sun, 15 Dec 2013 16:42:05 -0800
Message-ID: <20131216004205.13453.56832.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44689 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab3LPAmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 19:42:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_FAIL_OVER_MAC to allow get/set of bonding parameter
fail_over_mac via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
 drivers/net/bonding/bond_options.c |   16 ++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   26 ++++++++------------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 40 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 9d11e43..d76bb1a 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -34,6 +34,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_ARP_ALL_TARGETS]	= { .type = NLA_U32 },
 	[IFLA_BOND_PRIMARY]		= { .type = NLA_U32 },
 	[IFLA_BOND_PRIMARY_RESELECT]	= { .type = NLA_U8 },
+	[IFLA_BOND_FAIL_OVER_MAC]	= { .type = NLA_U8 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -177,6 +178,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_FAIL_OVER_MAC]) {
+		int fail_over_mac =
+			nla_get_u8(data[IFLA_BOND_FAIL_OVER_MAC]);
+
+		err = bond_option_fail_over_mac_set(bond, fail_over_mac);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -207,6 +216,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_ALL_TARGETS */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_PRIMARY */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_PRIMARY_RESELECT */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_FAIL_OVER_MAC */
 		0;
 }
 
@@ -275,6 +285,10 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.primary_reselect))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_FAIL_OVER_MAC,
+		       bond->params.fail_over_mac))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 80a9df4..86f4620 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -535,3 +535,19 @@ int bond_option_primary_reselect_set(struct bonding *bond, int primary_reselect)
 
 	return 0;
 }
+
+int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac)
+{
+	if (bond_has_slaves(bond)) {
+		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
+		       bond->dev->name);
+		return -EPERM;
+	}
+
+	bond->params.fail_over_mac = fail_over_mac;
+	pr_info("%s: Setting fail_over_mac to %s (%d).\n",
+		bond->dev->name, fail_over_mac_tbl[fail_over_mac].modename,
+		fail_over_mac);
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 324afa5..c84a90f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -442,33 +442,23 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
 					   struct device_attribute *attr,
 					   const char *buf, size_t count)
 {
-	int new_value, ret = count;
+	int new_value, ret;
 	struct bonding *bond = to_bond(d);
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	if (bond_has_slaves(bond)) {
-		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
 	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
 	if (new_value < 0) {
 		pr_err("%s: Ignoring invalid fail_over_mac value %s.\n",
 		       bond->dev->name, buf);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
-	bond->params.fail_over_mac = new_value;
-	pr_info("%s: Setting fail_over_mac to %s (%d).\n",
-		bond->dev->name, fail_over_mac_tbl[new_value].modename,
-		new_value);
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_fail_over_mac_set(bond, new_value);
+	if (!ret)
+		ret = count;
 
-out:
 	rtnl_unlock();
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4e89d04..b69059b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -457,6 +457,7 @@ int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets);
 int bond_option_primary_set(struct bonding *bond, const char *primary);
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     int primary_reselect);
+int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index cf59d54..fd181ab 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -341,6 +341,7 @@ enum {
 	IFLA_BOND_ARP_ALL_TARGETS,
 	IFLA_BOND_PRIMARY,
 	IFLA_BOND_PRIMARY_RESELECT,
+	IFLA_BOND_FAIL_OVER_MAC,
 	__IFLA_BOND_MAX,
 };
 
