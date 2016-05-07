From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2 2/2 -net-next] ravb: Add missing free_irq() calls to ravb_close()
Date: Sat,  7 May 2016 13:17:12 +0200
Message-ID: <1462619832-5177-3-git-send-email-geert+renesas@glider.be>
References: <1462619832-5177-1-git-send-email-geert+renesas@glider.be>
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1462619832-5177-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When reopening the network device on ra7795/salvator-x, e.g. after a
DHCP timeout:

    IP-Config: Reopening network devices...
    genirq: Flags mismatch irq 139. 00000000 (eth0:ch24:emac) vs. 00000000 (
    ravb e6800000.ethernet eth0: cannot request IRQ eth0:ch24:emac
    IP-Config: Failed to open eth0
    IP-Config: No network devices available

The "mismatch" is due to requesting an IRQ that is already in use,
while IRQF_PROBE_SHARED wasn't set.

However, the real cause is that ravb_close() doesn't release any of the
R-Car Gen3-specific secondary IRQs.

Add the missing free_irq() calls to fix this.

Fixes: 22d4df8ff3a3cc72 ("ravb: Add support for r8a7795 SoC")
Fixes: f51bdc236b6c5835 ("ravb: Add dma queue interrupt support")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
This version is against net-next.git.

v2:
  - Clearly state which version this patch is against,
  - Add Fixes tags.
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
