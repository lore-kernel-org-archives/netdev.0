From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/6] htb: if HTB_HYSTERIS cleanup
Date: Wed, 2 Aug 2006 15:09:43 -0700
Message-ID: <20060802150943.2b5f7de5@dxpl.pdx.osdl.net>
References: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52429 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932274AbWHBWMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 18:12:24 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the conditional compilation around HTB_HYSTERSIS
since code was splitting mid expression.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/sched/sch_htb.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c0b80b7..d8c1a6b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -483,6 +483,20 @@ static void htb_deactivate_prios(struct 
 		htb_remove_class_from_row(q,cl,mask);
 }
 
+#if HTB_HYSTERESIS
+static inline long htb_lowater(const struct htb_class *cl)
+{
+	return cl->cmode != HTB_CANT_SEND ? -cl->cbuffer : 0;
+}
+static inline long htb_hiwater(const struct htb_class *cl)
+{
+	return cl->cmode == HTB_CAN_SEND ? -cl->buffer : 0;
+}
+#else
+#define htb_lowater(cl)	(0)
+#define htb_hiwater(cl)	(0)
+#endif
+
 /**
  * htb_class_mode - computes and returns current class mode
  *
@@ -499,19 +513,12 @@ htb_class_mode(struct htb_class *cl,long
 {
     long toks;
 
-    if ((toks = (cl->ctokens + *diff)) < (
-#if HTB_HYSTERESIS
-	    cl->cmode != HTB_CANT_SEND ? -cl->cbuffer :
-#endif
-       	    0)) {
+    if ((toks = (cl->ctokens + *diff)) < htb_lowater(cl)) {
 	    *diff = -toks;
 	    return HTB_CANT_SEND;
     }
-    if ((toks = (cl->tokens + *diff)) >= (
-#if HTB_HYSTERESIS
-	    cl->cmode == HTB_CAN_SEND ? -cl->buffer :
-#endif
-	    0))
+
+    if ((toks = (cl->tokens + *diff)) >= htb_hiwater(cl))
 	    return HTB_CAN_SEND;
 
     *diff = -toks;
-- 
1.4.0

