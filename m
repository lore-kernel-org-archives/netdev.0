From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] EtherExpress16: fix printing timed out status
Date: Sun, 28 Dec 2008 22:18:01 +0100
Message-ID: <4957ED09.2040806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: philb@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:19136 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755528AbYL1VR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2008 16:17:58 -0500
Received: by ey-out-2122.google.com with SMTP id 22so501511eye.37
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2008 13:17:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in drivers/net/eexpress.c:558, function unstick_cu()

while (!SCB_complete(rsst=scb_status(dev))) {
	...
	if (...)
		printk(KERN_WARNING "%s: Reset timed out status %04x, retrying...\n",
                                                       dev->name,rsst);
}

but this will become 

while (!((rsst = scb_status(dev) & 0x8000) != 0) ...

because of the macro:

#define SCB_complete(s) ((s&0x8000)!=0)

so rsst can only become either 0x8000 or 0, but in the latter case the loop ends,
I think the wrong timed out status is printed. This also cleans up similar macros.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---

 drivers/net/eexpress.h |   56 ++++++++++++++++++++++++------------------------
 1 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/drivers/net/eexpress.h b/drivers/net/eexpress.h
index 707df3f..dc9c6ea 100644
--- a/drivers/net/eexpress.h
+++ b/drivers/net/eexpress.h
@@ -68,17 +68,17 @@
  */
 
 /* these functions take the SCB status word and test the relevant status bit */
-#define SCB_complete(s) ((s&0x8000)!=0)
-#define SCB_rxdframe(s) ((s&0x4000)!=0)
-#define SCB_CUdead(s)   ((s&0x2000)!=0)
-#define SCB_RUdead(s)   ((s&0x1000)!=0)
-#define SCB_ack(s)      (s & 0xf000)
+#define SCB_complete(s) (((s) & 0x8000) != 0)
+#define SCB_rxdframe(s) (((s) & 0x4000) != 0)
+#define SCB_CUdead(s)   (((s) & 0x2000) != 0)
+#define SCB_RUdead(s)   (((s) & 0x1000) != 0)
+#define SCB_ack(s)      ((s) & 0xf000)
 
 /* Command unit status: 0=idle, 1=suspended, 2=active */
-#define SCB_CUstat(s)   ((s&0x0300)>>8)
+#define SCB_CUstat(s)   (((s)&0x0300)>>8)
 
 /* Receive unit status: 0=idle, 1=suspended, 2=out of resources, 4=ready */
-#define SCB_RUstat(s)   ((s&0x0070)>>4)
+#define SCB_RUstat(s)   (((s)&0x0070)>>4)
 
 /* SCB commands */
 #define SCB_CUnop       0x0000
@@ -98,18 +98,18 @@
  * Command block defines
  */
 
-#define Stat_Done(s)    ((s&0x8000)!=0)
-#define Stat_Busy(s)    ((s&0x4000)!=0)
-#define Stat_OK(s)      ((s&0x2000)!=0)
-#define Stat_Abort(s)   ((s&0x1000)!=0)
-#define Stat_STFail     ((s&0x0800)!=0)
-#define Stat_TNoCar(s)  ((s&0x0400)!=0)
-#define Stat_TNoCTS(s)  ((s&0x0200)!=0)
-#define Stat_TNoDMA(s)  ((s&0x0100)!=0)
-#define Stat_TDefer(s)  ((s&0x0080)!=0)
-#define Stat_TColl(s)   ((s&0x0040)!=0)
-#define Stat_TXColl(s)  ((s&0x0020)!=0)
-#define Stat_NoColl(s)  (s&0x000f)
+#define Stat_Done(s)    (((s) & 0x8000) != 0)
+#define Stat_Busy(s)    (((s) & 0x4000) != 0)
+#define Stat_OK(s)      (((s) & 0x2000) != 0)
+#define Stat_Abort(s)   (((s) & 0x1000) != 0)
+#define Stat_STFail     (((s) & 0x0800) != 0)
+#define Stat_TNoCar(s)  (((s) & 0x0400) != 0)
+#define Stat_TNoCTS(s)  (((s) & 0x0200) != 0)
+#define Stat_TNoDMA(s)  (((s) & 0x0100) != 0)
+#define Stat_TDefer(s)  (((s) & 0x0080) != 0)
+#define Stat_TColl(s)   (((s) & 0x0040) != 0)
+#define Stat_TXColl(s)  (((s) & 0x0020) != 0)
+#define Stat_NoColl(s)  ((s) & 0x000f)
 
 /* Cmd_END will end AFTER the command if this is the first
  * command block after an SCB_CUstart, but BEFORE the command
@@ -136,16 +136,16 @@
  * Frame Descriptor (Receive block) defines
  */
 
-#define FD_Done(s)  ((s&0x8000)!=0)
-#define FD_Busy(s)  ((s&0x4000)!=0)
-#define FD_OK(s)    ((s&0x2000)!=0)
+#define FD_Done(s)  (((s) & 0x8000) != 0)
+#define FD_Busy(s)  (((s) & 0x4000) != 0)
+#define FD_OK(s)    (((s) & 0x2000) != 0)
 
-#define FD_CRC(s)   ((s&0x0800)!=0)
-#define FD_Align(s) ((s&0x0400)!=0)
-#define FD_Resrc(s) ((s&0x0200)!=0)
-#define FD_DMA(s)   ((s&0x0100)!=0)
-#define FD_Short(s) ((s&0x0080)!=0)
-#define FD_NoEOF(s) ((s&0x0040)!=0)
+#define FD_CRC(s)   (((s) & 0x0800) != 0)
+#define FD_Align(s) (((s) & 0x0400) != 0)
+#define FD_Resrc(s) (((s) & 0x0200) != 0)
+#define FD_DMA(s)   (((s) & 0x0100) != 0)
+#define FD_Short(s) (((s) & 0x0080) != 0)
+#define FD_NoEOF(s) (((s) & 0x0040) != 0)
 
 struct rfd_header {
 	volatile unsigned long flags;

