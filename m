From: Dan Carpenter <error27@gmail.com>
Subject: [patch v2] qlge: pull NULL check ahead of dereference
Date: Thu, 19 Aug 2010 20:52:44 +0200
Message-ID: <20100819185244.GD6674@bicker>
References: <20100819100214.GB6674@bicker> <20100819121942.GA14895@linux-ox1b.qlogic.org> <20100819125933.GB14895@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Driver <Linux-Driver@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:61597 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab0HSSxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 14:53:10 -0400
Content-Disposition: inline
In-Reply-To: <20100819125933.GB14895@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a dereference before NULL check issue introduced in 1e213303d
"qlge: Add tx multiqueue support."  I've pulled the NULL check of
"net_rsp" forward a couple lines to avoid that.

Also Ron Mercer says that the early exit should be above the index
write.  ql_write_cq_idx(rx_ring);

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
v2: Moved the early exit ahead of the ql_write_cq_idx()

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 8d63f69..c9f9754 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2222,10 +2222,11 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 		ql_update_cq(rx_ring);
 		prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
 	}
+	if (!net_rsp)
+		return 0;
 	ql_write_cq_idx(rx_ring);
 	tx_ring = &qdev->tx_ring[net_rsp->txq_idx];
-	if (__netif_subqueue_stopped(qdev->ndev, tx_ring->wq_id) &&
-					net_rsp != NULL) {
+	if (__netif_subqueue_stopped(qdev->ndev, tx_ring->wq_id)) {
 		if (atomic_read(&tx_ring->queue_stopped) &&
 		    (atomic_read(&tx_ring->tx_count) > (tx_ring->wq_len / 4)))
 			/*
