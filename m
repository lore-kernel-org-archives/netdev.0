From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Always write MAC address to controller register
Date: Tue, 22 Nov 2016 10:07:46 -0500 (EST)
Message-ID: <20161122.100746.1225719841959525290.davem@davemloft.net>
References: <038ccd3c-6d77-d9e1-92e1-c41572684812@systec-electronic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: fugang.duan@nxp.com, netdev@vger.kernel.org,
        alexander.stein@systec-electronic.com
To: daniel.krueger@systec-electronic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755899AbcKVPHs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 10:07:48 -0500
In-Reply-To: <038ccd3c-6d77-d9e1-92e1-c41572684812@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This change is already in the tree via commit
b82d44d78480faff7456e9e0999acb9d38666057 made nearly
two months ago:

commit b82d44d78480faff7456e9e0999acb9d38666057
Author: Gavin Schenk <g.schenk@eckelmann.de>
Date:   Fri Sep 30 11:46:10 2016 +0200

    net: fec: set mac address unconditionally
    
    If the mac address origin is not dt, you can only safely assign a mac
    address after "link up" of the device. If the link is off the clocks are
    disabled and because of issues assigning registers when clocks are off the
    new mac address cannot be written in .ndo_set_mac_address() on some soc's.
    This fix sets the mac address unconditionally in fec_restart(...) and
    ensures consistency between fec registers and the network layer.
    
    Signed-off-by: Gavin Schenk <g.schenk@eckelmann.de>
    Acked-by: Fugang Duan <fugang.duan@nxp.com>
    Acked-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
    Fixes: 9638d19e4816 ("net: fec: add netif status check before set mac address")
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1fa2d87..48a033e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -913,13 +913,11 @@ fec_restart(struct net_device *ndev)
 	 * enet-mac reset will reset mac address registers too,
 	 * so need to reconfigure it.
 	 */
-	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
-		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
-		writel((__force u32)cpu_to_be32(temp_mac[0]),
-		       fep->hwp + FEC_ADDR_LOW);
-		writel((__force u32)cpu_to_be32(temp_mac[1]),
-		       fep->hwp + FEC_ADDR_HIGH);
-	}
+	memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
+	writel((__force u32)cpu_to_be32(temp_mac[0]),
+	       fep->hwp + FEC_ADDR_LOW);
+	writel((__force u32)cpu_to_be32(temp_mac[1]),
+	       fep->hwp + FEC_ADDR_HIGH);
 
 	/* Clear any outstanding interrupt. */
 	writel(0xffffffff, fep->hwp + FEC_IEVENT);
