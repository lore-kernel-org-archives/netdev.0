From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: introduce primary_lazy option
Date: Thu, 13 Aug 2009 08:44:55 -0700
Message-ID: <19189.1250178295@death.nxdomain.ibm.com>
References: <20090813150513.GB10449@psychotron.englab.brq.redhat.com>
Cc: davem@davemloft.net, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:55991 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbZHMPpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 11:45:12 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7DFdjBf002790
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 09:39:45 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7DFiuUX021290
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 09:45:00 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7DFisxx016991
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 09:44:56 -0600
In-reply-to: <20090813150513.GB10449@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>In some cases there is not desirable to switch back to primary interface when
>it's link recovers and rather stay wiith currently active one. We need to avoid
>packetloss as much as we can in some cases. This is solved by introducing
>primary_lazy option. Note that enslaved primary slave is set as current
>active no matter what.

	Are you just looking for a way to insure that, when the bond
first comes up (is configured at boot, for example), a particular slave
is the active slave?  In that case, why can't an explicit selection be
made via either ifenslave -c or /sys/class/net/bond0/bonding/active ?

	-J

>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>index d5181ce..f1b82af 100644
>--- a/Documentation/networking/bonding.txt
>+++ b/Documentation/networking/bonding.txt
>@@ -614,6 +614,15 @@ primary
>
> 	The primary option is only valid for active-backup mode.
>
>+primary_lazy
>+
>+	Specifies the behaviour of the primary slave in case of
>+	it's link recovery has been detected. By default (value 0) the
>+	primary slave is set as active slave immediately after the link
>+	recovery. If the value is 1 then current active slave doesn't
>+	change as long as it's link status doesn't change. This prevents
>+	the bonding device from flip-flopping.
>+
> updelay
>
> 	Specifies the time, in milliseconds, to wait before enabling a
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 3bf0cc6..00fbb9d 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -94,6 +94,7 @@ static int downdelay;
> static int use_carrier	= 1;
> static char *mode;
> static char *primary;
>+static int primary_lazy;
> static char *lacp_rate;
> static char *ad_select;
> static char *xmit_hash_policy;
>@@ -126,6 +127,9 @@ MODULE_PARM_DESC(mode, "Mode of operation : 0 for balance-rr, "
> 		       "6 for balance-alb");
> module_param(primary, charp, 0);
> MODULE_PARM_DESC(primary, "Primary network device to use");
>+module_param(primary_lazy, int, 0);
>+MODULE_PARM_DESC(primary_lazy, "Do not set primary slave active once it comes up; "
>+			       "0 for off (default), 1 for on");
> module_param(lacp_rate, charp, 0);
> MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner "
> 			    "(slow/fast)");
>@@ -1067,7 +1071,6 @@ out:
>
> }
>
>-
> /**
>  * find_best_interface - select the best available slave to be the active one
>  * @bond: our bonding struct
>@@ -1097,9 +1100,11 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
> 	 * and primary_slave that may be up and able to arp
> 	 */
> 	if ((bond->primary_slave) &&
>-	    (!bond->params.arp_interval) &&
>-	    (IS_UP(bond->primary_slave->dev))) {
>+	    (IS_UP(bond->primary_slave->dev)) &&
>+	    (!(bond->params.primary_lazy && old_active &&
>+	       (IS_UP(old_active->dev))) || bond->force_primary)) {
> 		new_active = bond->primary_slave;
>+		bond->force_primary = false;
> 	}
>
> 	/* remember where to stop iterating over the slaves */
>@@ -1674,8 +1679,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>
> 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
> 		/* if there is a primary slave, remember it */
>-		if (strcmp(bond->params.primary, new_slave->dev->name) == 0)
>+		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
> 			bond->primary_slave = new_slave;
>+			bond->force_primary = true;
>+		}
> 	}
>
> 	write_lock_bh(&bond->curr_slave_lock);
>@@ -2929,7 +2936,9 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
> 	 */
> 	if (bond->primary_slave &&
> 	    (bond->primary_slave != bond->curr_active_slave) &&
>-	    (bond->primary_slave->link == BOND_LINK_UP))
>+	    (bond->primary_slave->link == BOND_LINK_UP) &&
>+	    !(bond->params.primary_lazy && bond->curr_active_slave &&
>+              bond->curr_active_slave->link == BOND_LINK_UP))
> 		commit++;
>
> 	read_unlock(&bond->curr_slave_lock);
>@@ -3035,7 +3044,9 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
> 	 */
> 	if (bond->primary_slave &&
> 	    (bond->primary_slave != bond->curr_active_slave) &&
>-	    (bond->primary_slave->link == BOND_LINK_UP)) {
>+	    (bond->primary_slave->link == BOND_LINK_UP) &&
>+	    !(bond->params.primary_lazy && bond->curr_active_slave &&
>+              bond->curr_active_slave->link == BOND_LINK_UP)) {
> 		write_lock_bh(&bond->curr_slave_lock);
> 		bond_change_active_slave(bond, bond->primary_slave);
> 		write_unlock_bh(&bond->curr_slave_lock);
>@@ -4987,6 +4998,17 @@ static int bond_check_params(struct bond_params *params)
> 		primary = NULL;
> 	}
>
>+	if (primary) {
>+		if ((primary_lazy != 0) && (primary_lazy != 1)) {
>+			pr_warning(DRV_NAME
>+				   ": Warning: primary_lazy module parameter "
>+				   "(%d), not of valid value (0/1), so it was "
>+				   "set to 0\n",
>+				   primary_lazy);
>+			primary_lazy = 1;
>+		}
>+	}
>+
> 	if (fail_over_mac) {
> 		fail_over_mac_value = bond_parse_parm(fail_over_mac,
> 						      fail_over_mac_tbl);
>@@ -5018,6 +5040,7 @@ static int bond_check_params(struct bond_params *params)
> 	params->use_carrier = use_carrier;
> 	params->lacp_fast = lacp_fast;
> 	params->primary[0] = 0;
>+	params->primary_lazy = primary_lazy;
> 	params->fail_over_mac = fail_over_mac_value;
>
> 	if (primary) {
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 55bf34f..573fe82 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1209,6 +1209,59 @@ static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR,
> 		   bonding_show_primary, bonding_store_primary);
>
> /*
>+ * Show and set the primary_lazy flag.
>+ */
>+static ssize_t bonding_show_primary_lazy(struct device *d,
>+				    struct device_attribute *attr,
>+				    char *buf)
>+{
>+	struct bonding *bond = to_bond(d);
>+
>+	return sprintf(buf, "%d\n", bond->params.primary_lazy);
>+}
>+
>+static ssize_t bonding_store_primary_lazy(struct device *d,
>+				     struct device_attribute *attr,
>+				     const char *buf, size_t count)
>+{
>+	int new_value, ret = count;
>+	struct bonding *bond = to_bond(d);
>+
>+	if (!rtnl_trylock())
>+		return restart_syscall();
>+
>+	if (sscanf(buf, "%d", &new_value) != 1) {
>+		pr_err(DRV_NAME
>+		       ": %s: no primary_lazy value specified.\n",
>+		       bond->dev->name);
>+		ret = -EINVAL;
>+		goto out;
>+	}
>+	if ((new_value == 0) || (new_value == 1)) {
>+		bond->params.primary_lazy = new_value;
>+		pr_info(DRV_NAME ": %s: Setting primary_lazy to %d.\n",
>+		       bond->dev->name, new_value);
>+		if (!bond->params.primary_lazy) {
>+			bond->force_primary = true;
>+			read_lock(&bond->lock);
>+			write_lock_bh(&bond->curr_slave_lock);
>+			bond_select_active_slave(bond);
>+			write_unlock_bh(&bond->curr_slave_lock);
>+			read_unlock(&bond->lock);
>+		}
>+	} else {
>+		pr_info(DRV_NAME
>+		       ": %s: Ignoring invalid primary_lazy value %d.\n",
>+		       bond->dev->name, new_value);
>+	}
>+out:
>+	rtnl_unlock();
>+	return count;
>+}
>+static DEVICE_ATTR(primary_lazy, S_IRUGO | S_IWUSR,
>+		   bonding_show_primary_lazy, bonding_store_primary_lazy);
>+
>+/*
>  * Show and set the use_carrier flag.
>  */
> static ssize_t bonding_show_carrier(struct device *d,
>@@ -1497,6 +1550,7 @@ static struct attribute *per_bond_attrs[] = {
> 	&dev_attr_num_unsol_na.attr,
> 	&dev_attr_miimon.attr,
> 	&dev_attr_primary.attr,
>+	&dev_attr_primary_lazy.attr,
> 	&dev_attr_use_carrier.attr,
> 	&dev_attr_active_slave.attr,
> 	&dev_attr_mii_status.attr,
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 6290a50..ac35c6c 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -131,6 +131,7 @@ struct bond_params {
> 	int lacp_fast;
> 	int ad_select;
> 	char primary[IFNAMSIZ];
>+	int primary_lazy;
> 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
> };
>
>@@ -190,6 +191,7 @@ struct bonding {
> 	struct   slave *curr_active_slave;
> 	struct   slave *current_arp_slave;
> 	struct   slave *primary_slave;
>+	bool     force_primary;
> 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
> 	rwlock_t lock;
> 	rwlock_t curr_slave_lock;

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
