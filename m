From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 4/8] bonding: add use_carrier netlink support
Date: Thu, 07 Nov 2013 01:43:15 -0800
Message-ID: <20131107094315.15846.18644.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37358 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074Ab3KGJtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:49:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_USE_CARRIER to allow get/set of bonding parameter
use_carrier via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   12 ++++++++++++
 drivers/net/bonding/bond_options.c |   14 ++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   24 +++++++++++-------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index e684713..4f81d87 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -27,6 +27,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_MIIMON]		= { .type = NLA_U32 },
 	[IFLA_BOND_UPDELAY]		= { .type = NLA_U32 },
 	[IFLA_BOND_DOWNDELAY]		= { .type = NLA_U32 },
+	[IFLA_BOND_USE_CARRIER]		= { .type = NLA_U8 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -93,6 +94,13 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_USE_CARRIER]) {
+		int use_carrier = nla_get_u8(data[IFLA_BOND_USE_CARRIER]);
+
+		err = bond_option_use_carrier_set(bond, use_carrier);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -115,6 +123,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIIMON */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_UPDELAY */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_DOWNDELAY */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_USE_CARRIER */
 		0;
 }
 
@@ -140,6 +149,9 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (nla_put_u32(skb, IFLA_BOND_DOWNDELAY, bond->params.downdelay))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_USE_CARRIER, bond->params.use_carrier))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 738be5f..8743d6b 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -240,3 +240,17 @@ int bond_option_downdelay_set(struct bonding *bond, int downdelay)
 
 	return 0;
 }
+
+int bond_option_use_carrier_set(struct bonding *bond, int use_carrier)
+{
+	if ((use_carrier == 0) || (use_carrier == 1)) {
+		bond->params.use_carrier = use_carrier;
+		pr_info("%s: Setting use_carrier to %d.\n",
+			bond->dev->name, use_carrier);
+	} else {
+		pr_info("%s: Ignoring invalid use_carrier value %d.\n",
+			bond->dev->name, use_carrier);
+	}
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 41a62ac..c74d430 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1114,25 +1114,23 @@ static ssize_t bonding_store_carrier(struct device *d,
 				     struct device_attribute *attr,
 				     const char *buf, size_t count)
 {
-	int new_value, ret = count;
+	int new_value, ret;
 	struct bonding *bond = to_bond(d);
 
-
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no use_carrier value specified.\n",
 		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-	if ((new_value == 0) || (new_value == 1)) {
-		bond->params.use_carrier = new_value;
-		pr_info("%s: Setting use_carrier to %d.\n",
-			bond->dev->name, new_value);
-	} else {
-		pr_info("%s: Ignoring invalid use_carrier value %d.\n",
-			bond->dev->name, new_value);
+		return -EINVAL;
 	}
-out:
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_use_carrier_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(use_carrier, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 40987f3..1f3aef6 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -431,6 +431,7 @@ int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_
 int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_updelay_set(struct bonding *bond, int updelay);
 int bond_option_downdelay_set(struct bonding *bond, int downdelay);
+int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a372831..6101db7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -334,6 +334,7 @@ enum {
 	IFLA_BOND_MIIMON,
 	IFLA_BOND_UPDELAY,
 	IFLA_BOND_DOWNDELAY,
+	IFLA_BOND_USE_CARRIER,
 	__IFLA_BOND_MAX,
 };
 
