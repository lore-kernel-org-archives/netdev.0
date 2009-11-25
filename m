From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH] b44.c box lockup fix (netconsole): ratelimit NAPI poll
	error message
Date: Wed, 25 Nov 2009 22:35:46 +0100
Message-ID: <20091125213546.GA6168@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zambrano@broadcom.com, dave@thedillows.org, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759274AbZKYVfm@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

my OpenWrt MIPSEL ASUS WL-500gP v2 kept locking up during driver
debugging with kobject debugging turned on (when debugging non-working
drivers such as USB, ftdi_sio and usb_audio).
Turns out that it's not very helpful to have a netconsole-deployed
network driver's interrupt handler message spew noise permanently
(see comment in patch).

See
http://bugzilla.kernel.org/show_bug.cgi?id=14691
for background information.

Tested on 2.6.30.9 and working (now normal debug messages manage
to come through, too, yet box still locked up, simply due to excessive
_normal_ log messages such as kobject logging, but that's _expected_
and user-correctable).

checkpatch.pl'd, applies cleanly to -rc8.
Likely -stable candidate material.

r8169 (and perhaps other netconsole-capable drivers?)
might need such a correction, too, if the
                        if (likely(napi_schedule_prep(&tp->napi)))
                                __napi_schedule(&tp->napi);
                        else if (netif_msg_intr(tp)) {
                                printk(KERN_INFO "%s: interrupt %04x in poll\n",
                                dev->name, status);
                        }
is similarly problematic.
BTW: this patch here is to be seen separate from the r8169 interrupt handler
rework as discussed at "r8169: avoid losing MSI interrupts", since even with a
"working" interrupt handler (i.e. one that closes the "new interrupt" race window,
which the one in b44 currently probably doesn't) such error messages
have a fatal feedback loop in the case of netconsole deployment.

Thanks,

Signed-off-by: Andreas Mohr <andi@lisas.de>

--- linux-2.6.30.9/drivers/net/b44.c.orig	2009-11-25 20:49:48.000000000 +0100
+++ linux-2.6.30.9/drivers/net/b44.c	2009-11-25 21:26:34.000000000 +0100
@@ -913,8 +913,18 @@
 			__b44_disable_ints(bp);
 			__napi_schedule(&bp->napi);
 		} else {
-			printk(KERN_ERR PFX "%s: Error, poll already scheduled\n",
-			       dev->name);
+			/* netconsole fix!!:
+			 * without ratelimiting, this message would:
+			 * immediately find its way out to b44 netconsole ->
+			 * new IRQ -> re-encounter failed napi_schedule_prep()
+			 * -> error message -> ad nauseam -> box LOCKUP.
+			 * See thread "r8169: avoid losing MSI interrupts"
+			 * for further inspiration. */
+			if (printk_ratelimit())
+				printk(KERN_ERR PFX
+					"%s: Error, poll already scheduled; "
+					"istat 0x%x, imask 0x%x\n",
+						dev->name, istat, imask);
 		}
 
 irq_ack:
