From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 7/8] bonding: add arp_validate netlink support
Date: Thu, 07 Nov 2013 01:43:37 -0800
Message-ID: <20131107094337.15846.47722.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37566 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab3KGJyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:54:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_ARP_VALIDATE to allow get/set of bonding parameter
arp_validate via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   12 ++++++++++++
 drivers/net/bonding/bond_options.c |   22 ++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   30 ++++++++----------------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 44 insertions(+), 22 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index e4673ba..a5ca6e0 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -30,6 +30,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_USE_CARRIER]		= { .type = NLA_U8 },
 	[IFLA_BOND_ARP_INTERVAL]	= { .type = NLA_U32 },
 	[IFLA_BOND_ARP_IP_TARGET]	= { .type = NLA_NESTED },
+	[IFLA_BOND_ARP_VALIDATE]	= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -125,6 +126,13 @@ static int bond_changelink(struct net_device *bond_dev,
 				return err;
 		}
 	}
+	if (data[IFLA_BOND_ARP_VALIDATE]) {
+		int arp_validate = nla_get_u32(data[IFLA_BOND_ARP_VALIDATE]);
+
+		err = bond_option_arp_validate_set(bond, arp_validate);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -151,6 +159,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_INTERVAL */
 						/* IFLA_BOND_ARP_IP_TARGET */
 		nla_total_size(sizeof(u32)) * BOND_MAX_ARP_TARGETS +
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_VALIDATE */
 		0;
 }
 
@@ -203,6 +212,9 @@ static int bond_fill_info(struct sk_buff *skb,
 	else
 		nla_nest_cancel(skb, targets);
 
+	if (nla_put_u32(skb, IFLA_BOND_ARP_VALIDATE, bond->params.arp_validate))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index f57f113..9c36215 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -404,3 +404,25 @@ int bond_option_arp_ip_target_clear_all(struct bonding *bond)
 
 	return 0;
 }
+
+int bond_option_arp_validate_set(struct bonding *bond, int arp_validate)
+{
+	if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
+		pr_err("%s: arp_validate only supported in active-backup mode.\n",
+		       bond->dev->name);
+		return -EINVAL;
+	}
+	pr_info("%s: setting arp_validate to %s (%d).\n",
+		bond->dev->name, arp_validate_tbl[arp_validate].modename,
+		arp_validate);
+
+	if (bond->dev->flags & IFF_UP) {
+		if (!arp_validate)
+			bond->recv_probe = NULL;
+		else if (bond->params.arp_interval)
+			bond->recv_probe = bond_arp_rcv;
+	}
+	bond->params.arp_validate = arp_validate;
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index aa97b12..8a35440 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -367,35 +367,21 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 					  const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret = count;
+	int new_value, ret;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
 	new_value = bond_parse_parm(buf, arp_validate_tbl);
 	if (new_value < 0) {
 		pr_err("%s: Ignoring invalid arp_validate value %s\n",
 		       bond->dev->name, buf);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
-		pr_err("%s: arp_validate only supported in active-backup mode.\n",
-		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
-	pr_info("%s: setting arp_validate to %s (%d).\n",
-		bond->dev->name, arp_validate_tbl[new_value].modename,
-		new_value);
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_arp_validate_set(bond, new_value);
+	if (!ret)
+		ret = count;
 
-	if (bond->dev->flags & IFF_UP) {
-		if (!new_value)
-			bond->recv_probe = NULL;
-		else if (bond->params.arp_interval)
-			bond->recv_probe = bond_arp_rcv;
-	}
-	bond->params.arp_validate = new_value;
-out:
 	rtnl_unlock();
 
 	return ret;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e5d215d..77bbd71 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -436,6 +436,7 @@ int bond_option_arp_interval_set(struct bonding *bond, int arp_interval);
 int bond_option_arp_ip_target_set(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_unset(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_clear_all(struct bonding *bond);
+int bond_option_arp_validate_set(struct bonding *bond, int arp_validate);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 58dd318..c17f801 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -337,6 +337,7 @@ enum {
 	IFLA_BOND_USE_CARRIER,
 	IFLA_BOND_ARP_INTERVAL,
 	IFLA_BOND_ARP_IP_TARGET,
+	IFLA_BOND_ARP_VALIDATE,
 	__IFLA_BOND_MAX,
 };
 
