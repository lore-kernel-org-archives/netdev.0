From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/12] nfp: add set_mac_address support while the interface is up
Date: Sat, 27 May 2017 17:34:00 -0700
Message-ID: <20170528003411.17603-2-jakub.kicinski@netronome.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: oss-drivers@netronome.com,
        =?UTF-8?q?Pablo=20Casc=C3=B3n?= <pablo.cascon@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35139 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdE1Aen (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:43 -0400
Received: by mail-pf0-f176.google.com with SMTP id n23so32604947pfb.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:43 -0700 (PDT)
In-Reply-To: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Cascón <pablo.cascon@netronome.com>

Expose FW app ability to change MAC address at runtime.  Make sure
we only depend on it if FW app advertised the right capability.

Signed-off-by: Pablo Cascón <pablo.cascon@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 44 +++++++++++++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  2 +
 2 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index b3f5c8af6789..9312a737fbc9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2123,17 +2123,16 @@ void nfp_net_coalesce_write_cfg(struct nfp_net *nn)
 /**
  * nfp_net_write_mac_addr() - Write mac address to the device control BAR
  * @nn:      NFP Net device to reconfigure
+ * @addr:    MAC address to write
  *
  * Writes the MAC address from the netdev to the device control BAR.  Does not
  * perform the required reconfig.  We do a bit of byte swapping dance because
  * firmware is LE.
  */
-static void nfp_net_write_mac_addr(struct nfp_net *nn)
+static void nfp_net_write_mac_addr(struct nfp_net *nn, const u8 *addr)
 {
-	nn_writel(nn, NFP_NET_CFG_MACADDR + 0,
-		  get_unaligned_be32(nn->dp.netdev->dev_addr));
-	nn_writew(nn, NFP_NET_CFG_MACADDR + 6,
-		  get_unaligned_be16(nn->dp.netdev->dev_addr + 4));
+	nn_writel(nn, NFP_NET_CFG_MACADDR + 0, get_unaligned_be32(addr));
+	nn_writew(nn, NFP_NET_CFG_MACADDR + 6, get_unaligned_be16(addr + 4));
 }
 
 static void nfp_net_vec_clear_ring_data(struct nfp_net *nn, unsigned int idx)
@@ -2238,7 +2237,7 @@ static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, nn->dp.num_rx_rings == 64 ?
 		  0xffffffffffffffffULL : ((u64)1 << nn->dp.num_rx_rings) - 1);
 
-	nfp_net_write_mac_addr(nn);
+	nfp_net_write_mac_addr(nn, nn->dp.netdev->dev_addr);
 
 	nn_writel(nn, NFP_NET_CFG_MTU, nn->dp.netdev->mtu);
 
@@ -2997,6 +2996,27 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 	}
 }
 
+static int nfp_net_set_mac_address(struct net_device *netdev, void *addr)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	struct sockaddr *saddr = addr;
+	int err;
+
+	err = eth_prepare_mac_addr_change(netdev, addr);
+	if (err)
+		return err;
+
+	nfp_net_write_mac_addr(nn, saddr->sa_data);
+
+	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_MACADDR);
+	if (err)
+		return err;
+
+	eth_commit_mac_addr_change(netdev, addr);
+
+	return 0;
+}
+
 const struct net_device_ops nfp_net_netdev_ops = {
 	.ndo_open		= nfp_net_netdev_open,
 	.ndo_stop		= nfp_net_netdev_close,
@@ -3006,7 +3026,7 @@ const struct net_device_ops nfp_net_netdev_ops = {
 	.ndo_tx_timeout		= nfp_net_tx_timeout,
 	.ndo_set_rx_mode	= nfp_net_set_rx_mode,
 	.ndo_change_mtu		= nfp_net_change_mtu,
-	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_mac_address	= nfp_net_set_mac_address,
 	.ndo_set_features	= nfp_net_set_features,
 	.ndo_features_check	= nfp_net_features_check,
 	.ndo_get_phys_port_name	= nfp_port_get_phys_port_name,
@@ -3029,7 +3049,7 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->fw_ver.resv, nn->fw_ver.class,
 		nn->fw_ver.major, nn->fw_ver.minor,
 		nn->max_mtu);
-	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
+	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
 		nn->cap,
 		nn->cap & NFP_NET_CFG_CTRL_PROMISC  ? "PROMISC "  : "",
 		nn->cap & NFP_NET_CFG_CTRL_L2BC     ? "L2BCFILT " : "",
@@ -3051,7 +3071,8 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->cap & NFP_NET_CFG_CTRL_NVGRE    ? "NVGRE "	  : "",
 		nfp_net_ebpf_capable(nn)            ? "BPF "	  : "",
 		nn->cap & NFP_NET_CFG_CTRL_CSUM_COMPLETE ?
-						      "RXCSUM_COMPLETE " : "");
+						      "RXCSUM_COMPLETE " : "",
+		nn->cap & NFP_NET_CFG_CTRL_LIVE_ADDR ? "LIVE_ADDR " : "");
 }
 
 /**
@@ -3211,7 +3232,7 @@ int nfp_net_init(struct nfp_net *nn)
 	if (nn->dp.chained_metadata_format && nn->fw_ver.major != 4)
 		nn->cap &= ~NFP_NET_CFG_CTRL_RSS;
 
-	nfp_net_write_mac_addr(nn);
+	nfp_net_write_mac_addr(nn, nn->dp.netdev->dev_addr);
 
 	/* Determine RX packet/metadata boundary offset */
 	if (nn->fw_ver.major >= 2) {
@@ -3241,6 +3262,9 @@ int nfp_net_init(struct nfp_net *nn)
 	 * and netdev->hw_features advertises which features are
 	 * supported.  By default we enable most features.
 	 */
+	if (nn->cap & NFP_NET_CFG_CTRL_LIVE_ADDR)
+		netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+
 	netdev->hw_features = NETIF_F_HIGHDMA;
 	if (nn->cap & NFP_NET_CFG_CTRL_RXCSUM_ANY) {
 		netdev->hw_features |= NETIF_F_RXCSUM;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index df75b8dc3617..c8208bf370e0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -135,6 +135,7 @@
 #define   NFP_NET_CFG_CTRL_LSO2		  (0x1 << 28) /* LSO/TSO (version 2) */
 #define   NFP_NET_CFG_CTRL_RSS2		  (0x1 << 29) /* RSS (version 2) */
 #define   NFP_NET_CFG_CTRL_CSUM_COMPLETE  (0x1 << 30) /* Checksum complete */
+#define   NFP_NET_CFG_CTRL_LIVE_ADDR	  (0x1 << 31) /* live MAC addr change */
 
 #define NFP_NET_CFG_CTRL_LSO_ANY	(NFP_NET_CFG_CTRL_LSO | \
 					 NFP_NET_CFG_CTRL_LSO2)
@@ -157,6 +158,7 @@
 #define   NFP_NET_CFG_UPDATE_IRQMOD       (0x1 <<  8) /* IRQ mod change */
 #define   NFP_NET_CFG_UPDATE_VXLAN	  (0x1 <<  9) /* VXLAN port change */
 #define   NFP_NET_CFG_UPDATE_BPF	  (0x1 << 10) /* BPF program load */
+#define   NFP_NET_CFG_UPDATE_MACADDR	  (0x1 << 11) /* MAC address change */
 #define   NFP_NET_CFG_UPDATE_ERR          (0x1 << 31) /* A error occurred */
 #define NFP_NET_CFG_TXRS_ENABLE         0x0008
 #define NFP_NET_CFG_RXRS_ENABLE         0x0010
-- 
2.11.0
