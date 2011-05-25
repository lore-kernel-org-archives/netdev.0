From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH v2] bonding: documentation and code cleanup for resend_igmp
Date: Wed, 25 May 2011 15:38:58 -0300
Message-ID: <1306348738-23946-1-git-send-email-fbl@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Rick Jones <rick.jones2@hp.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428Ab1EYSjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2011 14:39:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improves the documentation about how IGMP resend parameter
works, fix two missing checks and coding style issues.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 Documentation/networking/bonding.txt |   13 +++++++++++--
 drivers/net/bonding/bond_main.c      |   12 +++++++-----
 drivers/net/bonding/bond_sysfs.c     |   10 +++++-----
 3 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 1f45bd8..675612f 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -770,8 +770,17 @@ resend_igmp
 	a failover event. One membership report is issued immediately after
 	the failover, subsequent packets are sent in each 200ms interval.
 
-	The valid range is 0 - 255; the default value is 1. This option
-	was added for bonding version 3.7.0.
+	The valid range is 0 - 255; the default value is 1. A value of 0
+	prevents the IGMP membership report from being issued in response
+	to the failover event.
+
+	This option is useful for bonding modes balance-rr (0), active-backup
+	(1), balance-tlb (5) and balance-alb (6), in which a failover can
+	switch the IGMP traffic from one slave to another.  Therefore a fresh
+	IGMP report must be issued to cause the switch to forward the incoming
+	IGMP traffic over the newly selected slave.
+
+	This option was added for bonding version 3.7.0.
 
 3. Configuring Bonding Devices
 ==============================
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6dc4284..86a8001 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -852,7 +852,7 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
-							mcast_work.work);
+					    mcast_work.work);
 	bond_resend_igmp_join_requests(bond);
 }
 
@@ -1172,10 +1172,12 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	}
 
 	/* resend IGMP joins since active slave has changed or
-	 * all were sent on curr_active_slave */
-	if (((USES_PRIMARY(bond->params.mode) && new_active) ||
-	     bond->params.mode == BOND_MODE_ROUNDROBIN) &&
-	    netif_running(bond->dev)) {
+	 * all were sent on curr_active_slave.
+	 * resend only if bond is brought up with the affected
+	 * bonding modes and the retransmission is enabled */
+	if (netif_running(bond->dev) && (bond->params.resend_igmp > 0) &&
+	    ((USES_PRIMARY(bond->params.mode) && new_active) ||
+	     bond->params.mode == BOND_MODE_ROUNDROBIN)) {
 		bond->igmp_retrans = bond->params.resend_igmp;
 		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 4059bfc..a32848a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1539,8 +1539,8 @@ static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
  * Show and set the number of IGMP membership reports to send on link failure
  */
 static ssize_t bonding_show_resend_igmp(struct device *d,
-					 struct device_attribute *attr,
-					 char *buf)
+					struct device_attribute *attr,
+					char *buf)
 {
 	struct bonding *bond = to_bond(d);
 
@@ -1548,8 +1548,8 @@ static ssize_t bonding_show_resend_igmp(struct device *d,
 }
 
 static ssize_t bonding_store_resend_igmp(struct device *d,
-					  struct device_attribute *attr,
-					  const char *buf, size_t count)
+					 struct device_attribute *attr,
+					 const char *buf, size_t count)
 {
 	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
@@ -1561,7 +1561,7 @@ static ssize_t bonding_store_resend_igmp(struct device *d,
 		goto out;
 	}
 
-	if (new_value < 0) {
+	if (new_value < 0 || new_value > 255) {
 		pr_err("%s: Invalid resend_igmp value %d not in range 0-255; rejected.\n",
 		       bond->dev->name, new_value);
 		ret = -EINVAL;
-- 
1.7.4

