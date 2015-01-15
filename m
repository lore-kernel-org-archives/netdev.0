From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: fix cpsw hung with add vlan using vconfig
Date: Thu, 15 Jan 2015 14:59:28 +0530
Message-ID: <1421314168-12009-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:44055 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbbAOJ3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 04:29:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

while adding vlan in dual EMAC mode, only specific ports should be
subscribed for the vlan, else it will lead to switching mode and
if both ports connected to same switch cpsw will hung as it creates
a network loop. Fixing this by adding only specific ports in case
of dual EMAC.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 64d1cef..e068d48 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1634,16 +1634,24 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
 				unsigned short vid)
 {
 	int ret;
-	int unreg_mcast_mask;
+	int unreg_mcast_mask = 0;
+	u32 port_mask;
 
-	if (priv->ndev->flags & IFF_ALLMULTI)
-		unreg_mcast_mask = ALE_ALL_PORTS;
-	else
-		unreg_mcast_mask = ALE_PORT_1 | ALE_PORT_2;
+	if (priv->data.dual_emac) {
+		port_mask = (1 << (priv->emac_port + 1)) | ALE_PORT_HOST;
+
+		if (priv->ndev->flags & IFF_ALLMULTI)
+			unreg_mcast_mask = port_mask;
+	} else {
+		port_mask = ALE_ALL_PORTS;
+
+		if (priv->ndev->flags & IFF_ALLMULTI)
+			unreg_mcast_mask = ALE_ALL_PORTS;
+		else
+			unreg_mcast_mask = ALE_PORT_1 | ALE_PORT_2;
+	}
 
-	ret = cpsw_ale_add_vlan(priv->ale, vid,
-				ALE_ALL_PORTS << priv->host_port,
-				0, ALE_ALL_PORTS << priv->host_port,
+	ret = cpsw_ale_add_vlan(priv->ale, vid, port_mask, 0, port_mask,
 				unreg_mcast_mask << priv->host_port);
 	if (ret != 0)
 		return ret;
@@ -1654,8 +1662,7 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
 		goto clean_vid;
 
 	ret = cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
-				 ALE_ALL_PORTS << priv->host_port,
-				 ALE_VLAN, vid, 0);
+				 port_mask, ALE_VLAN, vid, 0);
 	if (ret != 0)
 		goto clean_vlan_ucast;
 	return 0;
-- 
2.2.1.62.g3f15098
