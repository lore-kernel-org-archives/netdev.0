From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH V3 4/7] PHYLIB: queue work on any cpu
Date: Mon, 18 Mar 2013 20:53:26 +0530
Message-ID: <9a366f17b93a5e18777360481c94e6db763b45b7.1363617402.git.viresh.kumar@linaro.org>
References: <cover.1363617402.git.viresh.kumar@linaro.org>
Cc: linaro-kernel@lists.linaro.org, robin.randhawa@arm.com,
	Steve.Bannister@arm.com, Liviu.Dudau@arm.com,
	charles.garcia-tobin@arm.com, Arvind.Chauhan@arm.com,
	linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	Viresh Kumar <viresh.kumar@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: pjt@google.com, paul.mckenney@linaro.org, tglx@linutronix.de,
	tj@kernel.org, suresh.b.siddha@intel.com, venki@google.com,
	mingo@redhat.com, peterz@infradead.org, rostedt@goodmis.org
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <cover.1363617402.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1363617402.git.viresh.kumar@linaro.org>
References: <cover.1363617402.git.viresh.kumar@linaro.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phylib uses workqueues for multiple purposes. There is no real dependency of
scheduling these on the cpu which scheduled them.

On a idle system, it is observed that and idle cpu wakes up many times just to
service this work. It would be better if we can schedule it on a cpu which isn't
idle to save on power.

By idle cpu (from scheduler's perspective) we mean:
- Current task is idle task
- nr_running == 0
- wake_list is empty

This patch replaces the schedule_work() and schedule_delayed_work() routines
with their queue_[delayed_]work_on_any_cpu() siblings with system_wq as
parameter.

These routines would look for the closest (via scheduling domains) non-idle cpu
(non-idle from schedulers perspective). If the current cpu is not idle or all
cpus are idle, work will be scheduled on local cpu.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 drivers/net/phy/phy.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 298b4c2..a517706 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -439,7 +439,7 @@ void phy_start_machine(struct phy_device *phydev,
 {
 	phydev->adjust_state = handler;
 
-	schedule_delayed_work(&phydev->state_queue, HZ);
+	queue_delayed_work_on_any_cpu(system_wq, &phydev->state_queue, HZ);
 }
 
 /**
@@ -527,7 +527,7 @@ static irqreturn_t phy_interrupt(int irq, void *phy_dat)
 	disable_irq_nosync(irq);
 	atomic_inc(&phydev->irq_disable);
 
-	schedule_work(&phydev->phy_queue);
+	queue_work_on_any_cpu(system_wq, &phydev->phy_queue);
 
 	return IRQ_HANDLED;
 }
@@ -682,7 +682,7 @@ static void phy_change(struct work_struct *work)
 
 	/* reschedule state queue work to run as soon as possible */
 	cancel_delayed_work_sync(&phydev->state_queue);
-	schedule_delayed_work(&phydev->state_queue, 0);
+	queue_delayed_work_on_any_cpu(system_wq, &phydev->state_queue, 0);
 
 	return;
 
@@ -966,7 +966,8 @@ void phy_state_machine(struct work_struct *work)
 	if (err < 0)
 		phy_error(phydev);
 
-	schedule_delayed_work(&phydev->state_queue, PHY_STATE_TIME * HZ);
+	queue_delayed_work_on_any_cpu(system_wq, &phydev->state_queue,
+			PHY_STATE_TIME * HZ);
 }
 
 static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
-- 
1.7.12.rc2.18.g61b472e

