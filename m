From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 5/8] bonding: add arp_interval netlink support
Date: Thu, 07 Nov 2013 01:43:23 -0800
Message-ID: <20131107094322.15846.10917.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37565 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab3KGJyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:54:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_ARP_INTERVAL to allow get/set of bonding parameter
arp_interval via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   12 +++++++
 drivers/net/bonding/bond_options.c |   48 ++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   58 ++++++------------------------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 71 insertions(+), 49 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 4f81d87..9c50165 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -28,6 +28,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_UPDELAY]		= { .type = NLA_U32 },
 	[IFLA_BOND_DOWNDELAY]		= { .type = NLA_U32 },
 	[IFLA_BOND_USE_CARRIER]		= { .type = NLA_U8 },
+	[IFLA_BOND_ARP_INTERVAL]	= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -101,6 +102,13 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_ARP_INTERVAL]) {
+		int arp_interval = nla_get_u32(data[IFLA_BOND_ARP_INTERVAL]);
+
+		err = bond_option_arp_interval_set(bond, arp_interval);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -124,6 +132,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_UPDELAY */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_DOWNDELAY */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_USE_CARRIER */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_INTERVAL */
 		0;
 }
 
@@ -152,6 +161,9 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (nla_put_u8(skb, IFLA_BOND_USE_CARRIER, bond->params.use_carrier))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, IFLA_BOND_ARP_INTERVAL, bond->params.arp_interval))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 8743d6b..c4b60ad 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -254,3 +254,51 @@ int bond_option_use_carrier_set(struct bonding *bond, int use_carrier)
 
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
+	if (bond->params.mode == BOND_MODE_ALB ||
+	    bond->params.mode == BOND_MODE_TLB) {
+		pr_info("%s: ARP monitoring cannot be used with ALB/TLB. Only MII monitoring is supported on %s.\n",
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
index c74d430..644b745 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -517,59 +517,19 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 	struct bonding *bond = to_bond(d);
 	int new_value, ret = count;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no arp_interval value specified.\n",
 		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (new_value < 0) {
-		pr_err("%s: Invalid arp_interval value %d not in range 0-%d; rejected.\n",
-		       bond->dev->name, new_value, INT_MAX);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (bond->params.mode == BOND_MODE_ALB ||
-	    bond->params.mode == BOND_MODE_TLB) {
-		pr_info("%s: ARP monitoring cannot be used with ALB/TLB. Only MII monitoring is supported on %s.\n",
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
index 1f3aef6..caaa5e7 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -432,6 +432,7 @@ int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_updelay_set(struct bonding *bond, int updelay);
 int bond_option_downdelay_set(struct bonding *bond, int downdelay);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
+int bond_option_arp_interval_set(struct bonding *bond, int arp_interval);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 6101db7..858b09e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -335,6 +335,7 @@ enum {
 	IFLA_BOND_UPDELAY,
 	IFLA_BOND_DOWNDELAY,
 	IFLA_BOND_USE_CARRIER,
+	IFLA_BOND_ARP_INTERVAL,
 	__IFLA_BOND_MAX,
 };
 
