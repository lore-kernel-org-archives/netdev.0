From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net: stmicro: stmac: do not grab a mutex in irq off section
Date: Tue, 18 Feb 2014 18:34:03 +0100
Message-ID: <1392744843-6324-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:44211 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbaBRReT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 12:34:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I captured this:

|libphy: stmmac-0:04 - Link is Up - 1000/Full
|BUG: sleeping function called from invalid context at kernel/mutex.c:616
|in_atomic(): 1, irqs_disabled(): 128, pid: 31, name: kworker/1:1
|CPU: 1 PID: 31 Comm: kworker/1:1 Not tainted 3.12.0-00324-g28301d2-dirty #5
|[<8042f8e8>] (mutex_lock_nested+0x28/0x3cc) from [<802a226c>] (mdiobus_read+0x38/0x64)
|[<802a226c>] (mdiobus_read+0x38/0x64) from [<802a1968>] (genphy_update_link+0x18/0x50)
|[<802a1968>] (genphy_update_link+0x18/0x50) from [<802a19ac>] (genphy_read_status+0xc/0x180)
|[<802a19ac>] (genphy_read_status+0xc/0x180) from [<8029fb0c>] (phy_init_eee+0x4c/0x2ac)
|[<8029fb0c>] (phy_init_eee+0x4c/0x2ac) from [<802a7550>] (stmmac_eee_init+0x40/0x104)
|[<802a7550>] (stmmac_eee_init+0x40/0x104) from [<802a8678>] (stmmac_adjust_link+0x118/0x228)
|[<802a8678>] (stmmac_adjust_link+0x118/0x228) from [<802a0af4>] (phy_state_machine+0x23c/0x39c)
|[<802a0af4>] (phy_state_machine+0x23c/0x39c) from [<800371b8>] (process_one_work+0x1a4/0x44c)
|[<800371b8>] (process_one_work+0x1a4/0x44c) from [<80037884>] (worker_thread+0x138/0x390)
|[<80037884>] (worker_thread+0x138/0x390) from [<8003e850>] (kthread+0xb4/0xb8)
|[<8003e850>] (kthread+0xb4/0xb8) from [<8000e5a8>] (ret_from_fork+0x14/0x2c)
|stmmac: Energy-Efficient Ethernet initialized

stmmac_eee_init() is called in other places without this lock.
phy_print_status() is just a printk() and the if condition is not
protected by the lock so I moved the unlock part just before that.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 751a73a..a514d8b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -730,6 +730,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		priv->speed = 0;
 		priv->oldduplex = -1;
 	}
+	spin_unlock_irqrestore(&priv->lock, flags);
 
 	if (new_state && netif_msg_link(priv))
 		phy_print_status(phydev);
@@ -738,8 +739,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 	 * MAC related HW registers.
 	 */
 	priv->eee_enabled = stmmac_eee_init(priv);
-
-	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 /**
-- 
1.9.0.rc3
