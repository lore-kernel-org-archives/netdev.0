From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH v3 4/7] net: pch_gbe: Add device tree support
Date: Fri, 2 Jun 2017 16:40:39 -0700
Message-ID: <20170602234042.22782-5-paul.burton@imgtec.com>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tobias Klauser <tklauser@distanz.ch>,
        "David S . Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>, <linux-mips@linux-mips.org>,
        Eric Dumazet <edumazet@google.com>,
        Paul Burton <paul.burton@imgtec.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:60565 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBXmu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 19:42:50 -0400
In-Reply-To: <20170602234042.22782-1-paul.burton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce support for retrieving the PHY reset GPIO from device tree,
which will be used on the MIPS Boston development board. This requires
support for probe deferral in order to work correctly, since the order
of device probe is not guaranteed & typically the EG20T GPIO controller
device will be probed after the ethernet MAC.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org
---

Changes in v3: None

Changes in v2:
- Tidy up handling of parsing private data, drop err_out.

 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 31 +++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index cb9b904786e4..59a42c20d433 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -23,6 +23,8 @@
 #include <linux/net_tstamp.h>
 #include <linux/ptp_classify.h>
 #include <linux/gpio.h>
+#include <linux/gpio/consumer.h>
+#include <linux/of_gpio.h>
 
 #define DRV_VERSION     "1.01"
 const char pch_driver_version[] = DRV_VERSION;
@@ -2565,13 +2567,40 @@ static void pch_gbe_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
+static struct pch_gbe_privdata *
+pch_gbe_get_priv(struct pci_dev *pdev, const struct pci_device_id *pci_id)
+{
+	struct pch_gbe_privdata *pdata;
+	struct gpio_desc *gpio;
+
+	if (!IS_ENABLED(CONFIG_OF))
+		return (struct pch_gbe_privdata *)pci_id->driver_data;
+
+	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata)
+		return ERR_PTR(-ENOMEM);
+
+	gpio = devm_gpiod_get(&pdev->dev, "phy-reset", GPIOD_ASIS);
+	if (!IS_ERR(gpio))
+		pdata->phy_reset_gpio = gpio;
+	else if (PTR_ERR(gpio) != -ENOENT)
+		return ERR_PTR(PTR_ERR(gpio));
+
+	return pdata;
+}
+
 static int pch_gbe_probe(struct pci_dev *pdev,
 			  const struct pci_device_id *pci_id)
 {
 	struct net_device *netdev;
 	struct pch_gbe_adapter *adapter;
+	struct pch_gbe_privdata *pdata;
 	int ret;
 
+	pdata = pch_gbe_get_priv(pdev, pci_id);
+	if (IS_ERR(pdata))
+		return PTR_ERR(pdata);
+
 	ret = pcim_enable_device(pdev);
 	if (ret)
 		return ret;
@@ -2609,7 +2638,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
 	adapter->hw.reg = pcim_iomap_table(pdev)[PCH_GBE_PCI_BAR];
-	adapter->pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
+	adapter->pdata = pdata;
 	if (adapter->pdata && adapter->pdata->platform_init)
 		adapter->pdata->platform_init(pdev, adapter->pdata);
 
-- 
2.13.0
