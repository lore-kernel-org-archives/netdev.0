From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v2 11/12] net: ethernet: aquantia: Fixed memory allocation if AQ_CFG_RX_FRAME_MAX > 1 page.
Date: Sat, 18 Feb 2017 00:07:33 +0300
Message-ID: <c45b44987d24c7aae83c796a3731295317ae83f7.1487365317.git.pavel.belous@aquantia.com>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0059.outbound.protection.outlook.com ([104.47.32.59]:9772
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935081AbdBQVJf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 16:09:35 -0500
In-Reply-To: <cover.1487365317.git.pavel.belous@aquantia.com>
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
index daed4c1..25dc9b4 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -596,9 +596,9 @@ __acquires(&ring->lock)
 
 	do {
 		if (spin_trylock(&ring->header.lock)) {
-			frags = aq_nic_map_skb(self, skb, &buffers[0]);
+			frags = aq_nic_map_skb(self, skb, buffers);
 
-			aq_ring_tx_append_buffs(ring, &buffers[0], frags);
+			aq_ring_tx_append_buffs(ring, buffers, frags);
 
 			err = self->aq_hw_ops.hw_ring_tx_xmit(self->aq_hw,
 							      ring, frags);
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 4c40644..0877625 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -278,6 +278,8 @@ int aq_ring_rx_fill(struct aq_ring_s *self)
 	struct aq_ring_buff_s *buff = NULL;
 	int err = 0;
 	int i = 0;
+	unsigned int pages_order = fls(AQ_CFG_RX_FRAME_MAX / PAGE_SIZE +
+		(AQ_CFG_RX_FRAME_MAX % PAGE_SIZE ? 1 : 0)) - 1;
 
 	for (i = aq_ring_avail_dx(self); i--;
 		self->sw_tail = aq_ring_next_dx(self, self->sw_tail)) {
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
