From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH] net: mvneta: fix DMA buffer unmapping in mvneta_rx()
Date: Tue, 15 Sep 2015 22:41:21 +0200
Message-ID: <1442349681-27437-1-git-send-email-simon.guinot@sequanux.org>
References: <20150915203634.GI7306@kw.sim.vm.gnt>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Vincent Donnefort <vdonnefort@gmail.com>,
	Yoann Sculo <yoann@sculo.fr>, Sebastien Rannou <mxs@sbrk.org>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Simon Guinot <simon.guinot@sequanux.org>,
	<stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Oren Laskin <oren@igneous.io>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150915203634.GI7306@kw.sim.vm.gnt>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a regression introduced by the commit a84e32894191
("net: mvneta: fix refilling for Rx DMA buffers"). Due to this commit
the newly allocated Rx buffers are DMA-unmapped in place of those passed
to the networking stack. Obviously, this causes data corruptions.

This patch fixes the issue by ensuring that the right Rx buffers are
DMA-unmapped.

Reported-by: Oren Laskin <oren@igneous.io>
Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
Fixes: a84e32894191 ("net: mvneta: fix refilling for Rx DMA buffers")
Cc: <stable@vger.kernel.org> # v3.8+
---
 drivers/net/ethernet/marvell/mvneta.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 62e48bc0cb23..03e052a1cf5a 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1479,6 +1479,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		struct mvneta_rx_desc *rx_desc = mvneta_rxq_next_desc_get(rxq);
 		struct sk_buff *skb;
 		unsigned char *data;
+		dma_addr_t phys_addr;
 		u32 rx_status;
 		int rx_bytes, err;
 
@@ -1486,6 +1487,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
 		data = (unsigned char *)rx_desc->buf_cookie;
+		phys_addr = rx_desc->buf_phys_addr;
 
 		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
 		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
@@ -1534,7 +1536,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		if (!skb)
 			goto err_drop_frame;
 
-		dma_unmap_single(dev->dev.parent, rx_desc->buf_phys_addr,
+		dma_unmap_single(dev->dev.parent, phys_addr,
 				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
 
 		rcvd_pkts++;
-- 
2.1.4
