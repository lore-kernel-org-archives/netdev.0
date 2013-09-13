From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v3] bonding: Make alb learning packet interval configurable
Date: Fri, 13 Sep 2013 11:05:33 -0400
Message-ID: <1379084733-9219-1-git-send-email-nhorman@tuxdriver.com>
References: <1378822490-28667-1-git-send-email-nhorman@tuxdriver.com>
Cc: vfalico@redhat.com, Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35671 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428Ab3IMPGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 11:06:00 -0400
In-Reply-To: <1378822490-28667-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

running bonding in ALB mode requires that learning packets be sent periodically,
so that the switch knows where to send responding traffic.  However, depending
on switch configuration, there may not be any need to send traffic at the
default rate of 3 packets per second, which represents little more than wasted
data.  Allow the ALB learning packet interval to be made configurable via sysfs

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Acked-by: Veaceslav Falico <vfalico@redhat.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>

---
Change Notes:
v2)
Add documentation

v3)
Document the default value and make it a new macro
---
 Documentation/networking/bonding.txt |  6 ++++++
 drivers/net/bonding/bond_alb.c       |  2 +-
 drivers/net/bonding/bond_alb.h       |  9 +++++----
 drivers/net/bonding/bond_main.c      |  1 +
 drivers/net/bonding/bond_sysfs.c     | 39 ++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |  1 +
 6 files changed, 53 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 87bbcfe..9b28e71 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -1362,6 +1362,12 @@ To add ARP targets:
 To remove an ARP target:
 # echo -192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
 
+To configure the interval between learning packet transmits:
+# echo 12 > /sys/class/net/bond0/bonding/lp_interval
+	NOTE: the lp_inteval is the number of seconds between instances where
+the bonding driver sends learning packets to each slaves peer switch.  The
+default interval is 1 second.
+
 Example Configuration
 ---------------------
 	We begin with the same example that is shown in section 3.3,
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 91f179d..f428ef57 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1472,7 +1472,7 @@ void bond_alb_monitor(struct work_struct *work)
 	bond_info->lp_counter++;
 
 	/* send learning packets */
-	if (bond_info->lp_counter >= BOND_ALB_LP_TICKS) {
+	if (bond_info->lp_counter >= BOND_ALB_LP_TICKS(bond)) {
 		/* change of curr_active_slave involves swapping of mac addresses.
 		 * in order to avoid this swapping from happening while
 		 * sending the learning packets, the curr_slave_lock must be held for
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 28d8e4c..c5eff5d 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -36,14 +36,15 @@ struct slave;
 					 * Used for division - never set
 					 * to zero !!!
 					 */
-#define BOND_ALB_LP_INTERVAL	    1	/* In seconds, periodic send of
-					 * learning packets to the switch
-					 */
+#define BOND_ALB_DEFAULT_LP_INTERVAL 1
+#define BOND_ALB_LP_INTERVAL(bond) (bond->params.lp_interval)	/* In seconds, periodic send of
+								 * learning packets to the switch
+								 */
 
 #define BOND_TLB_REBALANCE_TICKS (BOND_TLB_REBALANCE_INTERVAL \
 				  * ALB_TIMER_TICKS_PER_SEC)
 
-#define BOND_ALB_LP_TICKS (BOND_ALB_LP_INTERVAL \
+#define BOND_ALB_LP_TICKS(bond) (BOND_ALB_LP_INTERVAL(bond) \
 			   * ALB_TIMER_TICKS_PER_SEC)
 
 #define TLB_HASH_TABLE_SIZE 256	/* The size of the clients hash table.
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 39e5b1c..31106b5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4416,6 +4416,7 @@ static int bond_check_params(struct bond_params *params)
 	params->all_slaves_active = all_slaves_active;
 	params->resend_igmp = resend_igmp;
 	params->min_links = min_links;
+	params->lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ce46776..4532259 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1680,6 +1680,44 @@ out:
 static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
 		   bonding_show_resend_igmp, bonding_store_resend_igmp);
 
+
+static ssize_t bonding_show_lp_interval(struct device *d,
+					struct device_attribute *attr,
+					char *buf)
+{
+	struct bonding *bond = to_bond(d);
+	return sprintf(buf, "%d\n", bond->params.lp_interval);
+}
+
+static ssize_t bonding_store_lp_interval(struct device *d,
+					 struct device_attribute *attr,
+					 const char *buf, size_t count)
+{
+	struct bonding *bond = to_bond(d);
+	int new_value, ret = count;
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		pr_err("%s: no lp interval value specified.\n",
+			bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (new_value <= 0) {
+		pr_err ("%s: lp_interval must be between 1 and %d\n",
+			bond->dev->name, INT_MAX);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	bond->params.lp_interval = new_value;
+out:
+	return ret;
+}
+
+static DEVICE_ATTR(lp_interval, S_IRUGO | S_IWUSR,
+		   bonding_show_lp_interval, bonding_store_lp_interval);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -1710,6 +1748,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_all_slaves_active.attr,
 	&dev_attr_resend_igmp.attr,
 	&dev_attr_min_links.attr,
+	&dev_attr_lp_interval.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index f7ab161..4bd9d5b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -176,6 +176,7 @@ struct bond_params {
 	int tx_queues;
 	int all_slaves_active;
 	int resend_igmp;
+	int lp_interval;
 };
 
 struct bond_parm_tbl {
-- 
1.8.3.1
