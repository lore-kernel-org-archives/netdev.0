From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 8/8] bonding: add arp_all_targets netlink support
Date: Thu, 12 Dec 2013 14:10:45 -0800
Message-ID: <20131212221045.21629.50040.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53416 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492Ab3LLWKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 17:10:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_ARP_ALL_TARGETS to allow get/set of bonding parameter
arp_all_targets via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
 drivers/net/bonding/bond_options.c |   11 +++++++++++
 drivers/net/bonding/bond_sysfs.c   |   16 ++++++++++------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 8588cb9..d7d84db 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -31,6 +31,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_ARP_INTERVAL]	= { .type = NLA_U32 },
 	[IFLA_BOND_ARP_IP_TARGET]	= { .type = NLA_NESTED },
 	[IFLA_BOND_ARP_VALIDATE]	= { .type = NLA_U32 },
+	[IFLA_BOND_ARP_ALL_TARGETS]	= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -145,6 +146,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_ARP_ALL_TARGETS]) {
+		int arp_all_targets =
+			nla_get_u32(data[IFLA_BOND_ARP_ALL_TARGETS]);
+
+		err = bond_option_arp_all_targets_set(bond, arp_all_targets);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -172,6 +181,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 						/* IFLA_BOND_ARP_IP_TARGET */
 		nla_total_size(sizeof(u32)) * BOND_MAX_ARP_TARGETS +
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_VALIDATE */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_ALL_TARGETS */
 		0;
 }
 
@@ -227,6 +237,10 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (nla_put_u32(skb, IFLA_BOND_ARP_VALIDATE, bond->params.arp_validate))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, IFLA_BOND_ARP_ALL_TARGETS,
+			bond->params.arp_all_targets))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 698079e..dfef673 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -458,3 +458,14 @@ int bond_option_arp_validate_set(struct bonding *bond, int arp_validate)
 
 	return 0;
 }
+
+int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets)
+{
+	pr_info("%s: setting arp_all_targets to %s (%d).\n",
+		bond->dev->name, arp_all_targets_tbl[arp_all_targets].modename,
+		arp_all_targets);
+
+	bond->params.arp_all_targets = arp_all_targets;
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index bda00a0..dad9bea 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -399,7 +399,7 @@ static ssize_t bonding_store_arp_all_targets(struct device *d,
 					  const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value;
+	int new_value, ret;
 
 	new_value = bond_parse_parm(buf, arp_all_targets_tbl);
 	if (new_value < 0) {
@@ -407,13 +407,17 @@ static ssize_t bonding_store_arp_all_targets(struct device *d,
 		       bond->dev->name, buf);
 		return -EINVAL;
 	}
-	pr_info("%s: setting arp_all_targets to %s (%d).\n",
-		bond->dev->name, arp_all_targets_tbl[new_value].modename,
-		new_value);
 
-	bond->params.arp_all_targets = new_value;
+	if (!rtnl_trylock())
+		return restart_syscall();
 
-	return count;
+	ret = bond_option_arp_all_targets_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
+
+	return ret;
 }
 
 static DEVICE_ATTR(arp_all_targets, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index cef10ad..8283cbd 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -449,6 +449,7 @@ int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 int bond_option_arp_validate_set(struct bonding *bond, int arp_validate);
+int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 3ba16fa..a897b7e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -338,6 +338,7 @@ enum {
 	IFLA_BOND_ARP_INTERVAL,
 	IFLA_BOND_ARP_IP_TARGET,
 	IFLA_BOND_ARP_VALIDATE,
+	IFLA_BOND_ARP_ALL_TARGETS,
 	__IFLA_BOND_MAX,
 };
 
