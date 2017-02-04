From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 07/12] skge: use napi_complete_done()
Date: Sat,  4 Feb 2017 15:24:57 -0800
Message-ID: <20170204232502.22361-8-edumazet@google.com>
References: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33312 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751785AbdBDXZX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:23 -0500
Received: by mail-pf0-f182.google.com with SMTP id y143so14439984pfb.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:23 -0800 (PST)
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API and get rid of napi_gro_flush()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/marvell/skge.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 81106b73e468b3d542fbbef94503278103c7..edb95271a4f2f784d740b3201364a5e45de1 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3201,7 +3201,7 @@ static void skge_tx_done(struct net_device *dev)
 	}
 }
 
-static int skge_poll(struct napi_struct *napi, int to_do)
+static int skge_poll(struct napi_struct *napi, int budget)
 {
 	struct skge_port *skge = container_of(napi, struct skge_port, napi);
 	struct net_device *dev = skge->netdev;
@@ -3214,7 +3214,7 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 
 	skge_write8(hw, Q_ADDR(rxqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
 
-	for (e = ring->to_clean; prefetch(e->next), work_done < to_do; e = e->next) {
+	for (e = ring->to_clean; prefetch(e->next), work_done < budget; e = e->next) {
 		struct skge_rx_desc *rd = e->desc;
 		struct sk_buff *skb;
 		u32 control;
@@ -3236,12 +3236,10 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 	wmb();
 	skge_write8(hw, Q_ADDR(rxqaddr[skge->port], Q_CSR), CSR_START);
 
-	if (work_done < to_do) {
+	if (work_done < budget && napi_complete_done(napi, work_done)) {
 		unsigned long flags;
 
-		napi_gro_flush(napi, false);
 		spin_lock_irqsave(&hw->hw_lock, flags);
-		__napi_complete(napi);
 		hw->intr_mask |= napimask[skge->port];
 		skge_write32(hw, B0_IMSK, hw->intr_mask);
 		skge_read32(hw, B0_IMSK);
-- 
2.11.0.483.g087da7b7c-goog
