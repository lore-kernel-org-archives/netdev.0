From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 v2] bonding: allow resetting slave failure
 counters
Date: Wed, 1 Jun 2011 18:31:54 +0200
Message-ID: <20110601163153.GB2784@psychotron.redhat.com>
References: <1306921249-3623-1-git-send-email-jpirko@redhat.com>
 <4DE63E85.7020508@redhat.com>
 <20110601135321.GA2909@psychotron.brq.redhat.com>
 <16056.1306944819@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Flavio Leitner <fbl@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628Ab1FARXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 13:23:12 -0400
Content-Disposition: inline
In-Reply-To: <16056.1306944819@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to reset failure counters for all enslaved devices.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

v1->v2: added version bump
	added version note to doc
	moved and adjusted printk
---
 Documentation/networking/bonding.txt |    9 +++++++++
 drivers/net/bonding/bond_sysfs.c     |   28 ++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |    4 ++--
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 675612f..7a8da01 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -782,6 +782,15 @@ resend_igmp
 
 	This option was added for bonding version 3.7.0.
 
+reset_failure_counters
+
+	This write-only control file will zero failure counters for
+	all slaves.  Note there is no appropriate module parameter for this
+	since it would not make much sense.
+	Write any value to perform reset.
+
+	This option was added for bonding version 3.7.2.
+
 3. Configuring Bonding Devices
 ==============================
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 88fcb25..342b4ed 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1572,6 +1572,33 @@ out:
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
+	pr_info("%s: Resetting failure counters.\n", bond->dev->name);
+
+	read_lock(&bond->lock);
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
@@ -1600,6 +1627,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_queue_id.attr,
 	&dev_attr_all_slaves_active.attr,
 	&dev_attr_resend_igmp.attr,
+	&dev_attr_reset_failure_counters.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ea1d005..62528f8 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -24,8 +24,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.7.1"
-#define DRV_RELDATE	"April 27, 2011"
+#define DRV_VERSION	"3.7.2"
+#define DRV_RELDATE	"Jun 1, 2011"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
-- 
1.7.4.4

