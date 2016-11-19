From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2: use READ_ONCE() instead of barrier()
Date: Sat, 19 Nov 2016 14:57:11 -0800
Message-ID: <1479596231.8455.354.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Rasesh Mody <rasesh.mody@cavium.com>,
        Harish Patil <harish.patil@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36160 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752941AbcKSW5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 17:57:14 -0500
Received: by mail-pf0-f196.google.com with SMTP id c4so13164436pfb.3
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2016 14:57:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

barrier() is a big hammer compared to READ_ONCE(),
and requires comments explaining what is protected.

READ_ONCE() is more precise and compiler should generate
better overall code.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9960a9249dc0d0c8fb3494989e882a4c96e64970..d5d1026be4b70a320c48af7545a1891c74e19a47 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -254,13 +254,10 @@ static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_tx_ring_info *txr)
 {
 	u32 diff;
 
-	/* Tell compiler to fetch tx_prod and tx_cons from memory. */
-	barrier();
-
 	/* The ring uses 256 indices for 255 entries, one of them
 	 * needs to be skipped.
 	 */
-	diff = txr->tx_prod - txr->tx_cons;
+	diff = READ_ONCE(txr->tx_prod) - READ_ONCE(txr->tx_cons);
 	if (unlikely(diff >= BNX2_TX_DESC_CNT)) {
 		diff &= 0xffff;
 		if (diff == BNX2_TX_DESC_CNT)
@@ -2839,10 +2836,8 @@ bnx2_get_hw_tx_cons(struct bnx2_napi *bnapi)
 {
 	u16 cons;
 
-	/* Tell compiler that status block fields can change. */
-	barrier();
-	cons = *bnapi->hw_tx_cons_ptr;
-	barrier();
+	cons = READ_ONCE(*bnapi->hw_tx_cons_ptr);
+
 	if (unlikely((cons & BNX2_MAX_TX_DESC_CNT) == BNX2_MAX_TX_DESC_CNT))
 		cons++;
 	return cons;
@@ -3141,10 +3136,8 @@ bnx2_get_hw_rx_cons(struct bnx2_napi *bnapi)
 {
 	u16 cons;
 
-	/* Tell compiler that status block fields can change. */
-	barrier();
-	cons = *bnapi->hw_rx_cons_ptr;
-	barrier();
+	cons = READ_ONCE(*bnapi->hw_rx_cons_ptr);
+
 	if (unlikely((cons & BNX2_MAX_RX_DESC_CNT) == BNX2_MAX_RX_DESC_CNT))
 		cons++;
 	return cons;
