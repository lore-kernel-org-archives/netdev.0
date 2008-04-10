From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH]: net/bonding: Enable to change device type before enslaving
Date: Thu, 10 Apr 2008 18:09:51 +0300
Message-ID: <47FE2DBF.7080803@voltaire.com>
Reply-To: monis@voltaire.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Olga Stern <olgas@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:19610 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753675AbYDJOGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:06:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The bonding network device is being created  with device type ARPHDR_ETHER.
Although the device type changes with first slave we want to be able to change
it when it has zero slaves. The reason is to make the kernel choose the right
function for multicast address translation (ib_xxx_mc_map) which is determined by
device type even when no slaves are enslaved. If not so, the kernel picks a wrong
translation function and wrong HW addresses will be passed to slaves when the
bonding device tries to set their multicast lists.

Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 drivers/net/bonding/bond_sysfs.c |   48 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 90a1f31..86fec7e 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -950,6 +950,7 @@ out:
 }
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR, bonding_show_lacp, bonding_store_lacp);
 
+
 /*
  * Show and set the MII monitor interval.  There are two tricky bits
  * here.  First, if MII monitoring is activated, then we must disable
@@ -1039,6 +1040,52 @@ out:
 static DEVICE_ATTR(miimon, S_IRUGO | S_IWUSR, bonding_show_miimon, bonding_store_miimon);
 
 /*
+ * Show and set the device type of the bonding device
+ */
+static ssize_t bonding_show_devtype(struct device *d,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->dev->type);
+}
+
+static ssize_t bonding_store_devtype(struct device *d,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: no device type value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (bond->slave_cnt > 0) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Can't change device type when slaves are present; rejected.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (new_value <= 0) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Invalid  device type %d not in range %d-%d; rejected.\n",
+		       bond->dev->name, new_value, 1, INT_MAX);
+		ret = -EINVAL;
+		goto out;
+	}
+	bond->dev->type = new_value;
+out:
+	return ret;
+}
+static DEVICE_ATTR(devtype, S_IRUGO | S_IWUSR, bonding_show_devtype, bonding_store_devtype);
+
+/*
  * Show and set the primary slave.  The store function is much
  * simpler than bonding_store_slaves function because it only needs to
  * handle one interface name.
@@ -1387,6 +1434,7 @@ static struct attribute *per_bond_attrs[
 	&dev_attr_updelay.attr,
 	&dev_attr_lacp_rate.attr,
 	&dev_attr_xmit_hash_policy.attr,
+	&dev_attr_devtype.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
 	&dev_attr_use_carrier.attr,
