From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/5] [IrDA] stir4200 fixes
Date: Mon, 03 Dec 2007 10:28:35 +0100
Message-ID: <20071203093053.767931752@sortiz.org>
References: <20071203092831.724254969@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=stir4200.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The attached patch observes the stir4200 fifo size and will clear the fifo, if
the size is increasing, while it should be transmitting bytes

From: Olaf Hartmann <olaf.hartmann-kAcfE3m5wwkaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

---
 drivers/net/irda/stir4200.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: net-2.6/drivers/net/irda/stir4200.c
===================================================================
--- net-2.6.orig/drivers/net/irda/stir4200.c	2007-11-25 05:53:43.000000000 +0100
+++ net-2.6/drivers/net/irda/stir4200.c	2007-11-26 02:16:12.000000000 +0100
@@ -142,9 +142,6 @@
 };
 
 enum StirFifoCtlMask {
-	FIFOCTL_EOF = 0x80,
-	FIFOCTL_UNDER = 0x40,
-	FIFOCTL_OVER = 0x20,
 	FIFOCTL_DIR = 0x10,
 	FIFOCTL_CLR = 0x08,
 	FIFOCTL_EMPTY = 0x04,
@@ -594,9 +591,10 @@
 {
 	int err;
 	unsigned long count, status;
+	unsigned long prev_count = 0x1fff;
 
 	/* Read FIFO status and count */
-	for(;;) {
+	for (;; prev_count = count) {
 		err = read_reg(stir, REG_FIFOCTL, stir->fifo_status, 
 				   FIFO_REGS_SIZE);
 		if (unlikely(err != FIFO_REGS_SIZE)) {
@@ -629,6 +627,10 @@
 		if (space >= 0 && STIR_FIFO_SIZE - 4 > space + count)
 			return 0;
 
+		/* queue confused */
+		if (prev_count < count)
+			break;
+
 		/* estimate transfer time for remaining chars */
 		msleep((count * 8000) / stir->speed);
 	}

-- 


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
