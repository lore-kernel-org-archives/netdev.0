From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [git patches] net driver updates for .27
Date: Mon, 2 Jun 2008 10:41:37 +1000
Message-ID: <20080602104137.8d8c0db5.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tony Breeds <tony@bakeyournoodle.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:46035 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755AbYFBAlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jun 2008 20:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Another update, another ping ....

Begin forwarded message:

Date: Thu, 29 May 2008 22:39:28 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Jeff Garzik <jeff@garzik.org>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Breeds <tony@bakeyournoodle.com>
Subject: Re: [git patches] net driver updates for .27


Hi Jeff,

On Thu, 29 May 2008 03:33:02 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>
> From: Jeff Garzik <jeff@garzik.org>
> Date: Thu, 22 May 2008 15:10:49 -0400
> 
> > Please pull from 'upstream-next-davem' branch of
> > master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-next-davem

Is there some reason you missed "Fix various 8390 builds" from Tony
Breeds.  I have been carrying it in linux-next for some time and would
appreciate it being merged.  It fixes a build regression in the current
net-next tree.

I have included the patch below.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

Date: Mon, 19 May 2008 15:03:52 +1000
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@redhat.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Randy Dunlap <randy.dunlap@oracle.com>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Linux/m68k <linux-m68k@vger.kernel.org>
Subject: [PATCH v3] Fix various 8390 builds
From: tony@bakeyournoodle.com (Tony Breeds)

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
Updated to remove pointless casts

 drivers/net/lib8390.c |    4 ++++
 1 file changed, 4 insertions(+)

 Dave, Jeff can one of you take this?


diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index ed49527..00d59ab 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -553,6 +553,8 @@ static void __ei_poll(struct net_device *dev)
 static void ei_tx_err(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
+	/* ei_local is used on some platforms via the EI_SHIFT macro */
+	struct ei_device *ei_local __maybe_unused = netdev_priv(dev);
 	unsigned char txsr = ei_inb_p(e8390_base+EN0_TSR);
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
@@ -815,6 +817,8 @@ static void ei_rx_overrun(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
+	/* ei_local is used on some platforms via the EI_SHIFT macro */
+	struct ei_device *ei_local __maybe_unused = netdev_priv(dev);
 
 	/*
 	 * Record whether a Tx was in progress and then issue the
