From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/3] nfp: remove legacy MAC address lookup
Date: Tue,  4 Jul 2017 02:27:20 -0700
Message-ID: <20170704092721.780-3-jakub.kicinski@netronome.com>
References: <20170704092721.780-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35033 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752228AbdGDJ2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 05:28:38 -0400
Received: by mail-pf0-f182.google.com with SMTP id c73so112791925pfk.2
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 02:28:38 -0700 (PDT)
In-Reply-To: <20170704092721.780-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The legacy MAC address lookup doesn't work well with breakout
cables.  We are probably better off picking random addresses
than the wrong ones in the theoretical scenario where management
FW didn't tell us what the port config is.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/main.c  |  3 +-
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c  |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_main.h     |  3 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 34 ++++-------------------
 4 files changed, 8 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 5fe6d3582597..fc10f27e0a0c 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -245,8 +245,7 @@ nfp_flower_spawn_phy_reprs(struct nfp_app *app, struct nfp_flower_priv *priv)
 		}
 
 		SET_NETDEV_DEV(reprs->reprs[phys_port], &priv->nn->pdev->dev);
-		nfp_net_get_mac_addr(app->pf, port,
-				     eth_tbl->ports[i].eth_index);
+		nfp_net_get_mac_addr(app->pf, port);
 
 		cmsg_port_id = nfp_flower_cmsg_phys_port(phys_port);
 		err = nfp_repr_init(app, reprs->reprs[phys_port],
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c b/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
index c11a6c34e217..4e37c81f9eaf 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
@@ -69,7 +69,7 @@ int nfp_app_nic_vnic_init(struct nfp_app *app, struct nfp_net *nn,
 	if (err)
 		return err < 0 ? err : 0;
 
-	nfp_net_get_mac_addr(app->pf, nn->port, id);
+	nfp_net_get_mac_addr(app->pf, nn->port);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index 365252ab4660..6922410806db 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -149,8 +149,7 @@ void nfp_net_pci_remove(struct nfp_pf *pf);
 int nfp_hwmon_register(struct nfp_pf *pf);
 void nfp_hwmon_unregister(struct nfp_pf *pf);
 
-void
-nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_port *port, unsigned int id);
+void nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_port *port);
 
 bool nfp_ctrl_tx(struct nfp_net *nn, struct sk_buff *skb);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index bfcdada29cc0..5797dbf2b507 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -84,46 +84,22 @@ static int nfp_is_ready(struct nfp_pf *pf)
  * nfp_net_get_mac_addr() - Get the MAC address.
  * @pf:       NFP PF handle
  * @port:     NFP port structure
- * @id:	      NFP port id
  *
  * First try to get the MAC address from NSP ETH table. If that
- * fails try HWInfo.  As a last resort generate a random address.
+ * fails generate a random address.
  */
-void
-nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_port *port, unsigned int id)
+void nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_port *port)
 {
 	struct nfp_eth_table_port *eth_port;
-	u8 mac_addr[ETH_ALEN];
-	const char *mac_str;
-	char name[32];
 
 	eth_port = __nfp_port_get_eth_port(port);
-	if (eth_port) {
-		ether_addr_copy(port->netdev->dev_addr, eth_port->mac_addr);
-		ether_addr_copy(port->netdev->perm_addr, eth_port->mac_addr);
-		return;
-	}
-
-	snprintf(name, sizeof(name), "eth%d.mac", id);
-
-	mac_str = nfp_hwinfo_lookup(pf->hwinfo, name);
-	if (!mac_str) {
-		nfp_warn(pf->cpp, "Can't lookup MAC address. Generate\n");
-		eth_hw_addr_random(port->netdev);
-		return;
-	}
-
-	if (sscanf(mac_str, "%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx",
-		   &mac_addr[0], &mac_addr[1], &mac_addr[2],
-		   &mac_addr[3], &mac_addr[4], &mac_addr[5]) != 6) {
-		nfp_warn(pf->cpp, "Can't parse MAC address (%s). Generate.\n",
-			 mac_str);
+	if (!eth_port) {
 		eth_hw_addr_random(port->netdev);
 		return;
 	}
 
-	ether_addr_copy(port->netdev->dev_addr, mac_addr);
-	ether_addr_copy(port->netdev->perm_addr, mac_addr);
+	ether_addr_copy(port->netdev->dev_addr, eth_port->mac_addr);
+	ether_addr_copy(port->netdev->perm_addr, eth_port->mac_addr);
 }
 
 static struct nfp_eth_table_port *
-- 
2.11.0
