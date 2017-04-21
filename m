From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/5] nfp: fix free list buffer size reporting
Date: Fri, 21 Apr 2017 07:20:51 -0700
Message-ID: <20170421142052.107388-5-jakub.kicinski@netronome.com>
References: <20170421142052.107388-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:34790 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161436AbdDUOXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 10:23:11 -0400
Received: by mail-yb0-f173.google.com with SMTP id 11so40440392ybw.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 07:23:11 -0700 (PDT)
In-Reply-To: <20170421142052.107388-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP headroom should not be included in free list buffer size.

Fixes: 6fe0c3b43804 ("nfp: add support for xdp_adjust_head()")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index edab27a211fa..3a025f019703 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2155,7 +2155,7 @@ nfp_net_tx_ring_hw_cfg_write(struct nfp_net *nn,
  */
 static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 {
-	u32 new_ctrl, update = 0;
+	u32 bufsz, new_ctrl, update = 0;
 	unsigned int r;
 	int err;
 
@@ -2189,8 +2189,9 @@ static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nfp_net_write_mac_addr(nn);
 
 	nn_writel(nn, NFP_NET_CFG_MTU, nn->dp.netdev->mtu);
-	nn_writel(nn, NFP_NET_CFG_FLBUFSZ,
-		  nn->dp.fl_bufsz - NFP_NET_RX_BUF_NON_DATA);
+
+	bufsz = nn->dp.fl_bufsz - nn->dp.rx_dma_off - NFP_NET_RX_BUF_NON_DATA;
+	nn_writel(nn, NFP_NET_CFG_FLBUFSZ, bufsz);
 
 	/* Enable device */
 	new_ctrl |= NFP_NET_CFG_CTRL_ENABLE;
-- 
2.11.0
