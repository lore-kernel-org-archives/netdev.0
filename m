From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/2] e1000: fix lockdep warning in
	e1000_reset_task
Date: Fri, 22 Nov 2013 12:20:28 +0400
Message-ID: <0555e8c422c9d920758399edfa08f72df9120713.1385107870.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, devel@openvz.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>, Jeff Kirsher
	<jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The patch fixes the following lockdep warning, which is 100%
reproducible on network restart:

======================================================
[ INFO: possible circular locking dependency detected ]
3.12.0+ #47 Tainted: GF
-------------------------------------------------------
kworker/1:1/27 is trying to acquire lock:
 ((&(&adapter->watchdog_task)->work)){+.+...}, at: [<ffffffff8108a5b0>] flush_work+0x0/0x70

but task is already holding lock:
 (&adapter->mutex){+.+...}, at: [<ffffffffa0177c0a>] e1000_reset_task+0x4a/0xa0 [e1000]

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #1 (&adapter->mutex){+.+...}:
       [<ffffffff810bdb5d>] lock_acquire+0x9d/0x120
       [<ffffffff816b8cbc>] mutex_lock_nested+0x4c/0x390
       [<ffffffffa017233d>] e1000_watchdog+0x7d/0x5b0 [e1000]
       [<ffffffff8108b972>] process_one_work+0x1d2/0x510
       [<ffffffff8108ca80>] worker_thread+0x120/0x3a0
       [<ffffffff81092c1e>] kthread+0xee/0x110
       [<ffffffff816c3d7c>] ret_from_fork+0x7c/0xb0

-> #0 ((&(&adapter->watchdog_task)->work)){+.+...}:
       [<ffffffff810bd9c0>] __lock_acquire+0x1710/0x1810
       [<ffffffff810bdb5d>] lock_acquire+0x9d/0x120
       [<ffffffff8108a5eb>] flush_work+0x3b/0x70
       [<ffffffff8108b5d8>] __cancel_work_timer+0x98/0x140
       [<ffffffff8108b693>] cancel_delayed_work_sync+0x13/0x20
       [<ffffffffa0170cec>] e1000_down_and_stop+0x3c/0x60 [e1000]
       [<ffffffffa01775b1>] e1000_down+0x131/0x220 [e1000]
       [<ffffffffa0177c12>] e1000_reset_task+0x52/0xa0 [e1000]
       [<ffffffff8108b972>] process_one_work+0x1d2/0x510
       [<ffffffff8108ca80>] worker_thread+0x120/0x3a0
       [<ffffffff81092c1e>] kthread+0xee/0x110
       [<ffffffff816c3d7c>] ret_from_fork+0x7c/0xb0

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&adapter->mutex);
                               lock((&(&adapter->watchdog_task)->work));
                               lock(&adapter->mutex);
  lock((&(&adapter->watchdog_task)->work));

 *** DEADLOCK ***

3 locks held by kworker/1:1/27:
 #0:  (events){.+.+.+}, at: [<ffffffff8108b906>] process_one_work+0x166/0x510
 #1:  ((&adapter->reset_task)){+.+...}, at: [<ffffffff8108b906>] process_one_work+0x166/0x510
 #2:  (&adapter->mutex){+.+...}, at: [<ffffffffa0177c0a>] e1000_reset_task+0x4a/0xa0 [e1000]

stack backtrace:
CPU: 1 PID: 27 Comm: kworker/1:1 Tainted: GF            3.12.0+ #47
Hardware name: System manufacturer System Product Name/P5B-VM SE, BIOS 0501    05/31/2007
Workqueue: events e1000_reset_task [e1000]
 ffffffff820f6000 ffff88007b9dba98 ffffffff816b54a2 0000000000000002
 ffffffff820f5e50 ffff88007b9dbae8 ffffffff810ba936 ffff88007b9dbac8
 ffff88007b9dbb48 ffff88007b9d8f00 ffff88007b9d8780 ffff88007b9d8f00
Call Trace:
 [<ffffffff816b54a2>] dump_stack+0x49/0x5f
 [<ffffffff810ba936>] print_circular_bug+0x216/0x310
 [<ffffffff810bd9c0>] __lock_acquire+0x1710/0x1810
 [<ffffffff8108a5b0>] ? __flush_work+0x250/0x250
 [<ffffffff810bdb5d>] lock_acquire+0x9d/0x120
 [<ffffffff8108a5b0>] ? __flush_work+0x250/0x250
 [<ffffffff8108a5eb>] flush_work+0x3b/0x70
 [<ffffffff8108a5b0>] ? __flush_work+0x250/0x250
 [<ffffffff8108b5d8>] __cancel_work_timer+0x98/0x140
 [<ffffffff8108b693>] cancel_delayed_work_sync+0x13/0x20
 [<ffffffffa0170cec>] e1000_down_and_stop+0x3c/0x60 [e1000]
 [<ffffffffa01775b1>] e1000_down+0x131/0x220 [e1000]
 [<ffffffffa0177c12>] e1000_reset_task+0x52/0xa0 [e1000]
 [<ffffffff8108b972>] process_one_work+0x1d2/0x510
 [<ffffffff8108b906>] ? process_one_work+0x166/0x510
 [<ffffffff8108ca80>] worker_thread+0x120/0x3a0
 [<ffffffff8108c960>] ? manage_workers+0x2c0/0x2c0
 [<ffffffff81092c1e>] kthread+0xee/0x110
 [<ffffffff81092b30>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff816c3d7c>] ret_from_fork+0x7c/0xb0
 [<ffffffff81092b30>] ? __init_kthread_worker+0x70/0x70

== The issue background ==

The problem occurs, because e1000_down(), which is called under
adapter->mutex by e1000_reset_task(), tries to synchronously cancel
e1000 auxiliary works (reset_task, watchdog_task, phy_info_task,
fifo_stall_task), which take adapter->mutex in their handlers. So the
question is what does adapter->mutex protect there?

The adapter->mutex was introduced by commit 0ef4ee ("e1000: convert to
private mutex from rtnl") as a replacement for rtnl_lock() taken in the
asynchronous handlers. It targeted on fixing a similar lockdep warning
issued when e1000_down() was called under rtnl_lock(), and it fixed it,
but unfortunately it introduced the lockdep warning described above.
Anyway, that said the source of this bug is that the asynchronous works
were made to take rtnl_lock() some time ago, so let's look deeper and
find why it was added there.

The rtnl_lock() was added to asynchronous handlers by commit 338c15
("e1000: fix occasional panic on unload") in order to prevent
asynchronous handlers from execution after the module is unloaded
(e1000_down() is called) as it follows from the comment to the commit:

> Net drivers in general have an issue where timers fired
> by mod_timer or work threads with schedule_work are running
> outside of the rtnl_lock.
>
> With no other lock protection these routines are vulnerable
> to races with driver unload or reset paths.
>
> The longer term solution to this might be a redesign with
> safer locks being taken in the driver to guarantee no
> reentrance, but for now a safe and effective fix is
> to take the rtnl_lock in these routines.

I'm not sure if this locking scheme fixed the problem or just made it
unlikely, although I incline to the latter. Anyway, this was long time
ago when e1000 auxiliary works were implemented as timers scheduling
real work handlers in their routines. The e1000_down() function only
canceled the timers, but left the real handlers running if they were
running, which could result in work execution after module unload.
Today, the e1000 driver uses sane delayed works instead of the pair
timer+work to implement its delayed asynchronous handlers, and the
e1000_down() synchronously cancels all the works so that the problem
that commit 338c15 tried to cope with disappeared, and we don't need any
locks in the handlers any more. Moreover, any locking there can
potentially result in a deadlock.

So, this patch reverts commits 0ef4ee and 338c15.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/e1000/e1000.h      |    2 --
 drivers/net/ethernet/intel/e1000/e1000_main.c |   36 +++----------------------
 2 files changed, 3 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 58c1472..8b0b97d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -312,8 +312,6 @@ struct e1000_adapter {
 	struct delayed_work watchdog_task;
 	struct delayed_work fifo_stall_task;
 	struct delayed_work phy_info_task;
-
-	struct mutex mutex;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index ad6800a..ca0723f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -544,21 +544,8 @@ void e1000_down(struct e1000_adapter *adapter)
 	e1000_clean_all_rx_rings(adapter);
 }
 
-static void e1000_reinit_safe(struct e1000_adapter *adapter)
-{
-	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
-		msleep(1);
-	mutex_lock(&adapter->mutex);
-	e1000_down(adapter);
-	e1000_up(adapter);
-	mutex_unlock(&adapter->mutex);
-	clear_bit(__E1000_RESETTING, &adapter->flags);
-}
-
 void e1000_reinit_locked(struct e1000_adapter *adapter)
 {
-	/* if rtnl_lock is not held the call path is bogus */
-	ASSERT_RTNL();
 	WARN_ON(in_interrupt());
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
 		msleep(1);
@@ -1321,7 +1308,6 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
 	e1000_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
-	mutex_init(&adapter->mutex);
 
 	set_bit(__E1000_DOWN, &adapter->flags);
 
@@ -2330,11 +2316,8 @@ static void e1000_update_phy_info_task(struct work_struct *work)
 	struct e1000_adapter *adapter = container_of(work,
 						     struct e1000_adapter,
 						     phy_info_task.work);
-	if (test_bit(__E1000_DOWN, &adapter->flags))
-		return;
-	mutex_lock(&adapter->mutex);
+
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
-	mutex_unlock(&adapter->mutex);
 }
 
 /**
@@ -2350,9 +2333,6 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 	struct net_device *netdev = adapter->netdev;
 	u32 tctl;
 
-	if (test_bit(__E1000_DOWN, &adapter->flags))
-		return;
-	mutex_lock(&adapter->mutex);
 	if (atomic_read(&adapter->tx_fifo_stall)) {
 		if ((er32(TDT) == er32(TDH)) &&
 		   (er32(TDFT) == er32(TDFH)) &&
@@ -2373,7 +2353,6 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 			schedule_delayed_work(&adapter->fifo_stall_task, 1);
 		}
 	}
-	mutex_unlock(&adapter->mutex);
 }
 
 bool e1000_has_link(struct e1000_adapter *adapter)
@@ -2427,10 +2406,6 @@ static void e1000_watchdog(struct work_struct *work)
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	u32 link, tctl;
 
-	if (test_bit(__E1000_DOWN, &adapter->flags))
-		return;
-
-	mutex_lock(&adapter->mutex);
 	link = e1000_has_link(adapter);
 	if ((netif_carrier_ok(netdev)) && link)
 		goto link_up;
@@ -2521,7 +2496,7 @@ link_up:
 			adapter->tx_timeout_count++;
 			schedule_work(&adapter->reset_task);
 			/* exit immediately since reset is imminent */
-			goto unlock;
+			return;
 		}
 	}
 
@@ -2549,9 +2524,6 @@ link_up:
 	/* Reschedule the task */
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		schedule_delayed_work(&adapter->watchdog_task, 2 * HZ);
-
-unlock:
-	mutex_unlock(&adapter->mutex);
 }
 
 enum latency_range {
@@ -3500,10 +3472,8 @@ static void e1000_reset_task(struct work_struct *work)
 	struct e1000_adapter *adapter =
 		container_of(work, struct e1000_adapter, reset_task);
 
-	if (test_bit(__E1000_DOWN, &adapter->flags))
-		return;
 	e_err(drv, "Reset adapter\n");
-	e1000_reinit_safe(adapter);
+	e1000_reinit_locked(adapter);
 }
 
 /**
-- 
1.7.10.4


------------------------------------------------------------------------------
Shape the Mobile Experience: Free Subscription
Software experts and developers: Be at the forefront of tech innovation.
Intel(R) Software Adrenaline delivers strategic insight and game-changing 
conversations that shape the rapidly evolving mobile landscape. Sign up now. 
http://pubads.g.doubleclick.net/gampad/clk?id=63431311&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
