From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH 3/3] bonding: add retransmit membership reports tunable
Date: Tue,  5 Oct 2010 21:23:59 -0300
Message-ID: <1286324639-22314-3-git-send-email-fleitner@redhat.com>
References: <20101005220757.GB19931@redhat.com>
Cc: bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Flavio Leitner <fleitner@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758097Ab0JFAY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 20:24:29 -0400
In-Reply-To: <20101005220757.GB19931@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow sysadmins to configure the number of multicast
membership report sent on a link failure event.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 Documentation/networking/bonding.txt |    8 ++++++
 drivers/net/bonding/bond_main.c      |   15 +++++++++++
 drivers/net/bonding/bond_sysfs.c     |   44 ++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |    2 +
 include/linux/if_bonding.h           |    3 ++
 5 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index d2b62b7..5dc6387 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -765,6 +765,14 @@ xmit_hash_policy
 	does not exist, and the layer2 policy is the only policy.  The
 	layer2+3 value was added for bonding version 3.2.2.
 
+resend_igmp
+
+	Specifies the number of IGMP membership reports to be issued after
+	a failover event. One membership report is issued immediately after
+	the failover, subsequent packets are sent in each 200ms interval.
+
+	The valid range is 0 - 255; the default value is 1. This option
+	was added for bonding version 3.7.0.
 
 3. Configuring Bonding Devices
 ==============================
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6554b47..19206ba 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -109,6 +109,7 @@ static char *arp_validate;
 static char *fail_over_mac;
 static int all_slaves_active = 0;
 static struct bond_params bonding_defaults;
+static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -163,6 +164,8 @@ module_param(all_slaves_active, int, 0);
 MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface"
 				     "by setting active flag for all slaves.  "
 				     "0 for never (default), 1 for always.");
+module_param(resend_igmp, int, 0);
+MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link failure");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -905,6 +908,9 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 		}
 	}
 
+	if (--bond->igmp_retrans > 0)
+		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
+
 	read_unlock(&bond->lock);
 }
 
@@ -1213,6 +1219,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	 * all were sent on curr_active_slave */
 	if ((USES_PRIMARY(bond->params.mode) && new_active) ||
 	    bond->params.mode == BOND_MODE_ROUNDROBIN) {
+		bond->igmp_retrans = bond->params.resend_igmp;
 		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
 	}
 }
@@ -4929,6 +4936,13 @@ static int bond_check_params(struct bond_params *params)
 		all_slaves_active = 0;
 	}
 
+	if (resend_igmp < 0 || resend_igmp > 255) {
+		pr_warning("Warning: resend_igmp (%d) should be between "
+			   "0 and 255, resetting to %d\n",
+			   resend_igmp, BOND_DEFAULT_RESEND_IGMP);
+		resend_igmp = BOND_DEFAULT_RESEND_IGMP;
+	}
+
 	/* reset values for TLB/ALB */
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
@@ -5101,6 +5115,7 @@ static int bond_check_params(struct bond_params *params)
 	params->fail_over_mac = fail_over_mac_value;
 	params->tx_queues = tx_queues;
 	params->all_slaves_active = all_slaves_active;
+	params->resend_igmp = resend_igmp;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index c311aed..01b4c3f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1592,6 +1592,49 @@ out:
 static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
 		   bonding_show_slaves_active, bonding_store_slaves_active);
 
+/*
+ * Show and set the number of IGMP membership reports to send on link failure
+ */
+static ssize_t bonding_show_resend_igmp(struct device *d,
+					 struct device_attribute *attr,
+					 char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.resend_igmp);
+}
+
+static ssize_t bonding_store_resend_igmp(struct device *d,
+					  struct device_attribute *attr,
+					  const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		pr_err("%s: no resend_igmp value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (new_value < 0) {
+		pr_err("%s: Invalid resend_igmp value %d not in range 0-255; rejected.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	pr_info("%s: Setting resend_igmp to %d.\n",
+		bond->dev->name, new_value);
+	bond->params.resend_igmp = new_value;
+out:
+	return ret;
+}
+
+static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
+		   bonding_show_resend_igmp, bonding_store_resend_igmp);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -1619,6 +1662,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_ad_partner_mac.attr,
 	&dev_attr_queue_id.attr,
 	&dev_attr_all_slaves_active.attr,
+	&dev_attr_resend_igmp.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 308ed10..c15f213 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -136,6 +136,7 @@ struct bond_params {
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
 	int tx_queues;
 	int all_slaves_active;
+	int resend_igmp;
 };
 
 struct bond_parm_tbl {
@@ -202,6 +203,7 @@ struct bonding {
 	s8	 send_grat_arp;
 	s8	 send_unsol_na;
 	s8	 setup_by_slave;
+	s8       igmp_retrans;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
 	char     proc_file_name[IFNAMSIZ];
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index 2c79943..a17edda 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -84,6 +84,9 @@
 #define BOND_DEFAULT_MAX_BONDS  1   /* Default maximum number of devices to support */
 
 #define BOND_DEFAULT_TX_QUEUES 16   /* Default number of tx queues per device */
+
+#define BOND_DEFAULT_RESEND_IGMP	1 /* Default number of IGMP membership reports */
+
 /* hashing types */
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
 #define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ (TCP || UDP)) */
-- 
1.7.0.1

