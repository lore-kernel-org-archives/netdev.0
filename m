From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: peak_pci: prevent use after free at netdev removal
Date: Wed, 21 May 2014 13:15:59 +0200
Message-ID: <1400670959-14211-2-git-send-email-mkl@pengutronix.de>
References: <1400670959-14211-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1400670959-14211-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephane Grosjean <s.grosjean@peak-system.com>

As remarked by Christopher R. Baker in his post at

http://marc.info/?l=linux-can&m=139707295706465&w=2

there's a possibility for an use after free condition at device removal.

This simplified patch introduces an additional variable to prevent the issue.
Thanks for catching this.

Cc: linux-stable <stable@vger.kernel.org>
Reported-by: Christopher R. Baker <cbaker@rec.ri.cmu.edu>
Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/peak_pci.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index c540e3d..564933a 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -551,7 +551,7 @@ static int peak_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct sja1000_priv *priv;
 	struct peak_pci_chan *chan;
-	struct net_device *dev;
+	struct net_device *dev, *prev_dev;
 	void __iomem *cfg_base, *reg_base;
 	u16 sub_sys_id, icr;
 	int i, err, channels;
@@ -688,11 +688,13 @@ failure_remove_channels:
 	writew(0x0, cfg_base + PITA_ICR + 2);
 
 	chan = NULL;
-	for (dev = pci_get_drvdata(pdev); dev; dev = chan->prev_dev) {
-		unregister_sja1000dev(dev);
-		free_sja1000dev(dev);
+	for (dev = pci_get_drvdata(pdev); dev; dev = prev_dev) {
 		priv = netdev_priv(dev);
 		chan = priv->priv;
+		prev_dev = chan->prev_dev;
+
+		unregister_sja1000dev(dev);
+		free_sja1000dev(dev);
 	}
 
 	/* free any PCIeC resources too */
@@ -726,10 +728,12 @@ static void peak_pci_remove(struct pci_dev *pdev)
 
 	/* Loop over all registered devices */
 	while (1) {
+		struct net_device *prev_dev = chan->prev_dev;
+
 		dev_info(&pdev->dev, "removing device %s\n", dev->name);
 		unregister_sja1000dev(dev);
 		free_sja1000dev(dev);
-		dev = chan->prev_dev;
+		dev = prev_dev;
 
 		if (!dev) {
 			/* do that only for first channel */
-- 
2.0.0.rc2
