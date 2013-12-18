From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 1/5] bonding: add num_grat_arp attribute netlink
 support
Date: Tue, 17 Dec 2013 21:30:09 -0800
Message-ID: <20131218053009.13529.4563.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45791 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab3LRFaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:30:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_NUM_PEER_NOTIF to allow get/set of bonding parameter
num_grat_arp via netlink.  Bonding parameter num_unsol_na is
synonymous with num_grat_arp, so add only one netlink attribute
to represent both bonding parameters.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
 drivers/net/bonding/bond_options.c |    6 ++++++
 drivers/net/bonding/bond_sysfs.c   |   21 +++++++++++++++++++--
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 428b394..4a79b01 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -37,6 +37,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_FAIL_OVER_MAC]	= { .type = NLA_U8 },
 	[IFLA_BOND_XMIT_HASH_POLICY]	= { .type = NLA_U8 },
 	[IFLA_BOND_RESEND_IGMP]		= { .type = NLA_U32 },
+	[IFLA_BOND_NUM_PEER_NOTIF]	= { .type = NLA_U8 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -204,6 +205,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_NUM_PEER_NOTIF]) {
+		int num_peer_notif =
+			nla_get_u8(data[IFLA_BOND_NUM_PEER_NOTIF]);
+
+		err = bond_option_num_peer_notif_set(bond, num_peer_notif);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -237,6 +246,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_FAIL_OVER_MAC */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_XMIT_HASH_POLICY */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_RESEND_IGMP */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_NUM_PEER_NOTIF */
 		0;
 }
 
@@ -317,6 +327,10 @@ static int bond_fill_info(struct sk_buff *skb,
 			bond->params.resend_igmp))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_NUM_PEER_NOTIF,
+		       bond->params.num_peer_notif))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 1ed7dff..01a9669 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -576,3 +576,9 @@ int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp)
 
 	return 0;
 }
+
+int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif)
+{
+	bond->params.num_peer_notif = num_peer_notif;
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index f5c1a54..7efa33a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -790,8 +790,25 @@ static ssize_t bonding_store_num_peer_notif(struct device *d,
 					    const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int err = kstrtou8(buf, 10, &bond->params.num_peer_notif);
-	return err ? err : count;
+	u8 new_value;
+	int ret;
+
+	ret = kstrtou8(buf, 10, &new_value);
+	if (!ret) {
+		pr_err("%s: invalid value %s specified.\n",
+		       bond->dev->name, buf);
+		return ret;
+	}
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_num_peer_notif_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
+	return ret;
 }
 static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR,
 		   bonding_show_num_peer_notif, bonding_store_num_peer_notif);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c70ad9f..73538b7 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -461,6 +461,7 @@ int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac);
 int bond_option_xmit_hash_policy_set(struct bonding *bond,
 				     int xmit_hash_policy);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
+int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 6e275d5..bfe3d3b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -344,6 +344,7 @@ enum {
 	IFLA_BOND_FAIL_OVER_MAC,
 	IFLA_BOND_XMIT_HASH_POLICY,
 	IFLA_BOND_RESEND_IGMP,
+	IFLA_BOND_NUM_PEER_NOTIF,
 	__IFLA_BOND_MAX,
 };
 
