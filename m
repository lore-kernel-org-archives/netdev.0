From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 4/4] bonding: add active_slaves attribute
Date: Fri, 27 Dec 2013 23:16:03 -0800
Message-ID: <20131228071603.6296.23176.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48634 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298Ab3L1HQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 02:16:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add active_slaves list to sysfs and netlink interfaces.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   34 ++++++++++++++++++++++++++++++-
 drivers/net/bonding/bond_sysfs.c   |   39 ++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h       |    1 +
 3 files changed, 73 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 1b4013b..b111da7 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -46,6 +46,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_AD_LACP_RATE]	= { .type = NLA_U8 },
 	[IFLA_BOND_AD_SELECT]		= { .type = NLA_U8 },
 	[IFLA_BOND_AD_INFO]		= { .type = NLA_NESTED },
+	[IFLA_BOND_ACTIVE_SLAVES]	= { .type = NLA_NESTED },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -288,6 +289,21 @@ static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
 
 static size_t bond_get_size(const struct net_device *bond_dev)
 {
+	struct bonding *bond = netdev_priv(bond_dev);
+
+	int active_slave_count(struct bonding *bond)
+	{
+		struct list_head *iter;
+		struct slave *slave;
+		int count = 0;
+
+		bond_for_each_slave(bond, slave, iter)
+			if (bond_is_active_slave(slave))
+				count++;
+
+		return count;
+	}
+
 	return nla_total_size(sizeof(u8)) +	/* IFLA_BOND_MODE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ACTIVE_SLAVE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIIMON */
@@ -317,6 +333,9 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_INFO_ACTOR_KEY */
 		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_INFO_PARTNER_KEY*/
 		nla_total_size(ETH_ALEN) +    /* IFLA_BOND_AD_INFO_PARTNER_MAC*/
+						/* IFLA_BOND_ACTIVE_SLAVES */
+		nla_total_size(sizeof(struct nlattr)) +
+		nla_total_size(sizeof(u32)) * active_slave_count(bond) +
 		0;
 }
 
@@ -325,7 +344,9 @@ static int bond_fill_info(struct sk_buff *skb,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct net_device *slave_dev = bond_option_active_slave_get(bond);
-	struct nlattr *targets;
+	struct nlattr *targets, *active_slaves;
+	struct list_head *iter;
+	struct slave *slave;
 	unsigned int packets_per_slave;
 	int i, targets_added;
 
@@ -461,6 +482,17 @@ static int bond_fill_info(struct sk_buff *skb,
 		}
 	}
 
+	active_slaves = nla_nest_start(skb, IFLA_BOND_ACTIVE_SLAVES);
+	if (!active_slaves)
+		goto nla_put_failure;
+
+	i = 0;
+	bond_for_each_slave(bond, slave, iter)
+		if (bond_is_active_slave(slave))
+			nla_put_u32(skb, i++, slave->dev->ifindex);
+
+	nla_nest_end(skb, active_slaves);
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 9a1ea4a..ad976eb 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -257,6 +257,44 @@ static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves,
 		   bonding_store_slaves);
 
 /*
+ * Show the active slaves in the current bond.
+ */
+static ssize_t bonding_show_active_slaves(struct device *d,
+					  struct device_attribute *attr,
+					  char *buf)
+{
+	struct bonding *bond = to_bond(d);
+	struct list_head *iter;
+	struct slave *slave;
+	int res = 0;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	bond_for_each_slave(bond, slave, iter) {
+		if (!bond_is_active_slave(slave))
+			continue;
+		if (res > (PAGE_SIZE - IFNAMSIZ)) {
+			/* not enough space for another interface name */
+			if ((PAGE_SIZE - res) > 10)
+				res = PAGE_SIZE - 10;
+			res += sprintf(buf + res, "++more++ ");
+			break;
+		}
+		res += sprintf(buf + res, "%s ", slave->dev->name);
+	}
+
+	rtnl_unlock();
+
+	if (res)
+		buf[res-1] = '\n'; /* eat the leftover space */
+
+	return res;
+}
+
+static DEVICE_ATTR(active_slaves, S_IRUGO, bonding_show_active_slaves, NULL);
+
+/*
  * Show and set the bonding mode.  The bond interface must be down to
  * change the mode.
  */
@@ -1441,6 +1479,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_min_links.attr,
 	&dev_attr_lp_interval.attr,
 	&dev_attr_packets_per_slave.attr,
+	&dev_attr_active_slaves.attr,
 	NULL,
 };
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 3e6bd3c..29d1c66 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -352,6 +352,7 @@ enum {
 	IFLA_BOND_AD_LACP_RATE,
 	IFLA_BOND_AD_SELECT,
 	IFLA_BOND_AD_INFO,
+	IFLA_BOND_ACTIVE_SLAVES,
 	__IFLA_BOND_MAX,
 };
 
