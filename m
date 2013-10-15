From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [net-next REPOST] 8390 ei_debug : Reenable the use of debugging in 8390 based chips
Date: Mon, 14 Oct 2013 22:46:01 -0400
Message-ID: <1381805161-18833-1-git-send-email-tedheadster@gmail.com>
Cc: Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:58942 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab3JOCqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 22:46:08 -0400
Received: by mail-qa0-f42.google.com with SMTP id w8so2978454qac.8
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 19:46:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet boards based on the 8390 chip had an '#ifdef notdef' disabling the
use of the debug variable ei_debug. Reenable it for those of us who still
occasionally use it.

Also handle the case of the 'ne' driver which uses 8390p.o rather than
8390.o. In that case ei_debug is aliased to eip_debug so it doesn't clash
with the previously exported ei_debug.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 drivers/net/ethernet/8390/8390.h     |    5 ++++-
 drivers/net/ethernet/8390/8390p.c    |    1 +
 drivers/net/ethernet/8390/axnet_cs.c |    5 -----
 drivers/net/ethernet/8390/lib8390.c  |    8 ++++++--
 drivers/net/ethernet/8390/ne.c       |    1 +
 5 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/8390/8390.h b/drivers/net/ethernet/8390/8390.h
index 2923c51..e6c547d 100644
--- a/drivers/net/ethernet/8390/8390.h
+++ b/drivers/net/ethernet/8390/8390.h
@@ -21,7 +21,10 @@ struct e8390_pkt_hdr {
   unsigned short count; /* header + packet length in bytes */
 };
 
-#ifdef notdef
+#if (defined EI_DEBUG && defined EIP_DEBUG)
+#define ei_debug eip_debug
+extern int eip_debug;
+#elif (defined EI_DEBUG && ! defined EIP_DEBUG)
 extern int ei_debug;
 #else
 #define ei_debug 1
diff --git a/drivers/net/ethernet/8390/8390p.c b/drivers/net/ethernet/8390/8390p.c
index e8fc2e8..0a27dea 100644
--- a/drivers/net/ethernet/8390/8390p.c
+++ b/drivers/net/ethernet/8390/8390p.c
@@ -7,6 +7,7 @@ static const char version[] =
 #define ei_outb(_v, _p)	outb(_v, _p)
 #define ei_inb_p(_p)	inb_p(_p)
 #define ei_outb_p(_v, _p) outb_p(_v, _p)
+#define EIP_DEBUG 1
 
 #include "lib8390.c"
 
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index d801c141..581560c 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -810,11 +810,6 @@ module_pcmcia_driver(axnet_cs_driver);
 #define ei_block_input (ei_local->block_input)
 #define ei_get_8390_hdr (ei_local->get_8390_hdr)
 
-/* use 0 for production, 1 for verification, >2 for debug */
-#ifndef ei_debug
-int ei_debug = 1;
-#endif
-
 /* Index to functions. */
 static void ei_tx_intr(struct net_device *dev);
 static void ei_tx_err(struct net_device *dev);
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index b329f5c..889d1fd 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -100,8 +100,12 @@
 #define ei_get_8390_hdr (ei_local->get_8390_hdr)
 
 /* use 0 for production, 1 for verification, >2 for debug */
-#ifndef ei_debug
-int ei_debug = 1;
+#if (defined EI_DEBUG && defined EIP_DEBUG)
+int eip_debug = EI_DEBUG;
+EXPORT_SYMBOL(eip_debug);
+#elif (defined EI_DEBUG && ! defined EIP_DEBUG)
+int ei_debug = EI_DEBUG;
+EXPORT_SYMBOL(ei_debug);
 #endif
 
 /* Index to functions. */
diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index b2e8405..4136b31 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -54,6 +54,7 @@ static const char version2[] =
 #include <linux/platform_device.h>
 
 #include <asm/io.h>
+#define EIP_DEBUG 1
 
 #include "8390.h"
 
-- 
1.7.2.5
