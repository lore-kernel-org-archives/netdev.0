From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: convert delay parameters to unsigned integers
Date: Tue, 06 Nov 2012 11:03:33 -0800
Message-ID: <5112.1352228613@death.nxdomain>
References: <1352202733-27906-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41055 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343Ab2KFTD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2012 14:03:56 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 6 Nov 2012 14:03:55 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 321FD38C8026
	for <netdev@vger.kernel.org>; Tue,  6 Nov 2012 14:03:52 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6J3oY9188668
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2012 14:03:50 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6J3d2U018595
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2012 12:03:40 -0700
In-reply-to: <1352202733-27906-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>This patch converts the following parameters from int to unsigned int in order
>to remove the unnecessary < 0 checks in the code and make it less error prone. 
>The functionality remains unchanged as before it wasn't allowed to have these 
>be less than zero too. Their maximum value was INT_MAX, now it will be UINT_MAX.
>It also fixes how min_links parameter is treated since it is unsigned int
>already but was treated as signed integer.

	Is this patch fixing any actual bugs, and if so, what?

>struct bond_params members:
>updelay downdelay miimon arp_interval
>
>The delay variable is initialized from updelay and downdelay parameters and
>counted down to zero so it should never be < 0.
>
>struct slave members:
>delay
>
>The change to struct ifbond's miimon parameter (s32 -> u32) will probably 
>affect some user-space software but it should be all right in 99 % of the
>cases as I don't think anyone uses > INT_MAX for that.

	The struct ifbond is used to pass information from the kernel to
user space in response to an SIOCBONDINFOQUERY ioctl.  It is not used to
set values within the kernel.  In any event, I don't believe it is
acceptable to modify a user-visible structure like this, even to change
types from signed to unsigned of the same size.

>Limited testing of this patch was done in VMs.

	If this is not actually fixing any bugs (i.e., is a cosmetic
change only), then I think it's reasonable to expect the changes to be
fully tested by you to insure there are no regressions introduced.

	In particular, if a negative number is passed in after your
patch is applied, is it accepted or rejected, and if it is accepted,
what is the value?  For example, if the user specifies "miimon=-1" does
that fail, or is miimon set to 4294967295?

	-J

>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_main.c   |  92 +++++++--------------
> drivers/net/bonding/bond_procfs.c |  10 +--
> drivers/net/bonding/bond_sysfs.c  | 169 ++++++++++++++++----------------------
> drivers/net/bonding/bonding.h     |  10 +--
> include/uapi/linux/if_bonding.h   |   2 +-
> 5 files changed, 114 insertions(+), 169 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index b2530b0..a6983e2 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -87,21 +87,21 @@
> #define BOND_LINK_MON_INTERV	0
> #define BOND_LINK_ARP_INTERV	0
>
>-static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
>+static unsigned int max_bonds	= BOND_DEFAULT_MAX_BONDS;
> static int tx_queues	= BOND_DEFAULT_TX_QUEUES;
> static int num_peer_notif = 1;
>-static int miimon	= BOND_LINK_MON_INTERV;
>-static int updelay;
>-static int downdelay;
>+static unsigned int miimon	= BOND_LINK_MON_INTERV;
>+static unsigned int updelay;
>+static unsigned int downdelay;
> static int use_carrier	= 1;
> static char *mode;
> static char *primary;
> static char *primary_reselect;
> static char *lacp_rate;
>-static int min_links;
>+static unsigned int min_links;
> static char *ad_select;
> static char *xmit_hash_policy;
>-static int arp_interval = BOND_LINK_ARP_INTERV;
>+static unsigned int arp_interval = BOND_LINK_ARP_INTERV;
> static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
> static char *arp_validate;
> static char *fail_over_mac;
>@@ -109,7 +109,7 @@ static int all_slaves_active = 0;
> static struct bond_params bonding_defaults;
> static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
>
>-module_param(max_bonds, int, 0);
>+module_param(max_bonds, uint, 0);
> MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
> module_param(tx_queues, int, 0);
> MODULE_PARM_DESC(tx_queues, "Max number of transmit queues (default = 16)");
>@@ -119,11 +119,11 @@ MODULE_PARM_DESC(num_grat_arp, "Number of peer notifications to send on "
> module_param_named(num_unsol_na, num_peer_notif, int, 0644);
> MODULE_PARM_DESC(num_unsol_na, "Number of peer notifications to send on "
> 			       "failover event (alias of num_grat_arp)");
>-module_param(miimon, int, 0);
>+module_param(miimon, uint, 0);
> MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
>-module_param(updelay, int, 0);
>+module_param(updelay, uint, 0);
> MODULE_PARM_DESC(updelay, "Delay before considering link up, in milliseconds");
>-module_param(downdelay, int, 0);
>+module_param(downdelay, uint, 0);
> MODULE_PARM_DESC(downdelay, "Delay before considering link down, "
> 			    "in milliseconds");
> module_param(use_carrier, int, 0);
>@@ -151,14 +151,14 @@ module_param(ad_select, charp, 0);
> MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic; "
> 			    "0 for stable (default), 1 for bandwidth, "
> 			    "2 for count");
>-module_param(min_links, int, 0);
>+module_param(min_links, uint, 0);
> MODULE_PARM_DESC(min_links, "Minimum number of available links before turning on carrier");
>
> module_param(xmit_hash_policy, charp, 0);
> MODULE_PARM_DESC(xmit_hash_policy, "balance-xor and 802.3ad hashing method; "
> 				   "0 for layer 2 (default), 1 for layer 3+4, "
> 				   "2 for layer 2+3");
>-module_param(arp_interval, int, 0);
>+module_param(arp_interval, uint, 0);
> MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
> module_param_array(arp_ip_target, charp, NULL, 0);
> MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
>@@ -983,7 +983,7 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
> {
> 	struct slave *new_active, *old_active;
> 	struct slave *bestslave = NULL;
>-	int mintime = bond->params.updelay;
>+	unsigned int mintime = bond->params.updelay;
> 	int i;
>
> 	new_active = bond->curr_active_slave;
>@@ -1063,7 +1063,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
>
> 		if (new_active->link == BOND_LINK_BACK) {
> 			if (USES_PRIMARY(bond->params.mode)) {
>-				pr_info("%s: making interface %s the new active one %d ms earlier.\n",
>+				pr_info("%s: making interface %s the new active one %u ms earlier.\n",
> 					bond->dev->name, new_active->dev->name,
> 					(bond->params.updelay - new_active->delay) * bond->params.miimon);
> 			}
>@@ -2356,7 +2356,7 @@ static int bond_miimon_inspect(struct bonding *bond)
> 			slave->link = BOND_LINK_FAIL;
> 			slave->delay = bond->params.downdelay;
> 			if (slave->delay) {
>-				pr_info("%s: link status down for %sinterface %s, disabling it in %d ms.\n",
>+				pr_info("%s: link status down for %sinterface %s, disabling it in %u ms.\n",
> 					bond->dev->name,
> 					(bond->params.mode ==
> 					 BOND_MODE_ACTIVEBACKUP) ?
>@@ -2373,7 +2373,7 @@ static int bond_miimon_inspect(struct bonding *bond)
> 				 */
> 				slave->link = BOND_LINK_UP;
> 				slave->jiffies = jiffies;
>-				pr_info("%s: link status up again after %d ms for interface %s.\n",
>+				pr_info("%s: link status up again after %u ms for interface %s.\n",
> 					bond->dev->name,
> 					(bond->params.downdelay - slave->delay) *
> 					bond->params.miimon,
>@@ -2381,7 +2381,7 @@ static int bond_miimon_inspect(struct bonding *bond)
> 				continue;
> 			}
>
>-			if (slave->delay <= 0) {
>+			if (slave->delay == 0) {
> 				slave->new_link = BOND_LINK_DOWN;
> 				commit++;
> 				continue;
>@@ -2398,7 +2398,7 @@ static int bond_miimon_inspect(struct bonding *bond)
> 			slave->delay = bond->params.updelay;
>
> 			if (slave->delay) {
>-				pr_info("%s: link status up for interface %s, enabling it in %d ms.\n",
>+				pr_info("%s: link status up for interface %s, enabling it in %u ms.\n",
> 					bond->dev->name, slave->dev->name,
> 					ignore_updelay ? 0 :
> 					bond->params.updelay *
>@@ -2408,7 +2408,7 @@ static int bond_miimon_inspect(struct bonding *bond)
> 		case BOND_LINK_BACK:
> 			if (!link_state) {
> 				slave->link = BOND_LINK_DOWN;
>-				pr_info("%s: link status down again after %d ms for interface %s.\n",
>+				pr_info("%s: link status down again after %u ms for interface %s.\n",
> 					bond->dev->name,
> 					(bond->params.updelay - slave->delay) *
> 					bond->params.miimon,
>@@ -2420,7 +2420,7 @@ static int bond_miimon_inspect(struct bonding *bond)
> 			if (ignore_updelay)
> 				slave->delay = 0;
>
>-			if (slave->delay <= 0) {
>+			if (slave->delay == 0) {
> 				slave->new_link = BOND_LINK_UP;
> 				commit++;
> 				ignore_updelay = false;
>@@ -2811,7 +2811,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
> 					    arp_work.work);
> 	struct slave *slave, *oldcurrent;
> 	int do_failover = 0;
>-	int delta_in_ticks, extra_ticks;
>+	unsigned int delta_in_ticks, extra_ticks;
> 	int i;
>
> 	read_lock(&bond->lock);
>@@ -3020,7 +3020,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
>  *
>  * Called with RTNL and bond->lock for read.
>  */
>-static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
>+static void bond_ab_arp_commit(struct bonding *bond, unsigned int delta_in_ticks)
> {
> 	struct slave *slave;
> 	int i;
>@@ -3166,7 +3166,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
> 	struct bonding *bond = container_of(work, struct bonding,
> 					    arp_work.work);
> 	bool should_notify_peers = false;
>-	int delta_in_ticks;
>+	unsigned int delta_in_ticks;
>
> 	read_lock(&bond->lock);
>
>@@ -4574,30 +4574,6 @@ static int bond_check_params(struct bond_params *params)
> 		params->ad_select = BOND_AD_STABLE;
> 	}
>
>-	if (max_bonds < 0) {
>-		pr_warning("Warning: max_bonds (%d) not in range %d-%d, so it was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
>-			   max_bonds, 0, INT_MAX, BOND_DEFAULT_MAX_BONDS);
>-		max_bonds = BOND_DEFAULT_MAX_BONDS;
>-	}
>-
>-	if (miimon < 0) {
>-		pr_warning("Warning: miimon module parameter (%d), not in range 0-%d, so it was reset to %d\n",
>-			   miimon, INT_MAX, BOND_LINK_MON_INTERV);
>-		miimon = BOND_LINK_MON_INTERV;
>-	}
>-
>-	if (updelay < 0) {
>-		pr_warning("Warning: updelay module parameter (%d), not in range 0-%d, so it was reset to 0\n",
>-			   updelay, INT_MAX);
>-		updelay = 0;
>-	}
>-
>-	if (downdelay < 0) {
>-		pr_warning("Warning: downdelay module parameter (%d), not in range 0-%d, so it was reset to 0\n",
>-			   downdelay, INT_MAX);
>-		downdelay = 0;
>-	}
>-
> 	if ((use_carrier != 0) && (use_carrier != 1)) {
> 		pr_warning("Warning: use_carrier module parameter (%d), not of valid value (0/1), so it was set to 1\n",
> 			   use_carrier);
>@@ -4651,7 +4627,7 @@ static int bond_check_params(struct bond_params *params)
> 	}
>
> 	if (bond_mode == BOND_MODE_ALB) {
>-		pr_notice("In ALB mode you might experience client disconnections upon reconnection of a link if the bonding module updelay parameter (%d msec) is incompatible with the forwarding delay time of the switch\n",
>+		pr_notice("In ALB mode you might experience client disconnections upon reconnection of a link if the bonding module updelay parameter (%u msec) is incompatible with the forwarding delay time of the switch\n",
> 			  updelay);
> 	}
>
>@@ -4660,19 +4636,19 @@ static int bond_check_params(struct bond_params *params)
> 			/* just warn the user the up/down delay will have
> 			 * no effect since miimon is zero...
> 			 */
>-			pr_warning("Warning: miimon module parameter not set and updelay (%d) or downdelay (%d) module parameter is set; updelay and downdelay have no effect unless miimon is set\n",
>+			pr_warning("Warning: miimon module parameter not set and updelay (%u) or downdelay (%u) module parameter is set; updelay and downdelay have no effect unless miimon is set\n",
> 				   updelay, downdelay);
> 		}
> 	} else {
> 		/* don't allow arp monitoring */
> 		if (arp_interval) {
>-			pr_warning("Warning: miimon (%d) and arp_interval (%d) can't be used simultaneously, disabling ARP monitoring\n",
>+			pr_warning("Warning: miimon (%u) and arp_interval (%u) can't be used simultaneously, disabling ARP monitoring\n",
> 				   miimon, arp_interval);
> 			arp_interval = 0;
> 		}
>
> 		if ((updelay % miimon) != 0) {
>-			pr_warning("Warning: updelay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
>+			pr_warning("Warning: updelay (%u) is not a multiple of miimon (%u), updelay rounded to %u ms\n",
> 				   updelay, miimon,
> 				   (updelay / miimon) * miimon);
> 		}
>@@ -4680,7 +4656,7 @@ static int bond_check_params(struct bond_params *params)
> 		updelay /= miimon;
>
> 		if ((downdelay % miimon) != 0) {
>-			pr_warning("Warning: downdelay (%d) is not a multiple of miimon (%d), downdelay rounded to %d ms\n",
>+			pr_warning("Warning: downdelay (%u) is not a multiple of miimon (%u), downdelay rounded to %u ms\n",
> 				   downdelay, miimon,
> 				   (downdelay / miimon) * miimon);
> 		}
>@@ -4688,12 +4664,6 @@ static int bond_check_params(struct bond_params *params)
> 		downdelay /= miimon;
> 	}
>
>-	if (arp_interval < 0) {
>-		pr_warning("Warning: arp_interval module parameter (%d) , not in range 0-%d, so it was reset to %d\n",
>-			   arp_interval, INT_MAX, BOND_LINK_ARP_INTERV);
>-		arp_interval = BOND_LINK_ARP_INTERV;
>-	}
>-
> 	for (arp_ip_count = 0;
> 	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[arp_ip_count];
> 	     arp_ip_count++) {
>@@ -4711,7 +4681,7 @@ static int bond_check_params(struct bond_params *params)
>
> 	if (arp_interval && !arp_ip_count) {
> 		/* don't allow arping if no arp_ip_target given... */
>-		pr_warning("Warning: arp_interval module parameter (%d) specified without providing an arp_ip_target parameter, arp_interval was reset to 0\n",
>+		pr_warning("Warning: arp_interval module parameter (%u) specified without providing an arp_ip_target parameter, arp_interval was reset to 0\n",
> 			   arp_interval);
> 		arp_interval = 0;
> 	}
>@@ -4737,11 +4707,11 @@ static int bond_check_params(struct bond_params *params)
> 		arp_validate_value = 0;
>
> 	if (miimon) {
>-		pr_info("MII link monitoring set to %d ms\n", miimon);
>+		pr_info("MII link monitoring set to %u ms\n", miimon);
> 	} else if (arp_interval) {
> 		int i;
>
>-		pr_info("ARP monitoring set to %d ms, validate %s, with %d target(s):",
>+		pr_info("ARP monitoring set to %u ms, validate %s, with %d target(s):",
> 			arp_interval,
> 			arp_validate_tbl[arp_validate_value].modename,
> 			arp_ip_count);
>diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
>index 3cea38d..0b4c278 100644
>--- a/drivers/net/bonding/bond_procfs.c
>+++ b/drivers/net/bonding/bond_procfs.c
>@@ -94,17 +94,17 @@ static void bond_info_show_master(struct seq_file *seq)
>
> 	seq_printf(seq, "MII Status: %s\n", netif_carrier_ok(bond->dev) ?
> 		   "up" : "down");
>-	seq_printf(seq, "MII Polling Interval (ms): %d\n", bond->params.miimon);
>-	seq_printf(seq, "Up Delay (ms): %d\n",
>+	seq_printf(seq, "MII Polling Interval (ms): %u\n", bond->params.miimon);
>+	seq_printf(seq, "Up Delay (ms): %u\n",
> 		   bond->params.updelay * bond->params.miimon);
>-	seq_printf(seq, "Down Delay (ms): %d\n",
>+	seq_printf(seq, "Down Delay (ms): %u\n",
> 		   bond->params.downdelay * bond->params.miimon);
>
>
> 	/* ARP information */
> 	if (bond->params.arp_interval > 0) {
> 		int printed = 0;
>-		seq_printf(seq, "ARP Polling Interval (ms): %d\n",
>+		seq_printf(seq, "ARP Polling Interval (ms): %u\n",
> 				bond->params.arp_interval);
>
> 		seq_printf(seq, "ARP IP target/s (n.n.n.n form):");
>@@ -126,7 +126,7 @@ static void bond_info_show_master(struct seq_file *seq)
> 		seq_puts(seq, "\n802.3ad info\n");
> 		seq_printf(seq, "LACP rate: %s\n",
> 			   (bond->params.lacp_fast) ? "fast" : "slow");
>-		seq_printf(seq, "Min links: %d\n", bond->params.min_links);
>+		seq_printf(seq, "Min links: %u\n", bond->params.min_links);
> 		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
> 			   ad_select_tbl[bond->params.ad_select].modename);
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index ef8d2a0..b9a2131 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -503,28 +503,23 @@ static ssize_t bonding_show_arp_interval(struct device *d,
> {
> 	struct bonding *bond = to_bond(d);
>
>-	return sprintf(buf, "%d\n", bond->params.arp_interval);
>+	return sprintf(buf, "%u\n", bond->params.arp_interval);
> }
>
> static ssize_t bonding_store_arp_interval(struct device *d,
> 					  struct device_attribute *attr,
> 					  const char *buf, size_t count)
> {
>-	int new_value, ret = count;
>+	int ret = count;
>+	unsigned int new_value;
> 	struct bonding *bond = to_bond(d);
>
>-	if (sscanf(buf, "%d", &new_value) != 1) {
>+	if (sscanf(buf, "%u", &new_value) != 1) {
> 		pr_err("%s: no arp_interval value specified.\n",
> 		       bond->dev->name);
> 		ret = -EINVAL;
> 		goto out;
> 	}
>-	if (new_value < 0) {
>-		pr_err("%s: Invalid arp_interval value %d not in range 1-%d; rejected.\n",
>-		       bond->dev->name, new_value, INT_MAX);
>-		ret = -EINVAL;
>-		goto out;
>-	}
> 	if (bond->params.mode == BOND_MODE_ALB ||
> 	    bond->params.mode == BOND_MODE_TLB) {
> 		pr_info("%s: ARP monitoring cannot be used with ALB/TLB. Only MII monitoring is supported on %s.\n",
>@@ -532,7 +527,7 @@ static ssize_t bonding_store_arp_interval(struct device *d,
> 		ret = -EINVAL;
> 		goto out;
> 	}
>-	pr_info("%s: Setting ARP monitoring interval to %d.\n",
>+	pr_info("%s: Setting ARP monitoring interval to %u.\n",
> 		bond->dev->name, new_value);
> 	bond->params.arp_interval = new_value;
> 	if (bond->params.miimon) {
>@@ -682,14 +677,15 @@ static ssize_t bonding_show_downdelay(struct device *d,
> {
> 	struct bonding *bond = to_bond(d);
>
>-	return sprintf(buf, "%d\n", bond->params.downdelay * bond->params.miimon);
>+	return sprintf(buf, "%u\n", bond->params.downdelay * bond->params.miimon);
> }
>
> static ssize_t bonding_store_downdelay(struct device *d,
> 				       struct device_attribute *attr,
> 				       const char *buf, size_t count)
> {
>-	int new_value, ret = count;
>+	int ret = count;
>+	unsigned int new_value;
> 	struct bonding *bond = to_bond(d);
>
> 	if (!(bond->params.miimon)) {
>@@ -699,31 +695,22 @@ static ssize_t bonding_store_downdelay(struct device *d,
> 		goto out;
> 	}
>
>-	if (sscanf(buf, "%d", &new_value) != 1) {
>+	if (sscanf(buf, "%u", &new_value) != 1) {
> 		pr_err("%s: no down delay value specified.\n", bond->dev->name);
> 		ret = -EINVAL;
> 		goto out;
> 	}
>-	if (new_value < 0) {
>-		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
>-		       bond->dev->name, new_value, 1, INT_MAX);
>-		ret = -EINVAL;
>-		goto out;
>-	} else {
>-		if ((new_value % bond->params.miimon) != 0) {
>-			pr_warning("%s: Warning: down delay (%d) is not a multiple of miimon (%d), delay rounded to %d ms\n",
>-				   bond->dev->name, new_value,
>-				   bond->params.miimon,
>-				   (new_value / bond->params.miimon) *
>-				   bond->params.miimon);
>-		}
>-		bond->params.downdelay = new_value / bond->params.miimon;
>-		pr_info("%s: Setting down delay to %d.\n",
>-			bond->dev->name,
>-			bond->params.downdelay * bond->params.miimon);
>-
>+	if ((new_value % bond->params.miimon) != 0) {
>+		pr_warning("%s: Warning: down delay (%u) is not a multiple of miimon (%u), delay rounded to %u ms\n",
>+			   bond->dev->name, new_value,
>+			   bond->params.miimon,
>+			   (new_value / bond->params.miimon) *
>+			   bond->params.miimon);
> 	}
>-
>+	bond->params.downdelay = new_value / bond->params.miimon;
>+	pr_info("%s: Setting down delay to %u.\n",
>+		bond->dev->name,
>+		bond->params.downdelay * bond->params.miimon);
> out:
> 	return ret;
> }
>@@ -736,7 +723,7 @@ static ssize_t bonding_show_updelay(struct device *d,
> {
> 	struct bonding *bond = to_bond(d);
>
>-	return sprintf(buf, "%d\n", bond->params.updelay * bond->params.miimon);
>+	return sprintf(buf, "%u\n", bond->params.updelay * bond->params.miimon);
>
> }
>
>@@ -744,7 +731,8 @@ static ssize_t bonding_store_updelay(struct device *d,
> 				     struct device_attribute *attr,
> 				     const char *buf, size_t count)
> {
>-	int new_value, ret = count;
>+	int ret = count;
>+	unsigned int new_value;
> 	struct bonding *bond = to_bond(d);
>
> 	if (!(bond->params.miimon)) {
>@@ -754,30 +742,23 @@ static ssize_t bonding_store_updelay(struct device *d,
> 		goto out;
> 	}
>
>-	if (sscanf(buf, "%d", &new_value) != 1) {
>+	if (sscanf(buf, "%u", &new_value) != 1) {
> 		pr_err("%s: no up delay value specified.\n",
> 		       bond->dev->name);
> 		ret = -EINVAL;
> 		goto out;
> 	}
>-	if (new_value < 0) {
>-		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
>-		       bond->dev->name, new_value, 1, INT_MAX);
>-		ret = -EINVAL;
>-		goto out;
>-	} else {
>-		if ((new_value % bond->params.miimon) != 0) {
>-			pr_warning("%s: Warning: up delay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
>-				   bond->dev->name, new_value,
>-				   bond->params.miimon,
>-				   (new_value / bond->params.miimon) *
>-				   bond->params.miimon);
>-		}
>-		bond->params.updelay = new_value / bond->params.miimon;
>-		pr_info("%s: Setting up delay to %d.\n",
>-			bond->dev->name,
>-			bond->params.updelay * bond->params.miimon);
>+	if ((new_value % bond->params.miimon) != 0) {
>+		pr_warning("%s: Warning: up delay (%u) is not a multiple of miimon (%u), updelay rounded to %u ms\n",
>+			   bond->dev->name, new_value,
>+			   bond->params.miimon,
>+			   (new_value / bond->params.miimon) *
>+			   bond->params.miimon);
> 	}
>+	bond->params.updelay = new_value / bond->params.miimon;
>+	pr_info("%s: Setting up delay to %u.\n",
>+		bond->dev->name,
>+		bond->params.updelay * bond->params.miimon);
>
> out:
> 	return ret;
>@@ -846,7 +827,7 @@ static ssize_t bonding_show_min_links(struct device *d,
> {
> 	struct bonding *bond = to_bond(d);
>
>-	return sprintf(buf, "%d\n", bond->params.min_links);
>+	return sprintf(buf, "%u\n", bond->params.min_links);
> }
>
> static ssize_t bonding_store_min_links(struct device *d,
>@@ -952,65 +933,59 @@ static ssize_t bonding_show_miimon(struct device *d,
> {
> 	struct bonding *bond = to_bond(d);
>
>-	return sprintf(buf, "%d\n", bond->params.miimon);
>+	return sprintf(buf, "%u\n", bond->params.miimon);
> }
>
> static ssize_t bonding_store_miimon(struct device *d,
> 				    struct device_attribute *attr,
> 				    const char *buf, size_t count)
> {
>-	int new_value, ret = count;
>+	int ret = count;
>+	unsigned int new_value;
> 	struct bonding *bond = to_bond(d);
>
>-	if (sscanf(buf, "%d", &new_value) != 1) {
>+	if (sscanf(buf, "%u", &new_value) != 1) {
> 		pr_err("%s: no miimon value specified.\n",
> 		       bond->dev->name);
> 		ret = -EINVAL;
> 		goto out;
> 	}
>-	if (new_value < 0) {
>-		pr_err("%s: Invalid miimon value %d not in range %d-%d; rejected.\n",
>-		       bond->dev->name, new_value, 1, INT_MAX);
>-		ret = -EINVAL;
>-		goto out;
>-	} else {
>-		pr_info("%s: Setting MII monitoring interval to %d.\n",
>-			bond->dev->name, new_value);
>-		bond->params.miimon = new_value;
>-		if (bond->params.updelay)
>-			pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value.\n",
>-				bond->dev->name,
>-				bond->params.updelay * bond->params.miimon);
>-		if (bond->params.downdelay)
>-			pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value.\n",
>-				bond->dev->name,
>-				bond->params.downdelay * bond->params.miimon);
>-		if (bond->params.arp_interval) {
>-			pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
>-				bond->dev->name);
>-			bond->params.arp_interval = 0;
>-			if (bond->params.arp_validate) {
>-				bond->params.arp_validate =
>-					BOND_ARP_VALIDATE_NONE;
>-			}
>-			if (delayed_work_pending(&bond->arp_work)) {
>-				cancel_delayed_work(&bond->arp_work);
>-				flush_workqueue(bond->wq);
>-			}
>+	pr_info("%s: Setting MII monitoring interval to %u.\n",
>+		bond->dev->name, new_value);
>+	bond->params.miimon = new_value;
>+	if (bond->params.updelay)
>+		pr_info("%s: Note: Updating updelay (to %u) since it is a multiple of the miimon value.\n",
>+			bond->dev->name,
>+			bond->params.updelay * bond->params.miimon);
>+	if (bond->params.downdelay)
>+		pr_info("%s: Note: Updating downdelay (to %u) since it is a multiple of the miimon value.\n",
>+			bond->dev->name,
>+			bond->params.downdelay * bond->params.miimon);
>+	if (bond->params.arp_interval) {
>+		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
>+			bond->dev->name);
>+		bond->params.arp_interval = 0;
>+		if (bond->params.arp_validate) {
>+			bond->params.arp_validate =
>+				BOND_ARP_VALIDATE_NONE;
> 		}
>+		if (delayed_work_pending(&bond->arp_work)) {
>+			cancel_delayed_work(&bond->arp_work);
>+			flush_workqueue(bond->wq);
>+		}
>+	}
>
>-		if (bond->dev->flags & IFF_UP) {
>-			/* If the interface is up, we may need to fire off
>-			 * the MII timer. If the interface is down, the
>-			 * timer will get fired off when the open function
>-			 * is called.
>-			 */
>-			if (!delayed_work_pending(&bond->mii_work)) {
>-				INIT_DELAYED_WORK(&bond->mii_work,
>-						  bond_mii_monitor);
>-				queue_delayed_work(bond->wq,
>-						   &bond->mii_work, 0);
>-			}
>+	if (bond->dev->flags & IFF_UP) {
>+		/* If the interface is up, we may need to fire off
>+		 * the MII timer. If the interface is down, the
>+		 * timer will get fired off when the open function
>+		 * is called.
>+		 */
>+		if (!delayed_work_pending(&bond->mii_work)) {
>+			INIT_DELAYED_WORK(&bond->mii_work,
>+					  bond_mii_monitor);
>+			queue_delayed_work(bond->wq,
>+					   &bond->mii_work, 0);
> 		}
> 	}
> out:
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index f8af2fc..604124c 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -139,14 +139,14 @@ static inline int is_netpoll_tx_blocked(struct net_device *dev)
> struct bond_params {
> 	int mode;
> 	int xmit_policy;
>-	int miimon;
>+	unsigned int miimon;
> 	u8 num_peer_notif;
>-	int arp_interval;
>+	unsigned int arp_interval;
> 	int arp_validate;
> 	int use_carrier;
> 	int fail_over_mac;
>-	int updelay;
>-	int downdelay;
>+	unsigned int updelay;
>+	unsigned int downdelay;
> 	int lacp_fast;
> 	unsigned int min_links;
> 	int ad_select;
>@@ -175,7 +175,7 @@ struct slave {
> 	struct slave *next;
> 	struct slave *prev;
> 	struct bonding *bond; /* our master */
>-	int    delay;
>+	unsigned int    delay;
> 	unsigned long jiffies;
> 	unsigned long last_arp_rx;
> 	s8     link;    /* one of BOND_LINK_XXXX */
>diff --git a/include/uapi/linux/if_bonding.h b/include/uapi/linux/if_bonding.h
>index a17edda..9796b4a 100644
>--- a/include/uapi/linux/if_bonding.h
>+++ b/include/uapi/linux/if_bonding.h
>@@ -95,7 +95,7 @@
> typedef struct ifbond {
> 	__s32 bond_mode;
> 	__s32 num_slaves;
>-	__s32 miimon;
>+	__u32 miimon;
> } ifbond;
>
> typedef struct ifslave {
>-- 
>1.7.11.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
