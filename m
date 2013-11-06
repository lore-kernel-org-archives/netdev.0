From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 2/9] bonding: remove bond read lock for bond_mii_monitor()
Date: Wed, 06 Nov 2013 15:18:26 -0800
Message-ID: <29223.1383779906@death.nxdomain>
References: <5279E738.4040102@huawei.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:59587 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717Ab3KFXSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 18:18:32 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 6 Nov 2013 18:18:32 -0500
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1E701C90043
	for <netdev@vger.kernel.org>; Wed,  6 Nov 2013 18:18:28 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA6NIThO65536148
	for <netdev@vger.kernel.org>; Wed, 6 Nov 2013 23:18:29 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rA6NIS7d025266
	for <netdev@vger.kernel.org>; Wed, 6 Nov 2013 18:18:29 -0500
In-reply-to: <5279E738.4040102@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>The bond_mii_monitor() still use bond lock read to protect
>bond_has_slaves() and bond_miimon_inspect(), it is no effect,
>so I move the RTNL to the top of the function to protect the
>whole monitor, of course, if the bond state did not changed,
>the monitor still calling RTNL, it may bring more performance
>loss, but as a slow path, it is negligible.

	I'm not sure this last part is true (about it being ok to
acquire RTNL every pass).  The reason the bond_miimon_* functions are
arranged in the way they are is specifically to avoid taking RTNL
unnecessarily.  A common setting is miimon=100, which will acquire and
release RTNL ten times per second.

	The inspect function can be make RCU safe, and then the function
will operate pretty much as it does now (with the multiple phases).  If
a slave disappears between the phases, that's ok; one extra cycle on
RTNL isn't a big deal, but 10 per second arguably is.

	My comment also applies to the later patches in the series that
make similar "always acquire RTNL" changes to the ARP monitor, ALB
monitoring function, and the 802.3ad state machine.  That would be
patches:

Subject: [PATCH net-next 3/9] bonding: rebuild the lock use for
 bond_alb_monitor()
Subject: [PATCH net-next 4/9] bonding: rebuild the lock use for
 bond_loadbalance_arp_mon()
Subject: [PATCH net-next 5/9] bonding: rebuild the lock use for
 bond_activebackup_arp_mon()
Subject: [PATCH net-next 6/9] bonding: use RTNL instead of bond lock for
 bond_3ad_state_machine_handler()

	The 802.3ad state machine patch or the balance-alb patch,
combined with the miimon patch, will acquire and release the RTNL lock
20 times per second (10 for the 3ad state machine or alb monitor, and 10
more for a typical miimon configuration).  I don't believe this is a
reasonable implementation.

	-J

>also in bond_miimon_commit(), I remove the unwanted curr_slave_lock
>when calling the bond_select_active_slave(), the RTNL is enough.
>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_main.c | 44 ++++++++++++-----------------------------
> 1 file changed, 13 insertions(+), 31 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 9c9803c..98171eb 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2074,9 +2074,7 @@ static void bond_miimon_commit(struct bonding *bond)
> do_failover:
> 		ASSERT_RTNL();
> 		block_netpoll_tx();
>-		write_lock_bh(&bond->curr_slave_lock);
> 		bond_select_active_slave(bond);
>-		write_unlock_bh(&bond->curr_slave_lock);
> 		unblock_netpoll_tx();
> 	}
>
>@@ -2098,47 +2096,31 @@ void bond_mii_monitor(struct work_struct *work)
> 	bool should_notify_peers = false;
> 	unsigned long delay;
>
>-	read_lock(&bond->lock);
>-
> 	delay = msecs_to_jiffies(bond->params.miimon);
>
>-	if (!bond_has_slaves(bond))
>+	if (!rtnl_trylock()) {
>+		delay = 1;
> 		goto re_arm;
>+	}
>
>-	should_notify_peers = bond_should_notify_peers(bond);
>-
>-	if (bond_miimon_inspect(bond)) {
>-		read_unlock(&bond->lock);
>-
>-		/* Race avoidance with bond_close cancel of workqueue */
>-		if (!rtnl_trylock()) {
>-			read_lock(&bond->lock);
>-			delay = 1;
>-			should_notify_peers = false;
>-			goto re_arm;
>-		}
>+	if (!bond_has_slaves(bond)) {
>+		rtnl_unlock();
>+		goto re_arm;
>+	}
>
>-		read_lock(&bond->lock);
>+	should_notify_peers = bond_should_notify_peers(bond);
>
>+	if (bond_miimon_inspect(bond))
> 		bond_miimon_commit(bond);
>
>-		read_unlock(&bond->lock);
>-		rtnl_unlock();	/* might sleep, hold no other locks */
>-		read_lock(&bond->lock);
>-	}
>+	if (should_notify_peers)
>+		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
>+
>+	rtnl_unlock();
>
> re_arm:
> 	if (bond->params.miimon)
> 		queue_delayed_work(bond->wq, &bond->mii_work, delay);
>-
>-	read_unlock(&bond->lock);
>-
>-	if (should_notify_peers) {
>-		if (!rtnl_trylock())
>-			return;
>-		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
>-		rtnl_unlock();
>-	}
> }
>
> static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
>-- 
>1.8.2.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
