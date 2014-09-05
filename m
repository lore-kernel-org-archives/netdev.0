From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [RFC net-next 1/5] bonding: 3ad: use curr_slave_lock instead of bond->lock
Date: Fri, 05 Sep 2014 13:37:48 -0700
Message-ID: <23382.1409949468@localhost.localdomain>
References: <1409941011-5494-1-git-send-email-nikolay@redhat.com> <1409941011-5494-2-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, vfalico@gmail.com, andy@greyhouse.net,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45269 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaIEUh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 16:37:57 -0400
In-reply-to: <1409941011-5494-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>In 3ad mode the only syncing needed by bond->lock is for the wq
>and the recv handler, so change them to use curr_slave_lock.
>There're no locking dependencies here as 3ad doesn't use
>curr_slave_lock at all.

	One subtle aspect of the 3ad locking is that it's not really
using the "read" property of the read lock with regard to the state
machine; it's largely using it as a spin lock, because there is at most
one reader and at most one writer in the full state machine code
(although there are multiple reader possibilities elsewhere).  The code
would break if there actually were multiple read-lock holders in the
full state machine or aggregator selection logic simultaneously.

	Because the state machine and incoming LACPDU cases both acquire
the read lock for read, there is a separate per-port "state machine"
spin lock to protect only the per-port fields that LACPDU and periodic
state machine both touch.  The incoming LACPDU case doesn't call into
the full state machine, only the RX processing which can't go into agg
selection, so this works.

	The agg selection can be entered via the unbind path or the
periodic state machine (and only these two paths), and relies on the
"one reader max" usage of the read lock to mutex the code paths that may
enter agg selection.

	I suspect that what 3ad may need is a spin lock, not a read
lock, because the multiple reader property isn't really being utilized;
the incoming LACPDU and periodic state machine both acquire the read
lock for read, but then acquire a second per-port spin lock.  If the
"big" (bond->lock currently) lock is a spin lock, then the per-port
state machine lock is unnecessary, as the only purpose of the per-port
lock is to mutex the one case that does have multiple readers.

	In actual practice I doubt there are multiple simultaneous
readers very often; the periodic machine runs every 100 ms, but LACPDUs
arrive for each port either every second or every 30 seconds (depending
on admin configuration).

	Since contention on these locks is generally low, we're probably
better off in the long run with something simpler to understand.

	So, what I'm kind of saying here is that this patch isn't a bad
first step, but at least for the 3ad case, removal of the bond->lock
itself doesn't really simplify the locking as much as could be done.

	Thoughts?

	-J


>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_3ad.c  |  9 ++++-----
> drivers/net/bonding/bond_main.c | 12 +++++++-----
> 2 files changed, 11 insertions(+), 10 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index ee2c73a9de39..5d27a6207384 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -2057,7 +2057,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 	struct port *port;
> 	bool should_notify_rtnl = BOND_SLAVE_NOTIFY_LATER;
> 
>-	read_lock(&bond->lock);
>+	read_lock(&bond->curr_slave_lock);
> 	rcu_read_lock();
> 
> 	/* check if there are any slaves */
>@@ -2120,7 +2120,7 @@ re_arm:
> 		}
> 	}
> 	rcu_read_unlock();
>-	read_unlock(&bond->lock);
>+	read_unlock(&bond->curr_slave_lock);
> 
> 	if (should_notify_rtnl && rtnl_trylock()) {
> 		bond_slave_state_notify(bond);
>@@ -2395,7 +2395,6 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
> 	return 0;
> }
> 
>-/* Wrapper used to hold bond->lock so no slave manipulation can occur */
> int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
> {
> 	int ret;
>@@ -2487,9 +2486,9 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
> 	if (!lacpdu)
> 		return ret;
> 
>-	read_lock(&bond->lock);
>+	read_lock(&bond->curr_slave_lock);
> 	ret = bond_3ad_rx_indication(lacpdu, slave, skb->len);
>-	read_unlock(&bond->lock);
>+	read_unlock(&bond->curr_slave_lock);
> 	return ret;
> }
> 
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index f0f5eab0fab1..dcd331bd0c17 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1687,13 +1687,15 @@ static int __bond_release_one(struct net_device *bond_dev,
> 	 * for this slave anymore.
> 	 */
> 	netdev_rx_handler_unregister(slave_dev);
>-	write_lock_bh(&bond->lock);
> 
>-	/* Inform AD package of unbinding of slave. */
>-	if (BOND_MODE(bond) == BOND_MODE_8023AD)
>+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>+		/* Sync against bond_3ad_rx_indication and
>+		 * bond_3ad_state_machine_handler
>+		 */
>+		write_lock_bh(&bond->curr_slave_lock);
> 		bond_3ad_unbind_slave(slave);
>-
>-	write_unlock_bh(&bond->lock);
>+		write_unlock_bh(&bond->curr_slave_lock);
>+	}
> 
> 	netdev_info(bond_dev, "Releasing %s interface %s\n",
> 		    bond_is_active_slave(slave) ? "active" : "backup",
>-- 
>1.9.3
>

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
