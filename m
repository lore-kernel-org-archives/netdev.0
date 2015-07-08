From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: fix disabling of tx interrupt in rx isr
Date: Wed, 8 Jul 2015 12:17:46 +0530
Message-ID: <1436338066-7685-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>,
	Felipe Balbi <balbi@ti.com>, <stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the below commit, common isr is split into tx and rx, but in
rx isr tx interrupt is also disabled. So tx packets are not handled
during rx interrupts and rx napi completion. Fixing by disabling on
rx interrupt in rx isr.

Fixes: c03abd84634d ("net: ethernet: cpsw: don't requests IRQs we don't use")
Cc: Felipe Balbi <balbi@ti.com>
Cc: <stable@vger.kernel.org> # v4.0+
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e778703..f335bf1 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -138,19 +138,6 @@ do {								\
 #define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
 #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
 
-#define cpsw_enable_irq(priv)	\
-	do {			\
-		u32 i;		\
-		for (i = 0; i < priv->num_irqs; i++) \
-			enable_irq(priv->irqs_table[i]); \
-	} while (0)
-#define cpsw_disable_irq(priv)	\
-	do {			\
-		u32 i;		\
-		for (i = 0; i < priv->num_irqs; i++) \
-			disable_irq_nosync(priv->irqs_table[i]); \
-	} while (0)
-
 #define cpsw_slave_index(priv)				\
 		((priv->data.dual_emac) ? priv->emac_port :	\
 		priv->data.active_slave)
@@ -783,7 +770,7 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 
 	cpsw_intr_disable(priv);
 	if (priv->irq_enabled == true) {
-		cpsw_disable_irq(priv);
+		disable_irq_nosync(priv->irqs_table[0]);
 		priv->irq_enabled = false;
 	}
 
@@ -819,7 +806,7 @@ static int cpsw_poll(struct napi_struct *napi, int budget)
 		prim_cpsw = cpsw_get_slave_priv(priv, 0);
 		if (prim_cpsw->irq_enabled == false) {
 			prim_cpsw->irq_enabled = true;
-			cpsw_enable_irq(priv);
+			enable_irq(priv->irqs_table[0]);
 		}
 	}
 
@@ -1335,7 +1322,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	if (prim_cpsw->irq_enabled == false) {
 		if ((priv == prim_cpsw) || !netif_running(prim_cpsw->ndev)) {
 			prim_cpsw->irq_enabled = true;
-			cpsw_enable_irq(prim_cpsw);
+			enable_irq(prim_cpsw->irqs_table[0]);
 		}
 	}
 
-- 
2.5.0.rc0
