From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 4/5] bonding: add lp_interval attribute netlink
 support
Date: Tue, 17 Dec 2013 21:30:30 -0800
Message-ID: <20131218053030.13529.42150.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45837 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155Ab3LRFaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:30:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_LP_INTERVAL to allow get/set of bonding parameter
lp_interval via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
 drivers/net/bonding/bond_options.c |   13 +++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   20 +++++++++-----------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 1b65118..319212c 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -40,6 +40,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_NUM_PEER_NOTIF]	= { .type = NLA_U8 },
 	[IFLA_BOND_ALL_SLAVES_ACTIVE]	= { .type = NLA_U8 },
 	[IFLA_BOND_MIN_LINKS]		= { .type = NLA_U32 },
+	[IFLA_BOND_LP_INTERVAL]		= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -232,6 +233,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_LP_INTERVAL]) {
+		int lp_interval =
+			nla_get_u32(data[IFLA_BOND_LP_INTERVAL]);
+
+		err = bond_option_lp_interval_set(bond, lp_interval);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -268,6 +277,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_NUM_PEER_NOTIF */
 		nla_total_size(sizeof(u8)) +   /* IFLA_BOND_ALL_SLAVES_ACTIVE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIN_LINKS */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_LP_INTERVAL */
 		0;
 }
 
@@ -360,6 +370,10 @@ static int bond_fill_info(struct sk_buff *skb,
 			bond->params.min_links))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, IFLA_BOND_LP_INTERVAL,
+			bond->params.lp_interval))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index da49ac4..e313a8f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -620,3 +620,16 @@ int bond_option_min_links_set(struct bonding *bond, int min_links)
 
 	return 0;
 }
+
+int bond_option_lp_interval_set(struct bonding *bond, int lp_interval)
+{
+	if (lp_interval <= 0) {
+		pr_err("%s: lp_interval must be between 1 and %d\n",
+		       bond->dev->name, INT_MAX);
+		return -EINVAL;
+	}
+
+	bond->params.lp_interval = lp_interval;
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 359adda..c4cdbf6 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1369,24 +1369,22 @@ static ssize_t bonding_store_lp_interval(struct device *d,
 					 const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret = count;
+	int new_value, ret;
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no lp interval value specified.\n",
 			bond->dev->name);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
-	if (new_value <= 0) {
-		pr_err ("%s: lp_interval must be between 1 and %d\n",
-			bond->dev->name, INT_MAX);
-		ret = -EINVAL;
-		goto out;
-	}
+	if (!rtnl_trylock())
+		return restart_syscall();
 
-	bond->params.lp_interval = new_value;
-out:
+	ret = bond_option_lp_interval_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 7d7ad1c..0a1a69e 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -465,6 +465,7 @@ int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
 int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
 int bond_option_min_links_set(struct bonding *bond, int min_links);
+int bond_option_lp_interval_set(struct bonding *bond, int min_links);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c7a0f89..4825ae7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -347,6 +347,7 @@ enum {
 	IFLA_BOND_NUM_PEER_NOTIF,
 	IFLA_BOND_ALL_SLAVES_ACTIVE,
 	IFLA_BOND_MIN_LINKS,
+	IFLA_BOND_LP_INTERVAL,
 	__IFLA_BOND_MAX,
 };
 
