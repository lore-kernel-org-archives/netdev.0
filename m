From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v3 11/12] net: ethernet: aquantia: Fixed memory allocation if AQ_CFG_RX_FRAME_MAX > 1 page.
Date: Mon, 20 Feb 2017 14:41:53 +0300
Message-ID: <8c6d7500a366bcdb606e0fc2d91938c68f78c4b3.1487590641.git.pavel.belous@aquantia.com>
References: <cover.1487590641.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0086.outbound.protection.outlook.com ([104.47.42.86]:47808
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753021AbdBTLnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 06:43:16 -0500
In-Reply-To: <cover.1487590641.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

We should allocate the number of pages based on the config parameter
AQ_CFG_RX_FRAME_MAX.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c  | 4 ++--
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 4 +++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index fdd7d72..0b208c4 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -597,9 +597,9 @@ __acquires(&ring->lock)
 
 	do {
 		if (spin_trylock(&ring->header.lock)) {
-			frags = aq_nic_map_skb(self, skb, &buffers[0]);
+			frags = aq_nic_map_skb(self, skb, buffers);
 
-			aq_ring_tx_append_buffs(ring, &buffers[0], frags);
+			aq_ring_tx_append_buffs(ring, buffers, frags);
 
 			err = self->aq_hw_ops.hw_ring_tx_xmit(self->aq_hw,
 							      ring, frags);
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 4c40644..042976d 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -275,6 +275,8 @@ int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
 
 int aq_ring_rx_fill(struct aq_ring_s *self)
 {
+	unsigned int pages_order = fls(AQ_CFG_RX_FRAME_MAX / PAGE_SIZE +
+		(AQ_CFG_RX_FRAME_MAX % PAGE_SIZE ? 1 : 0)) - 1;
 	struct aq_ring_buff_s *buff = NULL;
 	int err = 0;
 	int i = 0;
@@ -287,7 +289,7 @@ int aq_ring_rx_fill(struct aq_ring_s *self)
 		buff->len = AQ_CFG_RX_FRAME_MAX;
 
 		buff->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
-					 __GFP_COMP, 0);
+					 __GFP_COMP, pages_order);
 		if (!buff->page) {
 			err = -ENOMEM;
 			goto err_exit;
-- 
2.7.4
