From: "Yang, Steve" <steve.yang@windriver.com>
Subject: RE: [patch] Performance enhancement patches for SB1250 MAC
Date: Tue, 21 Nov 2006 16:33:37 -0800
Message-ID: <F09F8223E8BE7D42BDA1800B19F3440D9221A0@ALA-MAIL03.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Martin Michlmayr" <tbm@cyrius.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57576 "EHLO mail.wrs.com")
	by vger.kernel.org with ESMTP id S1031232AbWKVAeC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 19:34:02 -0500
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patches have been tested on non-SMP and SMP configurations.

Regards, 
Steve Yang

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org] 
Sent: Tuesday, November 21, 2006 11:13 AM
To: Yang, Steve
Cc: Martin Michlmayr; netdev@vger.kernel.org
Subject: Re: [patch] Performance enhancement patches for SB1250 MAC

On Tue, 21 Nov 2006 08:45:58 -0800
"Yang, Steve" <steve.yang@windriver.com> wrote:

> Martin,
> 
> I've attached the two patches with this email.
> 
> Original submission email text:
> 
> "The attached are two network performance enhancement patches for 
> SB1250 MAC. The NAPI patch applies first. Followed by the "skb cache"
patch.
> They applied and builds cleanly on 2.6.18 kernel for the following 
> kernel option combinations:
> 
> SBMAC_NAPI	no	yes	yes
> SKB_CACHE	no	no	yes"
> 
> Regards,
> Steve Yang
> 
> -----Original Message-----
> From: Martin Michlmayr [mailto:tbm@cyrius.com]
> Sent: Tuesday, November 21, 2006 6:27 AM
> To: Stephen Hemminger
> Cc: Yang, Steve; netdev@vger.kernel.org
> Subject: Re: [patch] Performance enhancement patches for SB1250 MAC
> 
> * Stephen Hemminger <shemminger@osdl.org> [2006-11-20 15:35]:
> > > 1. I've submitted two patches, one for NAPI and the other for
> SKB_Cache.
> > > They can go in individually. You've expressed objections to
> SKB_Cache.
> > > What about the one for NAPI?
> > Yes, the NAPI one is great.
> 
> Should Steve resend the patch so it can be added or is it queued up 
> already?  It would be nice to have this in 2.6.20.
> --
> Martin Michlmayr
> tbm@cyrius.com

One comment about the driver in general (not NAPI related), is that
almost all uses of "volatile" in a driver are incorrect.  Especially
these because the device memory (__iomem) should already be mapped
non-cached.

Volatile protects against compiler issues, not device consistency.

@@ -197,13 +206,16 @@
 	volatile void __iomem *sbdma_config0;	/* DMA config register 0
*/
 	volatile void __iomem *sbdma_config1;	/* DMA config register 1
*/
 	volatile void __iomem *sbdma_dscrbase;	/* Descriptor base
address */
-	volatile void __iomem *sbdma_dscrcnt;     /* Descriptor count
register */
+	volatile void __iomem *sbdma_dscrcnt;   /* Descriptor count
register */
 	volatile void __iomem *sbdma_curdscr;	/* current descriptor
address */
+	volatile void __iomem *sbdma_oodpktlost;/* pkt drop (rx only) */
+
 
Also, how is this NAPI related (probably should be a different patch.
But I no nothing about MIPS SMP.

Index: linux-2.6.14-cgl/arch/mips/sibyte/bcm1480/irq.c
===================================================================
--- linux-2.6.14-cgl.orig/arch/mips/sibyte/bcm1480/irq.c
2006-09-20 14:58:41.000000000 -0700
+++ linux-2.6.14-cgl/arch/mips/sibyte/bcm1480/irq.c	2006-09-20
15:58:33.000000000 -0700
@@ -144,11 +144,11 @@
 	unsigned long flags;
 	unsigned int irq_dirty;
 
-	i = first_cpu(mask);
-	if (next_cpu(i, mask) <= NR_CPUS) {
+	if (cpus_weight(mask) != 1) {
 		printk("attempted to set irq affinity for irq %d to
multiple CPUs\n", irq);
 		return;
 	}
+	i = first_cpu(mask);
 
 	/* Convert logical CPU to physical CPU */
 	cpu = cpu_logical_map(i);



--
Stephen Hemminger <shemminger@osdl.org>
