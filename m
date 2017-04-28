From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/6] nfp: provide 256 bytes of XDP headroom in all configurations
Date: Thu, 27 Apr 2017 21:06:20 -0700
Message-ID: <20170428040620.8256-7-jakub.kicinski@netronome.com>
References: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:32844 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751178AbdD1EHC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 00:07:02 -0400
Received: by mail-pg0-f53.google.com with SMTP id y4so3026085pge.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 21:07:02 -0700 (PDT)
In-Reply-To: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For legacy reasons NFP FW may be compiled to DMA packets to a constant
offset into the buffer and use the space before it for metadata.  This
ensures that packets data always start at a certain offset regardless of
the amount of preceding metadata.

If rx offset is set to 0 there may still be up to 64 bytes of metadata
but metadata will start at the beginning of the buffer, instead of:

    data_start_offset = rx_offset - meta_len

Even though we make the buffers larger to accommodate up to 64 bytes of
metadata, if there is only N bytes of metadata, we will end up with
N bytes of headroom and 64 - N bytes of tailroom.  Therefore we can't
rely on that space for XDP headroom.  Make sure we always allocate
full 256 bytes.  This, unfortunately, means we can't fit the headroom
on an u8 any more.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        |  4 ++--
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 13 +------------
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index e7e9a9848746..38b41fdeaa8f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -470,10 +470,10 @@ struct nfp_net_dp {
 	u8 chained_metadata_format:1;
 
 	u8 rx_dma_dir;
-	u8 rx_dma_off;
-
 	u8 rx_offset;
 
+	u32 rx_dma_off;
+
 	u32 ctrl;
 	u32 fl_bufsz;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index c763a5b3bd6b..b9f3548bb65f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2966,11 +2966,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	dp->xdp_prog = prog;
 	dp->num_tx_rings += prog ? nn->dp.num_rx_rings : -nn->dp.num_rx_rings;
 	dp->rx_dma_dir = prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
-	if (prog)
-		dp->rx_dma_off = XDP_PACKET_HEADROOM -
-			(nn->dp.rx_offset ?: NFP_NET_MAX_PREPEND);
-	else
-		dp->rx_dma_off = 0;
+	dp->rx_dma_off = prog ? XDP_PACKET_HEADROOM - nn->dp.rx_offset : 0;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
 	err = nfp_net_ring_reconfig(nn, dp);
@@ -3198,13 +3194,6 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	int err;
 
-	/* XDP calls for 256 byte packet headroom which wouldn't fit in a u8.
-	 * We, however, reuse the metadata prepend space for XDP buffers which
-	 * is at least 1 byte long and as long as XDP headroom doesn't increase
-	 * above 256 the *extra* XDP headroom will fit on 8 bits.
-	 */
-	BUILD_BUG_ON(XDP_PACKET_HEADROOM > 256);
-
 	nn->dp.chained_metadata_format = nn->fw_ver.major > 3;
 
 	nn->dp.rx_dma_dir = DMA_FROM_DEVICE;
-- 
2.11.0
