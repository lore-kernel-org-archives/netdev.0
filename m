From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 25/25] bonding: convert slaves to use the new option API
Date: Tue, 21 Jan 2014 15:55:14 +0100
Message-ID: <1390316114-17815-26-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754925AbaAUO4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:56:21 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEuA2Q013972
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:56:10 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so slaves would use
the new bonding option API. Also move the option to its own set function
in bond_options.c and fix some style errors.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_options.c | 53 ++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_options.h |  2 ++
 drivers/net/bonding/bond_sysfs.c   | 51 +++---------------------------------
 3 files changed, 59 insertions(+), 47 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index b9e9bbe..c241601 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -301,6 +301,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_lp_interval_tbl,
 		.set = bond_option_lp_interval_set
 	},
+	[BOND_OPT_SLAVES] = {
+		.id = BOND_OPT_SLAVES,
+		.name = "slaves",
+		.desc = "Slave membership management",
+		.flags = BOND_OPTFLAG_RAWVAL,
+		.set = bond_option_slaves_set
+	},
 	{ }
 };
 
@@ -1215,3 +1222,49 @@ err_no_cmd:
 	goto out;
 
 }
+
+int bond_option_slaves_set(struct bonding *bond, struct bond_opt_value *newval)
+{
+	char command[IFNAMSIZ + 1] = { 0, };
+	struct net_device *dev;
+	char *ifname;
+	int ret;
+
+	sscanf(newval->string, "%16s", command); /* IFNAMSIZ*/
+	ifname = command + 1;
+	if ((strlen(command) <= 1) ||
+	    !dev_valid_name(ifname))
+		goto err_no_cmd;
+
+	dev = __dev_get_by_name(dev_net(bond->dev), ifname);
+	if (!dev) {
+		pr_info("%s: Interface %s does not exist!\n",
+			bond->dev->name, ifname);
+		ret = -ENODEV;
+		goto out;
+	}
+
+	switch (command[0]) {
+	case '+':
+		pr_info("%s: Adding slave %s.\n", bond->dev->name, dev->name);
+		ret = bond_enslave(bond->dev, dev);
+		break;
+
+	case '-':
+		pr_info("%s: Removing slave %s.\n", bond->dev->name, dev->name);
+		ret = bond_release(bond->dev, dev);
+		break;
+
+	default:
+		goto err_no_cmd;
+	}
+
+out:
+	return ret;
+
+err_no_cmd:
+	pr_err("no command found in slaves file for bond %s. Use +ifname or -ifname.\n",
+	       bond->dev->name);
+	ret = -EPERM;
+	goto out;
+}
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index eb3a773..433d37f 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -61,6 +61,7 @@ enum {
 	BOND_OPT_ALL_SLAVES_ACTIVE,
 	BOND_OPT_RESEND_IGMP,
 	BOND_OPT_LP_INTERVAL,
+	BOND_OPT_SLAVES,
 	BOND_OPT_LAST
 };
 
@@ -165,4 +166,5 @@ int bond_option_resend_igmp_set(struct bonding *bond,
 				struct bond_opt_value *newval);
 int bond_option_lp_interval_set(struct bonding *bond,
 				struct bond_opt_value *newval);
+int bond_option_slaves_set(struct bonding *bond, struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8667e55..ceacb12 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -201,58 +201,15 @@ static ssize_t bonding_store_slaves(struct device *d,
 				    struct device_attribute *attr,
 				    const char *buffer, size_t count)
 {
-	char command[IFNAMSIZ + 1] = { 0, };
-	char *ifname;
-	int res, ret = count;
-	struct net_device *dev;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
-	ifname = command + 1;
-	if ((strlen(command) <= 1) ||
-	    !dev_valid_name(ifname))
-		goto err_no_cmd;
-
-	dev = __dev_get_by_name(dev_net(bond->dev), ifname);
-	if (!dev) {
-		pr_info("%s: Interface %s does not exist!\n",
-			bond->dev->name, ifname);
-		ret = -ENODEV;
-		goto out;
-	}
-
-	switch (command[0]) {
-	case '+':
-		pr_info("%s: Adding slave %s.\n", bond->dev->name, dev->name);
-		res = bond_enslave(bond->dev, dev);
-		break;
-
-	case '-':
-		pr_info("%s: Removing slave %s.\n", bond->dev->name, dev->name);
-		res = bond_release(bond->dev, dev);
-		break;
-
-	default:
-		goto err_no_cmd;
-	}
-
-	if (res)
-		ret = res;
-	goto out;
-
-err_no_cmd:
-	pr_err("no command found in slaves file for bond %s. Use +ifname or -ifname.\n",
-	       bond->dev->name);
-	ret = -EPERM;
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_SLAVES, (char *)buffer);
+	if (!ret)
+		ret = count;
 
-out:
-	rtnl_unlock();
 	return ret;
 }
-
 static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves,
 		   bonding_store_slaves);
 
-- 
1.8.4.2
