From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 23/25] bonding: convert resend_igmp to use the new option API
Date: Wed, 22 Jan 2014 14:53:38 +0100
Message-ID: <1390398820-5355-24-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755979AbaAVNyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:16 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDsFde020820
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:15 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so resend_igmp would use
the new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 29 +++++++++++++++++++----------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 14 ++------------
 drivers/net/bonding/bonding.h      |  1 -
 5 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 828013a..1e099c6 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -265,7 +265,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int resend_igmp =
 			nla_get_u32(data[IFLA_BOND_RESEND_IGMP]);
 
-		err = bond_option_resend_igmp_set(bond, resend_igmp);
+		bond_opt_initval(&newval, resend_igmp);
+		err = __bond_opt_set(bond, BOND_OPT_RESEND_IGMP, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 7fafc34..1373093 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -111,6 +111,13 @@ static struct bond_opt_value bond_all_slaves_active_tbl[] = {
 	{ NULL,  -1, 0}
 };
 
+static struct bond_opt_value bond_resend_igmp_tbl[] = {
+	{ "off",     0,   0},
+	{ "maxval",  255, BOND_VALFLAG_MAX},
+	{ "default", 1,   BOND_VALFLAG_DEFAULT},
+	{ NULL,      -1,  0}
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -274,6 +281,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_all_slaves_active_tbl,
 		.set = bond_option_all_slaves_active_set
 	},
+	[BOND_OPT_RESEND_IGMP] = {
+		.id = BOND_OPT_RESEND_IGMP,
+		.name = "resend_igmp",
+		.desc = "Number of IGMP membership reports to send on link failure",
+		.values = bond_resend_igmp_tbl,
+		.set = bond_option_resend_igmp_set
+	},
 	{ }
 };
 
@@ -1038,17 +1052,12 @@ int bond_option_xmit_hash_policy_set(struct bonding *bond,
 	return 0;
 }
 
-int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp)
+int bond_option_resend_igmp_set(struct bonding *bond,
+				struct bond_opt_value *newval)
 {
-	if (resend_igmp < 0 || resend_igmp > 255) {
-		pr_err("%s: Invalid resend_igmp value %d not in range 0-255; rejected.\n",
-		       bond->dev->name, resend_igmp);
-		return -EINVAL;
-	}
-
-	bond->params.resend_igmp = resend_igmp;
-	pr_info("%s: Setting resend_igmp to %d.\n",
-		bond->dev->name, resend_igmp);
+	pr_info("%s: Setting resend_igmp to %llu.\n",
+		bond->dev->name, newval->value);
+	bond->params.resend_igmp = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 09ee8c8..f0c2cbb 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -59,6 +59,7 @@ enum {
 	BOND_OPT_ACTIVE_SLAVE,
 	BOND_OPT_QUEUE_ID,
 	BOND_OPT_ALL_SLAVES_ACTIVE,
+	BOND_OPT_RESEND_IGMP,
 	BOND_OPT_LAST
 };
 
@@ -159,4 +160,6 @@ int bond_option_queue_id_set(struct bonding *bond,
 			     struct bond_opt_value *newval);
 int bond_option_all_slaves_active_set(struct bonding *bond,
 				      struct bond_opt_value *newval);
+int bond_option_resend_igmp_set(struct bonding *bond,
+				struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 20210d2..1693ebd 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1043,23 +1043,13 @@ static ssize_t bonding_store_resend_igmp(struct device *d,
 					 struct device_attribute *attr,
 					 const char *buf, size_t count)
 {
-	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no resend_igmp value specified.\n",
-		       bond->dev->name);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_resend_igmp_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_RESEND_IGMP, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 9801c5d..1683e40 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -454,7 +454,6 @@ int bond_netlink_init(void);
 void bond_netlink_fini(void);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
-- 
1.8.4.2
