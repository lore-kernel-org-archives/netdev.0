From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/5] bonding: add lacp_rate attribute netlink
 support
Date: Fri, 03 Jan 2014 14:18:41 -0800
Message-ID: <20140103221841.1659.33879.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us, dingtianhong@huawei.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39584 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbaACWSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 17:18:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_AD_LACP_RATE to allow get/set of bonding parameter
lacp_rate via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 +++++++++++++
 drivers/net/bonding/bond_options.c |   29 ++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   40 ++++++++++--------------------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 56 insertions(+), 29 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 84acd144..45de873 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -43,6 +43,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_MIN_LINKS]		= { .type = NLA_U32 },
 	[IFLA_BOND_LP_INTERVAL]		= { .type = NLA_U32 },
 	[IFLA_BOND_PACKETS_PER_SLAVE]	= { .type = NLA_U32 },
+	[IFLA_BOND_AD_LACP_RATE]	= { .type = NLA_U8 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -252,6 +253,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_AD_LACP_RATE]) {
+		int lacp_rate =
+			nla_get_u8(data[IFLA_BOND_AD_LACP_RATE]);
+
+		err = bond_option_lacp_rate_set(bond, lacp_rate);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -290,6 +299,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIN_LINKS */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_LP_INTERVAL */
 		nla_total_size(sizeof(u32)) +  /* IFLA_BOND_PACKETS_PER_SLAVE */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_AD_LACP_RATE */
 		0;
 }
 
@@ -395,6 +405,10 @@ static int bond_fill_info(struct sk_buff *skb,
 			packets_per_slave))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_AD_LACP_RATE,
+		       bond->params.lacp_fast))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index f8a2cd8..ad67fbf 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -656,3 +656,32 @@ int bond_option_packets_per_slave_set(struct bonding *bond,
 
 	return 0;
 }
+
+int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate)
+{
+	if (bond->dev->flags & IFF_UP) {
+		pr_err("%s: Unable to update LACP rate because interface is up.\n",
+		       bond->dev->name);
+		return -EPERM;
+	}
+
+	if (bond->params.mode != BOND_MODE_8023AD) {
+		pr_err("%s: Unable to update LACP rate because bond is not in 802.3ad mode.\n",
+		       bond->dev->name);
+		return -EPERM;
+	}
+
+	if ((lacp_rate == 1) || (lacp_rate == 0)) {
+		bond->params.lacp_fast = lacp_rate;
+		bond_3ad_update_lacp_rate(bond);
+		pr_info("%s: Setting LACP rate to %s (%d).\n",
+			bond->dev->name, bond_lacp_tbl[lacp_rate].modename,
+			lacp_rate);
+	} else {
+		pr_err("%s: Ignoring invalid LACP rate value %d.\n",
+		       bond->dev->name, lacp_rate);
+		return -EINVAL;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a0a3476f..62d33dc 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -658,41 +658,23 @@ static ssize_t bonding_store_lacp(struct device *d,
 				  const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret = count;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	if (bond->dev->flags & IFF_UP) {
-		pr_err("%s: Unable to update LACP rate because interface is up.\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
-	if (bond->params.mode != BOND_MODE_8023AD) {
-		pr_err("%s: Unable to update LACP rate because bond is not in 802.3ad mode.\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
+	int new_value, ret;
 
 	new_value = bond_parse_parm(buf, bond_lacp_tbl);
-
-	if ((new_value == 1) || (new_value == 0)) {
-		bond->params.lacp_fast = new_value;
-		bond_3ad_update_lacp_rate(bond);
-		pr_info("%s: Setting LACP rate to %s (%d).\n",
-			bond->dev->name, bond_lacp_tbl[new_value].modename,
-			new_value);
-	} else {
+	if (new_value < 0) {
 		pr_err("%s: Ignoring invalid LACP rate value %.*s.\n",
 		       bond->dev->name, (int)strlen(buf) - 1, buf);
-		ret = -EINVAL;
+		return -EINVAL;
 	}
-out:
-	rtnl_unlock();
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_lacp_rate_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8e8817f..585bfef 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -464,6 +464,7 @@ int bond_option_min_links_set(struct bonding *bond, int min_links);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
 int bond_option_packets_per_slave_set(struct bonding *bond,
 				      int packets_per_slave);
+int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8fbc7ca..0f8f38f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -349,6 +349,7 @@ enum {
 	IFLA_BOND_MIN_LINKS,
 	IFLA_BOND_LP_INTERVAL,
 	IFLA_BOND_PACKETS_PER_SLAVE,
+	IFLA_BOND_AD_LACP_RATE,
 	__IFLA_BOND_MAX,
 };
 
