From: Johan Hovold <jhovold@gmail.com>
Subject: [PATCH RESEND 3/5] Revert "net: eth: cpsw: Correctly attach to GPIO bitbang MDIO driver"
Date: Thu,  8 May 2014 10:09:22 +0200
Message-ID: <1399536564-7626-4-git-send-email-jhovold@gmail.com>
References: <1399534639-4947-1-git-send-email-jhovold@gmail.com>
 <1399536564-7626-1-git-send-email-jhovold@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Johan Hovold <jhovold@gmail.com>, Stefan Roese <sr@denx.de>,
	stable <stable@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:51848 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbaEHIJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 04:09:58 -0400
In-Reply-To: <1399536564-7626-1-git-send-email-jhovold@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit f8d56d8f892be43a2404356073e16401eb5a42e6.

Fix potential null-pointer dereference at probe if the mdio-gpio device
has not been successfully probed yet.

The offending commit is plain wrong for a number of reasons. First of
all it accesses internal driver data of an unrelated device. Neither
does it check that the data is non-null (which it is in case the device
has not been probed yet).

Furthermore, the decision on whether to treat any driver data according
to the mdio-gpio driver's internals is made based on the node name. But
the name is not compared against "mdio" which is the normal name for the
node, but rather against "gpio" which the node does not have to be named
(and shouldn't be according to the binding documentation). [ If this
hack is to be kept out-of-tree it should at least be matching against
the compatible property. ]

Cc: Stefan Roese <sr@denx.de>
Cc: stable <stable@vger.kernel.org>	# v3.14
Signed-off-by: Johan Hovold <jhovold@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 36aa109416c4..18d83d8d7f74 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1871,18 +1871,8 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
 		phyid = be32_to_cpup(parp+1);
 		mdio = of_find_device_by_node(mdio_node);
-
-		if (strncmp(mdio->name, "gpio", 4) == 0) {
-			/* GPIO bitbang MDIO driver attached */
-			struct mii_bus *bus = dev_get_drvdata(&mdio->dev);
-
-			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-				 PHY_ID_FMT, bus->id, phyid);
-		} else {
-			/* davinci MDIO driver attached */
-			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-				 PHY_ID_FMT, mdio->name, phyid);
-		}
+		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
+			 PHY_ID_FMT, mdio->name, phyid);
 
 		mac_addr = of_get_mac_address(slave_node);
 		if (mac_addr)
-- 
1.8.3.2
