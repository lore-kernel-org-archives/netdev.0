From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 12:08:50 -0600
Message-ID: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
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

The PCI-E modifications to bcm43xx do not set up the interrupt vector
correctly. Tested with BCM4311 (PCI-E) on x86_64 and BCM4306 (PCI) on i386.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

This fix should be applied to wireless-2.6 _AND_ pushed upstream to
2.6.20-rcX. Without this patch, none of the PCI-E interfaces will work.
This version incorporates Michael Buesch's comments, and forgoes some
code clean-ups that were in the first version/

Larry


Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2704,8 +2704,8 @@ static int bcm43xx_probe_cores(struct bc
 		sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
 
 		/* extract core_id, core_rev, core_vendor */
-		core_id = (sb_id_hi & 0xFFF0) >> 4;
-		core_rev = (sb_id_hi & 0xF);
+		core_id = (sb_id_hi & 0x8FF0) >> 4;
+		core_rev = ((sb_id_hi & 0xF) | ((sb_id_hi & 0x7000) >> 8));
 		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
 		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x\n",
@@ -2876,7 +2876,10 @@ static int bcm43xx_wireless_core_init(st
 		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		sbimconfiglow |= 0x32;
+		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
+			sbimconfiglow |= 0x32;
+		else
+			sbimconfiglow |= 0x53;
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
 	}
 
@@ -3080,7 +3083,7 @@ static int bcm43xx_setup_backplane_pci_c
 	if (err)
 		goto out;
 
-	if (bcm->current_core->rev < 6 ||
+	if (bcm->current_core->rev < 6 &&
 		bcm->current_core->id == BCM43xx_COREID_PCI) {
 		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
 		value |= (1 << backplane_flag_nr);

---
