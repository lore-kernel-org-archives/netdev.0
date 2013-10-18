From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/7] bonding: move active_slave getting into separate function
Date: Fri, 18 Oct 2013 17:43:37 +0200
Message-ID: <1382111019-1102-6-git-send-email-jiri@resnulli.us>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:36139 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756487Ab3JRPnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:43:49 -0400
Received: by mail-ee0-f52.google.com with SMTP id d51so255999eek.39
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:43:48 -0700 (PDT)
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_options.c | 18 ++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   |  8 ++++----
 drivers/net/bonding/bonding.h      |  2 ++
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 09af5d1..9a5223c 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -57,6 +57,24 @@ int bond_option_mode_set(struct bonding *bond, int mode)
 	return 0;
 }
 
+static struct net_device *__bond_option_active_slave_get(struct bonding *bond,
+							 struct slave *slave)
+{
+	return USES_PRIMARY(bond->params.mode) && slave ? slave->dev : NULL;
+}
+
+struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond)
+{
+	struct slave *slave = rcu_dereference(bond->curr_active_slave);
+
+	return __bond_option_active_slave_get(bond, slave);
+}
+
+struct net_device *bond_option_active_slave_get(struct bonding *bond)
+{
+	return __bond_option_active_slave_get(bond, bond->curr_active_slave);
+}
+
 int bond_option_active_slave_set(struct bonding *bond,
 				 struct net_device *slave_dev)
 {
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index abd2600..47749c9 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1219,13 +1219,13 @@ static ssize_t bonding_show_active_slave(struct device *d,
 					 char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	struct slave *curr;
+	struct net_device *slave_dev;
 	int count = 0;
 
 	rcu_read_lock();
-	curr = rcu_dereference(bond->curr_active_slave);
-	if (USES_PRIMARY(bond->params.mode) && curr)
-		count = sprintf(buf, "%s\n", curr->dev->name);
+	slave_dev = bond_option_active_slave_get_rcu(bond);
+	if (slave_dev)
+		count = sprintf(buf, "%s\n", slave_dev->name);
 	rcu_read_unlock();
 
 	return count;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 686759d..046a605 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -428,6 +428,8 @@ int bond_netlink_init(void);
 void bond_netlink_fini(void);
 int bond_option_mode_set(struct bonding *bond, int mode);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
+struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
+struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
 struct bond_net {
 	struct net *		net;	/* Associated network namespace */
-- 
1.8.3.1
