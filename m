From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix miimon and arp_interval delayed work race conditions
Date: Wed, 28 Nov 2012 11:15:07 -0800
Message-ID: <21151.1354130107@death.nxdomain>
References: <1353759471-30323-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:52365 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932509Ab2K1Wx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 17:53:28 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 28 Nov 2012 17:53:27 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 37AECC9003E
	for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 17:53:25 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qASMrO9c333552
	for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 17:53:25 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qASMtJnl022164
	for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 15:55:19 -0700
In-reply-to: <1353759471-30323-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>First I would give three observations which will be used later.
>Observation 1: if (delayed_work_pending(wq)) cancel_delayed_work(wq)
> This usage is wrong because the pending bit is cleared just before the work's fn is
> executed and if the function re-arms itself we might end up with the work still
> running. It is safe to call cancel_delayed_work_sync() even if the work is not queued
> at all.
>Observation 2: Use of INIT_DELAYED_WORK()
> Work needs to be initialized only once prior to (de/en)queueing.
>Observation 3: IFF_UP is set only after ndo_open is called
>
>Related race conditions:
>1. Race between bonding_store_miimon() and bonding_store_arp_interval()
> Because of Obs.1 we can end up having both works enqueued.
>2. Multiple races with INIT_DELAYED_WORK()
> Since the works are not protected by anything between INIT_DELAYED_WORK() and
> calls to (en/de)queue it is possible for races between the following functions:
> (races are also possible between the calls to INIT_DELAYED_WORK() and workqueue code)
> bonding_store_miimon() - bonding_store_arp_interval(), bond_close(), bond_open(),
>			  enqueued functions
> bonding_store_arp_interval() - bonding_store_miimon(), bond_close(), bond_open(),
>				enqueued functions
>3. By Obs.1 we need to change bond_cancel_all()
>
>Bugs 1 and 2 are fixed by moving all work initializations in bond_open which by
>Obs. 2 and Obs. 3 and the fact that we make sure that all works are cancelled in
>bond_close(), is guaranteed not to have any work enqueued. Also RTNL lock is now
>acquired in bonding_store_miimon/arp_interval so they can't race with bond_close
>and bond_open. The opposing work is cancelled only if the IFF_UP flag is set
>and it is cancelled unconditionally. The opposing work is already cancelled if
>the interface is down so no need to cancel it again. This way we don't need new
>synchronizations for the bonding workqueue. These bug (and fixes) are tied 
>together and belong in the same patch.
>Note: I have left 1 line intentionally over 80 characters (84) because I didn't
>      like how it looks broken down. If you'd prefer it otherwise, then simply
>      break it.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

	The patch looks good, although, once applied, the commit message
as shown by "git log" is hard to read due to the formatting (long
lines).  Can you reflow the text to less than 75 columns to make it more
readable in the log?

	This is true for the other two patches as well (that they look
good, and their text runs long), although the log messages are much
shorter.

	-J

>---
> drivers/net/bonding/bond_main.c  | 88 ++++++++++++----------------------------
> drivers/net/bonding/bond_sysfs.c | 34 +++++-----------
> 2 files changed, 36 insertions(+), 86 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 5f5b69f..1445c7d 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3459,6 +3459,28 @@ static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
>
> /*-------------------------- Device entry points ----------------------------*/
>
>+static void bond_work_init_all(struct bonding *bond)
>+{
>+	INIT_DELAYED_WORK(&bond->mcast_work,
>+			  bond_resend_igmp_join_requests_delayed);
>+	INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
>+	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
>+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
>+		INIT_DELAYED_WORK(&bond->arp_work, bond_activebackup_arp_mon);
>+	else
>+		INIT_DELAYED_WORK(&bond->arp_work, bond_loadbalance_arp_mon);
>+	INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
>+}
>+
>+static void bond_work_cancel_all(struct bonding *bond)
>+{
>+	cancel_delayed_work_sync(&bond->mii_work);
>+	cancel_delayed_work_sync(&bond->arp_work);
>+	cancel_delayed_work_sync(&bond->alb_work);
>+	cancel_delayed_work_sync(&bond->ad_work);
>+	cancel_delayed_work_sync(&bond->mcast_work);
>+}
>+
> static int bond_open(struct net_device *bond_dev)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
>@@ -3481,41 +3503,27 @@ static int bond_open(struct net_device *bond_dev)
> 	}
> 	read_unlock(&bond->lock);
>
>-	INIT_DELAYED_WORK(&bond->mcast_work, bond_resend_igmp_join_requests_delayed);
>+	bond_work_init_all(bond);
>
> 	if (bond_is_lb(bond)) {
> 		/* bond_alb_initialize must be called before the timer
> 		 * is started.
> 		 */
>-		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB))) {
>-			/* something went wrong - fail the open operation */
>+		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB)))
> 			return -ENOMEM;
>-		}
>-
>-		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
> 		queue_delayed_work(bond->wq, &bond->alb_work, 0);
> 	}
>
>-	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
>-		INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
>+	if (bond->params.miimon)  /* link check interval, in milliseconds. */
> 		queue_delayed_work(bond->wq, &bond->mii_work, 0);
>-	}
>
> 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
>-		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
>-			INIT_DELAYED_WORK(&bond->arp_work,
>-					  bond_activebackup_arp_mon);
>-		else
>-			INIT_DELAYED_WORK(&bond->arp_work,
>-					  bond_loadbalance_arp_mon);
>-
> 		queue_delayed_work(bond->wq, &bond->arp_work, 0);
> 		if (bond->params.arp_validate)
> 			bond->recv_probe = bond_arp_rcv;
> 	}
>
> 	if (bond->params.mode == BOND_MODE_8023AD) {
>-		INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
> 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
> 		/* register to receive LACPDUs */
> 		bond->recv_probe = bond_3ad_lacpdu_recv;
>@@ -3530,34 +3538,10 @@ static int bond_close(struct net_device *bond_dev)
> 	struct bonding *bond = netdev_priv(bond_dev);
>
> 	write_lock_bh(&bond->lock);
>-
> 	bond->send_peer_notif = 0;
>-
> 	write_unlock_bh(&bond->lock);
>
>-	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
>-		cancel_delayed_work_sync(&bond->mii_work);
>-	}
>-
>-	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
>-		cancel_delayed_work_sync(&bond->arp_work);
>-	}
>-
>-	switch (bond->params.mode) {
>-	case BOND_MODE_8023AD:
>-		cancel_delayed_work_sync(&bond->ad_work);
>-		break;
>-	case BOND_MODE_TLB:
>-	case BOND_MODE_ALB:
>-		cancel_delayed_work_sync(&bond->alb_work);
>-		break;
>-	default:
>-		break;
>-	}
>-
>-	if (delayed_work_pending(&bond->mcast_work))
>-		cancel_delayed_work_sync(&bond->mcast_work);
>-
>+	bond_work_cancel_all(bond);
> 	if (bond_is_lb(bond)) {
> 		/* Must be called only after all
> 		 * slaves have been released
>@@ -4436,26 +4420,6 @@ static void bond_setup(struct net_device *bond_dev)
> 	bond_dev->features |= bond_dev->hw_features;
> }
>
>-static void bond_work_cancel_all(struct bonding *bond)
>-{
>-	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
>-		cancel_delayed_work_sync(&bond->mii_work);
>-
>-	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
>-		cancel_delayed_work_sync(&bond->arp_work);
>-
>-	if (bond->params.mode == BOND_MODE_ALB &&
>-	    delayed_work_pending(&bond->alb_work))
>-		cancel_delayed_work_sync(&bond->alb_work);
>-
>-	if (bond->params.mode == BOND_MODE_8023AD &&
>-	    delayed_work_pending(&bond->ad_work))
>-		cancel_delayed_work_sync(&bond->ad_work);
>-
>-	if (delayed_work_pending(&bond->mcast_work))
>-		cancel_delayed_work_sync(&bond->mcast_work);
>-}
>-
> /*
> * Destroy a bonding device.
> * Must be under rtnl_lock when this function is called.
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index ef8d2a0..3327a07 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -513,6 +513,8 @@ static ssize_t bonding_store_arp_interval(struct device *d,
> 	int new_value, ret = count;
> 	struct bonding *bond = to_bond(d);
>
>+	if (!rtnl_trylock())
>+		return restart_syscall();
> 	if (sscanf(buf, "%d", &new_value) != 1) {
> 		pr_err("%s: no arp_interval value specified.\n",
> 		       bond->dev->name);
>@@ -539,10 +541,6 @@ static ssize_t bonding_store_arp_interval(struct device *d,
> 		pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
> 			bond->dev->name, bond->dev->name);
> 		bond->params.miimon = 0;
>-		if (delayed_work_pending(&bond->mii_work)) {
>-			cancel_delayed_work(&bond->mii_work);
>-			flush_workqueue(bond->wq);
>-		}
> 	}
> 	if (!bond->params.arp_targets[0]) {
> 		pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
>@@ -554,19 +552,12 @@ static ssize_t bonding_store_arp_interval(struct device *d,
> 		 * timer will get fired off when the open function
> 		 * is called.
> 		 */
>-		if (!delayed_work_pending(&bond->arp_work)) {
>-			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
>-				INIT_DELAYED_WORK(&bond->arp_work,
>-						  bond_activebackup_arp_mon);
>-			else
>-				INIT_DELAYED_WORK(&bond->arp_work,
>-						  bond_loadbalance_arp_mon);
>-
>-			queue_delayed_work(bond->wq, &bond->arp_work, 0);
>-		}
>+		cancel_delayed_work_sync(&bond->mii_work);
>+		queue_delayed_work(bond->wq, &bond->arp_work, 0);
> 	}
>
> out:
>+	rtnl_unlock();
> 	return ret;
> }
> static DEVICE_ATTR(arp_interval, S_IRUGO | S_IWUSR,
>@@ -962,6 +953,8 @@ static ssize_t bonding_store_miimon(struct device *d,
> 	int new_value, ret = count;
> 	struct bonding *bond = to_bond(d);
>
>+	if (!rtnl_trylock())
>+		return restart_syscall();
> 	if (sscanf(buf, "%d", &new_value) != 1) {
> 		pr_err("%s: no miimon value specified.\n",
> 		       bond->dev->name);
>@@ -993,10 +986,6 @@ static ssize_t bonding_store_miimon(struct device *d,
> 				bond->params.arp_validate =
> 					BOND_ARP_VALIDATE_NONE;
> 			}
>-			if (delayed_work_pending(&bond->arp_work)) {
>-				cancel_delayed_work(&bond->arp_work);
>-				flush_workqueue(bond->wq);
>-			}
> 		}
>
> 		if (bond->dev->flags & IFF_UP) {
>@@ -1005,15 +994,12 @@ static ssize_t bonding_store_miimon(struct device *d,
> 			 * timer will get fired off when the open function
> 			 * is called.
> 			 */
>-			if (!delayed_work_pending(&bond->mii_work)) {
>-				INIT_DELAYED_WORK(&bond->mii_work,
>-						  bond_mii_monitor);
>-				queue_delayed_work(bond->wq,
>-						   &bond->mii_work, 0);
>-			}
>+			cancel_delayed_work_sync(&bond->arp_work);
>+			queue_delayed_work(bond->wq, &bond->mii_work, 0);
> 		}
> 	}
> out:
>+	rtnl_unlock();
> 	return ret;
> }
> static DEVICE_ATTR(miimon, S_IRUGO | S_IWUSR,
>-- 
>1.7.11.7
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
