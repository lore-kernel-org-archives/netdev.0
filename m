From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: Re: forcedeth received irq with unknown events
Date: Thu, 29 Apr 2004 15:24:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40910211.40301@gmx.net>
References: <20040429143006.4f8b5df0.dn.tlp@gmx.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040705010704050401040601"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Peter <dn.tlp@gmx.net>
In-Reply-To: <20040429143006.4f8b5df0.dn.tlp@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040705010704050401040601
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Simon Peter wrote:
> Hi there!
> 
> Since i plugged the DSL-Modem directly to my onboard nForce2 network
> card (it's a Shuttle AN35-400 Mobo), i constantly get the following
> messages in my syslog:
> 
> Apr 29 14:15:02 server kernel: eth0: received irq with unknown events
> 0x1. Please report
> Apr 29 14:15:33 server last message repeated 28 times
> Apr 29 14:15:55 server last message repeated 23 times
> 
> The message seems to be displaying more frequently the more traffic is
> on the link.

This 0x1 event is a receive error. It seems only users with cable modems
have this problem. I've got no idea why it happens with cable modems and
nothing else, but it could indeed be crappy hardware on the modem side.

What we don't know yet is if the receive error is hard or soft. Soft
errors generally can be recovered from, so it would be a shame throwing
the packets away.

> Formerly, the nForce2 board was connected to a 100mbps switch to my LAN
> and i didn't get any of these messages.

Your switch didn't let the malformed/incorrect packets through, so you
computer didn't see them.


> If you need any more info to get this fixed, just reply!

Could you please try the attached patch (will create LOTS of debug
messages) for a few minutes and mail the relevant part of your
/var/log/messages to me privately (it will be >100 kB, so I don't want to
burden the list with it).


> Great work with the driver!

Thanks,
Carl-Daniel
-- 
http://www.hailfinger.org/

--------------040705010704050401040601
Content-Type: text/plain;
 name="forcedeth_0x1event_rx_patch2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="forcedeth_0x1event_rx_patch2.txt"

===== drivers/net/forcedeth.c 1.1 vs edited =====
--- 1.1/drivers/net/forcedeth.c	Thu Feb  5 02:11:13 2004
+++ edited/drivers/net/forcedeth.c	Tue Mar  2 21:04:06 2004
@@ -120,6 +120,7 @@
 #define NVREG_IRQSTAT_MIIEVENT	0x040
 #define NVREG_IRQSTAT_MASK		0x1ff
 	NvRegIrqMask = 0x004,
+#define NVREG_IRQ_RX_ERR		0x0001
 #define NVREG_IRQ_RX			0x0002
 #define NVREG_IRQ_RX_NOBUF		0x0004
 #define NVREG_IRQ_TX_ERR		0x0008
@@ -129,7 +130,7 @@
 #define NVREG_IRQ_TX1			0x0100
 #define NVREG_IRQMASK_WANTED_1		0x005f
 #define NVREG_IRQMASK_WANTED_2		0x0147
-#define NVREG_IRQ_UNKNOWN		(~(NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR|NVREG_IRQ_TX2|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_TX1))
+#define NVREG_IRQ_UNKNOWN		(~(NVREG_IRQ_RX_ERR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR|NVREG_IRQ_TX2|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_TX1))
 
 	NvRegUnknownSetupReg6 = 0x008,
 #define NVREG_UNKSETUP6_VAL		3
@@ -847,7 +848,7 @@
 
 		i = np->cur_rx % RX_RING;
 		prd = &np->rx_ring[i];
-		dprintk(KERN_DEBUG "%s: rx_process: looking at packet %d, Flags 0x%x.\n",
+		printk(KERN_INFO "%s: rx_process: looking at packet %d, Flags 0x%x.\n",
 					dev->name, np->cur_rx, prd->Flags);
 
 		if (prd->Flags & cpu_to_le16(NV_RX_AVAIL))
@@ -880,25 +881,30 @@
 		len = le16_to_cpu(prd->Length);
 
 		if (prd->Flags & cpu_to_le16(NV_RX_MISSEDFRAME)) {
+			printk(KERN_INFO "%s: rx_process: missed frame\n", dev->name);
 			np->stats.rx_missed_errors++;
 			np->stats.rx_errors++;
 			goto next_pkt;
 		}
 		if (prd->Flags & cpu_to_le16(NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3|NV_RX_ERROR4)) {
+			printk(KERN_INFO "%s: rx_process: error 1-4\n", dev->name);
 			np->stats.rx_errors++;
 			goto next_pkt;
 		}
 		if (prd->Flags & cpu_to_le16(NV_RX_CRCERR)) {
+			printk(KERN_INFO "%s: rx_process: crc error\n", dev->name);
 			np->stats.rx_crc_errors++;
 			np->stats.rx_errors++;
 			goto next_pkt;
 		}
 		if (prd->Flags & cpu_to_le16(NV_RX_OVERFLOW)) {
+			printk(KERN_INFO "%s: rx_process: overflow\n", dev->name);
 			np->stats.rx_over_errors++;
 			np->stats.rx_errors++;
 			goto next_pkt;
 		}
 		if (prd->Flags & cpu_to_le16(NV_RX_ERROR)) {
+			printk(KERN_INFO "%s: rx_process: generic error\n", dev->name);
 			/* framing errors are soft errors, the rest is fatal. */
 			if (prd->Flags & cpu_to_le16(NV_RX_FRAMINGERR)) {
 				if (prd->Flags & cpu_to_le16(NV_RX_SUBSTRACT1)) {
@@ -1096,7 +1102,7 @@
 			spin_unlock(&np->lock);
 		}
 
-		if (events & (NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF)) {
+		if (events & (NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_RX_ERR)) {
 			rx_process(dev);
 			if (alloc_rx(dev)) {
 				spin_lock(&np->lock);
@@ -1110,6 +1116,10 @@
 			spin_lock(&np->lock);
 			link_irq(dev);
 			spin_unlock(&np->lock);
+		}
+		if (events & (NVREG_IRQ_RX_ERR)) {
+			printk(KERN_INFO "%s: received irq with events 0x%x. Probably RX fail. Trying to get diagnostics.\n",
+						dev->name, events);
 		}
 		if (events & (NVREG_IRQ_TX_ERR)) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",

--------------040705010704050401040601--
