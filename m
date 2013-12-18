From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 5/5] bonding: add packets_per_slave attribute netlink
 support
Date: Tue, 17 Dec 2013 21:30:37 -0800
Message-ID: <20131218053037.13529.67219.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45849 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155Ab3LRFam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:30:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_PACKETS_PER_SLAVE to allow get/set of bonding parameter
packets_per_slave via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   21 +++++++++++++++++++++
 drivers/net/bonding/bond_options.c |   23 +++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   28 +++++++++++-----------------
 drivers/net/bonding/bonding.h      |    2 ++
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 58 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 319212c..a0a422e 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -19,6 +19,7 @@
 #include <linux/if_ether.h>
 #include <net/netlink.h>
 #include <net/rtnetlink.h>
+#include <linux/reciprocal_div.h>
 #include "bonding.h"
 
 static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
@@ -41,6 +42,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_ALL_SLAVES_ACTIVE]	= { .type = NLA_U8 },
 	[IFLA_BOND_MIN_LINKS]		= { .type = NLA_U32 },
 	[IFLA_BOND_LP_INTERVAL]		= { .type = NLA_U32 },
+	[IFLA_BOND_PACKETS_PER_SLAVE]	= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -241,6 +243,15 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_PACKETS_PER_SLAVE]) {
+		int packets_per_slave =
+			nla_get_u32(data[IFLA_BOND_PACKETS_PER_SLAVE]);
+
+		err = bond_option_packets_per_slave_set(bond,
+							packets_per_slave);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -278,6 +289,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u8)) +   /* IFLA_BOND_ALL_SLAVES_ACTIVE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIN_LINKS */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_LP_INTERVAL */
+		nla_total_size(sizeof(u32)) +  /* IFLA_BOND_PACKETS_PER_SLAVE */
 		0;
 }
 
@@ -287,6 +299,7 @@ static int bond_fill_info(struct sk_buff *skb,
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct net_device *slave_dev = bond_option_active_slave_get(bond);
 	struct nlattr *targets;
+	unsigned int packets_per_slave;
 	int i, targets_added;
 
 	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
@@ -374,6 +387,14 @@ static int bond_fill_info(struct sk_buff *skb,
 			bond->params.lp_interval))
 		goto nla_put_failure;
 
+	packets_per_slave = bond->params.packets_per_slave;
+	if (packets_per_slave > 1)
+		packets_per_slave = reciprocal_value(packets_per_slave);
+
+	if (nla_put_u32(skb, IFLA_BOND_PACKETS_PER_SLAVE,
+			packets_per_slave))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index e313a8f..f8a2cd8 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -16,6 +16,7 @@
 #include <linux/netdevice.h>
 #include <linux/rwlock.h>
 #include <linux/rcupdate.h>
+#include <linux/reciprocal_div.h>
 #include "bonding.h"
 
 static bool bond_mode_is_valid(int mode)
@@ -633,3 +634,25 @@ int bond_option_lp_interval_set(struct bonding *bond, int lp_interval)
 
 	return 0;
 }
+
+int bond_option_packets_per_slave_set(struct bonding *bond,
+				      int packets_per_slave)
+{
+	if (packets_per_slave < 0 || packets_per_slave > USHRT_MAX) {
+		pr_err("%s: packets_per_slave must be between 0 and %u\n",
+		       bond->dev->name, USHRT_MAX);
+		return -EINVAL;
+	}
+
+	if (bond->params.mode != BOND_MODE_ROUNDROBIN)
+		pr_warn("%s: Warning: packets_per_slave has effect only in balance-rr mode\n",
+			bond->dev->name);
+
+	if (packets_per_slave > 1)
+		bond->params.packets_per_slave =
+			reciprocal_value(packets_per_slave);
+	else
+		bond->params.packets_per_slave = packets_per_slave;
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index c4cdbf6..a0a3476f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1409,28 +1409,22 @@ static ssize_t bonding_store_packets_per_slave(struct device *d,
 					       const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret = count;
+	int new_value, ret;
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no packets_per_slave value specified.\n",
 		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (new_value < 0 || new_value > USHRT_MAX) {
-		pr_err("%s: packets_per_slave must be between 0 and %u\n",
-		       bond->dev->name, USHRT_MAX);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
-	if (bond->params.mode != BOND_MODE_ROUNDROBIN)
-		pr_warn("%s: Warning: packets_per_slave has effect only in balance-rr mode\n",
-			bond->dev->name);
-	if (new_value > 1)
-		bond->params.packets_per_slave = reciprocal_value(new_value);
-	else
-		bond->params.packets_per_slave = new_value;
-out:
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_packets_per_slave_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0a1a69e..5886f07 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -466,6 +466,8 @@ int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
 int bond_option_min_links_set(struct bonding *bond, int min_links);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
+int bond_option_packets_per_slave_set(struct bonding *bond,
+				      int packets_per_slave);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 4825ae7..8fbc7ca 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -348,6 +348,7 @@ enum {
 	IFLA_BOND_ALL_SLAVES_ACTIVE,
 	IFLA_BOND_MIN_LINKS,
 	IFLA_BOND_LP_INTERVAL,
+	IFLA_BOND_PACKETS_PER_SLAVE,
 	__IFLA_BOND_MAX,
 };
 
