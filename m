From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: fix multicast flush in dual emac mode
Date: Tue, 13 Jan 2015 17:35:49 +0530
Message-ID: <1421150749-4329-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>,
	<stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since ALE table is a common resource for both the interfaces in Dual EMAC
mode and while bringing up the second interface in cpsw_ndo_set_rx_mode()
all the multicast entries added by the first interface is flushed out and
only second interface multicast addresses are added. Fixing this by
flushing multicast addresses based on dual EMAC port vlans which will not
affect the other emac port multicast addresses.

Fixes: d9ba8f9 (driver: net: ethernet: cpsw: dual emac interface implementation)
Cc: <stable@vger.kernel.org> # v3.9+
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c     | 11 +++++++++--
 drivers/net/ethernet/ti/cpsw_ale.c | 10 +++++++++-
 drivers/net/ethernet/ti/cpsw_ale.h |  2 +-
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e61ee83..64d1cef 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -610,7 +610,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 
 			/* Clear all mcast from ALE */
 			cpsw_ale_flush_multicast(ale, ALE_ALL_PORTS <<
-						 priv->host_port);
+						 priv->host_port, -1);
 
 			/* Flood All Unicast Packets to Host port */
 			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 1);
@@ -634,6 +634,12 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	int vid;
+
+	if (priv->data.dual_emac)
+		vid = priv->slaves[priv->emac_port].port_vlan;
+	else
+		vid = priv->data.default_vlan;
 
 	if (ndev->flags & IFF_PROMISC) {
 		/* Enable promiscuous mode */
@@ -649,7 +655,8 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	cpsw_ale_set_allmulti(priv->ale, priv->ndev->flags & IFF_ALLMULTI);
 
 	/* Clear all mcast from ALE */
-	cpsw_ale_flush_multicast(priv->ale, ALE_ALL_PORTS << priv->host_port);
+	cpsw_ale_flush_multicast(priv->ale, ALE_ALL_PORTS << priv->host_port,
+				 vid);
 
 	if (!netdev_mc_empty(ndev)) {
 		struct netdev_hw_addr *ha;
diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 097ebe7..5246b3a 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -234,7 +234,7 @@ static void cpsw_ale_flush_mcast(struct cpsw_ale *ale, u32 *ale_entry,
 		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
 }
 
-int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask)
+int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask, int vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS];
 	int ret, idx;
@@ -245,6 +245,14 @@ int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask)
 		if (ret != ALE_TYPE_ADDR && ret != ALE_TYPE_VLAN_ADDR)
 			continue;
 
+		/* if vid passed is -1 then remove all multicast entry from
+		 * the table irrespective of vlan id, if a valid vlan id is
+		 * passed then remove only multicast added to that vlan id.
+		 * if vlan id doesn't match then move on to next entry.
+		 */
+		if (vid != -1 && cpsw_ale_get_vlan_id(ale_entry) != vid)
+			continue;
+
 		if (cpsw_ale_get_mcast(ale_entry)) {
 			u8 addr[6];
 
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index c0d4127..af1e7ec 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -92,7 +92,7 @@ void cpsw_ale_stop(struct cpsw_ale *ale);
 
 int cpsw_ale_set_ageout(struct cpsw_ale *ale, int ageout);
 int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask);
-int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask);
+int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask, int vid);
 int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
 		       int flags, u16 vid);
 int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port,
-- 
2.2.1.62.g3f15098
