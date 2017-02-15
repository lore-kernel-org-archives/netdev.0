From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next 11/13] net: ethernet: aquantia: Refactoring buffers copying.
Date: Wed, 15 Feb 2017 23:01:19 +0300
Message-ID: <de4d3c34fac8c7bbbb614f776ca1255fd6aa03a6.1487187192.git.pavel.belous@aquantia.com>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0063.outbound.protection.outlook.com ([104.47.40.63]:44304
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751430AbdBOUDn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:03:43 -0500
In-Reply-To: <cover.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This fix simplified copying data to the ring buffer.
Also, there was an error in the code when the second memcpy
is called with zero length. It didn't break the driver, but it's bad.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 25 ++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 4c40644..8ebed0d 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -108,18 +108,19 @@ void aq_ring_tx_append_buffs(struct aq_ring_s *self,
 			     struct aq_ring_buff_s *buffer,
 			     unsigned int buffers)
 {
-	if (likely(self->sw_tail + buffers < self->size)) {
-		memcpy(&self->buff_ring[self->sw_tail], buffer,
-		       sizeof(buffer[0]) * buffers);
-	} else {
-		unsigned int first_part = self->size - self->sw_tail;
-		unsigned int second_part = buffers - first_part;
-
-		memcpy(&self->buff_ring[self->sw_tail], buffer,
-		       sizeof(buffer[0]) * first_part);
-
-		memcpy(&self->buff_ring[0], &buffer[first_part],
-		       sizeof(buffer[0]) * second_part);
+	int buff_len = min(self->size - self->sw_tail, buffers);
+
+	memcpy(&self->buff_ring[self->sw_tail],
+	       buffer,
+	       sizeof(struct aq_ring_buff_s) * buff_len);
+
+	/* We are in the end of the ring.
+	 *  Copy remains data to beginning of the ring
+	 */
+	if (buffers > buff_len) {
+		memcpy(self->buff_ring,
+		       &buffer[buff_len],
+		       sizeof(struct aq_ring_buff_s) * (buffers - buff_len));
 	}
 }
 
-- 
2.7.4
