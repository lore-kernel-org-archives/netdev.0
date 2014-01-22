From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 17/25] bonding: convert primary to use the new option API
Date: Wed, 22 Jan 2014 14:53:32 +0100
Message-ID: <1390398820-5355-18-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52949 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755811AbaAVNyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:10 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDs9ks013367
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:09 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so primary would use
the new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 26 ++++++++++++++++----------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 11 +----------
 drivers/net/bonding/bonding.h      |  1 -
 5 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 64e45c9..b27e09d 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -227,7 +227,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (dev)
 			primary = dev->name;
 
-		err = bond_option_primary_set(bond, primary);
+		bond_opt_initstr(&newval, primary);
+		err = __bond_opt_set(bond, BOND_OPT_PRIMARY, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index cb515d9..f094a31 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -207,6 +207,16 @@ static struct bond_option bond_opts[] = {
 		.values = bond_intmax_tbl,
 		.set = bond_option_miimon_set
 	},
+	[BOND_OPT_PRIMARY] = {
+		.id = BOND_OPT_PRIMARY,
+		.name = "primary",
+		.desc = "Primary network device to use",
+		.flags = BOND_OPTFLAG_RAWVAL,
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_ACTIVEBACKUP) |
+						BIT(BOND_MODE_TLB) |
+						BIT(BOND_MODE_ALB)),
+		.set = bond_option_primary_set
+	},
 	{ }
 };
 
@@ -885,23 +895,19 @@ int bond_option_arp_all_targets_set(struct bonding *bond,
 	return 0;
 }
 
-int bond_option_primary_set(struct bonding *bond, const char *primary)
+int bond_option_primary_set(struct bonding *bond, struct bond_opt_value *newval)
 {
+	char *p, *primary = newval->string;
 	struct list_head *iter;
 	struct slave *slave;
-	int err = 0;
 
 	block_netpoll_tx();
 	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
-	if (!USES_PRIMARY(bond->params.mode)) {
-		pr_err("%s: Unable to set primary slave; %s is in mode %d\n",
-		       bond->dev->name, bond->dev->name, bond->params.mode);
-		err = -EINVAL;
-		goto out;
-	}
-
+	p = strchr(primary, '\n');
+	if (p)
+		*p = '\0';
 	/* check to see if we are clearing primary */
 	if (!strlen(primary)) {
 		pr_info("%s: Setting primary slave to None.\n",
@@ -934,7 +940,7 @@ out:
 	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 
-	return err;
+	return 0;
 }
 
 int bond_option_primary_reselect_set(struct bonding *bond, int primary_reselect)
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 90f00c6..6ff83103 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -53,6 +53,7 @@ enum {
 	BOND_OPT_AD_SELECT,
 	BOND_OPT_NUM_PEER_NOTIF,
 	BOND_OPT_MIIMON,
+	BOND_OPT_PRIMARY,
 	BOND_OPT_LAST
 };
 
@@ -141,4 +142,6 @@ int bond_option_ad_select_set(struct bonding *bond,
 int bond_option_num_peer_notif_set(struct bonding *bond,
 				   struct bond_opt_value *newval);
 int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval);
+int bond_option_primary_set(struct bonding *bond,
+			    struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 3f6e4d6..10c58ef 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -710,21 +710,12 @@ static ssize_t bonding_store_primary(struct device *d,
 				     const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	char ifname[IFNAMSIZ];
 	int ret;
 
-	sscanf(buf, "%15s", ifname); /* IFNAMSIZ */
-	if (ifname[0] == '\n')
-		ifname[0] = '\0';
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_primary_set(bond, ifname);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_PRIMARY, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4d04619..8916854 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -456,7 +456,6 @@ int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-int bond_option_primary_set(struct bonding *bond, const char *primary);
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     int primary_reselect);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
-- 
1.8.4.2
