From: <hliang1025@gmail.com>
Subject: [PATCH] net: ethernet : stmicro: fixed power suspend and resume failure in stmmac driver
Date: Tue, 30 Sep 2014 13:55:34 +0800
Message-ID: <1412056534-7995-1-git-send-email-hliang1025@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<adi-linux-docs@lists.sourceforge.net>,
	Hao Liang <hliang1025@gmail.com>
To: <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hao Liang <hliang1025@gmail.com>

This is the fix for a power management issue caused by suspend and resume function in stmmac_main.c.
After enable CONFIG_DEBUG_ATOMIC_SLEEP which enable sleep-inside atomic section checking, power
managemet can not work normally. Board couldn't wakeup successfully after suspend. Command
"echo mem > /sys/power/state" suspend the board.

In suspend and resume function of stmmac driver, there are some sleep-inside function in atomic section
created by spin lock. These functions will causes system warnings and wakeup issue when enable
CONFIG_DEBUG_ATOMIC_SLEEP.

This bug was fixed by:
* replace some sleep function with non-sleep function
  clk_disable_unprepare -> clk_disable ...
* decrease the atomic area created by spin lock function. The original atomic area in resume function is
too large.

Signed-off-by: Hao Liang <hliang1025@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6e6ee22..2effbfe 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2924,9 +2924,8 @@ int stmmac_suspend(struct net_device *ndev)
 	if (priv->phydev)
 		phy_stop(priv->phydev);
 
-	spin_lock_irqsave(&priv->lock, flags);
-
 	netif_device_detach(ndev);
+
 	netif_stop_queue(ndev);
 
 	napi_disable(&priv->napi);
@@ -2935,6 +2934,8 @@ int stmmac_suspend(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	priv->hw->dma->stop_rx(priv->ioaddr);
 
+	spin_lock_irqsave(&priv->lock, flags);
+
 	stmmac_clear_descriptors(priv);
 
 	/* Enable Power down mode by programming the PMT regs */
@@ -2945,7 +2946,7 @@ int stmmac_suspend(struct net_device *ndev)
 		stmmac_set_mac(priv->ioaddr, false);
 		pinctrl_pm_select_sleep_state(priv->device);
 		/* Disable clock in case of PWM is off */
-		clk_disable_unprepare(priv->stmmac_clk);
+		clk_disable(priv->stmmac_clk);
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -2977,12 +2978,14 @@ int stmmac_resume(struct net_device *ndev)
 	} else {
 		pinctrl_pm_select_default_state(priv->device);
 		/* enable the clk prevously disabled */
-		clk_prepare_enable(priv->stmmac_clk);
+		clk_enable(priv->stmmac_clk);
 		/* reset the phy so that it's ready */
 		if (priv->mii)
 			stmmac_mdio_reset(priv->mii);
 	}
 
+	spin_unlock_irqrestore(&priv->lock, flags);
+
 	netif_device_attach(ndev);
 
 	stmmac_hw_setup(ndev);
@@ -2991,8 +2994,6 @@ int stmmac_resume(struct net_device *ndev)
 
 	netif_start_queue(ndev);
 
-	spin_unlock_irqrestore(&priv->lock, flags);
-
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
-- 
1.7.9.5
