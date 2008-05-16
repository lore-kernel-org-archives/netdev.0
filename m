From: tony@bakeyournoodle.com (Tony Breeds)
Subject: Re: linux-next: Tree for May 14
Date: Fri, 16 May 2008 12:10:09 +1000
Message-ID: <20080516021009.GS20457@bakeyournoodle.com>
References: <20080514170106.3cbcb201.sfr@canb.auug.org.au> <Pine.LNX.4.64.0805142237240.11631@anakin> <20080514135008.60e5df96.randy.dunlap@oracle.com> <20080514210447.GK20457@bakeyournoodle.com> <20080515010550.GL20457@bakeyournoodle.com> <Pine.LNX.4.64.0805150914220.11631@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805150914220.11631@anakin>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2008 at 09:17:15AM +0200, Geert Uytterhoeven wrote:
 
> Wow, did you really get all of this from that webpage??

Sorry no.  I ran the build again ... mmm cross compilers :)

> Thanks for chasing this down!

np.
 
> Technically, it could also happen on PPC (APUS), but all APUS support got
> removed a few months ago.
> So maybe CONFIG_ZORRO is more appropriate?

Well as it turns out it can happen in a few other plcaes (the same error
is visible on sh aswell:
	http://kisskb.ellerman.id.au/kisskb/buildresult/27769/ )

Below is a new fix. Thoughts?.

From: Tony Breeds <tony@bakeyournoodle.com>
Subject: [PATCH] Fix various 8390 builds

The commit 3f8cb098859bbea29d7b3765a3102e4a6bf81b85
(drivers/net/lib8390: fix warning, trim trailing whitespace) removed
ei_local from ei_tx_err() and ei_rx_overrun() resulting in the following
build errors on m68k and sh:

  Using /scratch1/tony/next as source for kernel
  GEN     /scratch1/tony/next_out/Makefile
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    /scratch1/tony/next/scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC [M]  drivers/net/zorro8390.o
In file included from /scratch1/tony/next/drivers/net/zorro8390.c:47:
drivers/net/lib8390.c: In function 'ei_tx_err':
drivers/net/lib8390.c:556: error: 'ei_local' undeclared (first use in this function)
drivers/net/lib8390.c:556: error: (Each undeclared identifier is reported only once
drivers/net/lib8390.c:556: error: for each function it appears in.)
drivers/net/lib8390.c: In function 'ei_rx_overrun':
drivers/net/lib8390.c:823: error: 'ei_local' undeclared (first use in this function)
make[3]: *** [drivers/net/zorro8390.o] Error 1
make[2]: *** [drivers/net] Error 2
make[1]: *** [drivers] Error 2
make: *** [sub-make] Error 2

The problem is that ei_inb_p() is using various #defines (from
drivers/net/8390.h) that use EI_SHIFT, which in some drivers on some
architectures use ei_local.  Tag ei_local as "__maybe_unused" to keep it
around and keep the warnings the original commit is trying to silence
... silenced.

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
---
 drivers/net/lib8390.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index ed49527..fb00268 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -553,6 +553,9 @@ static void __ei_poll(struct net_device *dev)
 static void ei_tx_err(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
+	/* ei_local is used on some platforms via the EI_SHIFT macro */
+	struct ei_device *ei_local __maybe_unused =
+		(struct ei_device *) netdev_priv(dev);
 	unsigned char txsr = ei_inb_p(e8390_base+EN0_TSR);
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
@@ -815,6 +818,9 @@ static void ei_rx_overrun(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
+	/* ei_local is used on some platforms via the EI_SHIFT macro */
+	struct ei_device *ei_local __maybe_unused =
+		(struct ei_device *) netdev_priv(dev);
 
 	/*
 	 * Record whether a Tx was in progress and then issue the
-- 
1.5.5.1

