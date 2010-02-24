From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: optimize 4k-boundary check when stocking rx pages
Date: Wed, 24 Feb 2010 23:11:19 +0100
Message-ID: <4B85A407.5050800@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1887 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758042Ab0BXWpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 17:45:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small optimization to the code which checks to see if we'd cross
a 4K boundary when stocking RX ring.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
Signed-off-by: Guillaume Morin <guillaume@morinfr.org>

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c0884a9..03f9fc0 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.5.1-1.453"
+#define MYRI10GE_VERSION_STR "1.5.2-1.459"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -1201,6 +1201,9 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 {
 	struct page *page;
 	int idx;
+#if MYRI10GE_ALLOC_SIZE > 4096
+	int end_offset;
+#endif
 
 	if (unlikely(rx->watchdog_needed && !watchdog))
 		return;
@@ -1242,9 +1245,9 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 
 #if MYRI10GE_ALLOC_SIZE > 4096
 		/* don't cross a 4KB boundary */
-		if ((rx->page_offset >> 12) !=
-		    ((rx->page_offset + bytes - 1) >> 12))
-			rx->page_offset = (rx->page_offset + 4096) & ~4095;
+		end_offset = rx->page_offset + bytes - 1;
+		if ((unsigned)(rx->page_offset ^ end_offset) > 4095)
+			rx->page_offset = end_offset & ~4095;
 #endif
 		rx->fill_cnt++;
 


