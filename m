From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 5/8] bonding: add arp_interval netlink support
Date: Thu, 12 Dec 2013 14:10:24 -0800
Message-ID: <20131212221023.21629.65304.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53349 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab3LLWK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 17:10:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_ARP_INTERVAL to allow get/set of bonding parameter
arp_interval via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   21 ++++++++++++
 drivers/net/bonding/bond_options.c |   47 ++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   61 ++++++------------------------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 80 insertions(+), 51 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 7edf639..58e7123 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -28,6 +28,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_UPDELAY]		= { .type = NLA_U32 },
 	[IFLA_BOND_DOWNDELAY]		= { .type = NLA_U32 },
 	[IFLA_BOND_USE_CARRIER]		= { .type = NLA_U8 },
+	[IFLA_BOND_ARP_INTERVAL]	= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -45,6 +46,7 @@ static int bond_changelink(struct net_device *bond_dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	int miimon = 0;
 	int err;
 
 	if (!data)
@@ -74,7 +76,7 @@ static int bond_changelink(struct net_device *bond_dev,
 			return err;
 	}
 	if (data[IFLA_BOND_MIIMON]) {
-		int miimon = nla_get_u32(data[IFLA_BOND_MIIMON]);
+		miimon = nla_get_u32(data[IFLA_BOND_MIIMON]);
 
 		err = bond_option_miimon_set(bond, miimon);
 		if (err)
@@ -101,6 +103,19 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_ARP_INTERVAL]) {
+		int arp_interval = nla_get_u32(data[IFLA_BOND_ARP_INTERVAL]);
+
+		if (arp_interval && miimon) {
+			pr_err("%s: ARP monitoring cannot be used with MII monitoring.\n",
+			       bond->dev->name);
+			return -EINVAL;
+		}
+
+		err = bond_option_arp_interval_set(bond, arp_interval);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -124,6 +139,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_UPDELAY */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_DOWNDELAY */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_USE_CARRIER */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_INTERVAL */
 		0;
 }
 
@@ -154,6 +170,9 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (nla_put_u8(skb, IFLA_BOND_USE_CARRIER, bond->params.use_carrier))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, IFLA_BOND_ARP_INTERVAL, bond->params.arp_interval))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 6fc7bbf..a84e729 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -259,3 +259,50 @@ int bond_option_use_carrier_set(struct bonding *bond, int use_carrier)
 
 	return 0;
 }
+
+int bond_option_arp_interval_set(struct bonding *bond, int arp_interval)
+{
+	if (arp_interval < 0) {
+		pr_err("%s: Invalid arp_interval value %d not in range 0-%d; rejected.\n",
+		       bond->dev->name, arp_interval, INT_MAX);
+		return -EINVAL;
+	}
+	if (BOND_NO_USES_ARP(bond->params.mode)) {
+		pr_info("%s: ARP monitoring cannot be used with ALB/TLB/802.3ad. Only MII monitoring is supported on %s.\n",
+			bond->dev->name, bond->dev->name);
+		return -EINVAL;
+	}
+	pr_info("%s: Setting ARP monitoring interval to %d.\n",
+		bond->dev->name, arp_interval);
+	bond->params.arp_interval = arp_interval;
+	if (arp_interval) {
+		if (bond->params.miimon) {
+			pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
+				bond->dev->name, bond->dev->name);
+			bond->params.miimon = 0;
+		}
+		if (!bond->params.arp_targets[0])
+			pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
+				bond->dev->name);
+	}
+	if (bond->dev->flags & IFF_UP) {
+		/* If the interface is up, we may need to fire off
+		 * the ARP timer.  If the interface is down, the
+		 * timer will get fired off when the open function
+		 * is called.
+		 */
+		if (!arp_interval) {
+			if (bond->params.arp_validate)
+				bond->recv_probe = NULL;
+			cancel_delayed_work_sync(&bond->arp_work);
+		} else {
+			/* arp_validate can be set only in active-backup mode */
+			if (bond->params.arp_validate)
+				bond->recv_probe = bond_arp_rcv;
+			cancel_delayed_work_sync(&bond->mii_work);
+			queue_delayed_work(bond->wq, &bond->arp_work, 0);
+		}
+	}
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 114760a..12128bf 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -506,60 +506,21 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 					  const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret = count;
+	int new_value, ret;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no arp_interval value specified.\n",
-		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (new_value < 0) {
-		pr_err("%s: Invalid arp_interval value %d not in range 0-%d; rejected.\n",
-		       bond->dev->name, new_value, INT_MAX);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (BOND_NO_USES_ARP(bond->params.mode)) {
-		pr_info("%s: ARP monitoring cannot be used with ALB/TLB/802.3ad. Only MII monitoring is supported on %s.\n",
-			bond->dev->name, bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-	pr_info("%s: Setting ARP monitoring interval to %d.\n",
-		bond->dev->name, new_value);
-	bond->params.arp_interval = new_value;
-	if (new_value) {
-		if (bond->params.miimon) {
-			pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
-				bond->dev->name, bond->dev->name);
-			bond->params.miimon = 0;
-		}
-		if (!bond->params.arp_targets[0])
-			pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
-				bond->dev->name);
-	}
-	if (bond->dev->flags & IFF_UP) {
-		/* If the interface is up, we may need to fire off
-		 * the ARP timer.  If the interface is down, the
-		 * timer will get fired off when the open function
-		 * is called.
-		 */
-		if (!new_value) {
-			if (bond->params.arp_validate)
-				bond->recv_probe = NULL;
-			cancel_delayed_work_sync(&bond->arp_work);
-		} else {
-			/* arp_validate can be set only in active-backup mode */
-			if (bond->params.arp_validate)
-				bond->recv_probe = bond_arp_rcv;
-			cancel_delayed_work_sync(&bond->mii_work);
-			queue_delayed_work(bond->wq, &bond->arp_work, 0);
-		}
+		bond->dev->name);
+		return -EINVAL;
 	}
-out:
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_arp_interval_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
 	rtnl_unlock();
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index df159da..44df273 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -443,6 +443,7 @@ int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_updelay_set(struct bonding *bond, int updelay);
 int bond_option_downdelay_set(struct bonding *bond, int downdelay);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
+int bond_option_arp_interval_set(struct bonding *bond, int arp_interval);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 77c41bd..c73d878 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -335,6 +335,7 @@ enum {
 	IFLA_BOND_UPDELAY,
 	IFLA_BOND_DOWNDELAY,
 	IFLA_BOND_USE_CARRIER,
+	IFLA_BOND_ARP_INTERVAL,
 	__IFLA_BOND_MAX,
 };
 
