From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH v2] net: stmicro: stmmac: do not grab a mutex in irq off section
Date: Thu, 20 Mar 2014 17:06:05 +0100
Message-ID: <1395331565-23074-1-git-send-email-bigeasy@linutronix.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	peppe.cavallaro@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:43389 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbaCTQGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 12:06:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

|libphy: stmmac-0:01 - Link is Up - 1000/Full
|BUG: sleeping function called from invalid context at kernel/locking/mutex.c:616
|in_atomic(): 1, irqs_disabled(): 128, pid: 52, name: kworker/1:1
|4 locks held by kworker/1:1/52:
|
| #0:  (events_power_efficient){.+.+..}, at: [<800383a4>] process_one_work+0x128/0x450
| #1:  ((&(&dev->state_queue)->work)){+.+...}, at: [<800383a4>] process_one_work+0x128/0x450
| #2:  (&dev->lock#2){+.+...}, at: [<8025d9a4>] phy_state_machine+0x1c/0x39c
| #3:  (&(&priv->lock)->rlock){+.....}, at: [<802661b4>] stmmac_adjust_link+0x34/0x228
|CPU: 1 PID: 52 Comm: kworker/1:1 Not tainted 3.13.0-dirty #24
|Workqueue: events_power_efficient phy_state_machine
|[<8034eff4>] (mutex_lock_nested+0x28/0x434) from [<8025f35c>] (mdiobus_read+0x44/0x70)
|[<8025f35c>] (mdiobus_read+0x44/0x70) from [<8025ea40>] (genphy_update_link+0x18/0x50)
|[<8025ea40>] (genphy_update_link+0x18/0x50) from [<8025ea84>] (genphy_read_status+0xc/0x180)
|[<8025ea84>] (genphy_read_status+0xc/0x180) from [<8025cbd0>] (phy_init_eee+0x4c/0x2ac)
|[<8025cbd0>] (phy_init_eee+0x4c/0x2ac) from [<8026516c>] (stmmac_eee_init+0x40/0x104)
|[<8026516c>] (stmmac_eee_init+0x40/0x104) from [<80266298>] (stmmac_adjust_link+0x118/0x228)
|[<80266298>] (stmmac_adjust_link+0x118/0x228) from [<8025dbc4>] (phy_state_machine+0x23c/0x39c)
|[<8025dbc4>] (phy_state_machine+0x23c/0x39c) from [<80038420>] (process_one_work+0x1a4/0x450)
|stmmac: Energy-Efficient Ethernet initialized

stmmac_eee_init() is called in other places without this spin lock.
In stmmac_adjust_link() I just moved the unlock prior phy_print_status()
as it does not look like this lock protects stmmac_eee_init() (except it
ensures that does not get called twice).
For the resume case I moved stmmac_eee_init() out of stmmac_hw_setup()
and added it to both callers after the lock is dropped.
DaveM pointed out a problem with two concurent calls to
stmmac_eee_init() which would be bad. For that there is this
eee_init_lock mutex now.

Cc: peppe.cavallaro@st.com
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
This was tested on v3.13 and forward ported against net-next. I couldn't test
the resume/suspend path.

 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 13 +++++++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index f9e60d7..cff07f2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -98,6 +98,7 @@ struct stmmac_priv {
 	int lpi_irq;
 	int eee_enabled;
 	int eee_active;
+	struct mutex eee_init_lock;
 	int tx_lpi_timer;
 	int pcs;
 	unsigned int mode;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8543e1c..d0769c2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -277,6 +277,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 {
 	bool ret = false;
 
+	mutex_lock(&priv->eee_init_lock);
 	/* Using PCS we cannot dial with the phy registers at this stage
 	 * so we do not support extra feature like EEE.
 	 */
@@ -326,6 +327,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 		ret = true;
 	}
 out:
+	mutex_unlock(&priv->eee_init_lock);
 	return ret;
 }
 
@@ -741,6 +743,8 @@ static void stmmac_adjust_link(struct net_device *dev)
 		priv->oldduplex = -1;
 	}
 
+	spin_unlock_irqrestore(&priv->lock, flags);
+
 	if (new_state && netif_msg_link(priv))
 		phy_print_status(phydev);
 
@@ -748,8 +752,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 	 * MAC related HW registers.
 	 */
 	priv->eee_enabled = stmmac_eee_init(priv);
-
-	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 /**
@@ -1667,8 +1669,6 @@ static int stmmac_hw_setup(struct net_device *dev)
 	}
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS;
 
-	priv->eee_enabled = stmmac_eee_init(priv);
-
 	stmmac_init_tx_coalesce(priv);
 
 	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
@@ -1729,6 +1729,8 @@ static int stmmac_open(struct net_device *dev)
 		goto init_error;
 	}
 
+	priv->eee_enabled = stmmac_eee_init(priv);
+
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
@@ -2792,6 +2794,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 
 	spin_lock_init(&priv->lock);
 	spin_lock_init(&priv->tx_lock);
+	mutex_init(&priv->eee_init_lock);
 
 	ret = register_netdev(ndev);
 	if (ret) {
@@ -2943,6 +2946,8 @@ int stmmac_resume(struct net_device *ndev)
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
+	priv->eee_enabled = stmmac_eee_init(priv);
+
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
-- 
1.9.1
