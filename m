From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: RFC:  Enabling ethernet drivers to return FCS in the skb?
Date: Thu, 20 Nov 2003 17:34:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031120173404.A1538@sygehus.dk>
References: <3FB94311.10004@candelatech.com> <20031119123556.A7622@sygehus.dk> <3FBB8D61.6010106@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <3FBB8D61.6010106@candelatech.com>; from greearb@candelatech.com on Wed, Nov 19, 2003 at 07:33:53AM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2003 at 07:33:53AM -0800, Ben Greear wrote:
> Rask Ingemann Lambertsen wrote:
> > 
> > The Intel i82586 and i82596 and can be told to receive frames with a bad FCS.
> > They can also be told to send a precomputed FCS rather than computing it on
> > the fly. The i82596 and tulip can also transfer the FCS to memory when
> > receiving frames. I guess all of this is also supported on the i82557/8/9.
> 
> If you have a patch or example code that shows how to do this, I'd love to
> see it.  I have code that should RX bad CSUM from the Intel folks, but I can't
> get it to generate bad CRC (it does framing errors instead with my attempt),
> so I can't test the RX code properly!

The i825xx Ethernet chips are configured by putting a configure command on
the TX list. One of the bits of the configure command tells the chip to
discard or keep packets with errors. Assuming you can find that piece of
code, flipping the bit is easy enough. Similiarily for transferring the FCS
to/from memory. IIRC, this is a per-frame setting for TX on i82596 and
i82557/8/9. You can find i82596 documentation on Intel's home page and
the i82557/8/9 on SourceForge under the e100 (or was it e1000?) project.

You will still need to hack the RX code to not discard frames with the error
flag set.

I don't have any code to show for it.

Please note that error counters displayed by "ifconfig" and "netstat -i" are
based on /proc/net/dev (or so), which is a munged version of
dev->get_stats(). Use "ip -s -s link show" to get the real values (and
correctly labelled too). And even then, some drivers may not maintain the
statistics properly.

> I have the path from user-space to the NIC written, so just need to tweak the
> drivers a bit...

Indeed, since currently drivers are assumed to strip the FCS on RX and
insert it on TX. There is no defined way of telling the drivers that the FCS
should be in the skb.

> Do you know if tulip can be told to accept bad FCS and/or if it can generate
> a frame with bad FCS somehow?

No. I don't know much about the tulip. But here is what I do know:
1) The FCS is transferred to memory right after the frame data. If you
disable the rx_copy_break, then you'll find it in the skb (at skb->tail).
2) The maximum frame size, all included, is 2047 bytes, because of the
descriptor format. Some "jumbo" frame, eh?
3) Frames larger than 1514 bytes (not including the FCS) are flagged as
errored, even when otherwise perfectly fine, and passed to the host. With a
bit of luck, the tulip will pass you frames with a bad FCS too.
4) The transmitter stops working after a few frames if the MTU is larger
than about 2014 bytes.

You can hack the RX path to mung the error bits before testing them. Like so
(this is my experimental VLAN/jumbo frame hack for the de2104x driver):

--- linux-2.6.0-test8/drivers/net/tulip/de2104x.c-orig	Tue Oct 21 12:34:44 2003
+++ linux-2.6.0-test8/drivers/net/tulip/de2104x.c	Tue Nov 11 15:29:15 2003
@@ -19,7 +19,6 @@
 	  like dl2k.c/sundance.c
 	* Constants (module parms?) for Rx work limit
 	* Complete reset on PciErr
-	* Jumbo frames / dev->change_mtu
 	* Adjust Rx FIFO threshold and Max Rx DMA burst on Rx FIFO error
 	* Adjust Tx FIFO threshold and Max Tx DMA burst on Tx FIFO error
 	* Implement Tx software interrupt mitigation via
@@ -36,6 +35,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
@@ -94,6 +100,7 @@
 	  (CP)->tx_tail + (DE_TX_RING_SIZE - 1) - (CP)->tx_head :	\
 	  (CP)->tx_tail - (CP)->tx_head - 1)
 
+#define PKT_BUF_SZ_MAX		2047	/* Maximum Rx buffer size. */
 #define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer.*/
 #define RX_OFFSET		2
 
@@ -403,7 +410,7 @@
 	int rc;
 
 	while (rx_work--) {
-		u32 status, len;
+		u32 status, len, status_hacked;
 		dma_addr_t mapping;
 		struct sk_buff *skb, *copy_skb;
 		unsigned copying_skb, buflen;
@@ -424,7 +431,13 @@
 			goto rx_next;
 		}
 
-		if (unlikely((status & 0x38008300) != 0x0300)) {
+		/* Ugly Jumbo frame hack. Remove error flag on long frames. */
+		if ((status & (RxErrLong | RxErrCRC | RxErrFIFO | RxErrRunt | RxErrFrame)) == RxErrLong)
+			status_hacked = status & ~(RxError | RxErrLong);
+		else
+			status_hacked = status;
+
+		if (unlikely((status_hacked & 0x38008300) != 0x0300)) {
 			de_rx_err_acct(de, rx_tail, status, len);
 			goto rx_next;
 		}
@@ -1372,6 +1390,8 @@
 		printk(KERN_DEBUG "%s: enabling interface\n", dev->name);
 
 	de->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
+	if (de->rx_buf_sz > PKT_BUF_SZ_MAX)
+		de->rx_buf_sz = PKT_BUF_SZ_MAX;
 
 	rc = de_alloc_rings(de);
 	if (rc) {
@@ -1464,6 +1482,18 @@
 	netif_wake_queue(dev);
 }
 
+static int de_change_mtu (struct net_device *dev, int mtu)
+{
+	if (netif_running (dev))
+		return (-EBUSY);
+	
+	if (mtu < 0 || mtu > PKT_BUF_SZ_MAX - VLAN_ETH_HLEN - 4)
+		return (-EINVAL);
+
+	dev->mtu = mtu;
+	return (0);
+}
+
 static void __de_get_regs(struct de_private *de, u8 *buf)
 {
 	int i;
@@ -1964,6 +1994,7 @@
 	dev->ethtool_ops = &de_ethtool_ops;
 	dev->tx_timeout = de_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+	dev->change_mtu = de_change_mtu;
 
 	dev->irq = pdev->irq;
 

I saw a link to the tulip documentation somewhere, but I neither bookmarked
the URL nor downloaded the documentation. :-(

-- 
Regards,
Rask Ingemann Lambertsen
