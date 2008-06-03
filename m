From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 2/2] Change HTB_HYSTERESIS to a runtime parameter
	htb_hysteresis.
Date: Tue, 03 Jun 2008 16:06:32 +0200
Message-ID: <1212501992.13164.33.camel@localhost.localdomain>
References: <1212501803.13164.27.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Martin Devera <devik@cdi.cz>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56444 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbYFCObO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 10:31:14 -0400
In-Reply-To: <1212501803.13164.27.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add a htb_hysteresis parameter to htb_sch.ko and by sysfs magic make
it runtime adjustable via /sys/module/sch_htb/parameters/htb_hysteresis
mode 640.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 net/sched/sch_htb.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 9134f02..6807c97 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -28,6 +28,7 @@
  * $Id: sch_htb.c,v 1.25 2003/12/07 11:08:25 devik Exp devik $
  */
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -53,13 +54,17 @@
 */
 
 #define HTB_HSIZE 16		/* classid hash size */
-#define HTB_HYSTERESIS 0	/* whether to use mode hysteresis for speedup */
+static int htb_hysteresis __read_mostly = 0; /* whether to use mode hysteresis for speedup */
 #define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
 
 #if HTB_VER >> 16 != TC_HTB_PROTOVER
 #error "Mismatched sch_htb.c and pkt_sch.h"
 #endif
 
+/* Module parameter and sysfs export */
+module_param    (htb_hysteresis, int, 0640);
+MODULE_PARM_DESC(htb_hysteresis, "Hysteresis mode, less CPU load, less accurate");
+
 /* used internaly to keep status of single class */
 enum htb_cmode {
 	HTB_CANT_SEND,		/* class can't send and can't borrow */
@@ -462,19 +467,21 @@ static void htb_deactivate_prios(struct htb_sched *q, struct htb_class *cl)
 		htb_remove_class_from_row(q, cl, mask);
 }
 
-#if HTB_HYSTERESIS
 static inline long htb_lowater(const struct htb_class *cl)
 {
-	return cl->cmode != HTB_CANT_SEND ? -cl->cbuffer : 0;
+	if (htb_hysteresis)
+		return cl->cmode != HTB_CANT_SEND ? -cl->cbuffer : 0;
+	else
+		return 0;
 }
 static inline long htb_hiwater(const struct htb_class *cl)
 {
-	return cl->cmode == HTB_CAN_SEND ? -cl->buffer : 0;
+	if (htb_hysteresis)
+		return cl->cmode == HTB_CAN_SEND ? -cl->buffer : 0;
+	else
+		return 0;
 }
-#else
-#define htb_lowater(cl)	(0)
-#define htb_hiwater(cl)	(0)
-#endif
+
 
 /**
  * htb_class_mode - computes and returns current class mode
-- 
1.5.4.2


