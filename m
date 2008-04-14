From: Moni Shoua <monis@voltaire.com>
Subject: Re: [PATCH] net/bonding: Send more than one gratuitous ARP when slave
 takes over
Date: Mon, 14 Apr 2008 18:25:11 +0300
Message-ID: <48037757.2070203@voltaire.com>
References: <47FE2D2D.2040504@voltaire.com>
Reply-To: monis@voltaire.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev <netdev@vger.kernel.org>,
	Olga Stern <olgas@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:42507 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761899AbYDNOWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 10:22:25 -0400
In-Reply-To: <47FE2D2D.2040504@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay,
This is a version of the patch with respect to the comments.
Please note that besides enabling set/get of the value through 
sysfs, I also made num_grat_arp a per-bond parameter.
thanks
 MoniS

--------------------------------------------------------------


With IPoIB, reception of gratuitous ARP by neighboring hosts
is essential for a successful change of slaves in case of failure.
Otherwise, they won't learn about the HW address change and need
to wait a long time until the neighboring system gives up and sends
an ARP request to learn the new HW address.  This patch decreases
the chance for a lost of a gratuitous ARP packet by sending it more
than once. The number retries is configurable and can be set with a module param.

Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 drivers/net/bonding/bond_main.c  |   23 ++++++++++++++++++----
 drivers/net/bonding/bond_sysfs.c |   40 +++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h    |    1 
 3 files changed, 60 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0f06753..d48edd4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -88,6 +88,7 @@ #define BOND_LINK_MON_INTERV	0
 #define BOND_LINK_ARP_INTERV	0
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
+static int num_grat_arp = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
 static int updelay	= 0;
 static int downdelay	= 0;
@@ -104,6 +105,8 @@ struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
+module_param(num_grat_arp, int, 0644);
+MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packets to send on failover event");
 module_param(miimon, int, 0);
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 module_param(updelay, int, 0);
@@ -1109,14 +1112,18 @@ void bond_change_active_slave(struct bon
 		if (new_active && bond->params.fail_over_mac)
 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
 				new_active->dev->addr_len);
+		bond->send_grat_arp = bond->params.num_grat_arp;
 		if (bond->curr_active_slave &&
 			test_bit(__LINK_STATE_LINKWATCH_PENDING,
 					&bond->curr_active_slave->dev->state)) {
 			dprintk("delaying gratuitous arp on %s\n",
 				bond->curr_active_slave->dev->name);
-			bond->send_grat_arp = 1;
-		} else
-			bond_send_gratuitous_arp(bond);
+		} else {
+			if (bond->send_grat_arp > 0) {
+				bond_send_gratuitous_arp(bond);
+				bond->send_grat_arp--;
+			}
+		}
 	}
 }
 
@@ -2144,7 +2151,7 @@ static int __bond_mii_monitor(struct bon
 			dprintk("sending delayed gratuitous arp on on %s\n",
 				bond->curr_active_slave->dev->name);
 			bond_send_gratuitous_arp(bond);
-			bond->send_grat_arp = 0;
+			bond->send_grat_arp--;
 		}
 	}
 	read_lock(&bond->curr_slave_lock);
@@ -4663,6 +4670,13 @@ static int bond_check_params(struct bond
 		use_carrier = 1;
 	}
 
+	if (num_grat_arp < 0 || num_grat_arp > 255) {
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: num_grat_arp (%d) not in range 0-255 so it "
+		       "was reset to 1 \n", num_grat_arp);
+		num_grat_arp = 1;
+	}
+
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
 		if (!miimon) {
@@ -4850,6 +4864,7 @@ static int bond_check_params(struct bond
 	params->mode = bond_mode;
 	params->xmit_policy = xmit_hashtype;
 	params->miimon = miimon;
+	params->num_grat_arp = num_grat_arp;
 	params->arp_interval = arp_interval;
 	params->arp_validate = arp_validate_value;
 	params->updelay = updelay;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 979c2d0..474ef02 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -952,6 +952,45 @@ out:
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR, bonding_show_lacp, bonding_store_lacp);
 
 /*
+ * Show and set the number of grat ARP to send after a failover event.
+ */
+static ssize_t bonding_show_n_grat_arp(struct device *d,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.num_grat_arp);
+}
+
+static ssize_t bonding_store_n_grat_arp(struct device *d,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: no num_grat_arp value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (new_value < 0 || new_value > 255) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Invalid num_grat_arp value %d not in range 0-255; rejected.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		bond->params.num_grat_arp = new_value;
+	}
+out:
+	return ret;
+}
+static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR, bonding_show_n_grat_arp, bonding_store_n_grat_arp);
+/*
  * Show and set the MII monitor interval.  There are two tricky bits
  * here.  First, if MII monitoring is activated, then we must disable
  * ARP monitoring.  Second, if the timer isn't running, we must
@@ -1388,6 +1427,7 @@ static struct attribute *per_bond_attrs[
 	&dev_attr_updelay.attr,
 	&dev_attr_lacp_rate.attr,
 	&dev_attr_xmit_hash_policy.attr,
+	&dev_attr_num_grat_arp.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
 	&dev_attr_use_carrier.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a3c74e2..ffa4813 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -125,6 +125,7 @@ struct bond_params {
 	int mode;
 	int xmit_policy;
 	int miimon;
+	int num_grat_arp;
 	int arp_interval;
 	int arp_validate;
 	int use_carrier;
