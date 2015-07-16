From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 3/3] mvneta: use inband status only when explicitly enabled
Date: Thu, 16 Jul 2015 17:53:12 +0300
Message-ID: <55A7C558.2030302@list.ru>
References: <55A7C45F.1070501@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A7C45F.1070501@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band link state
signaling") implemented the link parameters auto-negotiation unconditionally.
Unfortunately it appears that some HW that implements SGMII protocol,
doesn't generate the inband status, so it is not possible to auto-negotiate
anything with such HW.

This patch enables the auto-negotiation only if explicitly requested with
the 'managed' DT property.

This patch fixes the following regression:
https://lkml.org/lkml/2015/7/8/865

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/mvneta.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 74176ec..7a1deee 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3008,8 +3008,8 @@ static int mvneta_probe(struct platform_device *pdev)
 	const char *dt_mac_addr;
 	char hw_mac_addr[ETH_ALEN];
 	const char *mac_from;
+	const char *managed;
 	int phy_mode;
-	int fixed_phy = 0;
 	int err;

 	/* Our multiqueue support is not complete, so for now, only
@@ -3043,7 +3043,6 @@ static int mvneta_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "cannot register fixed PHY\n");
 			goto err_free_irq;
 		}
-		fixed_phy = 1;

 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
@@ -3067,8 +3066,10 @@ static int mvneta_probe(struct platform_device *pdev)
 	pp = netdev_priv(dev);
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
-	pp->use_inband_status = (phy_mode == PHY_INTERFACE_MODE_SGMII) &&
-				fixed_phy;
+
+	err = of_property_read_string(dn, "managed", &managed);
+	pp->use_inband_status = (err == 0 &&
+				 strcmp(managed, "in-band-status") == 0);

 	pp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
-- 
1.9.1
