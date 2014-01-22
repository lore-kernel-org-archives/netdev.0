From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 22/25] bonding: convert all_slaves_active to use the new option API
Date: Wed, 22 Jan 2014 14:53:37 +0100
Message-ID: <1390398820-5355-23-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755988AbaAVNyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:14 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDsEkl001434
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:14 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so all_slaves_active would use
the new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  4 ++--
 drivers/net/bonding/bond_options.c | 29 +++++++++++++++++------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 15 +++------------
 drivers/net/bonding/bonding.h      |  2 --
 5 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index dba1f2e..828013a 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -282,8 +282,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int all_slaves_active =
 			nla_get_u8(data[IFLA_BOND_ALL_SLAVES_ACTIVE]);
 
-		err = bond_option_all_slaves_active_set(bond,
-							all_slaves_active);
+		bond_opt_initval(&newval, all_slaves_active);
+		err = __bond_opt_set(bond, BOND_OPT_ALL_SLAVES_ACTIVE, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 8775c72..7fafc34 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -105,6 +105,12 @@ static struct bond_opt_value bond_use_carrier_tbl[] = {
 	{ NULL,  -1, 0}
 };
 
+static struct bond_opt_value bond_all_slaves_active_tbl[] = {
+	{ "off", 0,  BOND_VALFLAG_DEFAULT},
+	{ "on",  1,  0},
+	{ NULL,  -1, 0}
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -261,6 +267,13 @@ static struct bond_option bond_opts[] = {
 		.flags = BOND_OPTFLAG_RAWVAL,
 		.set = bond_option_queue_id_set
 	},
+	[BOND_OPT_ALL_SLAVES_ACTIVE] = {
+		.id = BOND_OPT_ALL_SLAVES_ACTIVE,
+		.name = "all_slaves_active",
+		.desc = "Keep all frames received on an interface by setting active flag for all slaves",
+		.values = bond_all_slaves_active_tbl,
+		.set = bond_option_all_slaves_active_set
+	},
 	{ }
 };
 
@@ -1049,25 +1062,17 @@ int bond_option_num_peer_notif_set(struct bonding *bond,
 }
 
 int bond_option_all_slaves_active_set(struct bonding *bond,
-				      int all_slaves_active)
+				      struct bond_opt_value *newval)
 {
 	struct list_head *iter;
 	struct slave *slave;
 
-	if (all_slaves_active == bond->params.all_slaves_active)
+	if (newval->value == bond->params.all_slaves_active)
 		return 0;
-
-	if ((all_slaves_active == 0) || (all_slaves_active == 1)) {
-		bond->params.all_slaves_active = all_slaves_active;
-	} else {
-		pr_info("%s: Ignoring invalid all_slaves_active value %d.\n",
-			bond->dev->name, all_slaves_active);
-		return -EINVAL;
-	}
-
+	bond->params.all_slaves_active = newval->value;
 	bond_for_each_slave(bond, slave, iter) {
 		if (!bond_is_active_slave(slave)) {
-			if (all_slaves_active)
+			if (newval->value)
 				slave->inactive = 0;
 			else
 				slave->inactive = 1;
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 396d504..09ee8c8 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -58,6 +58,7 @@ enum {
 	BOND_OPT_USE_CARRIER,
 	BOND_OPT_ACTIVE_SLAVE,
 	BOND_OPT_QUEUE_ID,
+	BOND_OPT_ALL_SLAVES_ACTIVE,
 	BOND_OPT_LAST
 };
 
@@ -156,4 +157,6 @@ int bond_option_active_slave_set(struct bonding *bond,
 				 struct bond_opt_value *newval);
 int bond_option_queue_id_set(struct bonding *bond,
 			     struct bond_opt_value *newval);
+int bond_option_all_slaves_active_set(struct bonding *bond,
+				      struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a9cd3f5..20210d2 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1015,22 +1015,13 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 					   const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret;
-
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no all_slaves_active value specified.\n",
-		       bond->dev->name);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
+	int ret;
 
-	ret = bond_option_all_slaves_active_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ALL_SLAVES_ACTIVE,
+				   (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4ac79e1..9801c5d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -455,8 +455,6 @@ void bond_netlink_fini(void);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
-int bond_option_all_slaves_active_set(struct bonding *bond,
-				      int all_slaves_active);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
-- 
1.8.4.2
