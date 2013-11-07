From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 6/8] bonding: add arp_ip_target netlink support
Date: Thu, 07 Nov 2013 01:43:30 -0800
Message-ID: <20131107094330.15846.84353.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37564 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943Ab3KGJyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:54:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_ARP_IP_TARGET to allow get/set of bonding parameter
arp_ip_target via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   43 ++++++++++++++-
 drivers/net/bonding/bond_options.c |  102 ++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   77 +++------------------------
 drivers/net/bonding/bonding.h      |    3 +
 include/uapi/linux/if_link.h       |    1 
 5 files changed, 155 insertions(+), 71 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 9c50165..e4673ba 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -29,6 +29,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_DOWNDELAY]		= { .type = NLA_U32 },
 	[IFLA_BOND_USE_CARRIER]		= { .type = NLA_U8 },
 	[IFLA_BOND_ARP_INTERVAL]	= { .type = NLA_U32 },
+	[IFLA_BOND_ARP_IP_TARGET]	= { .type = NLA_NESTED },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -109,6 +110,21 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_ARP_IP_TARGET]) {
+		struct nlattr *attr;
+		int rem;
+
+		err = bond_option_arp_ip_target_clear_all(bond);
+		if (err)
+			return err;
+
+		nla_for_each_nested(attr, data[IFLA_BOND_ARP_IP_TARGET], rem) {
+			__be32 target = nla_get_u32(attr);
+			err = bond_option_arp_ip_target_set(bond, target);
+			if (err)
+				return err;
+		}
+	}
 	return 0;
 }
 
@@ -133,6 +149,8 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_DOWNDELAY */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_USE_CARRIER */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_INTERVAL */
+						/* IFLA_BOND_ARP_IP_TARGET */
+		nla_total_size(sizeof(u32)) * BOND_MAX_ARP_TARGETS +
 		0;
 }
 
@@ -141,6 +159,8 @@ static int bond_fill_info(struct sk_buff *skb,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct net_device *slave_dev = bond_option_active_slave_get(bond);
+	struct nlattr *targets;
+	int i, targets_added;
 
 	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
 		goto nla_put_failure;
@@ -152,10 +172,12 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (nla_put_u32(skb, IFLA_BOND_MIIMON, bond->params.miimon))
 		goto nla_put_failure;
 
-	if (nla_put_u32(skb, IFLA_BOND_UPDELAY, bond->params.updelay))
+	if (nla_put_u32(skb, IFLA_BOND_UPDELAY,
+		bond->params.updelay * bond->params.miimon))
 		goto nla_put_failure;
 
-	if (nla_put_u32(skb, IFLA_BOND_DOWNDELAY, bond->params.downdelay))
+	if (nla_put_u32(skb, IFLA_BOND_DOWNDELAY,
+		bond->params.downdelay * bond->params.miimon))
 		goto nla_put_failure;
 
 	if (nla_put_u8(skb, IFLA_BOND_USE_CARRIER, bond->params.use_carrier))
@@ -164,6 +186,23 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (nla_put_u32(skb, IFLA_BOND_ARP_INTERVAL, bond->params.arp_interval))
 		goto nla_put_failure;
 
+	targets = nla_nest_start(skb, IFLA_BOND_ARP_IP_TARGET);
+	if (!targets)
+		goto nla_put_failure;
+
+	targets_added = 0;
+	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++) {
+		if (bond->params.arp_targets[i]) {
+			nla_put_u32(skb, i, bond->params.arp_targets[i]);
+			targets_added = 1;
+		}
+	}
+
+	if (targets_added)
+		nla_nest_end(skb, targets);
+	else
+		nla_nest_cancel(skb, targets);
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index c4b60ad..f57f113 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -302,3 +302,105 @@ int bond_option_arp_interval_set(struct bonding *bond, int arp_interval)
 
 	return 0;
 }
+
+int bond_option_arp_ip_target_set(struct bonding *bond, __be32 target)
+{
+	__be32 *targets = bond->params.arp_targets;
+	struct list_head *iter;
+	struct slave *slave;
+	int ind;
+
+	if ((target == 0) || (target == htonl(INADDR_BROADCAST))) {
+		pr_err("%s: invalid ARP target %pI4 specified for addition\n",
+		       bond->dev->name, &target);
+		return -EINVAL;
+	}
+
+	if (bond_get_targets_ip(targets, target) != -1) { /* dup */
+		pr_err("%s: ARP target %pI4 is already present\n",
+		       bond->dev->name, &target);
+		return -EINVAL;
+	}
+
+	ind = bond_get_targets_ip(targets, 0); /* first free slot */
+	if (ind == -1) {
+		pr_err("%s: ARP target table is full!\n",
+		       bond->dev->name);
+		return -EINVAL;
+	}
+
+	pr_info("%s: adding ARP target %pI4.\n", bond->dev->name,
+		 &target);
+
+	/* not to race with bond_arp_rcv */
+	write_lock_bh(&bond->lock);
+	bond_for_each_slave(bond, slave, iter)
+		slave->target_last_arp_rx[ind] = jiffies;
+	targets[ind] = target;
+	write_unlock_bh(&bond->lock);
+
+	return 0;
+}
+
+int bond_option_arp_ip_target_unset(struct bonding *bond, __be32 target)
+{
+	__be32 *targets = bond->params.arp_targets;
+	struct list_head *iter;
+	struct slave *slave;
+	unsigned long *targets_rx;
+	int ind, i, j;
+
+	if ((target == 0) || (target == htonl(INADDR_BROADCAST))) {
+		pr_err("%s: invalid ARP target %pI4 specified for removal\n",
+		       bond->dev->name, &target);
+		return -EINVAL;
+	}
+
+	ind = bond_get_targets_ip(targets, target);
+	if (ind == -1) {
+		pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
+			bond->dev->name, &target);
+		return -EINVAL;
+	}
+
+	if (ind == 0 && !targets[1] && bond->params.arp_interval)
+		pr_warn("%s: removing last arp target with arp_interval on\n",
+			bond->dev->name);
+
+	pr_info("%s: removing ARP target %pI4.\n", bond->dev->name,
+		&target);
+
+	write_lock_bh(&bond->lock);
+	bond_for_each_slave(bond, slave, iter) {
+		targets_rx = slave->target_last_arp_rx;
+		j = ind;
+		for (; (j < BOND_MAX_ARP_TARGETS-1) && targets[j+1]; j++)
+			targets_rx[j] = targets_rx[j+1];
+		targets_rx[j] = 0;
+	}
+	for (i = ind; (i < BOND_MAX_ARP_TARGETS-1) && targets[i+1]; i++)
+		targets[i] = targets[i+1];
+	targets[i] = 0;
+	write_unlock_bh(&bond->lock);
+
+	return 0;
+}
+
+int bond_option_arp_ip_target_clear_all(struct bonding *bond)
+{
+	__be32 *targets = bond->params.arp_targets;
+	struct list_head *iter;
+	struct slave *slave;
+	int i;
+
+	write_lock_bh(&bond->lock);
+	bond_for_each_slave(bond, slave, iter) {
+		for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
+			slave->target_last_arp_rx[i] = 0;
+	}
+	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
+		targets[i] = 0;
+	write_unlock_bh(&bond->lock);
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 644b745..aa97b12 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -561,88 +561,27 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 					 const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	struct list_head *iter;
-	struct slave *slave;
-	__be32 newtarget, *targets;
-	unsigned long *targets_rx;
-	int ind, i, j, ret = -EINVAL;
+	__be32 target;
+	int ret;
 
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	targets = bond->params.arp_targets;
-	newtarget = in_aton(buf + 1);
+	target = in_aton(buf + 1);
 	/* look for adds */
 	if (buf[0] == '+') {
-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err("%s: invalid ARP target %pI4 specified for addition\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
-		if (bond_get_targets_ip(targets, newtarget) != -1) { /* dup */
-			pr_err("%s: ARP target %pI4 is already present\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
-		ind = bond_get_targets_ip(targets, 0); /* first free slot */
-		if (ind == -1) {
-			pr_err("%s: ARP target table is full!\n",
-			       bond->dev->name);
-			goto out;
-		}
-
-		pr_info("%s: adding ARP target %pI4.\n", bond->dev->name,
-			 &newtarget);
-		/* not to race with bond_arp_rcv */
-		write_lock_bh(&bond->lock);
-		bond_for_each_slave(bond, slave, iter)
-			slave->target_last_arp_rx[ind] = jiffies;
-		targets[ind] = newtarget;
-		write_unlock_bh(&bond->lock);
+		ret = bond_option_arp_ip_target_set(bond, target);
 	} else if (buf[0] == '-')	{
-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err("%s: invalid ARP target %pI4 specified for removal\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
-		ind = bond_get_targets_ip(targets, newtarget);
-		if (ind == -1) {
-			pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
-				bond->dev->name, &newtarget);
-			goto out;
-		}
-
-		if (ind == 0 && !targets[1] && bond->params.arp_interval)
-			pr_warn("%s: removing last arp target with arp_interval on\n",
-				bond->dev->name);
-
-		pr_info("%s: removing ARP target %pI4.\n", bond->dev->name,
-			&newtarget);
-
-		write_lock_bh(&bond->lock);
-		bond_for_each_slave(bond, slave, iter) {
-			targets_rx = slave->target_last_arp_rx;
-			j = ind;
-			for (; (j < BOND_MAX_ARP_TARGETS-1) && targets[j+1]; j++)
-				targets_rx[j] = targets_rx[j+1];
-			targets_rx[j] = 0;
-		}
-		for (i = ind; (i < BOND_MAX_ARP_TARGETS-1) && targets[i+1]; i++)
-			targets[i] = targets[i+1];
-		targets[i] = 0;
-		write_unlock_bh(&bond->lock);
+		ret = bond_option_arp_ip_target_unset(bond, target);
 	} else {
 		pr_err("no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
 		       bond->dev->name);
 		ret = -EPERM;
-		goto out;
 	}
 
-	ret = count;
-out:
+	if (!ret)
+		ret = count;
+
 	rtnl_unlock();
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index caaa5e7..e5d215d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -433,6 +433,9 @@ int bond_option_updelay_set(struct bonding *bond, int updelay);
 int bond_option_downdelay_set(struct bonding *bond, int downdelay);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 int bond_option_arp_interval_set(struct bonding *bond, int arp_interval);
+int bond_option_arp_ip_target_set(struct bonding *bond, __be32 target);
+int bond_option_arp_ip_target_unset(struct bonding *bond, __be32 target);
+int bond_option_arp_ip_target_clear_all(struct bonding *bond);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 858b09e..58dd318 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -336,6 +336,7 @@ enum {
 	IFLA_BOND_DOWNDELAY,
 	IFLA_BOND_USE_CARRIER,
 	IFLA_BOND_ARP_INTERVAL,
+	IFLA_BOND_ARP_IP_TARGET,
 	__IFLA_BOND_MAX,
 };
 
