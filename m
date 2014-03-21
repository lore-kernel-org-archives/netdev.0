From: Nishanth Menon <nm@ti.com>
Subject: [PATCH V2] net: micrel : ks8851-ml: add vdd-supply support
Date: Fri, 21 Mar 2014 04:28:00 -0500
Message-ID: <1395394080-28964-1-git-send-email-nm@ti.com>
References: <20140321085158.GB30910@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nishanth Menon <nm@ti.com>, devicetree@vger.kernel.org,
 Tony Lindgren <tony@atomide.com>, netdev@vger.kernel.org,
 Markus Pargmann <mpa@pengutronix.de>,
 Russell King <rmk+kernel@arm.linux.org.uk>, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140321085158.GB30910@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Few platforms use external regulator to keep the ethernet MAC supplied.
So, request and enable the regulator for driver functionality.

Fixes: 66fda75f47dc (regulator: core: Replace direct ops->disable usage)
Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
Suggested-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Nishanth Menon <nm@ti.com>
---
This fixes a regression in SDP4430 platform as reported by Russel here:
http://marc.info/?t=139509918200014&r=1&w=2

Patch is based on [v3.14-rc7] tag, if it is too late to submit, I can repost
rebased to git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

Changes in v2: based on Marcus's comment, switched to managed regulator_get,
	however retained the enable/disable as balanced.
v1:  https://patchwork.kernel.org/patch/3871401/

 .../devicetree/bindings/net/micrel-ks8851.txt      |    1 +
 drivers/net/ethernet/micrel/ks8851.c               |   24 +++++++++++++++++++-
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/micrel-ks8851.txt b/Documentation/devicetree/bindings/net/micrel-ks8851.txt
index 11ace3c..4fc3927 100644
--- a/Documentation/devicetree/bindings/net/micrel-ks8851.txt
+++ b/Documentation/devicetree/bindings/net/micrel-ks8851.txt
@@ -7,3 +7,4 @@ Required properties:
 
 Optional properties:
 - local-mac-address : Ethernet mac address to use
+- vdd-supply:	supply for Ethernet mac
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 727b546a..44923e0 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -23,6 +23,7 @@
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/eeprom_93cx6.h>
+#include <linux/regulator/consumer.h>
 
 #include <linux/spi/spi.h>
 
@@ -83,6 +84,7 @@ union ks8851_tx_hdr {
  * @rc_rxqcr: Cached copy of KS_RXQCR.
  * @eeprom_size: Companion eeprom size in Bytes, 0 if no eeprom
  * @eeprom: 93CX6 EEPROM state for accessing on-board EEPROM.
+ * @vdd_reg:	Optional regulator supplying the chip
  *
  * The @lock ensures that the chip is protected when certain operations are
  * in progress. When the read or write packet transfer is in progress, most
@@ -130,6 +132,7 @@ struct ks8851_net {
 	struct spi_transfer	spi_xfer2[2];
 
 	struct eeprom_93cx6	eeprom;
+	struct regulator	*vdd_reg;
 };
 
 static int msg_enable;
@@ -1414,6 +1417,20 @@ static int ks8851_probe(struct spi_device *spi)
 	ks->spidev = spi;
 	ks->tx_space = 6144;
 
+	ks->vdd_reg = regulator_get_optional(&spi->dev, "vdd");
+	if (IS_ERR(ks->vdd_reg)) {
+		ret = PTR_ERR(ks->vdd_reg);
+		if (ret == -EPROBE_DEFER)
+			goto err_reg;
+	} else {
+		ret = regulator_enable(ks->vdd_reg);
+		if (ret) {
+			dev_err(&spi->dev, "regulator enable fail: %d\n",
+				ret);
+			goto err_reg;
+		}
+	}
+
 	mutex_init(&ks->lock);
 	spin_lock_init(&ks->statelock);
 
@@ -1508,8 +1525,11 @@ static int ks8851_probe(struct spi_device *spi)
 err_netdev:
 	free_irq(ndev->irq, ks);
 
-err_id:
 err_irq:
+err_id:
+	if (!IS_ERR(ks->vdd_reg))
+		regulator_disable(ks->vdd_reg);
+err_reg:
 	free_netdev(ndev);
 	return ret;
 }
@@ -1523,6 +1543,8 @@ static int ks8851_remove(struct spi_device *spi)
 
 	unregister_netdev(priv->netdev);
 	free_irq(spi->irq, priv);
+	if (!IS_ERR(priv->vdd_reg))
+		regulator_disable(priv->vdd_reg);
 	free_netdev(priv->netdev);
 
 	return 0;
-- 
1.7.9.5
