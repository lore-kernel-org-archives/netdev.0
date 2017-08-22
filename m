From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 1/2] net: phy: Freeze PHY polling before suspending devices
Date: Tue, 22 Aug 2017 20:37:25 +0200
Message-ID: <1503427046-17618-2-git-send-email-geert+renesas@glider.be>
References: <1503427046-17618-1-git-send-email-geert+renesas@glider.be>
Cc: Lukas Wunner <lukas@wunner.de>,
        "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
        netdev@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503427046-17618-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During system resume, the PHY state machine may be run from the
workqueue while the Ethernet device (and its PHY) are still suspended,
which may lead to a system crash.

E.g. on sh73a0/kzm9g and r8a73a4/ape6evm, the external Ethernet chip is
driven by a PM controlled clock.  If the Ethernet registers are accessed
while the clock is not running, the system will crash with an imprecise
external abort.

As this is a race condition with a small time window, it is not so easy
to trigger at will.  Using pm_test may increase your chances:

    # echo 0 > /sys/module/printk/parameters/console_suspend
    # echo platform > /sys/power/pm_test
    # echo mem > /sys/power/state

However, since commit 7ad813f208533ceb ("net: phy: Correctly process
PHY_HALTED in phy_stop_machine()"), this is much more likely to happen,
presumably due to the new sync point where phy_state_machine() calls
queue_delayed_work() just before entering system suspend.

To fix this, move PHY polling from the non-freezable to the freezable
power efficient work queue.  This is similar to what was done in commit
ea00353f36b64375 ("PCI: Freeze PME scan before suspending devices").

Stacktrace for posterity:

    PM: Syncing filesystems ... done.
    Freezing user space processes ... (elapsed 0.001 seconds) done.
    OOM killer disabled.
    Freezing remaining freezable tasks ... (elapsed 0.000 seconds) done.
    PM: suspend devices took 0.010 seconds
    Disabling non-boot CPUs ...
    Enabling non-boot CPUs ...
    Unhandled fault: imprecise external abort (0x1406) at 0x000cf6c8
    pgd = c0004000
    [000cf6c8] *pgd=00000000
    Internal error: : 1406 [#1] SMP ARM
    Modules linked in:
    CPU: 0 PID: 57 Comm: kworker/0:2 Not tainted 4.13.0-rc5-kzm9g-04113-g3a897d275111fd6c #903
    Hardware name: Generic SH73A0 (Flattened Device Tree)
    Workqueue: events_power_efficient phy_state_machine
    task: df6b4800 task.stack: df796000
    PC is at __smsc911x_reg_read+0x1c/0x60
    LR is at smsc911x_mac_read+0x4c/0x118
    pc : [<c03c7e88>]    lr : [<c03c8b88>]    psr: 200d0093
    sp : df797e98  ip : 00000000  fp : 00000001
    r10: 00000000  r9 : df70e380  r8 : 800d0093
    r7 : df631de8  r6 : 00000006  r5 : df631e08  r4 : df631dc0
    r3 : e0903000  r2 : 00000000  r1 : e09030a4  r0 : 00000000
    Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
    Control: 10c5387d  Table: 5ee1404a  DAC: 00000051
    Process kworker/0:2 (pid: 57, stack limit = 0xdf796210)
    Stack: (0xdf797e98 to 0xdf798000)
    7e80:                                                       df631dc0 00000001
    7ea0: 00000001 df631de8 600d0013 c03c8df4 df70e400 00000001 00000001 df70e458
    7ec0: df70e000 c03c7104 c03c6170 df70e000 df70e000 dfbc7bc0 df797f30 c03c6138
    7ee0: df77d900 c03c617c df77d900 df70e32c dfbc7bc0 c03c4218 df77d900 df70e32c
    7f00: dfbc7bc0 df797f30 dfbcb200 00000000 00000000 c013aa0c 00000001 00000000
    7f20: c013a994 00000000 00000000 00000000 c1117f70 00000000 00000000 c07420ec
    7f40: c0904900 df77d900 dfbc7bc0 dfbc7bc0 df796000 dfbc7bf4 c0904900 df77d918
    7f60: 00000008 c013b1e0 df6b4800 df75b500 df77e5c0 00000000 df44dea8 df77d900
    7f80: c013af28 df75b538 00000000 c0140584 df77e5c0 c0140460 00000000 00000000
    7fa0: 00000000 00000000 00000000 c0106ef0 00000000 00000000 00000000 00000000
    7fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    7fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
    [<c03c7e88>] (__smsc911x_reg_read) from [<c03c8b88>] (smsc911x_mac_read+0x4c/0x118)
    [<c03c8b88>] (smsc911x_mac_read) from [<c03c8df4>] (smsc911x_mii_read+0x2c/0xa4)
    [<c03c8df4>] (smsc911x_mii_read) from [<c03c7104>] (mdiobus_read+0x58/0x70)
    [<c03c7104>] (mdiobus_read) from [<c03c6138>] (genphy_update_link+0x18/0x50)
    [<c03c6138>] (genphy_update_link) from [<c03c617c>] (genphy_read_status+0xc/0x1cc)
    [<c03c617c>] (genphy_read_status) from [<c03c4218>] (phy_state_machine+0xa8/0x3dc)
    [<c03c4218>] (phy_state_machine) from [<c013aa0c>] (process_one_work+0x240/0x3fc)
    [<c013aa0c>] (process_one_work) from [<c013b1e0>] (worker_thread+0x2b8/0x3f4)
    [<c013b1e0>] (worker_thread) from [<c0140584>] (kthread+0x124/0x144)
    [<c0140584>] (kthread) from [<c0106ef0>] (ret_from_fork+0x14/0x24)
    Code: e5903000 e0831001 e5910000 f57ff04f (e12fff1e)

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/phy/phy.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index dae13f028c84ee17..2055165ca6349ee5 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -554,7 +554,8 @@ EXPORT_SYMBOL(phy_start_aneg);
  */
 void phy_start_machine(struct phy_device *phydev)
 {
-	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, HZ);
+	queue_delayed_work(system_freezable_power_efficient_wq,
+			   &phydev->state_queue, HZ);
 }
 EXPORT_SYMBOL_GPL(phy_start_machine);
 
@@ -574,7 +575,8 @@ void phy_trigger_machine(struct phy_device *phydev, bool sync)
 		cancel_delayed_work_sync(&phydev->state_queue);
 	else
 		cancel_delayed_work(&phydev->state_queue);
-	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
+	queue_delayed_work(system_freezable_power_efficient_wq,
+			   &phydev->state_queue, 0);
 }
 
 /**
@@ -1081,8 +1083,8 @@ void phy_state_machine(struct work_struct *work)
 	 * between states from phy_mac_interrupt()
 	 */
 	if (phydev->irq == PHY_POLL)
-		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
-				   PHY_STATE_TIME * HZ);
+		queue_delayed_work(system_freezable_power_efficient_wq,
+				   &phydev->state_queue, PHY_STATE_TIME * HZ);
 }
 
 /**
@@ -1099,7 +1101,7 @@ void phy_mac_interrupt(struct phy_device *phydev, int new_link)
 	phydev->link = new_link;
 
 	/* Trigger a state machine change */
-	queue_work(system_power_efficient_wq, &phydev->phy_queue);
+	queue_work(system_freezable_power_efficient_wq, &phydev->phy_queue);
 }
 EXPORT_SYMBOL(phy_mac_interrupt);
 
-- 
2.7.4
