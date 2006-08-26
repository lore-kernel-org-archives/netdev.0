From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] ssb: fix core CC and REV reading
Date: Sat, 26 Aug 2006 13:49:22 +0200
Message-ID: <200608261349.23217.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

Please apply this to wireless-dev.
This is the correct fix for the ChipCommon issue.

--

Fix CoreCode and CoreRev extraction from coreidhi.
And yes, it's ugly. But that's how the device works.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/misc/ssb.c
===================================================================
--- wireless-dev.orig/drivers/misc/ssb.c	2006-08-26 13:34:03.000000000 +0200
+++ wireless-dev/drivers/misc/ssb.c	2006-08-26 13:43:11.000000000 +0200
@@ -643,8 +643,9 @@ int ssb_probe_cores(struct ssb *ssb,
 		goto error;
 
 	idhi = ssb_read32(ssb, SSB_IDHIGH);
-	cc = (idhi & SSB_IDHIGH_CC_MASK) >> SSB_IDHIGH_CC_SHIFT;
-	rev = (idhi & SSB_IDHIGH_RC_MASK);
+	cc = (idhi & SSB_IDHIGH_CC) >> SSB_IDHIGH_CC_SHIFT;
+	rev = (idhi & SSB_IDHIGH_RCLO);
+	rev |= (idhi & SSB_IDHIGH_RCHI) >> SSB_IDHIGH_RCHI_SHIFT;
 
 	ssb->chipcommon_capabilities = 0;
 	ssb->nr_cores = 0;
@@ -716,9 +717,10 @@ int ssb_probe_cores(struct ssb *ssb,
 		core = &(ssb->cores[i]);
 
 		idhi = ssb_read32(ssb, SSB_IDHIGH);
-		core->cc = (idhi & SSB_IDHIGH_CC_MASK) >> SSB_IDHIGH_CC_SHIFT;
-		core->rev = (idhi & SSB_IDHIGH_RC_MASK);
-		core->vendor = (idhi & SSB_IDHIGH_VC_MASK) >> SSB_IDHIGH_VC_SHIFT;
+		core->cc = (idhi & SSB_IDHIGH_CC) >> SSB_IDHIGH_CC_SHIFT;
+		core->rev = (idhi & SSB_IDHIGH_RCLO);
+		core->rev |= (idhi & SSB_IDHIGH_RCHI) >> SSB_IDHIGH_RCHI_SHIFT;
+		core->vendor = (idhi & SSB_IDHIGH_VC) >> SSB_IDHIGH_VC_SHIFT;
 		core->index = i;
 
 		dprintk(KERN_DEBUG PFX "Core %d found: "
Index: wireless-dev/include/linux/ssb.h
===================================================================
--- wireless-dev.orig/include/linux/ssb.h	2006-08-26 13:34:03.000000000 +0200
+++ wireless-dev/include/linux/ssb.h	2006-08-26 13:40:11.000000000 +0200
@@ -100,10 +100,12 @@
 #define  SSB_IDLOW_SSBREV_22	0x00000000 /* <= 2.2 */
 #define  SSB_IDLOW_SSBREV_23	0x10000000 /* 2.3 */
 #define SSB_IDHIGH		0x0FFC     /* SB Identification High */
-#define  SSB_IDHIGH_RC_MASK	0x0000000f /* Revision Code */
-#define  SSB_IDHIGH_CC_MASK	0x0000fff0 /* Core Code */
+#define  SSB_IDHIGH_RCLO	0x0000000F /* Revision Code (low part) */
+#define  SSB_IDHIGH_CC		0x00008FF0 /* Core Code */
 #define  SSB_IDHIGH_CC_SHIFT	4
-#define  SSB_IDHIGH_VC_MASK	0xffff0000 /* Vendor Code */
+#define  SSB_IDHIGH_RCHI	0x00007000 /* Revision Code (high part) */
+#define  SSB_IDHIGH_RCHI_SHIFT	8	   /* yes, shift 8 is right */
+#define  SSB_IDHIGH_VC		0xFFFF0000 /* Vendor Code */
 #define  SSB_IDHIGH_VC_SHIFT	16
 
 /* SPROM shadow area. If not otherwise noted, fields are


-- 
Greetings Michael.
