From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: Re: forcedeth unknown events 0x21
Date: Mon, 22 Dec 2003 04:39:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FE6678B.5070006@gmx.net>
References: <Pine.LNX.4.58.0312180952100.21042@kiku.itsise>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070200010402080907090901"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Madis Janson <madis@ats.cyber.ee>
In-Reply-To: <Pine.LNX.4.58.0312180952100.21042@kiku.itsise>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070200010402080907090901
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Madis Janson wrote:
> When trying forcedeth_2_6_patch_v19.txt, i got the following message
> fastly repeating after ifup eth0:
> 
> "eth0: received irq with unknown events 0x21. Please report"
> 
> and it didn't work eighter (ifup just stalled).
> 
> kernel:
> 
> 2.6.0 release + patches:
> http://www.held.org.il/patches/patch-lirc-2.6.0-test9-oh.diff.bz2
> http://www.hailfinger.org/carldani/linux/patches/forcedeth/forcedeth_2_6_patch_v19.txt

Please try the attached patch on top of it and report back if it works.


Carl-Daniel
-- 
http://www.hailfinger.org/

--------------070200010402080907090901
Content-Type: text/plain;
 name="forcedeth_19test1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="forcedeth_19test1.diff"

===== drivers/net/forcedeth.c 1.8 vs edited =====
--- 1.8/drivers/net/forcedeth.c	Mon Dec  8 17:58:03 2003
+++ edited/drivers/net/forcedeth.c	Mon Dec 22 04:05:36 2003
@@ -127,6 +127,7 @@
 #define NVREG_IRQSTAT_MIIEVENT	0x040
 #define NVREG_IRQSTAT_MASK		0x1ff
 	NvRegIrqMask = 0x004,
+#define NVREG_IRQ_RX_ERR		0x0001
 #define NVREG_IRQ_RX			0x0002
 #define NVREG_IRQ_RX_NOBUF		0x0004
 #define NVREG_IRQ_TX_ERR		0x0008
@@ -136,7 +137,7 @@
 #define NVREG_IRQ_TX1			0x0100
 #define NVREG_IRQMASK_WANTED_1		0x005f
 #define NVREG_IRQMASK_WANTED_2		0x0147
-#define NVREG_IRQ_UNKNOWN		(~(NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR|NVREG_IRQ_TX2|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_TX1))
+#define NVREG_IRQ_UNKNOWN		(~(NVREG_IRQ_RX_ERR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR|NVREG_IRQ_TX2|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_TX1))
 
 	NvRegUnknownSetupReg6 = 0x008,
 #define NVREG_UNKSETUP6_VAL		3
@@ -1056,7 +1057,7 @@
 			spin_unlock(&np->lock);
 		}
 
-		if (events & (NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF)) {
+		if (events & (NVREG_IRQ_RX_ERR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF)) {
 			rx_process(dev);
 			if (alloc_rx(dev)) {
 				spin_lock(&np->lock);
@@ -1071,6 +1072,9 @@
 			link_irq(dev);
 			spin_unlock(&np->lock);
 		}
+		if (events & (NVREG_IRQ_RX_ERR)) {
+			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably RX fail.\n",
+						dev->name, events);
 		if (events & (NVREG_IRQ_TX_ERR)) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
 						dev->name, events);

--------------070200010402080907090901--
