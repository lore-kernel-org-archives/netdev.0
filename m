From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 08/12] nfp: provide nfp_port to of nfp_net_get_mac_addr()
Date: Tue, 20 Jun 2017 23:36:16 +0200
Message-ID: <1497994580-6271-9-git-send-email-simon.horman@netronome.com>
References: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:35057 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752648AbdFTVg6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 17:36:58 -0400
Received: by mail-qt0-f173.google.com with SMTP id f92so4931779qtb.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 14:36:58 -0700 (PDT)
In-Reply-To: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide port rather than vNIC as parameter of nfp_net_get_mac_addr.
This is to allow this function to be used by representor netdevs where
a vNIC may have more than one physical port none of which are associated
with the vNIC.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c  |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_main.h     |  3 ++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 25 +++++++++++------------
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c b/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
index 7b966bd3d214..c11a6c34e217 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
@@ -69,7 +69,7 @@ int nfp_app_nic_vnic_init(struct nfp_app *app, struct nfp_net *nn,
 	if (err)
 		return err < 0 ? err : 0;
 
-	nfp_net_get_mac_addr(app->pf, nn, id);
+	nfp_net_get_mac_addr(app->pf, nn->port, id);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index aa69d4101eb9..edc14dc78674 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -58,6 +58,7 @@ struct nfp_hwinfo;
 struct nfp_mip;
 struct nfp_net;
 struct nfp_nsp_identify;
+struct nfp_port;
 struct nfp_rtsym_table;
 
 /**
@@ -147,7 +148,7 @@ void nfp_hwmon_unregister(struct nfp_pf *pf);
 struct nfp_eth_table_port *
 nfp_net_find_port(struct nfp_eth_table *eth_tbl, unsigned int id);
 void
-nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_net *nn, unsigned int id);
+nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_port *port, unsigned int id);
 
 bool nfp_ctrl_tx(struct nfp_net *nn, struct sk_buff *skb);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index eb87e1c08bb1..e16a5fa92279 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -135,25 +135,24 @@ static u8 __iomem *nfp_net_map_area(struct nfp_cpp *cpp,
 /**
  * nfp_net_get_mac_addr() - Get the MAC address.
  * @pf:       NFP PF handle
- * @nn:       NFP Network structure
+ * @port:     NFP port structure
  * @id:	      NFP port id
  *
  * First try to get the MAC address from NSP ETH table. If that
  * fails try HWInfo.  As a last resort generate a random address.
  */
 void
-nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_net *nn, unsigned int id)
+nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_port *port, unsigned int id)
 {
 	struct nfp_eth_table_port *eth_port;
-	struct nfp_net_dp *dp = &nn->dp;
 	u8 mac_addr[ETH_ALEN];
 	const char *mac_str;
 	char name[32];
 
-	eth_port = __nfp_port_get_eth_port(nn->port);
+	eth_port = __nfp_port_get_eth_port(port);
 	if (eth_port) {
-		ether_addr_copy(dp->netdev->dev_addr, eth_port->mac_addr);
-		ether_addr_copy(dp->netdev->perm_addr, eth_port->mac_addr);
+		ether_addr_copy(port->netdev->dev_addr, eth_port->mac_addr);
+		ether_addr_copy(port->netdev->perm_addr, eth_port->mac_addr);
 		return;
 	}
 
@@ -161,22 +160,22 @@ nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_net *nn, unsigned int id)
 
 	mac_str = nfp_hwinfo_lookup(pf->hwinfo, name);
 	if (!mac_str) {
-		dev_warn(dp->dev, "Can't lookup MAC address. Generate\n");
-		eth_hw_addr_random(dp->netdev);
+		nfp_warn(pf->cpp, "Can't lookup MAC address. Generate\n");
+		eth_hw_addr_random(port->netdev);
 		return;
 	}
 
 	if (sscanf(mac_str, "%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx",
 		   &mac_addr[0], &mac_addr[1], &mac_addr[2],
 		   &mac_addr[3], &mac_addr[4], &mac_addr[5]) != 6) {
-		dev_warn(dp->dev,
-			 "Can't parse MAC address (%s). Generate.\n", mac_str);
-		eth_hw_addr_random(dp->netdev);
+		nfp_warn(pf->cpp, "Can't parse MAC address (%s). Generate.\n",
+			 mac_str);
+		eth_hw_addr_random(port->netdev);
 		return;
 	}
 
-	ether_addr_copy(dp->netdev->dev_addr, mac_addr);
-	ether_addr_copy(dp->netdev->perm_addr, mac_addr);
+	ether_addr_copy(port->netdev->dev_addr, mac_addr);
+	ether_addr_copy(port->netdev->perm_addr, mac_addr);
 }
 
 struct nfp_eth_table_port *
-- 
2.1.4
