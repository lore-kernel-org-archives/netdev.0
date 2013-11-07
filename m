From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 2/8] bonding: add updelay netlink support
Date: Thu, 07 Nov 2013 01:43:01 -0800
Message-ID: <20131107094301.15846.45204.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37356 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433Ab3KGJtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:49:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_UPDELAY to allow get/set of bonding parameter
updelay via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   12 +++++++++++
 drivers/net/bonding/bond_options.c |   29 +++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   39 +++++++++---------------------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 53 insertions(+), 29 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 38dd2f1..9ba5431 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -25,6 +25,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_MODE]		= { .type = NLA_U8 },
 	[IFLA_BOND_ACTIVE_SLAVE]	= { .type = NLA_U32 },
 	[IFLA_BOND_MIIMON]		= { .type = NLA_U32 },
+	[IFLA_BOND_UPDELAY]		= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -77,6 +78,13 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_UPDELAY]) {
+		int updelay = nla_get_u32(data[IFLA_BOND_UPDELAY]);
+
+		err = bond_option_updelay_set(bond, updelay);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -97,6 +105,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 	return nla_total_size(sizeof(u8)) +	/* IFLA_BOND_MODE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ACTIVE_SLAVE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIIMON */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_UPDELAY */
 		0;
 }
 
@@ -116,6 +125,9 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (nla_put_u32(skb, IFLA_BOND_MIIMON, bond->params.miimon))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, IFLA_BOND_UPDELAY, bond->params.updelay))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index eaafab9..c0fea66 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -182,3 +182,32 @@ int bond_option_miimon_set(struct bonding *bond, int miimon)
 	}
 	return 0;
 }
+
+int bond_option_updelay_set(struct bonding *bond, int updelay)
+{
+	if (!(bond->params.miimon)) {
+		pr_err("%s: Unable to set up delay as MII monitoring is disabled\n",
+		       bond->dev->name);
+		return -EPERM;
+	}
+
+	if (updelay < 0) {
+		pr_err("%s: Invalid up delay value %d not in range %d-%d; rejected.\n",
+		       bond->dev->name, updelay, 0, INT_MAX);
+		return -EINVAL;
+	} else {
+		if ((updelay % bond->params.miimon) != 0) {
+			pr_warn("%s: Warning: up delay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
+				bond->dev->name, updelay,
+				bond->params.miimon,
+				(updelay / bond->params.miimon) *
+				bond->params.miimon);
+		}
+		bond->params.updelay = updelay / bond->params.miimon;
+		pr_info("%s: Setting up delay to %d.\n",
+			bond->dev->name,
+			bond->params.updelay * bond->params.miimon);
+	}
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 2fb9777..1125bef 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -761,42 +761,23 @@ static ssize_t bonding_store_updelay(struct device *d,
 				     struct device_attribute *attr,
 				     const char *buf, size_t count)
 {
-	int new_value, ret = count;
+	int new_value, ret;
 	struct bonding *bond = to_bond(d);
 
-	if (!(bond->params.miimon)) {
-		pr_err("%s: Unable to set up delay as MII monitoring is disabled\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no up delay value specified.\n",
 		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (new_value < 0) {
-		pr_err("%s: Invalid up delay value %d not in range %d-%d; rejected.\n",
-		       bond->dev->name, new_value, 0, INT_MAX);
-		ret = -EINVAL;
-		goto out;
-	} else {
-		if ((new_value % bond->params.miimon) != 0) {
-			pr_warning("%s: Warning: up delay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
-				   bond->dev->name, new_value,
-				   bond->params.miimon,
-				   (new_value / bond->params.miimon) *
-				   bond->params.miimon);
-		}
-		bond->params.updelay = new_value / bond->params.miimon;
-		pr_info("%s: Setting up delay to %d.\n",
-			bond->dev->name,
-			bond->params.updelay * bond->params.miimon);
+		return -EINVAL;
 	}
 
-out:
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_updelay_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(updelay, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 91d7eae..408e6c2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -429,6 +429,7 @@ void bond_netlink_fini(void);
 int bond_option_mode_set(struct bonding *bond, int mode);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
 int bond_option_miimon_set(struct bonding *bond, int miimon);
+int bond_option_updelay_set(struct bonding *bond, int updelay);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b38472b..361414e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -332,6 +332,7 @@ enum {
 	IFLA_BOND_MODE,
 	IFLA_BOND_ACTIVE_SLAVE,
 	IFLA_BOND_MIIMON,
+	IFLA_BOND_UPDELAY,
 	__IFLA_BOND_MAX,
 };
 
