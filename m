From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 2/2] bonding: restructure locking of
 bond_ab_arp_probe()
Date: Mon, 27 Jan 2014 14:36:11 +0100
Message-ID: <20140127133610.GB13371@redhat.com>
References: <1390829613-1842-1-git-send-email-vfalico@redhat.com>
 <1390829613-1842-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753709AbaA0NjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 08:39:19 -0500
Content-Disposition: inline
In-Reply-To: <1390829613-1842-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 27, 2014 at 02:33:33PM +0100, Veaceslav Falico wrote:
>Currently we're calling it from under RCU context, however we're using some
>functions that require rtnl to be held.
>
>Fix this by restructuring the locking - don't call it under any locks,
>aquire rcu_read_lock() if we're sending _only_ (i.e. we have the active
>slave present), and use rtnl locking otherwise - if we need to modify
>(in)active flags of a slave.
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
>
>Notes:
>    v2->v3:
>    Use rtnl_trylock(), not to race with queue cancelling.
>
>    v1->v2:
>    Add two steps - one for sending/rcu, another for modifying/rtnl.
>
> drivers/net/bonding/bond_main.c | 38 ++++++++++++++++++++++++--------------
> 1 file changed, 24 insertions(+), 14 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 27e6fdd..7de0256 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2605,11 +2605,14 @@ do_failover:
> static void bond_ab_arp_probe(struct bonding *bond)
> {
> 	struct slave *slave, *before = NULL, *new_slave = NULL,
>-		     *curr_arp_slave = rcu_dereference(bond->current_arp_slave),
>-		     *curr_active_slave = rcu_dereference(bond->curr_active_slave);
>+		     *curr_arp_slave, *curr_active_slave;
> 	struct list_head *iter;
> 	bool found = false;
>
>+	rcu_read_lock();
>+	curr_arp_slave = rcu_dereference(bond->current_arp_slave);
>+	curr_active_slave = rcu_dereference(bond->curr_active_slave);
>+
> 	if (curr_arp_slave && curr_active_slave)
> 		pr_info("PROBE: c_arp %s && cas %s BAD\n",
> 			curr_arp_slave->dev->name,
>@@ -2617,23 +2620,31 @@ static void bond_ab_arp_probe(struct bonding *bond)
>
> 	if (curr_active_slave) {
> 		bond_arp_send_all(bond, curr_active_slave);
>+		rcu_read_unlock();
> 		return;
> 	}
>+	rcu_read_unlock();
>
> 	/* if we don't have a curr_active_slave, search for the next available
> 	 * backup slave from the current_arp_slave and make it the candidate
> 	 * for becoming the curr_active_slave
> 	 */
>
>+	rtnl_lock();

Right, git commit --amend would be great after git add...

Sorry, forgot to actually commit changes, will re-send.

>+	/* curr_arp_slave might have gone away */
>+	curr_arp_slave = rcu_dereference(bond->current_arp_slave);
>+
> 	if (!curr_arp_slave) {
>-		curr_arp_slave = bond_first_slave_rcu(bond);
>-		if (!curr_arp_slave)
>+		curr_arp_slave = bond_first_slave(bond);
>+		if (!curr_arp_slave) {
>+			rtnl_unlock();
> 			return;
>+		}
> 	}
>
> 	bond_set_slave_inactive_flags(curr_arp_slave);
>
>-	bond_for_each_slave_rcu(bond, slave, iter) {
>+	bond_for_each_slave(bond, slave, iter) {
> 		if (!found && !before && IS_UP(slave->dev))
> 			before = slave;
>
>@@ -2663,21 +2674,24 @@ static void bond_ab_arp_probe(struct bonding *bond)
> 	if (!new_slave && before)
> 		new_slave = before;
>
>-	if (!new_slave)
>+	if (!new_slave) {
>+		rtnl_unlock();
> 		return;
>+	}
>
> 	new_slave->link = BOND_LINK_BACK;
> 	bond_set_slave_active_flags(new_slave);
> 	bond_arp_send_all(bond, new_slave);
> 	new_slave->jiffies = jiffies;
> 	rcu_assign_pointer(bond->current_arp_slave, new_slave);
>+	rtnl_unlock();
> }
>
> static void bond_activebackup_arp_mon(struct work_struct *work)
> {
> 	struct bonding *bond = container_of(work, struct bonding,
> 					    arp_work.work);
>-	bool should_notify_peers = false;
>+	bool should_notify_peers = false, should_commit = false;
> 	int delta_in_ticks;
>
> 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>@@ -2686,12 +2700,11 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
> 		goto re_arm;
>
> 	rcu_read_lock();
>-
> 	should_notify_peers = bond_should_notify_peers(bond);
>+	should_commit = bond_ab_arp_inspect(bond);
>+	rcu_read_unlock();
>
>-	if (bond_ab_arp_inspect(bond)) {
>-		rcu_read_unlock();
>-
>+	if (should_commit) {
> 		/* Race avoidance with bond_close flush of workqueue */
> 		if (!rtnl_trylock()) {
> 			delta_in_ticks = 1;
>@@ -2700,13 +2713,10 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
> 		}
>
> 		bond_ab_arp_commit(bond);
>-
> 		rtnl_unlock();
>-		rcu_read_lock();
> 	}
>
> 	bond_ab_arp_probe(bond);
>-	rcu_read_unlock();
>
> re_arm:
> 	if (bond->params.arp_interval)
>-- 
>1.8.4
>
