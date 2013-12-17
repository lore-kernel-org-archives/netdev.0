From: Mark Brown <broonie@kernel.org>
Subject: [PATCH 03/11] PHYLIB: queue work on system_power_efficient_wq
Date: Tue, 17 Dec 2013 21:56:47 +0000
Message-ID: <1387317415-22252-3-git-send-email-broonie@kernel.org>
References: <20131217215601.GI28455@sirena.org.uk>
 <1387317415-22252-1-git-send-email-broonie@kernel.org>
Cc: Viresh Kumar <viresh.kumar@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: ltsi-dev@lists.linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:51403 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab3LQV5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:57:04 -0500
In-Reply-To: <1387317415-22252-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Viresh Kumar <viresh.kumar@linaro.org>

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
Signed-off-by: Tejun Heo <tj@kernel.org>
(cherry picked from commit bbb47bdeae756f04b896b55b51f230f3eb21f207)
Signed-off-by: Mark Brown <broonie@linaro.org>
---
 drivers/net/phy/phy.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 38f0b312ff85..663d2d0448b7 100644
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
1.8.5.1
