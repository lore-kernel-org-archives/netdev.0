From: tony@bakeyournoodle.com (Tony Breeds)
Subject: Re: linux-next: Tree for May 14
Date: Thu, 15 May 2008 11:05:50 +1000
Message-ID: <20080515010550.GL20457@bakeyournoodle.com>
References: <20080514170106.3cbcb201.sfr@canb.auug.org.au> <Pine.LNX.4.64.0805142237240.11631@anakin> <20080514135008.60e5df96.randy.dunlap@oracle.com> <20080514210447.GK20457@bakeyournoodle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514210447.GK20457@bakeyournoodle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2008 at 07:04:47AM +1000, Tony Breeds wrote:
> On Wed, May 14, 2008 at 01:50:08PM -0700, Randy Dunlap wrote:
>  
> > Ugh.  Can you please make the log file more readable?
> > 
> > Or is a problem with my browser (firefox)?
> 
> It's a raw download, save it as a file and then view it (or look at the
> source).

FWIW the error in question is:
  Using /scratch1/tony/next as source for kernel
  GEN     /scratch1/tony/next_out/Makefile
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    /scratch1/tony/next/scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC [M]  drivers/net/zorro8390.o
In file included from /scratch1/tony/next/drivers/net/zorro8390.c:47:
/scratch1/tony/next/drivers/net/lib8390.c: In function 'ei_tx_err':
/scratch1/tony/next/drivers/net/lib8390.c:556: error: 'ei_local' undeclared (first use in this function)
/scratch1/tony/next/drivers/net/lib8390.c:556: error: (Each undeclared identifier is reported only once
/scratch1/tony/next/drivers/net/lib8390.c:556: error: for each function it appears in.)
/scratch1/tony/next/drivers/net/lib8390.c: In function 'ei_rx_overrun':
/scratch1/tony/next/drivers/net/lib8390.c:823: error: 'ei_local' undeclared (first use in this function)
make[3]: *** [drivers/net/zorro8390.o] Error 1
make[2]: *** [drivers/net] Error 2
make[1]: *** [drivers] Error 2
make: *** [sub-make] Error 2

It was introduced by 3f8cb098859bbea29d7b3765a3102e4a6bf81b85
(drivers/net/lib8390: fix warning, trim trailing whitespace)

The problem is that ei_inb_p() is using various #defines (from
drivers/net/8390.h) that use EI_SHIFT, which in the zorro8390 case uses
ei_local.  Since zorro8390 is only build for m68k, guard the definition of
ei_local with CONFIG_M68K

The patch below fixes the zorro8390 build, and I think will keep the warnings
that Jeff is trying to silence silenced.

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>

---

 drivers/net/lib8390.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index ed49527..a3d04a1 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -553,6 +553,9 @@ static void __ei_poll(struct net_device *dev)
 static void ei_tx_err(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
+#ifdef CONFIG_M68K
+	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+#endif
 	unsigned char txsr = ei_inb_p(e8390_base+EN0_TSR);
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
@@ -815,6 +818,9 @@ static void ei_rx_overrun(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
+#ifdef CONFIG_M68K
+	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+#endif
 
 	/*
 	 * Record whether a Tx was in progress and then issue the

Yours Tony

  linux.conf.au    http://www.marchsouth.org/
  Jan 19 - 24 2009 The Australian Linux Technical Conference!

