From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH v2] gianfar: prevent fragmentation in DSA environments
Date: Mon, 22 Aug 2016 15:56:38 +0200
Message-ID: <1471874198-15321-1-git-send-email-zefir.kurtisi@neratec.com>
References: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: zefir.kurtisi@neratec.com, claudiu.manoil@freescale.com,
        andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:62615 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754926AbcHVN5x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 09:57:53 -0400
In-Reply-To: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eTSEC register MRBLR defines the maximum space in
the RX buffers and is set to 1536 by gianfar. This
reasonably covers the common use case where the MTU
is kept at default 1500. In that case, the largest
Ethernet frame size of 1518 plus an optional
GMAC_FCB_LEN of 8, and an additional padding of 8
to handle FSL_GIANFAR_DEV_HAS_TIMER totals to 1534
and nicely fit within the chosen MRBLR.

Alas, if the eTSEC is attached to a DSA enabled switch,
the (E)DSA header extension (4 or 8 bytes) causes every
maximum sized frame to be fragmented by the hardware.

This patch increases the maximum RX buffer size by 8
and rounds up to the next multiple of 64, which the
hardware's defines as RX buffer granularity.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/ethernet/freescale/gianfar.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Changes to v1:
* used roundup() for better readability of size increase
  (as suggested by Andrew Lunn)
* updated commmit log explaining what causes the S/G
  to kick in

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 373fd09..6e8a9c8 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -100,7 +100,8 @@ extern const char gfar_driver_version[];
 #define DEFAULT_RX_LFC_THR  16
 #define DEFAULT_LFC_PTVVAL  4
 
-#define GFAR_RXB_SIZE 1536
+/* prevent fragmenation by HW in DSA environments */
+#define GFAR_RXB_SIZE roundup(1536 + 8, 64)
 #define GFAR_SKBFRAG_SIZE (RXBUF_ALIGNMENT + GFAR_RXB_SIZE \
 			  + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 #define GFAR_RXB_TRUESIZE 2048
-- 
2.7.4
