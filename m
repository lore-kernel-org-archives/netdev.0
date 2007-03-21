From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/4] myri10ge: fix management of >4kB allocated pages
Date: Wed, 21 Mar 2007 19:46:57 +0100
Message-ID: <46017DA1.2050500@myri.com>
References: <45FDA22E.1070805@myri.com> <46017CB8.3060807@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1850 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933603AbXCUSsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 14:48:53 -0400
In-Reply-To: <46017CB8.3060807@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix management of allocated physical pages when the architecture
page size is not 4kB since the firmware cannot cross 4K boundary.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-18 21:14:23.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-21 19:30:38.000000000 +0100
@@ -905,6 +905,14 @@
 		    (rx->page_offset + bytes <= MYRI10GE_ALLOC_SIZE)) {
 			/* we can use part of previous page */
 			get_page(rx->page);
+#if MYRI10GE_ALLOC_SIZE > 4096
+			/* Firmware cannot cross 4K boundary.. */
+			if ((rx->page_offset >> 12) !=
+			    ((rx->page_offset + bytes - 1) >> 12)) {
+				rx->page_offset =
+				    (rx->page_offset + bytes) & ~4095;
+			}
+#endif
 		} else {
 			/* we need a new page */
 			page =


