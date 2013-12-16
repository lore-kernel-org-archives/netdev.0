From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 5/5] bonding: add resend_igmp attribute netlink
 support
Date: Sun, 15 Dec 2013 16:42:19 -0800
Message-ID: <20131216004219.13453.56377.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44720 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098Ab3LPAmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 19:42:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_RESEND_IGMP to allow get/set of bonding parameter
resend_igmp via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
 drivers/net/bonding/bond_options.c |   15 +++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |   20 ++++++++------------
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 39 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 89c55d3..44f186a 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -36,6 +36,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_PRIMARY_RESELECT]	= { .type = NLA_U8 },
 	[IFLA_BOND_FAIL_OVER_MAC]	= { .type = NLA_U8 },
 	[IFLA_BOND_XMIT_HASH_POLICY]	= { .type = NLA_U8 },
+	[IFLA_BOND_RESEND_IGMP]		= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -195,6 +196,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_RESEND_IGMP]) {
+		int resend_igmp =
+			nla_get_u32(data[IFLA_BOND_RESEND_IGMP]);
+
+		err = bond_option_resend_igmp_set(bond, resend_igmp);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -227,6 +236,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_PRIMARY_RESELECT */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_FAIL_OVER_MAC */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_XMIT_HASH_POLICY */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_RESEND_IGMP */
 		0;
 }
 
@@ -303,6 +313,10 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.xmit_policy))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, IFLA_BOND_RESEND_IGMP,
+		        bond->params.resend_igmp))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 8510c6d..1ed7dff 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -561,3 +561,18 @@ int bond_option_xmit_hash_policy_set(struct bonding *bond, int xmit_hash_policy)
 
 	return 0;
 }
+
+int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp)
+{
+	if (resend_igmp < 0 || resend_igmp > 255) {
+		pr_err("%s: Invalid resend_igmp value %d not in range 0-255; rejected.\n",
+		       bond->dev->name, resend_igmp);
+		return -EINVAL;
+	}
+
+	bond->params.resend_igmp = resend_igmp;
+	pr_info("%s: Setting resend_igmp to %d.\n",
+		bond->dev->name, resend_igmp);
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 4c75322..f5c1a54 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1336,21 +1336,17 @@ static ssize_t bonding_store_resend_igmp(struct device *d,
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no resend_igmp value specified.\n",
 		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
-	if (new_value < 0 || new_value > 255) {
-		pr_err("%s: Invalid resend_igmp value %d not in range 0-255; rejected.\n",
-		       bond->dev->name, new_value);
-		ret = -EINVAL;
-		goto out;
-	}
+	if (!rtnl_trylock())
+		return restart_syscall();
 
-	pr_info("%s: Setting resend_igmp to %d.\n",
-		bond->dev->name, new_value);
-	bond->params.resend_igmp = new_value;
-out:
+	ret = bond_option_resend_igmp_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4cb603e..c70ad9f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -460,6 +460,7 @@ int bond_option_primary_reselect_set(struct bonding *bond,
 int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac);
 int bond_option_xmit_hash_policy_set(struct bonding *bond,
 				     int xmit_hash_policy);
+int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 1a5d394..6e275d5 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -343,6 +343,7 @@ enum {
 	IFLA_BOND_PRIMARY_RESELECT,
 	IFLA_BOND_FAIL_OVER_MAC,
 	IFLA_BOND_XMIT_HASH_POLICY,
+	IFLA_BOND_RESEND_IGMP,
 	__IFLA_BOND_MAX,
 };
 
