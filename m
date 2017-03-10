From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/13] nfp: validate rx offset from the BAR and size down it's field
Date: Fri, 10 Mar 2017 10:38:36 -0800
Message-ID: <20170310183839.39568-11-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35572 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932965AbdCJSjc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:32 -0500
Received: by mail-pg0-f50.google.com with SMTP id b129so41791932pgc.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:32 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFP_NET_CFG_RX_OFFSET is 32bit wide, make sure what we read from
there is reasonable for packet headroom.  This allows us to store
the rx_offset in a 8bit variable.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        |  6 +++---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 14 +++++++++++---
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index db92463da440..5f0547c6efb8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -439,9 +439,9 @@ struct nfp_stat_pair {
  * @bpf_offload_xdp:	Offloaded BPF program is XDP
  * @chained_metadata_format:  Firemware will use new metadata format
  * @rx_dma_dir:		Mapping direction for RX buffers
+ * @rx_offset:		Offset in the RX buffers where packet data starts
  * @ctrl:		Local copy of the control register/word.
  * @fl_bufsz:		Currently configured size of the freelist buffers
- * @rx_offset:		Offset in the RX buffers where packet data starts
  * @xdp_prog:		Installed XDP program
  * @tx_rings:		Array of pre-allocated TX ring structures
  * @rx_rings:		Array of pre-allocated RX ring structures
@@ -466,11 +466,11 @@ struct nfp_net_dp {
 
 	u8 rx_dma_dir;
 
+	u8 rx_offset;
+
 	u32 ctrl;
 	u32 fl_bufsz;
 
-	u32 rx_offset;
-
 	struct bpf_prog *xdp_prog;
 
 	struct nfp_net_tx_ring *tx_rings;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index ab03f2f301cd..513f55dd746b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3124,10 +3124,18 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	nfp_net_write_mac_addr(nn);
 
 	/* Determine RX packet/metadata boundary offset */
-	if (nn->fw_ver.major >= 2)
-		nn->dp.rx_offset = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
-	else
+	if (nn->fw_ver.major >= 2) {
+		u32 reg;
+
+		reg = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
+		if (reg > NFP_NET_MAX_PREPEND) {
+			nn_err(nn, "Invalid rx offset: %d\n", reg);
+			return -EINVAL;
+		}
+		nn->dp.rx_offset = reg;
+	} else {
 		nn->dp.rx_offset = NFP_NET_RX_OFFSET;
+	}
 
 	/* Set default MTU and Freelist buffer size */
 	if (nn->max_mtu < NFP_NET_DEFAULT_MTU)
-- 
2.11.0
