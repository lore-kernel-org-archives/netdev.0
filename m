From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] ravb: Add missing free_irq() calls to ravb_close()
Date: Wed,  4 May 2016 15:03:07 +0200
Message-ID: <1462366987-18418-1-git-send-email-geert+renesas@glider.be>
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When reopening the network device on ra7795/salvator-x, e.g. after a
DHCP timeout:

    IP-Config: Reopening network devices...
    genirq: Flags mismatch irq 139. 00000000 (eth0:ch24:emac) vs. 00000000 (eth0:ch24:emac)
    ravb e6800000.ethernet eth0: cannot request IRQ eth0:ch24:emac
    IP-Config: Failed to open eth0
    IP-Config: No network devices available

The "mismatch" is due to requesting an IRQ that is already in use,
while IRQF_PROBE_SHARED wasn't set.

However, the real cause is that ravb_close() doesn't release any of the
R-Car Gen3-specific secondary IRQs.

Add the missing free_irq() calls to fix this.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/ethernet/renesas/ravb_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 34066e0649f5c673..867caf6e7a5a65ad 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1667,6 +1667,13 @@ static int ravb_close(struct net_device *ndev)
 		priv->phydev = NULL;
 	}
 
+	if (priv->chip_id != RCAR_GEN2) {
+		free_irq(priv->tx_irqs[RAVB_NC], ndev);
+		free_irq(priv->rx_irqs[RAVB_NC], ndev);
+		free_irq(priv->tx_irqs[RAVB_BE], ndev);
+		free_irq(priv->rx_irqs[RAVB_BE], ndev);
+		free_irq(priv->emac_irq, ndev);
+	}
 	free_irq(ndev->irq, ndev);
 
 	napi_disable(&priv->napi[RAVB_NC]);
-- 
1.9.1
