From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 21/25] bonding: convert queue_id to use the new option API
Date: Wed, 22 Jan 2014 14:53:36 +0100
Message-ID: <1390398820-5355-22-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755982AbaAVNyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:13 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDsD57020812
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:13 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so queue_id would use
the new bonding option API. Also move it to its own set function in
bond_options.c and fix some style errors.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_options.c | 70 ++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_options.h |  3 ++
 drivers/net/bonding/bond_sysfs.c   | 65 +++--------------------------------
 3 files changed, 77 insertions(+), 61 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 2315104d..8775c72 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -254,6 +254,13 @@ static struct bond_option bond_opts[] = {
 						BIT(BOND_MODE_ALB)),
 		.set = bond_option_active_slave_set
 	},
+	[BOND_OPT_QUEUE_ID] = {
+		.id = BOND_OPT_QUEUE_ID,
+		.name = "queue_id",
+		.desc = "Set queue id of a slave",
+		.flags = BOND_OPTFLAG_RAWVAL,
+		.set = bond_option_queue_id_set
+	},
 	{ }
 };
 
@@ -1130,3 +1137,66 @@ int bond_option_ad_select_set(struct bonding *bond,
 
 	return 0;
 }
+
+int bond_option_queue_id_set(struct bonding *bond,
+			     struct bond_opt_value *newval)
+{
+	struct slave *slave, *update_slave;
+	struct net_device *sdev;
+	struct list_head *iter;
+	char *delim;
+	int ret = 0;
+	u16 qid;
+
+	/* delim will point to queue id if successful */
+	delim = strchr(newval->string, ':');
+	if (!delim)
+		goto err_no_cmd;
+
+	/* Terminate string that points to device name and bump it
+	 * up one, so we can read the queue id there.
+	 */
+	*delim = '\0';
+	if (sscanf(++delim, "%hd\n", &qid) != 1)
+		goto err_no_cmd;
+
+	/* Check buffer length, valid ifname and queue id */
+	if (strlen(newval->string) > IFNAMSIZ ||
+	    !dev_valid_name(newval->string) ||
+	    qid > bond->dev->real_num_tx_queues)
+		goto err_no_cmd;
+
+	/* Get the pointer to that interface if it exists */
+	sdev = __dev_get_by_name(dev_net(bond->dev), newval->string);
+	if (!sdev)
+		goto err_no_cmd;
+
+	/* Search for thes slave and check for duplicate qids */
+	update_slave = NULL;
+	bond_for_each_slave(bond, slave, iter) {
+		if (sdev == slave->dev)
+			/* We don't need to check the matching
+			 * slave for dups, since we're overwriting it
+			 */
+			update_slave = slave;
+		else if (qid && qid == slave->queue_id) {
+			goto err_no_cmd;
+		}
+	}
+
+	if (!update_slave)
+		goto err_no_cmd;
+
+	/* Actually set the qids for the slave */
+	update_slave->queue_id = qid;
+
+out:
+	return ret;
+
+err_no_cmd:
+	pr_info("invalid input for queue_id set for %s.\n",
+		bond->dev->name);
+	ret = -EPERM;
+	goto out;
+
+}
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 1f486a7..396d504 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -57,6 +57,7 @@ enum {
 	BOND_OPT_PRIMARY_RESELECT,
 	BOND_OPT_USE_CARRIER,
 	BOND_OPT_ACTIVE_SLAVE,
+	BOND_OPT_QUEUE_ID,
 	BOND_OPT_LAST
 };
 
@@ -153,4 +154,6 @@ int bond_option_use_carrier_set(struct bonding *bond,
 				struct bond_opt_value *newval);
 int bond_option_active_slave_set(struct bonding *bond,
 				 struct bond_opt_value *newval);
+int bond_option_queue_id_set(struct bonding *bond,
+			     struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 181a59d..a9cd3f5 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -985,72 +985,15 @@ static ssize_t bonding_store_queue_id(struct device *d,
 				      struct device_attribute *attr,
 				      const char *buffer, size_t count)
 {
-	struct slave *slave, *update_slave;
 	struct bonding *bond = to_bond(d);
-	struct list_head *iter;
-	u16 qid;
-	int ret = count;
-	char *delim;
-	struct net_device *sdev = NULL;
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	/* delim will point to queue id if successful */
-	delim = strchr(buffer, ':');
-	if (!delim)
-		goto err_no_cmd;
-
-	/*
-	 * Terminate string that points to device name and bump it
-	 * up one, so we can read the queue id there.
-	 */
-	*delim = '\0';
-	if (sscanf(++delim, "%hd\n", &qid) != 1)
-		goto err_no_cmd;
-
-	/* Check buffer length, valid ifname and queue id */
-	if (strlen(buffer) > IFNAMSIZ ||
-	    !dev_valid_name(buffer) ||
-	    qid > bond->dev->real_num_tx_queues)
-		goto err_no_cmd;
-
-	/* Get the pointer to that interface if it exists */
-	sdev = __dev_get_by_name(dev_net(bond->dev), buffer);
-	if (!sdev)
-		goto err_no_cmd;
-
-	/* Search for thes slave and check for duplicate qids */
-	update_slave = NULL;
-	bond_for_each_slave(bond, slave, iter) {
-		if (sdev == slave->dev)
-			/*
-			 * We don't need to check the matching
-			 * slave for dups, since we're overwriting it
-			 */
-			update_slave = slave;
-		else if (qid && qid == slave->queue_id) {
-			goto err_no_cmd;
-		}
-	}
-
-	if (!update_slave)
-		goto err_no_cmd;
+	int ret;
 
-	/* Actually set the qids for the slave */
-	update_slave->queue_id = qid;
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_QUEUE_ID, (char *)buffer);
+	if (!ret)
+		ret = count;
 
-out:
-	rtnl_unlock();
 	return ret;
-
-err_no_cmd:
-	pr_info("invalid input for queue_id set for %s.\n",
-		bond->dev->name);
-	ret = -EPERM;
-	goto out;
 }
-
 static DEVICE_ATTR(queue_id, S_IRUGO | S_IWUSR, bonding_show_queue_id,
 		   bonding_store_queue_id);
 
-- 
1.8.4.2
