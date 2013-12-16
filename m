From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 1/5] bonding: add primary attribute netlink support
Date: Sun, 15 Dec 2013 16:41:51 -0800
Message-ID: <20131216004151.13453.44706.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44651 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LPAlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 19:41:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_PRIMARY to allow get/set of bonding parameter
primary via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   20 ++++++++++++++
 drivers/net/bonding/bond_options.c |   52 ++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   52 ++++++------------------------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 83 insertions(+), 43 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index d7d84db..4715b5f 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -32,6 +32,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_ARP_IP_TARGET]	= { .type = NLA_NESTED },
 	[IFLA_BOND_ARP_VALIDATE]	= { .type = NLA_U32 },
 	[IFLA_BOND_ARP_ALL_TARGETS]	= { .type = NLA_U32 },
+	[IFLA_BOND_PRIMARY]		= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -154,6 +155,19 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_PRIMARY]) {
+		int ifindex = nla_get_u32(data[IFLA_BOND_PRIMARY]);
+		struct net_device *dev;
+		char *primary = "";
+
+		dev = __dev_get_by_index(dev_net(bond_dev), ifindex);
+		if (dev)
+			primary = dev->name;
+
+		err = bond_option_primary_set(bond, primary);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -182,6 +196,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) * BOND_MAX_ARP_TARGETS +
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_VALIDATE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_ALL_TARGETS */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_PRIMARY */
 		0;
 }
 
@@ -241,6 +256,11 @@ static int bond_fill_info(struct sk_buff *skb,
 			bond->params.arp_all_targets))
 		goto nla_put_failure;
 
+	if (bond->primary_slave &&
+	    nla_put_u32(skb, IFLA_BOND_PRIMARY,
+			bond->primary_slave->dev->ifindex))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 600779e..c410d2d 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -467,3 +467,55 @@ int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets)
 
 	return 0;
 }
+
+int bond_option_primary_set(struct bonding *bond, const char *primary)
+{
+	struct list_head *iter;
+	struct slave *slave;
+	int err = 0;
+
+	block_netpoll_tx();
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
+	if (!USES_PRIMARY(bond->params.mode)) {
+		pr_err("%s: Unable to set primary slave; %s is in mode %d\n",
+		       bond->dev->name, bond->dev->name, bond->params.mode);
+		err = -EINVAL;
+		goto out;
+	}
+
+	/* check to see if we are clearing primary */
+	if (!strlen(primary)) {
+		pr_info("%s: Setting primary slave to None.\n",
+			bond->dev->name);
+		bond->primary_slave = NULL;
+		memset(bond->params.primary, 0, sizeof(bond->params.primary));
+		bond_select_active_slave(bond);
+		goto out;
+	}
+
+	bond_for_each_slave(bond, slave, iter) {
+		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
+			pr_info("%s: Setting %s as primary slave.\n",
+				bond->dev->name, slave->dev->name);
+			bond->primary_slave = slave;
+			strcpy(bond->params.primary, slave->dev->name);
+			bond_select_active_slave(bond);
+			goto out;
+		}
+	}
+
+	strncpy(bond->params.primary, primary, IFNAMSIZ);
+	bond->params.primary[IFNAMSIZ - 1] = 0;
+
+	pr_info("%s: Recording %s as primary, but it has not been enslaved to %s yet.\n",
+		bond->dev->name, primary, bond->dev->name);
+
+out:
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+	unblock_netpoll_tx();
+
+	return err;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 6368d29..7304c2b 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -871,56 +871,22 @@ static ssize_t bonding_store_primary(struct device *d,
 				     const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	struct list_head *iter;
 	char ifname[IFNAMSIZ];
-	struct slave *slave;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-	block_netpoll_tx();
-	write_lock_bh(&bond->curr_slave_lock);
-
-	if (!USES_PRIMARY(bond->params.mode)) {
-		pr_info("%s: Unable to set primary slave; %s is in mode %d\n",
-			bond->dev->name, bond->dev->name, bond->params.mode);
-		goto out;
-	}
+	int ret;
 
 	sscanf(buf, "%15s", ifname); /* IFNAMSIZ */
+	if (ifname[0] == '\n')
+		ifname[0] = '\0';
 
-	/* check to see if we are clearing primary */
-	if (!strlen(ifname) || buf[0] == '\n') {
-		pr_info("%s: Setting primary slave to None.\n",
-			bond->dev->name);
-		bond->primary_slave = NULL;
-		memset(bond->params.primary, 0, sizeof(bond->params.primary));
-		bond_select_active_slave(bond);
-		goto out;
-	}
-
-	bond_for_each_slave(bond, slave, iter) {
-		if (strncmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
-			pr_info("%s: Setting %s as primary slave.\n",
-				bond->dev->name, slave->dev->name);
-			bond->primary_slave = slave;
-			strcpy(bond->params.primary, slave->dev->name);
-			bond_select_active_slave(bond);
-			goto out;
-		}
-	}
+	if (!rtnl_trylock())
+		return restart_syscall();
 
-	strncpy(bond->params.primary, ifname, IFNAMSIZ);
-	bond->params.primary[IFNAMSIZ - 1] = 0;
+	ret = bond_option_primary_set(bond, ifname);
+	if (!ret)
+		ret = count;
 
-	pr_info("%s: Recording %s as primary, "
-		"but it has not been enslaved to %s yet.\n",
-		bond->dev->name, ifname, bond->dev->name);
-out:
-	write_unlock_bh(&bond->curr_slave_lock);
-	unblock_netpoll_tx();
 	rtnl_unlock();
-
-	return count;
+	return ret;
 }
 static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR,
 		   bonding_show_primary, bonding_store_primary);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8f0d6d0..ec35802 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -454,6 +454,7 @@ int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 int bond_option_arp_validate_set(struct bonding *bond, int arp_validate);
 int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets);
+int bond_option_primary_set(struct bonding *bond, const char *primary);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a897b7e..fb3cfe2 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -339,6 +339,7 @@ enum {
 	IFLA_BOND_ARP_IP_TARGET,
 	IFLA_BOND_ARP_VALIDATE,
 	IFLA_BOND_ARP_ALL_TARGETS,
+	IFLA_BOND_PRIMARY,
 	__IFLA_BOND_MAX,
 };
 
