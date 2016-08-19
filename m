From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH] gianfar: prevent fragmentation in DSA environments
Date: Fri, 19 Aug 2016 11:16:14 +0200
Message-ID: <1471598174-16938-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: claudiu.manoil@freescale.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:20214 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750850AbcHSJZD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 05:25:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eTSEC register MRBLR defines the maximum space in
the RX buffers and is set to 1536 by gianfar. This
reasonably covers the common use case where the MTU
is kept at default 1500.

Alas, if the eTSEC is attached to a DSA enabled switch,
the DSA header extension causes every maximum sized
frame to be fragmented by the hardware (1536 + 4).

This patch increases the maximum RX buffer size by
RBUF_ALIGNMENT (64) octets. Since the driver uses a
half-page memory schema, this change does not
increase allocated memory but allows the hardware to
use 1600 bytes of the totally available 2048.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/ethernet/freescale/gianfar.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 373fd09..02b794b 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -100,7 +100,8 @@ extern const char gfar_driver_version[];
 #define DEFAULT_RX_LFC_THR  16
 #define DEFAULT_LFC_PTVVAL  4
 
-#define GFAR_RXB_SIZE 1536
+/* prevent fragmenation by HW in DSA environments */
+#define GFAR_RXB_SIZE (1536 + RXBUF_ALIGNMENT)
 #define GFAR_SKBFRAG_SIZE (RXBUF_ALIGNMENT + GFAR_RXB_SIZE \
 			  + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 #define GFAR_RXB_TRUESIZE 2048
-- 
2.7.4
