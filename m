From: Johannes Erdfelt <johannes@erdfelt.com>
Subject: [RFC] tulip VLAN support
Date: Wed, 5 Jan 2005 11:34:25 -0800
Message-ID: <20050105193425.GY18847@sventech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I recently upgraded a system running a 2.4 kernel to a 2.6 based
distribution (Fedora Core 2, 2.6.9-1.6_FC2 kernel) and ran into a
problem using NFS. After spending some tracking it down, I found out it
was an MTU problem and then remembered I had the same problem a couple
of years ago with the 2.4 kernels I was running.

The problem is that the tulip driver doesn't handle 802.1q tags
correctly. Since the VLAN tagging adds 4 bytes to the beginning of the
frame, this can cause frame sizes to be too large for the driver (chip?)
and the packets get dropped.

I've taken the 2.4 patch I found (I forget who developed it, sorry) and
ported it to the 2.6 driver. The patch is relative to the 2.6.9-1.6_FC2
kernel for FC2, but I suspect it will apply to other kernels relatively
cleanly.

Before I rediff the patch against the BK tree and double check all of
the tulip variants are updated correctly as well, is there any interest
in accepting a patch like this?

The 2.4 patch worked for a couple of years for me with no problems and
this 2.6 patch has worked for over a week now with no problems. However,
I'm worried that there is a reason why a similar patch has not been
applied already.

JE

diff -ur linux-2.6.9.orig/drivers/net/tulip/interrupt.c linux-2.6.9/drivers/net/tulip/interrupt.c
--- linux-2.6.9.orig/drivers/net/tulip/interrupt.c	2004-10-18 14:55:36.000000000 -0700
+++ linux-2.6.9/drivers/net/tulip/interrupt.c	2004-12-30 15:23:51.085876693 -0800
@@ -155,9 +155,9 @@
                        if (--rx_work_limit < 0)
                                goto not_done;
  
-                       if ((status & 0x38008300) != 0x0300) {
-                               if ((status & 0x38000300) != 0x0300) {
-                                /* Ingore earlier buffers. */
+                       if ((status & (0x38000000 | RxDescFatalErr | RxWholePkt)) != RxWholePkt) {
+                               if ((status & (0x38000000 | RxWholePkt)) != RxWholePkt) {
+                                /* Ignore earlier buffers. */
                                        if ((status & 0xffff) != 0x7fff) {
                                                if (tulip_debug > 1)
                                                        printk(KERN_WARNING "%s: Oversized Ethernet frame "
@@ -182,10 +182,10 @@
                                struct sk_buff *skb;
   
 #ifndef final_version
-                               if (pkt_len > 1518) {
+                               if (pkt_len > 1522) {
                                        printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
                                               dev->name, pkt_len, pkt_len);
-                                       pkt_len = 1518;
+                                       pkt_len = 1522;
                                        tp->stats.rx_length_errors++;
                                }
 #endif
@@ -378,9 +378,9 @@
 				   dev->name, entry, status);
 		if (--rx_work_limit < 0)
 			break;
-		if ((status & 0x38008300) != 0x0300) {
-			if ((status & 0x38000300) != 0x0300) {
-				/* Ingore earlier buffers. */
+                if ((status & (0x38000000 | RxDescFatalErr | RxWholePkt)) != RxWholePkt) {
+                        if ((status & (0x38000000 | RxWholePkt)) != RxWholePkt) {
+				/* Ignore earlier buffers. */
 				if ((status & 0xffff) != 0x7fff) {
 					if (tulip_debug > 1)
 						printk(KERN_WARNING "%s: Oversized Ethernet frame "
@@ -405,10 +405,10 @@
 			struct sk_buff *skb;
 
 #ifndef final_version
-			if (pkt_len > 1518) {
+			if (pkt_len > 1522) {
 				printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
 					   dev->name, pkt_len, pkt_len);
-				pkt_len = 1518;
+				pkt_len = 1522;
 				tp->stats.rx_length_errors++;
 			}
 #endif
diff -ur linux-2.6.9.orig/drivers/net/tulip/tulip.h linux-2.6.9/drivers/net/tulip/tulip.h
--- linux-2.6.9.orig/drivers/net/tulip/tulip.h	2004-10-18 14:55:21.000000000 -0700
+++ linux-2.6.9/drivers/net/tulip/tulip.h	2004-12-30 15:20:21.432056171 -0800
@@ -191,7 +191,7 @@
 
 enum desc_status_bits {
 	DescOwned = 0x80000000,
-	RxDescFatalErr = 0x8000,
+	RxDescFatalErr = 0x4842,
 	RxWholePkt = 0x0300,
 };
 
@@ -259,7 +259,7 @@
 #define RX_RING_SIZE	128 
 #define MEDIA_MASK     31
 
-#define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer. */
+#define PKT_BUF_SZ		1540	/* Size of each temporary Rx buffer. */
 
 #define TULIP_MIN_CACHE_LINE	8	/* in units of 32-bit words */
 
diff -ur linux-2.6.9.orig/drivers/net/tulip/tulip_core.c linux-2.6.9/drivers/net/tulip/tulip_core.c
--- linux-2.6.9.orig/drivers/net/tulip/tulip_core.c	2004-10-18 14:54:32.000000000 -0700
+++ linux-2.6.9/drivers/net/tulip/tulip_core.c	2004-12-30 15:19:42.424578510 -0800
@@ -70,7 +70,7 @@
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
 	|| defined(__sparc_) || defined(__ia64__) \
 	|| defined(__sh__) || defined(__mips__)
-static int rx_copybreak = 1518;
+static int rx_copybreak = 1522;
 #else
 static int rx_copybreak = 100;
 #endif
