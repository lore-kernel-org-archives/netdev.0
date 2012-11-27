From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 2/2] net/davinci_emac: use clk_{prepare|unprepare}
Date: Tue, 27 Nov 2012 20:17:15 +0530
Message-ID: <1354027635-32627-2-git-send-email-nsekhar@ti.com>
References: <1354027635-32627-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        Mike Turquette
	<mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1354027635-32627-1-git-send-email-nsekhar-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Use clk_prepare()/clk_unprepare() in the driver since common
clock framework needs these to be called before clock is enabled.

This is in preparation of common clock framework migration
for DaVinci.

Cc: Mike Turquette <mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
---
 drivers/net/ethernet/ti/davinci_emac.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 7be04dc..e7b3b94 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -352,6 +352,7 @@ struct emac_priv {
 	/*platform specific members*/
 	void (*int_enable) (void);
 	void (*int_disable) (void);
+	struct clk *clk;
 };
 
 /* EMAC TX Host Error description strings */
@@ -1870,19 +1871,29 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 		dev_err(&pdev->dev, "failed to get EMAC clock\n");
 		return -EBUSY;
 	}
+
+	rc = clk_prepare(emac_clk);
+	if (rc) {
+		dev_err(&pdev->dev, "emac clock prepare failed.\n");
+		return rc;
+	}
+
 	emac_bus_frequency = clk_get_rate(emac_clk);
 
 	/* TODO: Probe PHY here if possible */
 
 	ndev = alloc_etherdev(sizeof(struct emac_priv));
-	if (!ndev)
-		return -ENOMEM;
+	if (!ndev) {
+		rc = -ENOMEM;
+		goto no_etherdev;
+	}
 
 	platform_set_drvdata(pdev, ndev);
 	priv = netdev_priv(ndev);
 	priv->pdev = pdev;
 	priv->ndev = ndev;
 	priv->msg_enable = netif_msg_init(debug_level, DAVINCI_EMAC_DEBUG);
+	priv->clk = emac_clk;
 
 	spin_lock_init(&priv->lock);
 
@@ -2020,6 +2031,8 @@ no_cpdma_chan:
 	cpdma_ctlr_destroy(priv->dma);
 no_pdata:
 	free_netdev(ndev);
+no_etherdev:
+	clk_unprepare(emac_clk);
 	return rc;
 }
 
@@ -2048,6 +2061,8 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 	free_netdev(ndev);
 
+	clk_unprepare(priv->clk);
+
 	return 0;
 }
 
-- 
1.7.10.1
