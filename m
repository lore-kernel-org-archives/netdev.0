From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ath9k: fix a memory leak in ath_rx_tasklet()
Date: Thu, 15 Mar 2012 13:43:29 -0700
Message-ID: <1331844209.19406.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jouni@qca.qualcomm.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Trond Wuellner <trond@chromium.org>,
	Grant Grundler <grundler@chromium.org>,
	Paul Stewart <pstew@chromium.org>,
	netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:33003 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031833Ab2COUne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 16:43:34 -0400
Received: by dajr28 with SMTP id r28so5021941daj.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 13:43:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0d95521ea7 (ath9k: use split rx buffers to get rid of order-1 skb
allocations) added in memory leak in error path.

sc->rx.frag should be cleared after the pskb_expand_head() call, or else
we jump to requeue_drop_frag and leak an skb.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jouni Malinen <jouni@qca.qualcomm.com>
Cc: Felix Fietkau <nbd@openwrt.org>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: Trond Wuellner <trond@chromium.org>
Cc: Grant Grundler <grundler@chromium.org>
Cc: Paul Stewart <pstew@chromium.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/wireless/ath/ath9k/recv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 7e1a91a..e74fc99 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -1917,13 +1917,13 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		if (sc->rx.frag) {
 			int space = skb->len - skb_tailroom(hdr_skb);
 
-			sc->rx.frag = NULL;
-
 			if (pskb_expand_head(hdr_skb, 0, space, GFP_ATOMIC) < 0) {
 				dev_kfree_skb(skb);
 				goto requeue_drop_frag;
 			}
 
+			sc->rx.frag = NULL;
+
 			skb_copy_from_linear_data(skb, skb_put(hdr_skb, skb->len),
 						  skb->len);
 			dev_kfree_skb_any(skb);
