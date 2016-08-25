From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] smc91x: remove ARM hack for unaligned 16-bit writes
Date: Thu, 25 Aug 2016 23:37:43 +0100
Message-ID: <20160825223743.GK1041@n2100.armlinux.org.uk>
References: <20160825144314.1850730-1-arnd@arndb.de>
 <3062310.z9h3CgCZ7p@wuerfel>
 <87inuopw04.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
        linux-arm-kernel@lists.infradead.org,
        Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87inuopw04.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 08:02:35PM +0200, Robert Jarzmik wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
> 
> > On Thursday, August 25, 2016 4:43:04 PM CEST Arnd Bergmann wrote:
> >>  drivers/net/ethernet/smsc/smc91x.h | 50 +++++++++++++++++++++++---------------
> >>  1 file changed, 30 insertions(+), 20 deletions(-)
> >> 
> >> While this patch fixes one bug on Neponset, it probably doesn't address
> >> the one that Russell ran into first, so this is for review only for now,
> >> until the remaining problem(s) have been worked out.
> >> 
> >
> > The comment should have been on another patch, my mistake. please
> > see v2.
> >
> > 	Arnd
> 
> Hi Arnd,
> 
> I didn't review the patch thoroughly, but I launched your 2 patches in my pxa
> little farm.
> 
> The result is that lubbock and mainstone are all right, but zylonite is broken
> (ie. networkless). I removed then these 2 patches and zylonite worked again.
> 
> I have also an error message on the console on a "broken" zylonite :
>   Changing smcs91x MAC address to 08:00:3e:26:0a:5b: ifconfig: SIOCSIFHWADDR:
>   Device or resource busy
> 
> I reran the test twice (2 times with your patches, 2 times without), the result
> looks consistent, ie. zylonite doesn't really like them.

Please try the patch below.  I sent this to Will a few days ago, as
he said (on irc) that he was also seeing problems on a platform he
had, but I've yet to hear back.  I've not posted it yet because I
haven't got around to writing a commit description for it.

It does require that at least one of 8-bit or 16-bit accesses are
supported, but I think that's already true.

8<========
From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH] net: smc91x: fix SMC accesses

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---

 drivers/net/ethernet/smsc/smc91x.h | 65 ++++++++++++++++++++++++++------------
 1 file changed, 45 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 1a55c7976df0..e17671c9d1b0 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -37,6 +37,27 @@
 #include <linux/smc91x.h>
 
 /*
+ * Any 16-bit access is performed with two 8-bit accesses if the hardware
+ * can't do it directly. Most registers are 16-bit so those are mandatory.
+ */
+#define SMC_outw_b(x, a, r)						\
+	do {								\
+		unsigned int __val16 = (x);				\
+		unsigned int __reg = (r);				\
+		SMC_outb(__val16, a, __reg);				\
+		SMC_outb(__val16 >> 8, a, __reg + (1 << SMC_IO_SHIFT));	\
+	} while (0)
+
+#define SMC_inw_b(a, r)							\
+	({								\
+		unsigned int __val16;					\
+		unsigned int __reg = r;					\
+		__val16  = SMC_inb(a, __reg);				\
+		__val16 |= SMC_inb(a, __reg + (1 << SMC_IO_SHIFT)) << 8; \
+		__val16;						\
+	})
+
+/*
  * Define your architecture specific bus configuration parameters here.
  */
 
@@ -55,10 +76,30 @@
 #define SMC_IO_SHIFT		(lp->io_shift)
 
 #define SMC_inb(a, r)		readb((a) + (r))
-#define SMC_inw(a, r)		readw((a) + (r))
+#define SMC_inw(a, r)							\
+	({								\
+		unsigned int __smc_r = r;				\
+		SMC_16BIT(lp) ? readw((a) + __smc_r) :			\
+		SMC_8BIT(lp) ? SMC_inw_b(a, __smc_r) :			\
+		({ BUG(); 0; });					\
+	})
+
 #define SMC_inl(a, r)		readl((a) + (r))
 #define SMC_outb(v, a, r)	writeb(v, (a) + (r))
+#define SMC_outw(v, a, r)						\
+	do {								\
+		unsigned int __v = v, __smc_r = r;			\
+		if (SMC_16BIT(lp))					\
+			__SMC_outw(__v, a, __smc_r);			\
+		else if (SMC_8BIT(lp))					\
+			SMC_outw_b(__v, a, __smc_r);			\
+		else							\
+			BUG();						\
+	} while (0)
+
 #define SMC_outl(v, a, r)	writel(v, (a) + (r))
+#define SMC_insb(a, r, p, l)	readsb((a) + (r), p, l)
+#define SMC_outsb(a, r, p, l)	writesb((a) + (r), p, l)
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 #define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
@@ -66,7 +107,7 @@
 #define SMC_IRQ_FLAGS		(-1)	/* from resource */
 
 /* We actually can't write halfwords properly if not word aligned */
-static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
+static inline void __SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 {
 	if ((machine_is_mainstone() || machine_is_stargate2() ||
 	     machine_is_pxa_idp()) && reg & 2) {
@@ -416,24 +457,8 @@ smc_pxa_dma_insw(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
 
 #if ! SMC_CAN_USE_16BIT
 
-/*
- * Any 16-bit access is performed with two 8-bit accesses if the hardware
- * can't do it directly. Most registers are 16-bit so those are mandatory.
- */
-#define SMC_outw(x, ioaddr, reg)					\
-	do {								\
-		unsigned int __val16 = (x);				\
-		SMC_outb( __val16, ioaddr, reg );			\
-		SMC_outb( __val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));\
-	} while (0)
-#define SMC_inw(ioaddr, reg)						\
-	({								\
-		unsigned int __val16;					\
-		__val16 =  SMC_inb( ioaddr, reg );			\
-		__val16 |= SMC_inb( ioaddr, reg + (1 << SMC_IO_SHIFT)) << 8; \
-		__val16;						\
-	})
-
+#define SMC_outw(x, ioaddr, reg)	SMC_outw_b(x, ioaddr, reg)
+#define SMC_inw(ioaddr, reg)		SMC_inw_b(ioaddr, reg)
 #define SMC_insw(a, r, p, l)		BUG()
 #define SMC_outsw(a, r, p, l)		BUG()
 
-- 
2.1.0

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
