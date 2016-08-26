From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] smc91x: remove ARM hack for unaligned 16-bit writes
Date: Fri, 26 Aug 2016 13:29:55 +0100
Message-ID: <20160826122955.GP1041@n2100.armlinux.org.uk>
References: <20160825144314.1850730-1-arnd@arndb.de>
 <87inuopw04.fsf@belgarion.home>
 <20160825223743.GK1041@n2100.armlinux.org.uk>
 <1899384.M1jdqOztqi@wuerfel>
 <20160826113848.GO1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>,
        Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Robert Jarzmik <robert.jarzmik@free.fr>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160826113848.GO1041@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2016 at 12:38:48PM +0100, Russell King - ARM Linux wrote:
> On Fri, Aug 26, 2016 at 11:41:21AM +0200, Arnd Bergmann wrote:
> > On Thursday, August 25, 2016 11:37:43 PM CEST Russell King - ARM Linux wrote:
> > > On Thu, Aug 25, 2016 at 08:02:35PM +0200, Robert Jarzmik wrote:
> > > > Arnd Bergmann <arnd@arndb.de> writes:
> > >  /*
> > > + * Any 16-bit access is performed with two 8-bit accesses if the hardware
> > > + * can't do it directly. Most registers are 16-bit so those are mandatory.
> > > + */
> > > +#define SMC_outw_b(x, a, r)						\
> > > +	do {								\
> > > +		unsigned int __val16 = (x);				\
> > > +		unsigned int __reg = (r);				\
> > > +		SMC_outb(__val16, a, __reg);				\
> > > +		SMC_outb(__val16 >> 8, a, __reg + (1 << SMC_IO_SHIFT));	\
> > > +	} while (0)
> > > +
> > > +#define SMC_inw_b(a, r)							\
> > > +	({								\
> > > +		unsigned int __val16;					\
> > > +		unsigned int __reg = r;					\
> > > +		__val16  = SMC_inb(a, __reg);				\
> > > +		__val16 |= SMC_inb(a, __reg + (1 << SMC_IO_SHIFT)) << 8; \
> > > +		__val16;						\
> > > +	})
> > > +
> > > +/*
> > >   * Define your architecture specific bus configuration parameters here.
> > >   */
> > >  
> > > @@ -55,10 +76,30 @@
> > >  #define SMC_IO_SHIFT		(lp->io_shift)
> > >  
> > >  #define SMC_inb(a, r)		readb((a) + (r))
> > > -#define SMC_inw(a, r)		readw((a) + (r))
> > > +#define SMC_inw(a, r)							\
> > > +	({								\
> > > +		unsigned int __smc_r = r;				\
> > > +		SMC_16BIT(lp) ? readw((a) + __smc_r) :			\
> > > +		SMC_8BIT(lp) ? SMC_inw_b(a, __smc_r) :			\
> > > +		({ BUG(); 0; });					\
> > > +	})
> > > +
> > 
> > I think this breaks machines that declare a device that just lists
> > SMC91X_USE_32BIT but not SMC91X_USE_16BIT. Right now, the way this
> > is interpreted is to use 32-bit accessors for most things, but
> > not avoiding 16-bit reads.
> 
> Your comment is wrong.  It breaks machines that declare a device
> with SMC91X_USE_32BIT but not _either_ of SMC91X_USE_16BIT _or_
> SMC91X_USE_8BIT.  As I already noted, but you obviously ignored.
> 
> In that note, I pointed out that this _was_ already the case with
> the original driver before your patch:
> 
> #if ! SMC_CAN_USE_16BIT
> ... code implementing SMC_outw() and SMC_inw() in terms of SMC_outb()
> and SMC_inb(), and defining SMC_insw() and SMC_outsw() as BUG()
> #endif
> #if !defined(SMC_insw) || !defined(SMC_outsw)
> #define SMC_insw(a, r, p, l)            BUG()
> #define SMC_outsw(a, r, p, l)           BUG()
> #endif
> 
> #if ! SMC_CAN_USE_8BIT
> #define SMC_inb(ioaddr, reg)            ({ BUG(); 0; })
> #define SMC_outb(x, ioaddr, reg)        BUG()
> #define SMC_insb(a, r, p, l)            BUG()
> #define SMC_outsb(a, r, p, l)           BUG()
> #endif
> 
> #if !defined(SMC_insb) || !defined(SMC_outsb)
> #define SMC_insb(a, r, p, l)            BUG()
> #define SMC_outsb(a, r, p, l)           BUG()
> #endif
> 
> So, if _neither_ SMC_CAN_USE_16BIT nor SMC_CAN_USE_8BIT are defined,
> trying to use the 16-bit accessors cause a BUG().
> 
> > That is a bit fishy though, and we could instead change the platform
> > data to always set both SMC91X_USE_32BIT and SMC91X_USE_16BIT.
> > 
> > The affected platforms are DT based machines with 32-bit I/O and
> > these board files:
> > 
> > arch/arm/mach-pxa/idp.c:        .flags = SMC91X_USE_32BIT | SMC91X_USE_DMA | SMC91X_NOWAIT,
> > arch/arm/mach-pxa/xcep.c:       .flags  = SMC91X_USE_32BIT | SMC91X_NOWAIT | SMC91X_USE_DMA,
> > arch/arm/mach-realview/core.c:  .flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
> > arch/blackfin/mach-bf561/boards/cm_bf561.c:     .flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
> > arch/blackfin/mach-bf561/boards/ezkit.c:        .flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
> 
> Right, this looks like another one of your bugs in this conversion.
> 
> #elif   defined(CONFIG_ARCH_INNOKOM) || \
>         defined(CONFIG_ARCH_PXA_IDP) || \
>         defined(CONFIG_ARCH_RAMSES) || \
>         defined(CONFIG_ARCH_PCM027)
> 
> #define SMC_CAN_USE_8BIT        1
> #define SMC_CAN_USE_16BIT       1
> #define SMC_CAN_USE_32BIT       1
> 
> So, IDP can use all of 32-bit, 16-bit and 8-bit accesses, meanwhile your
> conversion is telling the driver that it can only use 32-bit => your
> conversion of IDP is broken.
> 
> Before your conversion, realview depended on the default settings of
> smc91x, which is again:
> 
> #define SMC_CAN_USE_8BIT        1
> #define SMC_CAN_USE_16BIT       1
> #define SMC_CAN_USE_32BIT       1
> 
> So realview follows IDP - it can do 32-bit, 16-bit and 8-bit accesses,
> meanwhile your conversion tells the driver it can _only_ do 32-bit
> accesses, which is again broken.
> 
> XCEP falls into the same category, as do the other two blackfin
> cases from what I can see.
> 
> The point of the SMC_CAN_USE_xxx macros is to indicate to the SMC91x
> driver which sizes of access can be used on the hardware concerned.
> If SMC_CAN_USE_16BIT is set, then 16-bit accesses are possible.  If
> it's not set, then 8-bit accesses will be used if they're supported,
> otherwise it's a buggy configuration.
> 
> SMC_CAN_USE_32BIT says that 32-bit accesses are possible, but these
> are only used in a small number of cases as an optimisation.
> 
> It is a bug to configure the smc91x driver with both SMC_CAN_USE_16BIT
> and SMC_CAN_USE_8BIT clear.
> 
> Hence, it's a bug to tell the driver (via the platform data) that only
> 32-bit accesses can be performed.
> 
> So, while my patch may be fixing some of the brokenness, the rest of
> the brokenness also needs fixing by adjusting all the platform data
> to properly reflect which access sizes are possible, rather than what
> you seem to have done, which is to indicate what the largest possible
> access size is.
> 
> This is especially important as there are platforms around where 16-bit
> accesses to the SMC91x can be performed, but not 8-bit:
> 
> #elif   defined(CONFIG_MACH_LOGICPD_PXA270) ||  \
>         defined(CONFIG_MACH_NOMADIK_8815NHK)
> 
> #define SMC_CAN_USE_8BIT        0
> #define SMC_CAN_USE_16BIT       1
> #define SMC_CAN_USE_32BIT       0
> 
> #elif   defined(CONFIG_SH_SH4202_MICRODEV)
> 
> #define SMC_CAN_USE_8BIT        0
> #define SMC_CAN_USE_16BIT       1
> #define SMC_CAN_USE_32BIT       0
> 
> #elif   defined(CONFIG_M32R)
> 
> #define SMC_CAN_USE_8BIT        0
> #define SMC_CAN_USE_16BIT       1
> #define SMC_CAN_USE_32BIT       0
> 
> #elif defined(CONFIG_ARCH_MSM)
> 
> #define SMC_CAN_USE_8BIT        0
> #define SMC_CAN_USE_16BIT       1
> #define SMC_CAN_USE_32BIT       0
> 
> #elif defined(CONFIG_COLDFIRE)
> 
> #define SMC_CAN_USE_8BIT        0
> #define SMC_CAN_USE_16BIT       1
> #define SMC_CAN_USE_32BIT       0
> 
> ... etc ...

So, based on your patch introducing the breakage, these changes are
necessary to restore the per-platform capabilities that were originally
configured into the driver.  I've also checked over the tree, and added
the others that only set SMC91X_USE_32BIT.

Lastly, I've added a comment to linux/smc91x.h indicating how these
bits are supposed to be used.

There may be other platforms which need updating - setting these bits
incorrectly can lead to more complex IO accesses than are necessary,
which, in a SMP environment, would be racy.

For instance, a missing SMC91X_USE_8BIT results in the interrupt
acknowledgement being written using a read-modify-write sequence with
a 16-bit access under local_irq_save().  That's also another
illustration why supporting at least one of 8-bit or 16-bit access is
mandatory - there is no emulation of the 8 or 16-bit accesses in terms
of 32-bit accessors.

 arch/arm/mach-pxa/idp.c                    |  3 ++-
 arch/arm/mach-pxa/xcep.c                   |  3 ++-
 arch/arm/mach-realview/core.c              |  3 ++-
 arch/arm/mach-sa1100/pleb.c                |  2 +-
 arch/blackfin/mach-bf561/boards/cm_bf561.c |  3 ++-
 arch/blackfin/mach-bf561/boards/ezkit.c    |  3 ++-
 include/linux/smc91x.h                     | 10 ++++++++++
 7 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/arch/arm/mach-pxa/idp.c b/arch/arm/mach-pxa/idp.c
index c410d84b243d..30100ac94368 100644
--- a/arch/arm/mach-pxa/idp.c
+++ b/arch/arm/mach-pxa/idp.c
@@ -83,7 +83,8 @@ static struct resource smc91x_resources[] = {
 };
 
 static struct smc91x_platdata smc91x_platdata = {
-	.flags = SMC91X_USE_32BIT | SMC91X_USE_DMA | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		 SMC91X_USE_DMA | SMC91X_NOWAIT,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/arch/arm/mach-pxa/xcep.c b/arch/arm/mach-pxa/xcep.c
index 3f06cd90567a..056369ef250e 100644
--- a/arch/arm/mach-pxa/xcep.c
+++ b/arch/arm/mach-pxa/xcep.c
@@ -120,7 +120,8 @@ static struct resource smc91x_resources[] = {
 };
 
 static struct smc91x_platdata xcep_smc91x_info = {
-	.flags	= SMC91X_USE_32BIT | SMC91X_NOWAIT | SMC91X_USE_DMA,
+	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		  SMC91X_NOWAIT | SMC91X_USE_DMA,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/arch/arm/mach-realview/core.c b/arch/arm/mach-realview/core.c
index baf174542e36..b287deaf582c 100644
--- a/arch/arm/mach-realview/core.c
+++ b/arch/arm/mach-realview/core.c
@@ -93,7 +93,8 @@ static struct smsc911x_platform_config smsc911x_config = {
 };
 
 static struct smc91x_platdata smc91x_platdata = {
-	.flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		 SMC91X_NOWAIT,
 };
 
 static struct platform_device realview_eth_device = {
diff --git a/arch/arm/mach-sa1100/pleb.c b/arch/arm/mach-sa1100/pleb.c
index 1525d7b5f1b7..88149f85bc49 100644
--- a/arch/arm/mach-sa1100/pleb.c
+++ b/arch/arm/mach-sa1100/pleb.c
@@ -45,7 +45,7 @@ static struct resource smc91x_resources[] = {
 };
 
 static struct smc91x_platdata smc91x_platdata = {
-	.flags = SMC91X_USE_16BIT | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_16BIT | SMC91X_USE_8BIT | SMC91X_NOWAIT,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/arch/blackfin/mach-bf561/boards/cm_bf561.c b/arch/blackfin/mach-bf561/boards/cm_bf561.c
index c6db52ba3a06..10c57771822d 100644
--- a/arch/blackfin/mach-bf561/boards/cm_bf561.c
+++ b/arch/blackfin/mach-bf561/boards/cm_bf561.c
@@ -146,7 +146,8 @@ static struct platform_device hitachi_fb_device = {
 #include <linux/smc91x.h>
 
 static struct smc91x_platdata smc91x_info = {
-	.flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		 SMC91X_NOWAIT,
 	.leda = RPC_LED_100_10,
 	.ledb = RPC_LED_TX_RX,
 };
diff --git a/arch/blackfin/mach-bf561/boards/ezkit.c b/arch/blackfin/mach-bf561/boards/ezkit.c
index f35525b55819..57d1c43726d9 100644
--- a/arch/blackfin/mach-bf561/boards/ezkit.c
+++ b/arch/blackfin/mach-bf561/boards/ezkit.c
@@ -134,7 +134,8 @@ static struct platform_device net2272_bfin_device = {
 #include <linux/smc91x.h>
 
 static struct smc91x_platdata smc91x_info = {
-	.flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
+	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		 SMC91X_NOWAIT,
 	.leda = RPC_LED_100_10,
 	.ledb = RPC_LED_TX_RX,
 };
diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
index 76199b75d584..e302c447e057 100644
--- a/include/linux/smc91x.h
+++ b/include/linux/smc91x.h
@@ -1,6 +1,16 @@
 #ifndef __SMC91X_H__
 #define __SMC91X_H__
 
+/*
+ * These bits define which access sizes a platform can support, rather
+ * than the maximal access size.  So, if your platform can do 16-bit
+ * and 32-bit accesses to the SMC91x device, but not 8-bit, set both
+ * SMC91X_USE_16BIT and SMC91X_USE_32BIT.
+ *
+ * The SMC91x driver requires at least one of SMC91X_USE_8BIT or
+ * SMC91X_USE_16BIT to be supported - just setting SMC91X_USE_32BIT is
+ * an invalid configuration.
+ */
 #define SMC91X_USE_8BIT (1 << 0)
 #define SMC91X_USE_16BIT (1 << 1)
 #define SMC91X_USE_32BIT (1 << 2)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
