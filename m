From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH V5 3/5] PHYLIB: queue work on system_power_efficient_wq
Date: Wed, 24 Apr 2013 17:12:55 +0530
Message-ID: <a24dfa8042c4b8956163e855e53def7f7a53c137.1366803121.git.viresh.kumar@linaro.org>
References: <cover.1366803121.git.viresh.kumar@linaro.org>
Cc: davem@davemloft.net, airlied@redhat.com, axboe@kernel.dk,
	tglx@linutronix.de, peterz@infradead.org, mingo@redhat.com,
	rostedt@goodmis.org, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, robin.randhawa@arm.com,
	Steve.Bannister@arm.com, Liviu.Dudau@arm.com,
	charles.garcia-tobin@arm.com, arvind.chauhan@arm.com,
	linaro-kernel@lists.linaro.org, patches@linaro.org,
	Viresh Kumar <viresh.kumar@linaro.org>, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1366803121.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1366803121.git.viresh.kumar@linaro.org>
References: <cover.1366803121.git.viresh.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phylib uses workqueues for multiple purposes. There is no real dependency of
scheduling these on the cpu which scheduled them.

On a idle system, it is observed that and idle cpu wakes up many times just to
service this work. It would be better if we can schedule it on a cpu which the
scheduler believes to be the most appropriate one.

This patch replaces system_wq with system_power_efficient_wq for PHYLIB.

Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
Acked-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/phy/phy.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c14f147..984c0b5 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -439,7 +439,7 @@ void phy_start_machine(struct phy_device *phydev,
 {
 	phydev->adjust_state = handler;
 
-	schedule_delayed_work(&phydev->state_queue, HZ);
+	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, HZ);
 }
 
 /**
@@ -500,7 +500,7 @@ static irqreturn_t phy_interrupt(int irq, void *phy_dat)
 	disable_irq_nosync(irq);
 	atomic_inc(&phydev->irq_disable);
 
-	schedule_work(&phydev->phy_queue);
+	queue_work(system_power_efficient_wq, &phydev->phy_queue);
 
 	return IRQ_HANDLED;
 }
@@ -655,7 +655,7 @@ static void phy_change(struct work_struct *work)
 
 	/* reschedule state queue work to run as soon as possible */
 	cancel_delayed_work_sync(&phydev->state_queue);
-	schedule_delayed_work(&phydev->state_queue, 0);
+	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
 
 	return;
 
@@ -918,7 +918,8 @@ void phy_state_machine(struct work_struct *work)
 	if (err < 0)
 		phy_error(phydev);
 
-	schedule_delayed_work(&phydev->state_queue, PHY_STATE_TIME * HZ);
+	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
+			PHY_STATE_TIME * HZ);
 }
 
 static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
-- 
1.7.12.rc2.18.g61b472e
