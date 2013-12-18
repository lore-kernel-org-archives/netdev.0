From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 2/5] bonding: add all_slaves_active attribute netlink
 support
Date: Tue, 17 Dec 2013 21:30:16 -0800
Message-ID: <20131218053016.13529.63686.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45807 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab3LRFaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:30:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_ALL_SLAVES_ACTIVE to allow get/set of bonding parameter
all_slaves_active via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   15 +++++++++++++++
 drivers/net/bonding/bond_options.c |   29 +++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   34 +++++++---------------------------
 drivers/net/bonding/bonding.h      |    2 ++
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 54 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 4a79b01..ebc600f 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -38,6 +38,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_XMIT_HASH_POLICY]	= { .type = NLA_U8 },
 	[IFLA_BOND_RESEND_IGMP]		= { .type = NLA_U32 },
 	[IFLA_BOND_NUM_PEER_NOTIF]	= { .type = NLA_U8 },
+	[IFLA_BOND_ALL_SLAVES_ACTIVE]	= { .type = NLA_U8 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -213,6 +214,15 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_ALL_SLAVES_ACTIVE]) {
+		int all_slaves_active =
+			nla_get_u8(data[IFLA_BOND_ALL_SLAVES_ACTIVE]);
+
+		err = bond_option_all_slaves_active_set(bond,
+							all_slaves_active);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -247,6 +257,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_XMIT_HASH_POLICY */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_RESEND_IGMP */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_NUM_PEER_NOTIF */
+		nla_total_size(sizeof(u8)) +   /* IFLA_BOND_ALL_SLAVES_ACTIVE */
 		0;
 }
 
@@ -331,6 +342,10 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.num_peer_notif))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_ALL_SLAVES_ACTIVE,
+		       bond->params.all_slaves_active))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 01a9669..cbd8322 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -582,3 +582,32 @@ int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif)
 	bond->params.num_peer_notif = num_peer_notif;
 	return 0;
 }
+
+int bond_option_all_slaves_active_set(struct bonding *bond,
+				      int all_slaves_active)
+{
+	struct list_head *iter;
+	struct slave *slave;
+
+	if (all_slaves_active == bond->params.all_slaves_active)
+		return 0;
+
+	if ((all_slaves_active == 0) || (all_slaves_active == 1)) {
+		bond->params.all_slaves_active = all_slaves_active;
+	} else {
+		pr_info("%s: Ignoring invalid all_slaves_active value %d.\n",
+			bond->dev->name, all_slaves_active);
+		return -EINVAL;
+	}
+
+	bond_for_each_slave(bond, slave, iter) {
+		if (!bond_is_active_slave(slave)) {
+			if (all_slaves_active)
+				slave->inactive = 0;
+			else
+				slave->inactive = 1;
+		}
+	}
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7efa33a..9a37125 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1290,41 +1290,21 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 					   const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret = count;
-	struct list_head *iter;
-	struct slave *slave;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
+	int new_value, ret;
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no all_slaves_active value specified.\n",
 		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
-	if (new_value == bond->params.all_slaves_active)
-		goto out;
+	if (!rtnl_trylock())
+		return restart_syscall();
 
-	if ((new_value == 0) || (new_value == 1)) {
-		bond->params.all_slaves_active = new_value;
-	} else {
-		pr_info("%s: Ignoring invalid all_slaves_active value %d.\n",
-			bond->dev->name, new_value);
-		ret = -EINVAL;
-		goto out;
-	}
+	ret = bond_option_all_slaves_active_set(bond, new_value);
+	if (!ret)
+		ret = count;
 
-	bond_for_each_slave(bond, slave, iter) {
-		if (!bond_is_active_slave(slave)) {
-			if (new_value)
-				slave->inactive = 0;
-			else
-				slave->inactive = 1;
-		}
-	}
-out:
 	rtnl_unlock();
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 73538b7..3701e7d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -462,6 +462,8 @@ int bond_option_xmit_hash_policy_set(struct bonding *bond,
 				     int xmit_hash_policy);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
 int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
+int bond_option_all_slaves_active_set(struct bonding *bond,
+				      int all_slaves_active);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index bfe3d3b..93e9c1b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -345,6 +345,7 @@ enum {
 	IFLA_BOND_XMIT_HASH_POLICY,
 	IFLA_BOND_RESEND_IGMP,
 	IFLA_BOND_NUM_PEER_NOTIF,
+	IFLA_BOND_ALL_SLAVES_ACTIVE,
 	__IFLA_BOND_MAX,
 };
 
