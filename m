From: Willy Tarreau <w@1wt.eu>
Subject: Re: [Patch 2.6.22.2 ] : drivers/net/via-rhine.c:   Offload checksum handling to VT6105M
Date: Sun, 30 Dec 2007 23:33:54 +0100
Message-ID: <20071230223354.GA28568@1wt.eu>
References: <534451.72377.qm@web53807.mail.re2.yahoo.com> <20070818052351.GN6002@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: K Naru <squat_rack@yahoo.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758409AbXL3WeU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070818052351.GN6002@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kim,

On Fri, Aug 17, 2007 at 11:34:37AM -0700, K Naru wrote:
> From: Kim Naru (squat_rack@yahoo.com)
> 
> Added support to offload TCP/UDP/IP checksum to the
> VIA Technologies VT6105M chip.
> Firstly, let the stack know this chip is capable of
> doing its own checksum(IPV4 only).
> Secondly offload checksum to VT6105M, if necessary. 
> 
> 
> Verbose Mode:
> 
> #1. Define 3 bits(18,19,20) in Transmit Descriptor 1
> of chip, which affect checksum processing.
> The prefix(TDES1) for the 3 variables is the short
> name for Transmit Descriptior 1.
> #2. In rhine_init_one(), if pci_rev >=  VT6105M then
> set  NETIF_F_IP_CSUM(see skbuff.h for details).
> #3. In rhine_start_tx() if NETIF_F_IP_CSUM is set AND
> the stack requires a checksum then
> set either bit 19(UDP),20(TCP) AND bit 18(IP).
> 
> Note : The numbered items above(i.e.#1,#2,#3) denote
> pseudo code.
> 
> This patch was developed and tested on Imedia
> linux-2.6.20 under a PC-Engines Alix System board
> (www.pcengines.ch/alix.htm). It was tested(compilation
> only) on linux-2.6.22.2. The minor code change between
> 2.6.20 and 2.6.22 is the use of ip_hdr() in 2.26.22.
> 
> In 2.6.20 :
>                 struct iphdr *ip = skb->nh.iph;
> In 2.6.22 :
>                 const struct iphdr *ip = ip_hdr(skb);
> 
> Testing:
> 
> 
> ttcp,netperf ftp and top  where used. There appears to
> be a small CPU utilization gain. Throughput results 
> where more inconclusive.
> 
> The data sheet used to get information is 'VT6105M
> Data Sheet, Revision 1.63  June21,2006'.
> 
> Signed-off-by: Kim Naru (squat_rack@yahoo.com)
> 
> ---

Well, I've reformated your patch so that it can be applied, and very
slightly arranged it in order to save 13 bytes of code and a few CPU
cycles.

Also, I moved the if block before the spinlock as there is no reason
for this code to be run with the lock held.

I have run some performance measurements on an ALIX 3C2 motherboard
with a 2.6.22-stable kernel. What I see is a reduction of CPU usage
by about 20% when the network is saturated, but also a reduction of
the network speed by 8%!

Without the patch, I can produce a continuous traffic of about 99 Mbps with
about 11% CPU (system only, 89% idle).

With the patch, the traffic drops to 91 Mbps but CPU usage decreases to 9%.

Now, if I reduce the MTU to exactly 1000, then the traffic increases to about
98 Mbps, but it progressively reduces when the MTU moves away from 1000.

So I have run some deeper tests consisting in leaving NETIF_F_IP_CSUM unset
and still asking the NIC to compute the checksums. The conclusion is very
clear: as soon as *any* checksum bit is set (IP, TCP, UDP), the traffic
immediately drops.

I think that what happens is that the NIC is not pipelined at all and that
no data is transferred while a checksum is being computed. This would also
explain why reducing the MTU increases performance, since it reduces the
time required to compute a checksum, reducing the off time. And the more I
think about it, the more I think this is the problem, because the VT6105M
has a 2kB transmit buffer, so it cannot checksum a 1.5kB frame while sending
another one if it does it inside the buffer.

And I'm pretty sure that the checksum is computed in the buffer and that the
data is not transferred twice on the bus, because playing with PCI latency
timer and other parameters does not change anything.

So basically, we're there with a chip which can offload the CPU by performing
the checksums itself, but it reduces performance for packets larger than 1kB
(or possibly 500 bytes if there's a 1.5kB packet being transferred).

The driver should be adjusted to permit the user to enable and disable this
feature with ethtool. Right now, its status can only be consulted, and I'm
using dd on /dev/mem and /dev/kmem to change the values on the fly.

Given the fact that a 20% reduction on CPU usage which was already 10% only
leaves a net gain of about 2% more CPU available, I'm not convinced that there
is any advantage in enabling this feature by default with this NIC.

Here's the updated patch for reference (maybe you'd want to enhance it).

--- linux-2.6.22-wt3/drivers/net/via-rhine.c	2007-11-22 17:48:34 +0100
+++ linux-2.6.22-wt3.via-cksum/drivers/net/via-rhine.c	2007-12-30 20:53:30 +0100
@@ -95,6 +95,8 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/ip.h>
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/mii.h>
@@ -343,6 +345,9 @@
 
 /* Initial value for tx_desc.desc_length, Buffer size goes to bits 0-10 */
 #define TXDESC		0x00e08000
+#define TDES1_TCPCK	0x00100000  /* Bit 20, Transmit Desc 1  */
+#define TDES1_UDPCK	0x00080000  /* Bit 19, Transmit Desc 1  */
+#define TDES1_IPCK	0x00040000  /* Bit 18, Transmit Desc 1  */
 
 enum rx_status_bits {
 	RxOK=0x8000, RxWholePkt=0x0300, RxErr=0x008F
@@ -788,6 +793,9 @@
 	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
+	if (pci_rev >=  VT6105M)
+		dev->features |= NETIF_F_IP_CSUM;   /* chip does checksum */
+
 	/* dev->name not defined before register_netdev()! */
 	rc = register_netdev(dev);
 	if (rc)
@@ -1260,6 +1268,18 @@
 	rp->tx_ring[entry].desc_length =
 		cpu_to_le32(TXDESC | (skb->len >= ETH_ZLEN ? skb->len : ETH_ZLEN));
 
+	if ((dev->features & NETIF_F_IP_CSUM) &&
+	    (skb->ip_summed == CHECKSUM_PARTIAL)) {
+		/* Offload checksum to chip. */
+		const struct iphdr *ip = ip_hdr(skb);
+		unsigned long flag;
+
+		flag = (ip->protocol == IPPROTO_TCP) ? TDES1_TCPCK|TDES1_IPCK :
+		       (ip->protocol == IPPROTO_UDP) ? TDES1_UDPCK|TDES1_IPCK :
+		       TDES1_IPCK;
+		rp->tx_ring[entry].desc_length |= flag;
+	}
+
 	/* lock eth irq */
 	spin_lock_irq(&rp->lock);
 	wmb();

Best regards,
Willy

