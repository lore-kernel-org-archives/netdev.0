From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 13/25] bonding: convert min_links to use the new option API
Date: Wed, 22 Jan 2014 14:53:28 +0100
Message-ID: <1390398820-5355-14-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755642AbaAVNyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:05 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDs57N006623
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:05 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so min_links would use
the new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 16 ++++++++++++----
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 14 +-------------
 drivers/net/bonding/bonding.h      |  1 -
 5 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 508f2f5..a85466c 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -285,7 +285,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int min_links =
 			nla_get_u32(data[IFLA_BOND_MIN_LINKS]);
 
-		err = bond_option_min_links_set(bond, min_links);
+		bond_opt_initval(&newval, min_links);
+		err = __bond_opt_set(bond, BOND_OPT_MINLINKS, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 680296c..f882169 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -164,6 +164,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_lacp_rate_tbl,
 		.set = bond_option_lacp_rate_set
 	},
+	[BOND_OPT_MINLINKS] = {
+		.id = BOND_OPT_MINLINKS,
+		.name = "min_links",
+		.desc = "Minimum number of available links before turning on carrier",
+		.values = bond_intmax_tbl,
+		.set = bond_option_min_links_set
+	},
 	{ }
 };
 
@@ -990,11 +997,12 @@ int bond_option_all_slaves_active_set(struct bonding *bond,
 	return 0;
 }
 
-int bond_option_min_links_set(struct bonding *bond, int min_links)
+int bond_option_min_links_set(struct bonding *bond,
+			      struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting min links value to %u\n",
-		bond->dev->name, min_links);
-	bond->params.min_links = min_links;
+	pr_info("%s: Setting min links value to %llu\n",
+		bond->dev->name, newval->value);
+	bond->params.min_links = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 7ee1a78..cc8edef 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -49,6 +49,7 @@ enum {
 	BOND_OPT_DOWNDELAY,
 	BOND_OPT_UPDELAY,
 	BOND_OPT_LACP_RATE,
+	BOND_OPT_MINLINKS,
 	BOND_OPT_LAST
 };
 
@@ -130,4 +131,6 @@ int bond_option_updelay_set(struct bonding *bond,
 			    struct bond_opt_value *newval);
 int bond_option_lacp_rate_set(struct bonding *bond,
 			      struct bond_opt_value *newval);
+int bond_option_min_links_set(struct bonding *bond,
+			      struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a0a54d0..3ae9bfd 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -586,23 +586,11 @@ static ssize_t bonding_store_min_links(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 	int ret;
-	unsigned int new_value;
 
-	ret = kstrtouint(buf, 0, &new_value);
-	if (ret < 0) {
-		pr_err("%s: Ignoring invalid min links value %s.\n",
-		       bond->dev->name, buf);
-		return ret;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_min_links_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_MINLINKS, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(min_links, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index da03ede..df8c5ae 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -464,7 +464,6 @@ int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
 int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
 int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
-int bond_option_min_links_set(struct bonding *bond, int min_links);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
 int bond_option_ad_select_set(struct bonding *bond, int ad_select);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
-- 
1.8.4.2
