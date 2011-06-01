From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] bonding: allow resetting slave failure counters
Date: Wed,  1 Jun 2011 11:40:49 +0200
Message-ID: <1306921249-3623-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933179Ab1FAJlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 05:41:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to reset failure counters for all enslaved devices.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 Documentation/networking/bonding.txt |    7 +++++++
 drivers/net/bonding/bond_sysfs.c     |   27 +++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 675612f..2f51d73 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -782,6 +782,13 @@ resend_igmp
 
 	This option was added for bonding version 3.7.0.
 
+reset_failure_counters
+
+	This write-only control file will zero failure counters for
+	all slaves.  Note there is no appropriate module parameter for this
+	since it would not make much sense.
+	Write any value to perform reset.
+
 3. Configuring Bonding Devices
 ==============================
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 88fcb25..9b45164 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1572,6 +1572,32 @@ out:
 static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
 		   bonding_show_resend_igmp, bonding_store_resend_igmp);
 
+static ssize_t
+bonding_store_reset_failure_counters(struct device *d,
+				     struct device_attribute *attr,
+				     const char *buf, size_t count)
+{
+	struct slave *slave;
+	int i;
+	struct bonding *bond = to_bond(d);
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	read_lock(&bond->lock);
+	pr_info("%s: Resetting counters.\n", bond->dev->name);
+	bond_for_each_slave(bond, slave, i)
+		slave->link_failure_count = 0;
+	read_unlock(&bond->lock);
+
+	rtnl_unlock();
+
+	return count;
+}
+
+static DEVICE_ATTR(reset_failure_counters, S_IWUSR, NULL,
+		   bonding_store_reset_failure_counters);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -1600,6 +1626,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_queue_id.attr,
 	&dev_attr_all_slaves_active.attr,
 	&dev_attr_resend_igmp.attr,
+	&dev_attr_reset_failure_counters.attr,
 	NULL,
 };
 
-- 
1.7.4.4

