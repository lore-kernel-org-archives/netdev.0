From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 3/3] gianfar: Remove redundant ops for do_tstamp from xmit()
Date: Fri, 19 Feb 2016 12:47:34 +0200
Message-ID: <1455878854-28290-4-git-send-email-claudiu.manoil@freescale.com>
References: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0140.outbound.protection.outlook.com ([207.46.100.140]:1376
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992847AbcBSKyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 05:54:02 -0500
In-Reply-To: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timestamp BD status updates that can be merged into the
same "do_tstamp" block, no need for extra save/restore
to the BD area.  The code is more readable too.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 090f4f0..6f3d0ba 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2436,15 +2436,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		txbdp_tstamp = txbdp = next_txbd(txbdp, base,
 						 tx_queue->tx_ring_size);
 
-	if (nr_frags == 0) {
-		if (unlikely(do_tstamp)) {
-			u32 lstatus_ts = be32_to_cpu(txbdp_tstamp->lstatus);
-
-			lstatus_ts |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
-			txbdp_tstamp->lstatus = cpu_to_be32(lstatus_ts);
-		} else {
-			lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
-		}
+	if (likely(!nr_frags)) {
+		lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 	} else {
 		u32 lstatus_start = lstatus;
 
@@ -2488,8 +2481,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		bufaddr = be32_to_cpu(txbdp_start->bufPtr);
 		bufaddr += fcb_len;
+
 		lstatus_ts |= BD_LFLAG(TXBD_READY) |
 			      (skb_headlen(skb) - fcb_len);
+		if (!nr_frags)
+			lstatus_ts |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 
 		txbdp_tstamp->bufPtr = cpu_to_be32(bufaddr);
 		txbdp_tstamp->lstatus = cpu_to_be32(lstatus_ts);
-- 
1.7.11.7
