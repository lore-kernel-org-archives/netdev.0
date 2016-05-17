From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 -net-next] ravb: Add missing free_irq() calls to ravb_close()
Date: Tue, 17 May 2016 11:05:34 +0200
Message-ID: <1463475934-3062-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When reopening the network device on ra7795/salvator-x, e.g. after a
DHCP timeout:

    IP-Config: Reopening network devices...
    genirq: Flags mismatch irq 139. 00000000 (eth0:ch0:rx_be) vs. 00000000 (ravb e6800000.ethernet eth0: cannot request IRQ eth0:ch0:rx_be
    IP-Config: Failed to open eth0
    IP-Config: No network devices available

The "mismatch" is due to requesting an IRQ that is already in use,
while IRQF_PROBE_SHARED wasn't set.

However, the real cause is that ravb_close() doesn't release any of the
R-Car Gen3-specific secondary IRQs.

Add the missing free_irq() calls to fix this.

Fixes: f51bdc236b6c5835 ("ravb: Add dma queue interrupt support")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
This version is against today's net-next.git.

v3:
  - Add Acked-by,
  - Rebase against net-next.git, which has received a partial fix
    through net.git,

v2:
  - Clearly state which version this patch is against,
  - Add Fixes tags.
---
 drivers/net/ethernet/renesas/ravb_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index bcebafd780234f96..867caf6e7a5a65ad 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1667,8 +1667,13 @@ static int ravb_close(struct net_device *ndev)
 		priv->phydev = NULL;
 	}
 
-	if (priv->chip_id == RCAR_GEN3)
+	if (priv->chip_id != RCAR_GEN2) {
+		free_irq(priv->tx_irqs[RAVB_NC], ndev);
+		free_irq(priv->rx_irqs[RAVB_NC], ndev);
+		free_irq(priv->tx_irqs[RAVB_BE], ndev);
+		free_irq(priv->rx_irqs[RAVB_BE], ndev);
 		free_irq(priv->emac_irq, ndev);
+	}
 	free_irq(ndev->irq, ndev);
 
 	napi_disable(&priv->napi[RAVB_NC]);
-- 
1.9.1
