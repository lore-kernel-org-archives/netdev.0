From: Bartosz Folta <bfolta@cadence.com>
Subject: [PATCH] net: macb: Applied changes according to review made by Andy
 Shevchenko.
Date: Wed, 21 Dec 2016 08:53:05 +0000
Message-ID: <SN1PR0701MB1951B994F86160A24C436F30CC930@SN1PR0701MB1951.namprd07.prod.outlook.com>
References: <1482309315-582-1-git-send-email-bfolta@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Bartosz Folta <bfolta@cadence.com>,
        Rafal Ozieblo <rafalo@cadence.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Niklas Cassel <niklas.cassel@axis.com>,
        "Alexandre Torgue" <alexandre.torgue@st.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Simon Horman <simon.horman@netronome.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482309315-582-1-git-send-email-bfolta@cadence.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is sent in regard to recently applied patch
Commit 83a77e9ec4150ee4acc635638f7dedd9da523a26
net: macb: Added PCI wrapper for Platform Driver.
Andy's review does not appear on mailing lists. I can't reference it.

Signed-off-by: Bartosz Folta <bfolta@cadence.com>
---
 drivers/net/ethernet/cadence/macb_pci.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb_pci.c b/drivers/net/ethernet=
/cadence/macb_pci.c
index 92be2cd..6cec52c 100644
--- a/drivers/net/ethernet/cadence/macb_pci.c
+++ b/drivers/net/ethernet/cadence/macb_pci.c
@@ -1,5 +1,5 @@
 /**
- * macb_pci.c - Cadence GEM PCI wrapper.
+ * Cadence GEM PCI wrapper.
  *
  * Copyright (C) 2016 Cadence Design Systems - http://www.cadence.com
  *
@@ -45,32 +45,27 @@ static int macb_probe(struct pci_dev *pdev, const struc=
t pci_device_id *id)
 	struct macb_platform_data plat_data;
 	struct resource res[2];
=20
-	/* sanity check */
-	if (!id)
-		return -EINVAL;
-
 	/* enable pci device */
-	err =3D pci_enable_device(pdev);
+	err =3D pcim_enable_device(pdev);
 	if (err < 0) {
-		dev_err(&pdev->dev, "Enabling PCI device has failed: 0x%04X",
-			err);
-		return -EACCES;
+		dev_err(&pdev->dev, "Enabling PCI device has failed: %d", err);
+		return err;
 	}
=20
 	pci_set_master(pdev);
=20
 	/* set up resources */
 	memset(res, 0x00, sizeof(struct resource) * ARRAY_SIZE(res));
-	res[0].start =3D pdev->resource[0].start;
-	res[0].end =3D pdev->resource[0].end;
+	res[0].start =3D pci_resource_start(pdev, 0);
+	res[0].end =3D pci_resource_end(pdev, 0);
 	res[0].name =3D PCI_DRIVER_NAME;
 	res[0].flags =3D IORESOURCE_MEM;
-	res[1].start =3D pdev->irq;
+	res[1].start =3D pci_irq_vector(pdev, 0);
 	res[1].name =3D PCI_DRIVER_NAME;
 	res[1].flags =3D IORESOURCE_IRQ;
=20
-	dev_info(&pdev->dev, "EMAC physical base addr =3D 0x%p\n",
-		 (void *)(uintptr_t)pci_resource_start(pdev, 0));
+	dev_info(&pdev->dev, "EMAC physical base addr: %pa\n",
+		 &res[0].start);
=20
 	/* set up macb platform data */
 	memset(&plat_data, 0, sizeof(plat_data));
@@ -120,7 +115,6 @@ static int macb_probe(struct pci_dev *pdev, const struc=
t pci_device_id *id)
 	clk_unregister(plat_data.pclk);
=20
 err_pclk_register:
-	pci_disable_device(pdev);
 	return err;
 }
=20
@@ -130,7 +124,6 @@ static void macb_remove(struct pci_dev *pdev)
 	struct macb_platform_data *plat_data =3D dev_get_platdata(&plat_dev->dev)=
;
=20
 	platform_device_unregister(plat_dev);
-	pci_disable_device(pdev);
 	clk_unregister(plat_data->pclk);
 	clk_unregister(plat_data->hclk);
 }
--=20
1.9.1
