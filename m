From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/5] bonding: add ad_select attribute netlink
 support
Date: Fri, 03 Jan 2014 14:18:49 -0800
Message-ID: <20140103221849.1659.8145.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us, dingtianhong@huawei.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39605 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbaACWSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 17:18:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_AD_SELECT to allow get/set of bonding parameter
ad_select via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c    |   45 +++++++++++++++++++++++-------------
 drivers/net/bonding/bond_netlink.c |   14 +++++++++++
 drivers/net/bonding/bond_options.c |   22 ++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   29 ++++++++++-------------
 drivers/net/bonding/bonding.h      |    2 ++
 include/uapi/linux/if_link.h       |    1 +
 6 files changed, 80 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 11bedba..e06c445 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3933,6 +3933,29 @@ static void bond_uninit(struct net_device *bond_dev)
 
 /*------------------------- Module initialization ---------------------------*/
 
+int bond_parm_tbl_lookup(int mode, const struct bond_parm_tbl *tbl)
+{
+	int i;
+
+	for (i = 0; tbl[i].modename; i++)
+		if (mode == tbl[i].mode)
+			return tbl[i].mode;
+
+	return -1;
+}
+
+static int bond_parm_tbl_lookup_name(const char *modename,
+				     const struct bond_parm_tbl *tbl)
+{
+	int i;
+
+	for (i = 0; tbl[i].modename; i++)
+		if (strcmp(modename, tbl[i].modename) == 0)
+			return tbl[i].mode;
+
+	return -1;
+}
+
 /*
  * Convert string input module parms.  Accept either the
  * number of the mode or its string name.  A bit complicated because
@@ -3941,27 +3964,17 @@ static void bond_uninit(struct net_device *bond_dev)
  */
 int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
 {
-	int modeint = -1, i, rv;
-	char *p, modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
+	int modeint;
+	char *p, modestr[BOND_MAX_MODENAME_LEN + 1];
 
 	for (p = (char *)buf; *p; p++)
 		if (!(isdigit(*p) || isspace(*p)))
 			break;
 
-	if (*p)
-		rv = sscanf(buf, "%20s", modestr);
-	else
-		rv = sscanf(buf, "%d", &modeint);
-
-	if (!rv)
-		return -1;
-
-	for (i = 0; tbl[i].modename; i++) {
-		if (modeint == tbl[i].mode)
-			return tbl[i].mode;
-		if (strcmp(modestr, tbl[i].modename) == 0)
-			return tbl[i].mode;
-	}
+	if (*p && sscanf(buf, "%20s", modestr) != 0)
+		return bond_parm_tbl_lookup_name(modestr, tbl);
+	else if (sscanf(buf, "%d", &modeint) != 0)
+		return bond_parm_tbl_lookup(modeint, tbl);
 
 	return -1;
 }
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 45de873..df66dd8 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -44,6 +44,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_LP_INTERVAL]		= { .type = NLA_U32 },
 	[IFLA_BOND_PACKETS_PER_SLAVE]	= { .type = NLA_U32 },
 	[IFLA_BOND_AD_LACP_RATE]	= { .type = NLA_U8 },
+	[IFLA_BOND_AD_SELECT]		= { .type = NLA_U8 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -261,6 +262,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_AD_SELECT]) {
+		int ad_select =
+			nla_get_u8(data[IFLA_BOND_AD_SELECT]);
+
+		err = bond_option_ad_select_set(bond, ad_select);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -300,6 +309,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_LP_INTERVAL */
 		nla_total_size(sizeof(u32)) +  /* IFLA_BOND_PACKETS_PER_SLAVE */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_AD_LACP_RATE */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_AD_SELECT */
 		0;
 }
 
@@ -409,6 +419,10 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.lacp_fast))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_AD_SELECT,
+		       bond->params.ad_select))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index ad67fbf..c9691bf 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -685,3 +685,25 @@ int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate)
 
 	return 0;
 }
+
+int bond_option_ad_select_set(struct bonding *bond, int ad_select)
+{
+	if (bond->dev->flags & IFF_UP) {
+		pr_err("%s: Unable to update ad_select because interface is up.\n",
+		       bond->dev->name);
+		return -EPERM;
+	}
+
+	if (bond_parm_tbl_lookup(ad_select, ad_select_tbl) < 0) {
+		pr_err("%s: Ignoring invalid ad_select value %d.\n",
+		       bond->dev->name, ad_select);
+		return -EINVAL;
+	}
+
+	bond->params.ad_select = ad_select;
+	pr_info("%s: Setting ad_select to %s (%d).\n",
+		bond->dev->name, ad_select_tbl[ad_select].modename,
+		ad_select);
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 62d33dc..9a1ea4a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -733,29 +733,24 @@ static ssize_t bonding_store_ad_select(struct device *d,
 				       struct device_attribute *attr,
 				       const char *buf, size_t count)
 {
-	int new_value, ret = count;
+	int new_value, ret;
 	struct bonding *bond = to_bond(d);
 
-	if (bond->dev->flags & IFF_UP) {
-		pr_err("%s: Unable to update ad_select because interface is up.\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
 	new_value = bond_parse_parm(buf, ad_select_tbl);
-
-	if (new_value != -1) {
-		bond->params.ad_select = new_value;
-		pr_info("%s: Setting ad_select to %s (%d).\n",
-			bond->dev->name, ad_select_tbl[new_value].modename,
-			new_value);
-	} else {
+	if (new_value < 0) {
 		pr_err("%s: Ignoring invalid ad_select value %.*s.\n",
 		       bond->dev->name, (int)strlen(buf) - 1, buf);
-		ret = -EINVAL;
+		return -EINVAL;
 	}
-out:
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_ad_select_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 585bfef..955dc48 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -425,6 +425,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count);
 int bond_parse_parm(const char *mode_arg, const struct bond_parm_tbl *tbl);
+int bond_parm_tbl_lookup(int mode, const struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_create_debugfs(void);
@@ -465,6 +466,7 @@ int bond_option_lp_interval_set(struct bonding *bond, int min_links);
 int bond_option_packets_per_slave_set(struct bonding *bond,
 				      int packets_per_slave);
 int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate);
+int bond_option_ad_select_set(struct bonding *bond, int ad_select);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 0f8f38f..0fbb018 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -350,6 +350,7 @@ enum {
 	IFLA_BOND_LP_INTERVAL,
 	IFLA_BOND_PACKETS_PER_SLAVE,
 	IFLA_BOND_AD_LACP_RATE,
+	IFLA_BOND_AD_SELECT,
 	__IFLA_BOND_MAX,
 };
 
