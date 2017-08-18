From: Colin King <colin.king@canonical.com>
Subject: [PATCH] nfp: fix infinite loop on umapping cleanup
Date: Fri, 18 Aug 2017 12:11:50 +0100
Message-ID: <20170818111150.13716-1-colin.king@canonical.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        oss-drivers@netronome.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The while loop that performs the dma page unmapping never decrements
index counter f and hence loops forever. Fix this with a pre-decrement
on f.

Detected by CoverityScan, CID#1357309 ("Infinite loop")

Fixes: 4c3523623dc0 ("net: add driver for Netronome NFP4000/NFP6000 NIC VFs")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 4a990033c4d5..732f1d315fba 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -908,8 +908,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 
 err_unmap:
-	--f;
-	while (f >= 0) {
+	while (--f >= 0) {
 		frag = &skb_shinfo(skb)->frags[f];
 		dma_unmap_page(dp->dev, tx_ring->txbufs[wr_idx].dma_addr,
 			       skb_frag_size(frag), DMA_TO_DEVICE);
-- 
2.11.0
