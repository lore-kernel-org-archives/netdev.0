From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/3] myri10ge: fix management of the firmware 4KB boundary
 crossing restriction
Date: Tue, 10 Apr 2007 21:21:08 +0200
Message-ID: <461BE3A4.9080205@myri.com>
References: <461BE372.2000600@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:2008 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753107AbXDJTWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 15:22:10 -0400
In-Reply-To: <461BE372.2000600@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simpler way of dealing with the firmware 4KB boundary crossing
restriction for rx buffers.  This fixes a variety of memory
corruption issues when using an "uncommon" MTU with a 16KB
page size.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-04-06 09:05:17.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-04-10 21:03:59.000000000 +0200
@@ -900,19 +900,9 @@
 	/* try to refill entire ring */
 	while (rx->fill_cnt != (rx->cnt + rx->mask + 1)) {
 		idx = rx->fill_cnt & rx->mask;
-
-		if ((bytes < MYRI10GE_ALLOC_SIZE / 2) &&
-		    (rx->page_offset + bytes <= MYRI10GE_ALLOC_SIZE)) {
+		if (rx->page_offset + bytes <= MYRI10GE_ALLOC_SIZE) {
 			/* we can use part of previous page */
 			get_page(rx->page);
-#if MYRI10GE_ALLOC_SIZE > 4096
-			/* Firmware cannot cross 4K boundary.. */
-			if ((rx->page_offset >> 12) !=
-			    ((rx->page_offset + bytes - 1) >> 12)) {
-				rx->page_offset =
-				    (rx->page_offset + bytes) & ~4095;
-			}
-#endif
 		} else {
 			/* we need a new page */
 			page =
@@ -941,6 +931,13 @@
 
 		/* start next packet on a cacheline boundary */
 		rx->page_offset += SKB_DATA_ALIGN(bytes);
+
+#if MYRI10GE_ALLOC_SIZE > 4096
+		/* don't cross a 4KB boundary */
+		if ((rx->page_offset >> 12) !=
+		    ((rx->page_offset + bytes - 1) >> 12))
+			rx->page_offset = (rx->page_offset + 4096) & ~4095;
+#endif
 		rx->fill_cnt++;
 
 		/* copy 8 descriptors to the firmware at a time */


