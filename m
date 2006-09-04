From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] Add firmware version printout to wireless-2.6
	(bcm43xx-softmac)
Date: Mon, 04 Sep 2006 17:13:57 -0500
Message-ID: <44FCA525.3040503@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

John,

Please add this patch by Martin Langer to wireless-2.6.

Larry

==============================

This patch prints microcode revision, patchlevel, date and time to
KERN_INFO. Also, version 4.xx microcodes (rev>0x128) will be rejected
by the driver, because they still do not work.

Signed-off-by: Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>
Acked by Michael Buesch
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>


Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2393,6 +2393,33 @@ static int bcm43xx_chip_init(struct bcm4
  	}
  	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */

+	value16 = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				     BCM43xx_UCODE_REVISION);
+
+	dprintk(KERN_INFO PFX "Microcode rev 0x%x, pl 0x%x "
+		"(20%.2i-%.2i-%.2i  %.2i:%.2i:%.2i)\n", value16,
+		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_PATCHLEVEL),
+		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODE_DATE) >> 12) & 0xf,
+		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODE_DATE) >> 8) & 0xf,
+		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_DATE) & 0xff,
+		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_TIME) >> 11) & 0x1f,
+		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_TIME) >> 5) & 0x3f,
+		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_TIME) & 0x1f);
+
+	if ( value16 > 0x128 ) {
+		dprintk(KERN_ERR PFX
+			"Firmware: no support for microcode rev > 0x128\n");
+		err = -1;
+		goto err_release_fw;
+	}
+
  	err = bcm43xx_gpio_init(bcm);
  	if (err)
  		goto err_release_fw;
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -306,6 +306,12 @@
  #define BCM43xx_SBF_TIME_UPDATE		0x10000000
  #define BCM43xx_SBF_80000000		0x80000000 /*FIXME: fix name*/

+/* Microcode */
+#define BCM43xx_UCODE_REVISION          0x0000
+#define BCM43xx_UCODE_PATCHLEVEL        0x0002
+#define BCM43xx_UCODE_DATE              0x0004
+#define BCM43xx_UCODE_TIME              0x0006
+
  /* MicrocodeFlagsBitfield (addr + lo-word values?)*/
  #define BCM43xx_UCODEFLAGS_OFFSET	0x005E
