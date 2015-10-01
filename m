From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.1 25/29] mvneta: use inband status only when explicitly enabled
Date: Thu,  1 Oct 2015 11:32:01 +0200
Message-ID: <20151001093146.812883747@linuxfoundation.org>
References: <20151001093145.730759857@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151001093145.730759857@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

4.1-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Stas Sergeev <stsp@list.ru>

[ Upstream commit f8af8e6eb95093d5ce5ebcc52bd1929b0433e172 in net-next tree,
  will be pushed to Linus very soon. ]

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
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/ethernet/marvell/mvneta.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3029,8 +3029,8 @@ static int mvneta_probe(struct platform_
 	const char *dt_mac_addr;
 	char hw_mac_addr[ETH_ALEN];
 	const char *mac_from;
+	const char *managed;
 	int phy_mode;
-	int fixed_phy = 0;
 	int err;
 
 	/* Our multiqueue support is not complete, so for now, only
@@ -3064,7 +3064,6 @@ static int mvneta_probe(struct platform_
 			dev_err(&pdev->dev, "cannot register fixed PHY\n");
 			goto err_free_irq;
 		}
-		fixed_phy = 1;
 
 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
@@ -3088,8 +3087,10 @@ static int mvneta_probe(struct platform_
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
