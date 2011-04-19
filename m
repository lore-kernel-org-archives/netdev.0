From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 3/3] bonding,ipv4,ipv6,vlan: Handle NETDEV_BONDING_FAILOVER like NETDEV_NOTIFY_PEERS
Date: Tue, 19 Apr 2011 12:12:01 -0700
Message-ID: <26398.1303240321@death>
References: <1302911271.2845.41.camel@bwh-desktop> <22334.1302913805@death> <1303153792.2857.32.camel@bwh-desktop>
Cc: David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Brian Haley <brian.haley@hp.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44674 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795Ab1DSTMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 15:12:09 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3JIqoxc019152
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 14:52:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3JJC7wA2666516
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 15:12:07 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3JJC5JX009053
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 16:12:07 -0300
In-reply-to: <1303153792.2857.32.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:

>On Fri, 2011-04-15 at 17:30 -0700, Jay Vosburgh wrote:
>> Ben Hutchings <bhutchings@solarflare.com> wrote:
>> 
>> >It is undesirable for the bonding driver to be poking into higher
>> >level protocols, and notifiers provide a way to avoid that.  This does
>> >mean removing the ability to configure reptitition of gratuitous ARPs
>> >and unsolicited NAs.
>> 
>> 	In principle I think this is a good thing (getting rid of some
>> of those dependencies, duplicated code, etc).
>> 
>> 	However, the removal of the multiple grat ARP and NAs may be an
>> issue for some users.  I don't know that we can just remove this (along
>> with its API) without going through the feature removal process.
>
>Right.
>
>> 	As I recall, the multiple gratuitous ARP stuff was added for
>> Infiniband, because it is dependent on the grat ARP for a smooth
>> failover.
>> 
>> 	There is also currently logic to check the linkwatch link state
>> to wait for the link to go up prior to sending a grat ARP; this is also
>> for IB.
>
>Why would we activate a slave without link up?  Perhaps if the previous
>active slave is removed?

	It's special sauce for Infiniband; I don't recall the details
except that the submitter said that without it the initial gratuitous
ARP could be lost.  I didn't (and still don't) have IB hardware to test
this on.

	Ideally, I'd like to test the current situation (no checking of
linkwatch) for IB and see if the linkwatch trick is still necessary.  It
may have been due to some behavior of the device driver that is now
different.  For now, though, keeping it (as you've done) just in case
seems prudent.

>> 	Brian Haley added the unsolicited NAs; I've added him to the cc
>> so perhaps he (or somebody else) can comment on the necessity of keeping
>> the ability to send multiple NAs.
>[...]
>
>How about restoring the parameters like this:

	I think the patch below is better than Brian's suggestion (new
single parameter) because it won't break existing configurations, even
though it is doing magic under the covers.  If the magic is a real
concern, we could add logic to detect when both parameters are used and
set to different values, but I'm not really that worked up about it as
long as the magic is clearly documented.

>---
>From: Ben Hutchings <bhutchings@solarflare.com>
>Date: Mon, 18 Apr 2011 19:36:48 +0100
>Subject: [PATCH net-next-2.6] ipv4,ipv6,bonding: Restore control over number of peer notifications
>
>For backward compatibility, we should retain the module parameters and
>sysfs attributes to control the number of peer notifications
>(gratuitous ARPs and unsolicited NAs) sent after bonding failover.
>Also, it is possible for failover to take place even though the new
>active slave does not have link up, and in that case the peer
>notification should be deferred until it does.
>
>Change ipv4 and ipv6 so they do not automatically send peer
>notifications on bonding failover.  Change the bonding driver to send
>separate NETDEV_NOTIFY_PEERS notifications when the link is up, as
>many times as requested.  Since it does not directly control which
>protocols send notifications, make num_grat_arp and num_unsol_na
>aliases for a single parameter.
>
>Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>---
> Documentation/networking/bonding.txt |   31 ++++++++----------
> drivers/net/bonding/bond_main.c      |   59 ++++++++++++++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c     |   26 +++++++++++++++
> drivers/net/bonding/bonding.h        |    2 +
> net/ipv4/devinet.c                   |    1 -
> net/ipv6/ndisc.c                     |    1 -
> 6 files changed, 101 insertions(+), 19 deletions(-)
>
>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>index e27202b..511b4e5 100644
>--- a/Documentation/networking/bonding.txt
>+++ b/Documentation/networking/bonding.txt
>@@ -1,7 +1,7 @@
>
> 		Linux Ethernet Bonding Driver HOWTO
>
>-		Latest update: 23 September 2009
>+		Latest update: 18 April 2011
>
> Initial release : Thomas Davis <tadavis at lbl.gov>
> Corrections, HA extensions : 2000/10/03-15 :
>@@ -585,25 +585,22 @@ mode
> 		chosen.
>
> num_grat_arp
>-
>-	Specifies the number of gratuitous ARPs to be issued after a
>-	failover event.  One gratuitous ARP is issued immediately after
>-	the failover, subsequent ARPs are sent at a rate of one per link
>-	monitor interval (arp_interval or miimon, whichever is active).
>-
>-	The valid range is 0 - 255; the default value is 1.  This option
>-	affects only the active-backup mode.  This option was added for
>-	bonding version 3.3.0.
>-
> num_unsol_na
>
>-	Specifies the number of unsolicited IPv6 Neighbor Advertisements
>-	to be issued after a failover event.  One unsolicited NA is issued
>-	immediately after the failover.
>+	Specify the number of peer notifications (gratuitous ARPs and
>+	unsolicited IPv6 Neighbor Advertisements) to be issued after a
>+	failover event.  As soon as the link is up on the new slave
>+	(possibly immediately) a peer notification is sent on the
>+	bonding device and each VLAN sub-device.  This is repeated at
>+	each link monitor interval (arp_interval or miimon, whichever
>+	is active) if the number is greater than 1.
>+
>+	These notifications are now generated by the ipv4 and ipv6 code
>+	and the numbers of repetitions cannot be set independently.

	I think it would be good for the long run to be specific about
"now," i.e., bump the bonding version and specify that here.

>-	The valid range is 0 - 255; the default value is 1.  This option
>-	affects only the active-backup mode.  This option was added for
>-	bonding version 3.4.0.
>+	The valid range is 0 - 255; the default value is 1.  These options
>+	affect only the active-backup mode.  These options were added for
>+	bonding versions 3.3.0 and 3.4.0 respectively.
>
> primary
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 5cd4766..c9043db 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -89,6 +89,7 @@
>
> static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
> static int tx_queues	= BOND_DEFAULT_TX_QUEUES;
>+static int num_peer_notif = 1;
> static int miimon	= BOND_LINK_MON_INTERV;
> static int updelay;
> static int downdelay;
>@@ -111,6 +112,10 @@ module_param(max_bonds, int, 0);
> MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
> module_param(tx_queues, int, 0);
> MODULE_PARM_DESC(tx_queues, "Max number of transmit queues (default = 16)");
>+module_param_named(num_grat_arp, num_peer_notif, int, 0644);
>+MODULE_PARM_DESC(num_grat_arp, "Number of peer notifications to send on failover event");
>+module_param_named(num_unsol_na, num_peer_notif, int, 0644);
>+MODULE_PARM_DESC(num_unsol_na, "Number of peer notifications to send on failover event");

	Perhaps add "alias of num_grat_arp" here so it shows up in modinfo?

	In any event, with the version number thing I mentioned above, I
think this is a reasonable way to proceed.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


> module_param(miimon, int, 0);
> MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
> module_param(updelay, int, 0);
>@@ -1080,6 +1085,21 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
> 	return bestslave;
> }
>
>+static bool bond_should_notify_peers(struct bonding *bond)
>+{
>+	struct slave *slave = bond->curr_active_slave;
>+
>+	pr_debug("bond_should_notify_peers: bond %s slave %s\n",
>+		 bond->dev->name, slave ? slave->dev->name : "NULL");
>+
>+	if (!slave || !bond->send_peer_notif ||
>+	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
>+		return false;
>+
>+	bond->send_peer_notif--;
>+	return true;
>+}
>+
> /**
>  * change_active_interface - change the active slave into the specified one
>  * @bond: our bonding struct
>@@ -1147,16 +1167,28 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
> 			bond_set_slave_inactive_flags(old_active);
>
> 		if (new_active) {
>+			bool should_notify_peers = false;
>+
> 			bond_set_slave_active_flags(new_active);
>
> 			if (bond->params.fail_over_mac)
> 				bond_do_fail_over_mac(bond, new_active,
> 						      old_active);
>
>+			if (netif_running(bond->dev)) {
>+				bond->send_peer_notif =
>+					bond->params.num_peer_notif;
>+				should_notify_peers =
>+					bond_should_notify_peers(bond);
>+			}
>+
> 			write_unlock_bh(&bond->curr_slave_lock);
> 			read_unlock(&bond->lock);
>
> 			netdev_bonding_change(bond->dev, NETDEV_BONDING_FAILOVER);
>+			if (should_notify_peers)
>+				netdev_bonding_change(bond->dev,
>+						      NETDEV_NOTIFY_PEERS);
>
> 			read_lock(&bond->lock);
> 			write_lock_bh(&bond->curr_slave_lock);
>@@ -2555,6 +2587,7 @@ void bond_mii_monitor(struct work_struct *work)
> {
> 	struct bonding *bond = container_of(work, struct bonding,
> 					    mii_work.work);
>+	bool should_notify_peers = false;
>
> 	read_lock(&bond->lock);
> 	if (bond->kill_timers)
>@@ -2563,6 +2596,8 @@ void bond_mii_monitor(struct work_struct *work)
> 	if (bond->slave_cnt == 0)
> 		goto re_arm;
>
>+	should_notify_peers = bond_should_notify_peers(bond);
>+
> 	if (bond_miimon_inspect(bond)) {
> 		read_unlock(&bond->lock);
> 		rtnl_lock();
>@@ -2581,6 +2616,12 @@ re_arm:
> 				   msecs_to_jiffies(bond->params.miimon));
> out:
> 	read_unlock(&bond->lock);
>+
>+	if (should_notify_peers) {
>+		rtnl_lock();
>+		netdev_bonding_change(bond->dev, NETDEV_NOTIFY_PEERS);
>+		rtnl_unlock();
>+	}
> }
>
> static __be32 bond_glean_dev_ip(struct net_device *dev)
>@@ -3178,6 +3219,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
> {
> 	struct bonding *bond = container_of(work, struct bonding,
> 					    arp_work.work);
>+	bool should_notify_peers = false;
> 	int delta_in_ticks;
>
> 	read_lock(&bond->lock);
>@@ -3190,6 +3232,8 @@ void bond_activebackup_arp_mon(struct work_struct *work)
> 	if (bond->slave_cnt == 0)
> 		goto re_arm;
>
>+	should_notify_peers = bond_should_notify_peers(bond);
>+
> 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
> 		read_unlock(&bond->lock);
> 		rtnl_lock();
>@@ -3209,6 +3253,12 @@ re_arm:
> 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
> out:
> 	read_unlock(&bond->lock);
>+
>+	if (should_notify_peers) {
>+		rtnl_lock();
>+		netdev_bonding_change(bond->dev, NETDEV_NOTIFY_PEERS);
>+		rtnl_unlock();
>+	}
> }
>
> /*-------------------------- netdev event handling --------------------------*/
>@@ -3568,6 +3618,8 @@ static int bond_close(struct net_device *bond_dev)
>
> 	write_lock_bh(&bond->lock);
>
>+	bond->send_peer_notif = 0;
>+
> 	/* signal timers not to re-arm */
> 	bond->kill_timers = 1;
>
>@@ -4644,6 +4696,12 @@ static int bond_check_params(struct bond_params *params)
> 		use_carrier = 1;
> 	}
>
>+	if (num_peer_notif < 0 || num_peer_notif > 255) {
>+		pr_warning("Warning: num_grat_arp/num_unsol_na (%d) not in range 0-255 so it was reset to 1\n",
>+			   num_peer_notif);
>+		num_peer_notif = 1;
>+	}
>+
> 	/* reset values for 802.3ad */
> 	if (bond_mode == BOND_MODE_8023AD) {
> 		if (!miimon) {
>@@ -4833,6 +4891,7 @@ static int bond_check_params(struct bond_params *params)
> 	params->mode = bond_mode;
> 	params->xmit_policy = xmit_hashtype;
> 	params->miimon = miimon;
>+	params->num_peer_notif = num_peer_notif;
> 	params->arp_interval = arp_interval;
> 	params->arp_validate = arp_validate_value;
> 	params->updelay = updelay;
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 259ff32..58fb3e9 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -874,6 +874,30 @@ static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR,
> 		   bonding_show_ad_select, bonding_store_ad_select);
>
> /*
>+ * Show and set the number of peer notifications to send after a failover event.
>+ */
>+static ssize_t bonding_show_num_peer_notif(struct device *d,
>+					   struct device_attribute *attr,
>+					   char *buf)
>+{
>+	struct bonding *bond = to_bond(d);
>+	return sprintf(buf, "%d\n", bond->params.num_peer_notif);
>+}
>+
>+static ssize_t bonding_store_num_peer_notif(struct device *d,
>+					    struct device_attribute *attr,
>+					    const char *buf, size_t count)
>+{
>+	struct bonding *bond = to_bond(d);
>+	int err = kstrtou8(buf, 10, &bond->params.num_peer_notif);
>+	return err ? err : count;
>+}
>+static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR,
>+		   bonding_show_num_peer_notif, bonding_store_num_peer_notif);
>+static DEVICE_ATTR(num_unsol_na, S_IRUGO | S_IWUSR,
>+		   bonding_show_num_peer_notif, bonding_store_num_peer_notif);
>+
>+/*
>  * Show and set the MII monitor interval.  There are two tricky bits
>  * here.  First, if MII monitoring is activated, then we must disable
>  * ARP monitoring.  Second, if the timer isn't running, we must
>@@ -1572,6 +1596,8 @@ static struct attribute *per_bond_attrs[] = {
> 	&dev_attr_lacp_rate.attr,
> 	&dev_attr_ad_select.attr,
> 	&dev_attr_xmit_hash_policy.attr,
>+	&dev_attr_num_grat_arp.attr,
>+	&dev_attr_num_unsol_na.attr,
> 	&dev_attr_miimon.attr,
> 	&dev_attr_primary.attr,
> 	&dev_attr_primary_reselect.attr,
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 77180b1..5bf3b89 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -149,6 +149,7 @@ struct bond_params {
> 	int mode;
> 	int xmit_policy;
> 	int miimon;
>+	u8 num_peer_notif;
> 	int arp_interval;
> 	int arp_validate;
> 	int use_carrier;
>@@ -229,6 +230,7 @@ struct bonding {
> 	rwlock_t lock;
> 	rwlock_t curr_slave_lock;
> 	s8       kill_timers;
>+	u8	 send_peer_notif;
> 	s8	 setup_by_slave;
> 	s8       igmp_retrans;
> #ifdef CONFIG_PROC_FS
>diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>index acf553f..5345b0b 100644
>--- a/net/ipv4/devinet.c
>+++ b/net/ipv4/devinet.c
>@@ -1203,7 +1203,6 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
> 			break;
> 		/* fall through */
> 	case NETDEV_NOTIFY_PEERS:
>-	case NETDEV_BONDING_FAILOVER:
> 		/* Send gratuitous ARP to notify of link change */
> 		inetdev_send_gratuitous_arp(dev, in_dev);
> 		break;
>diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>index 6f7d491..a51fa74c 100644
>--- a/net/ipv6/ndisc.c
>+++ b/net/ipv6/ndisc.c
>@@ -1746,7 +1746,6 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
> 		fib6_run_gc(~0UL, net);
> 		break;
> 	case NETDEV_NOTIFY_PEERS:
>-	case NETDEV_BONDING_FAILOVER:
> 		ndisc_send_unsol_na(dev);
> 		break;
> 	default:
>-- 
>1.7.4
>
>
>-- 
>Ben Hutchings, Senior Software Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
