From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH] SMC91x: delete unused local variable "lp"
Date: Mon, 03 Nov 2008 12:15:00 -0500 (EST)
Message-ID: <alpine.LFD.2.00.0811031154270.13034@xanadu.home>
References: <1225288566-18457-1-git-send-email-vapier@gentoo.org>
 <20081104.014511.108120668.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: vapier@gentoo.org, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:56843 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbYKCRPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 12:15:33 -0500
In-reply-to: <20081104.014511.108120668.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Nov 2008, Atsushi Nemoto wrote:

> On Wed, 29 Oct 2008 09:56:06 -0400, Mike Frysinger <vapier@gentoo.org> wrote:
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> > ---
> >  drivers/net/smc91x.c |    2 --
> >  1 files changed, 0 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> > index c70870e..6f9895d 100644
> > --- a/drivers/net/smc91x.c
> > +++ b/drivers/net/smc91x.c
> > @@ -2060,7 +2060,6 @@ static int smc_request_attrib(struct platform_device *pdev,
> >  			      struct net_device *ndev)
> >  {
> >  	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
> > -	struct smc_local *lp = netdev_priv(ndev);
> >  
> >  	if (!res)
> >  		return 0;
> 
> The local variable 'lp' is actually used on some platforms (via
> SMC_IO_SHIFT).

Oops, indeed.

> Please revert this change and do another way ("unused" marker or
> something) to fix the warnings.

There were no warnings AFAIK.

Actually, the best fix might be the following patch:

-----
From: Nicolas Pitre <nico@cam.org>

Commit 51ac3beffd removed an apparently unused local variable from 
smc_request_attrib(), but some platforms actually needs the lp variable 
to define SMC_IO_SHIFT which is used to define ATTRIB_SIZE.

Let's always add a reference to lp to avoid such mistakes in the future,
which in the constant case gets optimized away at compile time.

Signed-off-by: Nicolas Pitre <nico@cam.org>

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 6f9895d..a657321 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2060,6 +2060,7 @@ static int smc_request_attrib(struct platform_device *pdev,
 			      struct net_device *ndev)
 {
 	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
+	struct smc_local *lp = netdev_priv(ndev);
 
 	if (!res)
 		return 0;
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index a07cc93..23fc21a 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -91,7 +91,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_CAN_USE_8BIT	0
 #define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	1
-#define SMC_IO_SHIFT		0
 #define SMC_NOWAIT      	1
 #define SMC_USE_BFIN_DMA	0
 
@@ -106,7 +105,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_CAN_USE_8BIT	0
 #define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	0
-#define SMC_IO_SHIFT		0
 #define SMC_NOWAIT      	1
 #define SMC_USE_BFIN_DMA	0
 
@@ -138,7 +136,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_CAN_USE_32BIT	0
 #define SMC_NOWAIT		1
 
-#define SMC_IO_SHIFT		0
 
 #define SMC_inw(a, r)		in_be16((volatile u16 *)((a) + (r)))
 #define SMC_outw(v, a, r)	out_be16((volatile u16 *)((a) + (r)), v)
@@ -172,7 +169,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_CAN_USE_8BIT	1
 #define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	0
-#define SMC_IO_SHIFT		0
 #define SMC_NOWAIT		1
 
 #define SMC_inb(a, r)		readb((a) + (r))
@@ -197,7 +193,7 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_NOWAIT		1
 
 /* The first two address lines aren't connected... */
-#define SMC_IO_SHIFT		2
+#define SMC_IO_SHIFT		(lp, 2)
 
 #define SMC_inb(a, r)		readb((a) + (r))
 #define SMC_outb(v, a, r)	writeb(v, (a) + (r))
@@ -210,7 +206,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_CAN_USE_8BIT	0
 #define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	0
-#define SMC_IO_SHIFT		0
 #define SMC_NOWAIT		1
 
 #define SMC_inw(a, r)		readw((a) + (r))
@@ -226,7 +221,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_CAN_USE_8BIT	1
 #define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	1
-#define SMC_IO_SHIFT		0
 #define SMC_NOWAIT		1
 #define SMC_USE_PXA_DMA		1
 
@@ -258,7 +252,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_CAN_USE_8BIT	0
 #define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	0
-#define SMC_IO_SHIFT		0
 #define SMC_NOWAIT		1
 
 #define SMC_inw(a, r)		readw((a) + (r))
@@ -387,7 +380,6 @@ static inline void LPD7_SMC_outsw (unsigned char* a, int r,
 #define SMC_CAN_USE_8BIT	0
 #define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	0
-#define SMC_IO_SHIFT		0
 #define SMC_NOWAIT		1
 
 #define SMC_inw(a, r)		au_readw((unsigned long)((a) + (r)))
@@ -682,7 +674,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
 #endif
 
 #ifndef SMC_IO_SHIFT
-#define SMC_IO_SHIFT	0
+#define SMC_IO_SHIFT	(lp, 0)
 #endif
 
 #ifndef	SMC_IRQ_FLAGS
