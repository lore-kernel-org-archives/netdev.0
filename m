From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Tue, 22 Jul 2008 09:50:00 +0200
Message-ID: <20080722075000.GB15807@elte.hu>
References: <20080721115555.GA24176@elte.hu> <20080721192138.GA27672@elte.hu> <20080721212447.GA10107@2ka.mipt.ru> <20080721.163349.113841731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, penberg@cs.helsinki.fi,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	vegard.nossum@gmail.com, rjw@sisk.pl, cl@linux-foundation.org,
	auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753798AbYGVHu7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080721.163349.113841731.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Tue, 22 Jul 2008 01:24:48 +0400
> 
> > On Mon, Jul 21, 2008 at 09:21:38PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> > > So it's now a strong likelyhood that this crash is a combination of 
> > > e1000e+netconsole.
> > 
> > e1000_clean_tx_irq() call looks particulary suspicious: it is called
> > without adapter->tx_queue_lock in poll controller (netconsole callback)
> > and with that lock in NAPI handler.
> > 
> > Can you check kind of this patch:
> 
> The call even seems pointless, since the caller will call ->poll() 
> (which is e1000_clean) as the very next action, and that will invoke 
> e1000_clean_tx_irq() properly.
> 
> I would just delete this call from e1000_netpoll() entirely.

ok, i've added the patch below to tip/out-of-tree.

Overnight test had about 100 successful bootups on this testbox. (until 
it stopped on a drivers/net/hp.c build error - which is unrelated to 
this problem)

So testing with netconsole disabled is conclusive enough to implicate 
netconsole strongly. I've now re-enabled netconsole on the testbox and 
will continue the test with the fix below. Previously it would crash 
within 10-40 iterations.

	Ingo

----------------->
commit bf89280dea6d97671aa5f75f2591ae7e8e3e6699
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Jul 22 09:44:32 2008 +0200

    e1000e: fix e1000_netpoll(), remove extraneous e1000_clean_tx_irq() call
    
    Evgeniy Polyakov noticed that drivers/net/e1000e/netdev.c:e1000_netpoll()
    was calling e1000_clean_tx_irq() without taking the TX lock.
    
    David Miller suggested to remove the call altogether: since in this
    callpah there's periodic calls to ->poll() anyway which will do
    e1000_clean_tx_irq() and will garbage-collect any finished TX ring
    descriptors.
    
    This might solve the e1000e+netconsole crashes i've been seeing:
    
    =============================================================================
    BUG skbuff_head_cache: Poison overwritten
    -----------------------------------------------------------------------------
    
    INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b
    INFO: Allocated in __alloc_skb+0x2c/0x110 age=0 cpu=0 pid=5098
    INFO: Freed in __kfree_skb+0x31/0x80 age=0 cpu=1 pid=4440
    INFO: Slab 0xc16cc140 objects=16 used=1 fp=0xf658ae00 flags=0x400000c3
    INFO: Object 0xf658ae00 @offset=3584 fp=0xf658af00
    
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/e1000e/netdev.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 869544b..9c0f56b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4067,8 +4067,6 @@ static void e1000_netpoll(struct net_device *netdev)
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
 
-	e1000_clean_tx_irq(adapter);
-
 	enable_irq(adapter->pdev->irq);
 }
 #endif
