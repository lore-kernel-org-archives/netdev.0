From: Romain Baeriswyl <Romain.Baeriswyl@abilis.com>
Subject: [RFC] net: stmmac: keep RXC running in LPI mode to avoid system overload
Date: Tue,  8 Oct 2013 17:06:35 +0200
Message-ID: <1381244795-3922-1-git-send-email-romainba@abilis.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Romain Baeriswyl <romainba@abilis.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to avoid system overload, the clock RXC from the Phy should not be 
stopped when in LPI mode.

With the RTL8211E PHY which support EEE mode and with Apple Airport Extreme that 
supports it also, the kernel get frozen as soon as some Ethernet transfers are 
on-going. System seems to be overloaded with too many interrupts. The 'top' 
command reports often around ~80% irq.

By letting the RXC clock running even in LPI mode as proposed below, the issue 
seems solved. Is it the right way to proceed?  

What is the power impact to not stop RXC in LPI mode?

---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e9eab29..d40d26b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -314,7 +314,8 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 	/* MAC core supports the EEE feature. */
 	if (priv->dma_cap.eee) {
 		/* Check if the PHY supports EEE */
-		if (phy_init_eee(priv->phydev, 1))
+		/* Keeps RXC running in LPI mode to avoid stability issue */
+		if (phy_init_eee(priv->phydev, 0))
 			goto out;
 
 		if (!priv->eee_active) {
@@ -770,7 +771,8 @@ static void stmmac_adjust_link(struct net_device *dev)
 	/* At this stage, it could be needed to setup the EEE or adjust some
 	 * MAC related HW registers.
 	 */
-	priv->eee_enabled = stmmac_eee_init(priv);
+	if (new_state)
+		priv->eee_enabled = stmmac_eee_init(priv);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
-- 
1.7.1
