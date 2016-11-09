From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 2/2] net: mvpp2: simplify MAC address set code
Date: Wed,  9 Nov 2016 14:56:34 +0200
Message-ID: <7ae8a23e40b4025e76fa24bec5332165353a36f8.1478696194.git.baruch@tkos.co.il>
References: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
Cc: netdev@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Baruch Siach <baruch@tkos.co.il>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:53460 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752590AbcKIM4v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 07:56:51 -0500
In-Reply-To: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated code for handling the !netif_running() case.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
Build tested only.
---
 drivers/net/ethernet/marvell/mvpp2.c | 26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index e427b4706726..64b7f985d517 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5674,32 +5674,28 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
 {
 	struct mvpp2_port *port = netdev_priv(dev);
 	const struct sockaddr *addr = p;
-	int err;
+	int err, restart_dev = 0;
 
 	if (!is_valid_ether_addr(addr->sa_data)) {
 		err = -EADDRNOTAVAIL;
 		goto error;
 	}
 
-	if (!netif_running(dev)) {
-		err = mvpp2_prs_update_mac_da(dev, addr->sa_data);
-		if (!err)
-			return 0;
-		/* Reconfigure parser to accept the original MAC address */
+	if (netif_running(dev)) {
+		mvpp2_stop_dev(port);
+		restart_dev = 1;
+	}
+
+	err = mvpp2_prs_update_mac_da(dev, addr->sa_data);
+	if (err) {
+		/* Reconfigure parser accept the original MAC address */
 		mvpp2_prs_update_mac_da(dev, dev->dev_addr);
 		goto error;
 	}
 
-	mvpp2_stop_dev(port);
-
-	err = mvpp2_prs_update_mac_da(dev, addr->sa_data);
-	if (!err)
-		goto out_start;
+	if (!restart_dev)
+		return 0;
 
-	/* Reconfigure parser accept the original MAC address */
-	mvpp2_prs_update_mac_da(dev, dev->dev_addr);
-	goto error;
-out_start:
 	mvpp2_start_dev(port);
 	mvpp2_egress_enable(port);
 	mvpp2_ingress_enable(port);
-- 
2.10.2
