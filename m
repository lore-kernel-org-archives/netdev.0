From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 2/5] bonding: add primary_select attribute netlink
 support
Date: Sun, 15 Dec 2013 16:41:58 -0800
Message-ID: <20131216004158.13453.63053.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44664 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab3LPAmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 19:42:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_PRIMARY_SELECT to allow get/set of bonding parameter
primary_select via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
 drivers/net/bonding/bond_options.c |   16 ++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   24 ++++++++----------------
 drivers/net/bonding/bonding.h      |    2 ++
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 4715b5f..9d11e43 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -33,6 +33,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_ARP_VALIDATE]	= { .type = NLA_U32 },
 	[IFLA_BOND_ARP_ALL_TARGETS]	= { .type = NLA_U32 },
 	[IFLA_BOND_PRIMARY]		= { .type = NLA_U32 },
+	[IFLA_BOND_PRIMARY_RESELECT]	= { .type = NLA_U8 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -168,6 +169,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_PRIMARY_RESELECT]) {
+		int primary_reselect =
+			nla_get_u8(data[IFLA_BOND_PRIMARY_RESELECT]);
+
+		err = bond_option_primary_reselect_set(bond, primary_reselect);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -197,6 +206,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_VALIDATE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_ALL_TARGETS */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_PRIMARY */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_PRIMARY_RESELECT */
 		0;
 }
 
@@ -261,6 +271,10 @@ static int bond_fill_info(struct sk_buff *skb,
 			bond->primary_slave->dev->ifindex))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_PRIMARY_RESELECT,
+		       bond->params.primary_reselect))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index c410d2d..80a9df4 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -519,3 +519,19 @@ out:
 
 	return err;
 }
+
+int bond_option_primary_reselect_set(struct bonding *bond, int primary_reselect)
+{
+	bond->params.primary_reselect = primary_reselect;
+	pr_info("%s: setting primary_reselect to %s (%d).\n",
+		bond->dev->name, pri_reselect_tbl[primary_reselect].modename,
+		primary_reselect);
+
+	block_netpoll_tx();
+	write_lock_bh(&bond->curr_slave_lock);
+	bond_select_active_slave(bond);
+	write_unlock_bh(&bond->curr_slave_lock);
+	unblock_netpoll_tx();
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7304c2b..324afa5 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -909,32 +909,24 @@ static ssize_t bonding_store_primary_reselect(struct device *d,
 					      struct device_attribute *attr,
 					      const char *buf, size_t count)
 {
-	int new_value, ret = count;
+	int new_value, ret;
 	struct bonding *bond = to_bond(d);
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-
 	new_value = bond_parse_parm(buf, pri_reselect_tbl);
 	if (new_value < 0)  {
 		pr_err("%s: Ignoring invalid primary_reselect value %.*s.\n",
 		       bond->dev->name,
 		       (int) strlen(buf) - 1, buf);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
-	bond->params.primary_reselect = new_value;
-	pr_info("%s: setting primary_reselect to %s (%d).\n",
-		bond->dev->name, pri_reselect_tbl[new_value].modename,
-		new_value);
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_primary_reselect_set(bond, new_value);
+	if (!ret)
+		ret = count;
 
-	block_netpoll_tx();
-	write_lock_bh(&bond->curr_slave_lock);
-	bond_select_active_slave(bond);
-	write_unlock_bh(&bond->curr_slave_lock);
-	unblock_netpoll_tx();
-out:
 	rtnl_unlock();
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ec35802..4e89d04 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -455,6 +455,8 @@ int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 int bond_option_arp_validate_set(struct bonding *bond, int arp_validate);
 int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets);
 int bond_option_primary_set(struct bonding *bond, const char *primary);
+int bond_option_primary_reselect_set(struct bonding *bond,
+				     int primary_reselect);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index fb3cfe2..cf59d54 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -340,6 +340,7 @@ enum {
 	IFLA_BOND_ARP_VALIDATE,
 	IFLA_BOND_ARP_ALL_TARGETS,
 	IFLA_BOND_PRIMARY,
+	IFLA_BOND_PRIMARY_RESELECT,
 	__IFLA_BOND_MAX,
 };
 
