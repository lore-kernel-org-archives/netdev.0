From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 4/5] bonding: add xmit_hash_policy attribute netlink
 support
Date: Sun, 15 Dec 2013 16:42:12 -0800
Message-ID: <20131216004212.13453.23799.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44707 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab3LPAmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 19:42:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_XMIT_HASH_POLICY to allow get/set of bonding parameter
xmit_hash_policy via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
 drivers/net/bonding/bond_options.c |   10 ++++++++++
 drivers/net/bonding/bond_sysfs.c   |   17 ++++++++++-------
 drivers/net/bonding/bonding.h      |    2 ++
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index d76bb1a..89c55d3 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -35,6 +35,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_PRIMARY]		= { .type = NLA_U32 },
 	[IFLA_BOND_PRIMARY_RESELECT]	= { .type = NLA_U8 },
 	[IFLA_BOND_FAIL_OVER_MAC]	= { .type = NLA_U8 },
+	[IFLA_BOND_XMIT_HASH_POLICY]	= { .type = NLA_U8 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -186,6 +187,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_XMIT_HASH_POLICY]) {
+		int xmit_hash_policy =
+			nla_get_u8(data[IFLA_BOND_XMIT_HASH_POLICY]);
+
+		err = bond_option_xmit_hash_policy_set(bond, xmit_hash_policy);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -217,6 +226,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_PRIMARY */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_PRIMARY_RESELECT */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_FAIL_OVER_MAC */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_XMIT_HASH_POLICY */
 		0;
 }
 
@@ -289,6 +299,10 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.fail_over_mac))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_XMIT_HASH_POLICY,
+		       bond->params.xmit_policy))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 86f4620..8510c6d 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -551,3 +551,13 @@ int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac)
 
 	return 0;
 }
+
+int bond_option_xmit_hash_policy_set(struct bonding *bond, int xmit_hash_policy)
+{
+	bond->params.xmit_policy = xmit_hash_policy;
+	pr_info("%s: setting xmit hash policy to %s (%d).\n",
+		bond->dev->name,
+		xmit_hashtype_tbl[xmit_hash_policy].modename, xmit_hash_policy);
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index c84a90f..4c75322 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -318,7 +318,7 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 				       struct device_attribute *attr,
 				       const char *buf, size_t count)
 {
-	int new_value, ret = count;
+	int new_value, ret;
 	struct bonding *bond = to_bond(d);
 
 	new_value = bond_parse_parm(buf, xmit_hashtype_tbl);
@@ -326,14 +326,17 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 		pr_err("%s: Ignoring invalid xmit hash policy value %.*s.\n",
 		       bond->dev->name,
 		       (int)strlen(buf) - 1, buf);
-		ret = -EINVAL;
-	} else {
-		bond->params.xmit_policy = new_value;
-		pr_info("%s: setting xmit hash policy to %s (%d).\n",
-			bond->dev->name,
-			xmit_hashtype_tbl[new_value].modename, new_value);
+		return -EINVAL;
 	}
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_xmit_hash_policy_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(xmit_hash_policy, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b69059b..4cb603e 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -458,6 +458,8 @@ int bond_option_primary_set(struct bonding *bond, const char *primary);
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     int primary_reselect);
 int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac);
+int bond_option_xmit_hash_policy_set(struct bonding *bond,
+				     int xmit_hash_policy);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index fd181ab..1a5d394 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -342,6 +342,7 @@ enum {
 	IFLA_BOND_PRIMARY,
 	IFLA_BOND_PRIMARY_RESELECT,
 	IFLA_BOND_FAIL_OVER_MAC,
+	IFLA_BOND_XMIT_HASH_POLICY,
 	__IFLA_BOND_MAX,
 };
 
