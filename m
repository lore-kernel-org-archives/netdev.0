From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: fix dual EMAC stall when connected to same switch
Date: Wed, 18 Jun 2014 17:21:48 +0530
Message-ID: <1403092308-31380-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>,
	Yegor Yefremov <yegorslists@googlemail.com>,
	Felipe Balbi <balbi@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:43370 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965876AbaFRLvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 07:51:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 629c9a8fd0bbdfc6d702526b327470166ec39c6b (drivers: net: cpsw: Add
default vlan for dual emac case also), api cpsw_add_default_vlan() also
changes the port vlan which is required to seperate the ports which results
in the following behavior

In Dual EMAC mode, when both the Etnernet connected is connected to same
switch, it creates a loop in the switch and when a broadcast packet is
received it is forwarded to the other port which stalls the whole switch
and needs a reset/power cycle to the switch to recover. So intead of using
the api, add only the default VLAN entry in dual EMAC case.

Cc: Yegor Yefremov <yegorslists@googlemail.com>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ff380da..b988d16 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1212,7 +1212,12 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	for_each_slave(priv, cpsw_slave_open, priv);
 
 	/* Add default VLAN */
-	cpsw_add_default_vlan(priv);
+	if (!priv->data.dual_emac)
+		cpsw_add_default_vlan(priv);
+	else
+		cpsw_ale_add_vlan(priv->ale, priv->data.default_vlan,
+				  ALE_ALL_PORTS << priv->host_port,
+				  ALE_ALL_PORTS << priv->host_port, 0, 0);
 
 	if (!cpsw_common_res_usage_state(priv)) {
 		/* setup tx dma to fixed prio and zero offset */
-- 
1.9.2.459.g68773ac
