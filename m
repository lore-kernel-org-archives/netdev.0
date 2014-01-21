From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 09/25] bonding: convert arp_ip_target to use the new option API
Date: Tue, 21 Jan 2014 15:54:58 +0100
Message-ID: <1390316114-17815-10-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754842AbaAUOzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:55:53 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEtrTY027142
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:55:53 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so arp_ip_target would use
the new bonding option API. This option is an exception because of
the way it's currently implemented that's why its netlink code is
a bit different from the other options to keep the functionality as
before and at the same time to have a single set function.

This patch also fixes a few stylistic errors.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c | 15 ++++++++----
 drivers/net/bonding/bond_options.c | 48 +++++++++++++++++++++++++++-----------
 drivers/net/bonding/bond_options.h |  4 ++++
 drivers/net/bonding/bond_sysfs.c   | 25 ++++----------------
 drivers/net/bonding/bonding.h      |  2 --
 5 files changed, 53 insertions(+), 41 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index c9264107..3aab730 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -173,16 +173,23 @@ static int bond_changelink(struct net_device *bond_dev,
 			return err;
 	}
 	if (data[IFLA_BOND_ARP_IP_TARGET]) {
-		__be32 targets[BOND_MAX_ARP_TARGETS] = { 0, };
 		struct nlattr *attr;
 		int i = 0, rem;
 
+		bond_option_arp_ip_targets_clear(bond);
 		nla_for_each_nested(attr, data[IFLA_BOND_ARP_IP_TARGET], rem) {
 			__be32 target = nla_get_be32(attr);
-			targets[i++] = target;
-		}
 
-		err = bond_option_arp_ip_targets_set(bond, targets, i);
+			bond_opt_initval(&newval, target);
+			err = __bond_opt_set(bond, BOND_OPT_ARP_TARGETS,
+					     &newval);
+			if (err)
+				break;
+			i++;
+		}
+		if (i == 0 && bond->params.arp_interval)
+			pr_warn("%s: removing last arp target with arp_interval on\n",
+				bond->dev->name);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index c3eb617..5f6b064 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -18,6 +18,7 @@
 #include <linux/rcupdate.h>
 #include <linux/reciprocal_div.h>
 #include <linux/ctype.h>
+#include <linux/inet.h>
 #include "bonding.h"
 
 static struct bond_opt_value bond_mode_tbl[] = {
@@ -128,6 +129,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_intmax_tbl,
 		.set = bond_option_arp_interval_set
 	},
+	[BOND_OPT_ARP_TARGETS] = {
+		.id = BOND_OPT_ARP_TARGETS,
+		.name = "arp_ip_target",
+		.desc = "arp targets in n.n.n.n form",
+		.flags = BOND_OPTFLAG_RAWVAL,
+		.set = bond_option_arp_ip_targets_set
+	},
 	{ }
 };
 
@@ -758,29 +766,41 @@ int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 	return 0;
 }
 
-int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
-				   int count)
+void bond_option_arp_ip_targets_clear(struct bonding *bond)
 {
-	int i, ret = 0;
+	int i;
 
 	/* not to race with bond_arp_rcv */
 	write_lock_bh(&bond->lock);
-
-	/* clear table */
 	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
 		_bond_options_arp_ip_target_set(bond, i, 0, 0);
+	write_unlock_bh(&bond->lock);
+}
 
-	if (count == 0 && bond->params.arp_interval)
-		pr_warn("%s: removing last arp target with arp_interval on\n",
-			bond->dev->name);
-
-	for (i = 0; i < count; i++) {
-		ret = _bond_option_arp_ip_target_add(bond, targets[i]);
-		if (ret)
-			break;
+int bond_option_arp_ip_targets_set(struct bonding *bond,
+				   struct bond_opt_value *newval)
+{
+	int ret = -EPERM;
+	__be32 target;
+
+	if (newval->string) {
+		if (!in4_pton(newval->string+1, -1, (u8 *)&target, -1, NULL)) {
+			pr_err("%s: invalid ARP target %pI4 specified\n",
+			       bond->dev->name, &target);
+			return ret;
+		}
+		if (newval->string[0] == '+')
+			ret = bond_option_arp_ip_target_add(bond, target);
+		else if (newval->string[0] == '-')
+			ret = bond_option_arp_ip_target_rem(bond, target);
+		else
+			pr_err("no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
+			       bond->dev->name);
+	} else {
+		target = newval->value;
+		ret = bond_option_arp_ip_target_add(bond, target);
 	}
 
-	write_unlock_bh(&bond->lock);
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index f02b857..da35148 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -45,6 +45,7 @@ enum {
 	BOND_OPT_ARP_ALL_TARGETS,
 	BOND_OPT_FAIL_OVER_MAC,
 	BOND_OPT_ARP_INTERVAL,
+	BOND_OPT_ARP_TARGETS,
 	BOND_OPT_LAST
 };
 
@@ -117,4 +118,7 @@ int bond_option_fail_over_mac_set(struct bonding *bond,
 				  struct bond_opt_value *newval);
 int bond_option_arp_interval_set(struct bonding *bond,
 				 struct bond_opt_value *newval);
+int bond_option_arp_ip_targets_set(struct bonding *bond,
+				   struct bond_opt_value *newval);
+void bond_option_arp_ip_targets_clear(struct bonding *bond);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 414d713..14cc9fe 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -455,8 +455,8 @@ static ssize_t bonding_show_arp_targets(struct device *d,
 					struct device_attribute *attr,
 					char *buf)
 {
-	int i, res = 0;
 	struct bonding *bond = to_bond(d);
+	int i, res = 0;
 
 	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++) {
 		if (bond->params.arp_targets[i])
@@ -465,6 +465,7 @@ static ssize_t bonding_show_arp_targets(struct device *d,
 	}
 	if (res)
 		buf[res-1] = '\n'; /* eat the leftover space */
+
 	return res;
 }
 
@@ -473,30 +474,12 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 					 const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	__be32 target;
-	int ret = -EPERM;
-
-	if (!in4_pton(buf + 1, -1, (u8 *)&target, -1, NULL)) {
-		pr_err("%s: invalid ARP target %pI4 specified\n",
-		       bond->dev->name, &target);
-		return -EPERM;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	if (buf[0] == '+')
-		ret = bond_option_arp_ip_target_add(bond, target);
-	else if (buf[0] == '-')
-		ret = bond_option_arp_ip_target_rem(bond, target);
-	else
-		pr_err("no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
-		       bond->dev->name);
+	int ret;
 
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ARP_TARGETS, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(arp_ip_target, S_IRUGO | S_IWUSR , bonding_show_arp_targets, bonding_store_arp_targets);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index af065af..85a32e3 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -454,8 +454,6 @@ int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_updelay_set(struct bonding *bond, int updelay);
 int bond_option_downdelay_set(struct bonding *bond, int downdelay);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
-int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
-				   int count);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 int bond_option_primary_set(struct bonding *bond, const char *primary);
-- 
1.8.4.2
