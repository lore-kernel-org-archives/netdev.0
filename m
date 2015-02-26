From: George McCollister <george.mccollister@gmail.com>
Subject: [PATCH net] drivers: net: cpsw: Set SECURE for dual_emac ucast
Date: Thu, 26 Feb 2015 15:19:30 -0600
Message-ID: <1424985570-19193-1-git-send-email-george.mccollister@gmail.com>
Cc: davem@davemloft.net, mugunthanvnm@ti.com, balbi@ti.com,
	lsorense@csclub.uwaterloo.ca, tony@atomide.com, mpa@pengutronix.de,
	jhovold@gmail.com, george.cherian@ti.com, tklauser@distanz.ch,
	George McCollister <george.mccollister@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:50547 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbbBZVTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 16:19:51 -0500
Received: by mail-ob0-f180.google.com with SMTP id vb8so14226754obc.11
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 13:19:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch, sending a packet with the source MAC address of one
of the CPSW interfaces to one of the CPSW slave ports while it's configured in
dual_emac mode would update the port_num field of the VLAN/Unicast Address
Table Entry. This would cause it to discard all incoming traffic addressed to
that MAC address, essentially rendering the port useless until the ALE table is
cleared (by starting and stopping the interface or rebooting.)

For example, if eth0 has a MAC address of 90:59:af:8f:43:e9 it will have
an ALE table entry:

00 00 00 00 59 90 02 30 e9 43 8f af
(VLAN Addr vlan_id=2 unicast type=0 port_num=0 addr=90:59:af:8f:43:e9)

If you configure another device with the same MAC address and connect it
to the first CPSW slave port and send some traffic the ALE table entry
becomes:

04 00 00 00 59 90 02 30 e9 43 8f af
(VLAN Addr vlan_id=2 unicast type=0 port_num=1 addr=90:59:af:8f:43:e9)

>From this point forward all incoming traffic addressed to
90:59:af:8f:43:e9 will be dropped.

Setting the SECURE bit for the VLAN/Unicast address table entry for each
interface's MAC address corrects the problem.

Signed-off-by: George McCollister <george.mccollister@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 7d8dd0d..49b0336 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1103,7 +1103,7 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
 	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 			   port_mask, ALE_VLAN, slave->port_vlan, 0);
 	cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
-		priv->host_port, ALE_VLAN, slave->port_vlan);
+		priv->host_port, ALE_VLAN | ALE_SECURE, slave->port_vlan);
 }
 
 static void soft_reset_slave(struct cpsw_slave *slave)
-- 
2.2.2
