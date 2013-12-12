From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 6/8] bonding: add arp_ip_target netlink support
Date: Thu, 12 Dec 2013 14:10:31 -0800
Message-ID: <20131212221030.21629.81548.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53373 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab3LLWKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 17:10:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_ARP_IP_TARGET to allow get/set of bonding parameter
arp_ip_target via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   36 ++++++++++
 drivers/net/bonding/bond_options.c |  130 ++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   84 ++++-------------------
 drivers/net/bonding/bonding.h      |    4 +
 include/uapi/linux/if_link.h       |    1 
 5 files changed, 187 insertions(+), 68 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 58e7123..6d30e5d 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -29,6 +29,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_DOWNDELAY]		= { .type = NLA_U32 },
 	[IFLA_BOND_USE_CARRIER]		= { .type = NLA_U8 },
 	[IFLA_BOND_ARP_INTERVAL]	= { .type = NLA_U32 },
+	[IFLA_BOND_ARP_IP_TARGET]	= { .type = NLA_NESTED },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -116,6 +117,20 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_ARP_IP_TARGET]) {
+		__be32 targets[BOND_MAX_ARP_TARGETS] = { 0, };
+		struct nlattr *attr;
+		int i = 0, rem;
+
+		nla_for_each_nested(attr, data[IFLA_BOND_ARP_IP_TARGET], rem) {
+			__be32 target = nla_get_u32(attr);
+			targets[i++] = target;
+		}
+
+		err = bond_option_arp_ip_targets_set(bond, targets, i);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -140,6 +155,8 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_DOWNDELAY */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_USE_CARRIER */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_INTERVAL */
+						/* IFLA_BOND_ARP_IP_TARGET */
+		nla_total_size(sizeof(u32)) * BOND_MAX_ARP_TARGETS +
 		0;
 }
 
@@ -148,6 +165,8 @@ static int bond_fill_info(struct sk_buff *skb,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct net_device *slave_dev = bond_option_active_slave_get(bond);
+	struct nlattr *targets;
+	int i, targets_added;
 
 	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
 		goto nla_put_failure;
@@ -173,6 +192,23 @@ static int bond_fill_info(struct sk_buff *skb,
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
index a84e729..f8c2e4f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -306,3 +306,133 @@ int bond_option_arp_interval_set(struct bonding *bond, int arp_interval)
 
 	return 0;
 }
+
+static void _bond_options_arp_ip_target_set(struct bonding *bond, int slot,
+					    __be32 target,
+					    unsigned long last_rx)
+{
+	__be32 *targets = bond->params.arp_targets;
+	struct list_head *iter;
+	struct slave *slave;
+
+	if (slot >= 0 && slot < BOND_MAX_ARP_TARGETS) {
+		bond_for_each_slave(bond, slave, iter)
+			slave->target_last_arp_rx[slot] = last_rx;
+		targets[slot] = target;
+	}
+}
+
+static int _bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
+{
+	__be32 *targets = bond->params.arp_targets;
+	int ind;
+
+	if (IS_IP_TARGET_UNUSABLE_ADDRESS(target)) {
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
+	pr_info("%s: adding ARP target %pI4.\n", bond->dev->name, &target);
+
+	_bond_options_arp_ip_target_set(bond, ind, target, jiffies);
+
+	return 0;
+}
+
+int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
+{
+	int ret;
+
+	/* not to race with bond_arp_rcv */
+	write_lock_bh(&bond->lock);
+	ret = _bond_option_arp_ip_target_add(bond, target);
+	write_unlock_bh(&bond->lock);
+
+	return ret;
+}
+
+int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
+{
+	__be32 *targets = bond->params.arp_targets;
+	struct list_head *iter;
+	struct slave *slave;
+	unsigned long *targets_rx;
+	int ind, i;
+
+	if (IS_IP_TARGET_UNUSABLE_ADDRESS(target)) {
+		pr_err("%s: invalid ARP target %pI4 specified for removal\n",
+		       bond->dev->name, &target);
+		return -EINVAL;
+	}
+
+	ind = bond_get_targets_ip(targets, target);
+	if (ind == -1) {
+		pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
+		       bond->dev->name, &target);
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
+	/* not to race with bond_arp_rcv */
+	write_lock_bh(&bond->lock);
+
+	bond_for_each_slave(bond, slave, iter) {
+		targets_rx = slave->target_last_arp_rx;
+		for (i = ind; (i < BOND_MAX_ARP_TARGETS-1) && targets[i+1]; i++)
+			targets_rx[i] = targets_rx[i+1];
+		targets_rx[i] = 0;
+	}
+	for (i = ind; (i < BOND_MAX_ARP_TARGETS-1) && targets[i+1]; i++)
+		targets[i] = targets[i+1];
+	targets[i] = 0;
+
+	write_unlock_bh(&bond->lock);
+
+	return 0;
+}
+
+int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
+				   int count)
+{
+	int i, ret = 0;
+
+	/* not to race with bond_arp_rcv */
+	write_lock_bh(&bond->lock);
+
+	/* clear table */
+	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
+		_bond_options_arp_ip_target_set(bond, i, 0, 0);
+
+	if (count == 0 && bond->params.arp_interval)
+		pr_warn("%s: removing last arp target with arp_interval on\n",
+			bond->dev->name);
+
+	for (i = 0; i < count; i++) {
+		ret = _bond_option_arp_ip_target_add(bond, targets[i]);
+		if (ret)
+			break;
+	}
+
+	write_unlock_bh(&bond->lock);
+	return ret;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 12128bf..a443bbd 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -552,81 +552,29 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 					 const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	struct list_head *iter;
-	struct slave *slave;
-	__be32 newtarget, *targets;
-	unsigned long *targets_rx;
-	int ind, i, j, ret = -EINVAL;
+	__be32 target;
+	int ret = -EPERM;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	targets = bond->params.arp_targets;
-	if (!in4_pton(buf + 1, -1, (u8 *)&newtarget, -1, NULL) ||
-	    IS_IP_TARGET_UNUSABLE_ADDRESS(newtarget)) {
-		pr_err("%s: invalid ARP target %pI4 specified for addition\n",
-		       bond->dev->name, &newtarget);
-		goto out;
+	if (!in4_pton(buf + 1, -1, (u8 *)&target, -1, NULL)) {
+		pr_err("%s: invalid ARP target %pI4 specified\n",
+		       bond->dev->name, &target);
+		return -EPERM;
 	}
-	/* look for adds */
-	if (buf[0] == '+') {
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
-	} else if (buf[0] == '-')	{
-		ind = bond_get_targets_ip(targets, newtarget);
-		if (ind == -1) {
-			pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
-				bond->dev->name, &newtarget);
-			goto out;
-		}
 
-		if (ind == 0 && !targets[1] && bond->params.arp_interval)
-			pr_warn("%s: removing last arp target with arp_interval on\n",
-				bond->dev->name);
-
-		pr_info("%s: removing ARP target %pI4.\n", bond->dev->name,
-			&newtarget);
+	if (!rtnl_trylock())
+		return restart_syscall();
 
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
-	} else {
+	if (buf[0] == '+')
+		ret = bond_option_arp_ip_target_add(bond, target);
+	else if (buf[0] == '-')
+		ret = bond_option_arp_ip_target_rem(bond, target);
+	else
 		pr_err("no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
 		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
 
-	ret = count;
-out:
+	if (!ret)
+		ret = count;
+
 	rtnl_unlock();
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 44df273..dcdc809 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -444,6 +444,10 @@ int bond_option_updelay_set(struct bonding *bond, int updelay);
 int bond_option_downdelay_set(struct bonding *bond, int downdelay);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 int bond_option_arp_interval_set(struct bonding *bond, int arp_interval);
+int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
+				   int count);
+int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
+int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c73d878..5b0c444 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -336,6 +336,7 @@ enum {
 	IFLA_BOND_DOWNDELAY,
 	IFLA_BOND_USE_CARRIER,
 	IFLA_BOND_ARP_INTERVAL,
+	IFLA_BOND_ARP_IP_TARGET,
 	__IFLA_BOND_MAX,
 };
 
