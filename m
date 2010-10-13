From: James Hogan <james@albanarts.com>
Subject: Re: [PATCH] b44: fix resume, request_irq after hw reset
Date: Wed, 13 Oct 2010 22:39:52 +0100
Message-ID: <201010132239.53550.james@albanarts.com>
References: <201010120022.13171.james@albanarts.com> <20101013.094659.226765041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, jpirko@redhat.com,
	fujita.tomonori@lab.ntt.co.jp, hauke@hauke-m.de,
	Larry.Finger@lwfinger.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45461 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab0JMVkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 17:40:47 -0400
In-Reply-To: <20101013.094659.226765041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 13 October 2010 17:46:59 David Miller wrote:
> From: James Hogan <james@albanarts.com>
> Date: Tue, 12 Oct 2010 00:22:12 +0100
> 
> > @@ -2309,6 +2303,12 @@ static int b44_resume(struct ssb_device *sdev)
> > 
> >  	netif_device_attach(bp->dev);
> >  	spin_unlock_irq(&bp->lock);
> > 
> > +	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, 
dev);
> > +	if (rc) {
> > +		netdev_err(dev, "request_irq failed\n");
> > +		return rc;
> > +	}
> > +
> > 
> >  	b44_enable_ints(bp);
> >  	netif_wake_queue(dev);
> 
> Since you've moved the request_irq() down, you'll need to adjust
> the error handling so that it undoes side effects made by this
> function up until this point.
> 
> F.e. netif_device_attach() has to be undone for one thing.
> 
> Next, b44_init_rings() allocates memory that you must now free.
> 
> Etc. etc. etc.
> 
> This change is not so simple. :-)

Very good point!

Does the ssb_bus_powerup need undoing as well? I'm guessing not since it
wasn't undone before.

How's the patch (at the bottom) looking? it does some better error handling 
and leaves the netif_device_attach(bp->dev); until after the irq is obtained.

I just noticed I actually get the following in my log after resume, so it 
appears something's going wrong even without the request_irq failing. Any idea 
what could be causing the padding to be overwritten? (my experience of net 
drivers and DMA are both non existent). If the net device is closed before 
suspend, this happens on open instead of resume.

Thanks
James

=============================================================================
BUG kmalloc_dma-2048: Padding overwritten. 
0xffff88000003fda8-0xffff88000003fdff
-----------------------------------------------------------------------------

INFO: Slab 0xffffea0000000c40 objects=15 used=1 fp=0xffff880000038000 
flags=0x40c1
Pid: 21848, comm: bash Not tainted 2.6.36-rc7-custom+ #18
Call Trace:
 [<ffffffff8111582d>] slab_err+0xaa/0xcc
 [<ffffffff81006666>] ? xen_set_pud+0x18/0x49
 [<ffffffff811171f4>] ? unfreeze_slab+0x53/0xb0
 [<ffffffff8111756c>] ? get_partial_node+0x20/0x79
 [<ffffffff81115cbd>] slab_pad_check+0xd2/0x124
 [<ffffffff81115da4>] check_slab+0x95/0x9c
 [<ffffffff811178eb>] __slab_alloc+0x326/0x42a
 [<ffffffff813d9096>] ? __netdev_alloc_skb+0x34/0x52
 [<ffffffff812467c6>] ? should_fail+0x91/0xf3
 [<ffffffff81119abb>] __kmalloc_node_track_caller+0x115/0x193
 [<ffffffff813d9096>] ? __netdev_alloc_skb+0x34/0x52
 [<ffffffff813d8076>] __alloc_skb+0x83/0x141
 [<ffffffff813d9096>] __netdev_alloc_skb+0x34/0x52
 [<ffffffffa030f6cf>] b44_alloc_rx_skb+0xf9/0x247 [b44]
 [<ffffffffa03b8000>] ? ssb_device_resume+0x0/0x36 [ssb]
 [<ffffffffa030f8b0>] b44_init_rings+0x93/0xa8 [b44]
 [<ffffffffa030fab3>] b44_resume+0x86/0x142 [b44]
 [<ffffffffa03b8030>] ssb_device_resume+0x30/0x36 [ssb]
 [<ffffffff813031df>] legacy_resume+0x24/0x5c
 [<ffffffff81303b9e>] device_resume+0xcd/0x1ba
 [<ffffffff81303dc3>] dpm_resume_end+0x138/0x3d8
 [<ffffffff8108db83>] suspend_devices_and_enter+0x1ba/0x203
 [<ffffffff8108dcb3>] enter_state+0xe7/0x12e
 [<ffffffff8108d3a5>] state_store+0xb6/0xd3
 [<ffffffff81235877>] kobj_attr_store+0x17/0x19
 [<ffffffff81183223>] sysfs_write_file+0x108/0x144
 [<ffffffff81126330>] vfs_write+0xae/0x10a
 [<ffffffff8112644f>] sys_write+0x4d/0x74
 [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
 Padding 0xffff88000003fa38:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 
ZZZZZZZZZZZZZZZZ
  <snip>
 Padding 0xffff88000003fd98:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 
ZZZZZZZZZZZZZZZZ
 Padding 0xffff88000003fda8:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
................
 Padding 0xffff88000003fdb8:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
................
 Padding 0xffff88000003fdc8:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
................
 Padding 0xffff88000003fdd8:  00 00 00 00 5a 5a 5a 5a 00 00 00 00 00 00 00 00 
....ZZZZ........
 Padding 0xffff88000003fde8:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
................
 Padding 0xffff88000003fdf8:  64 2a 8b 00 00 00 00 00                         
d*......        




---
 drivers/net/b44.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 1e620e2..5fd251c 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2296,16 +2296,22 @@ static int b44_resume(struct ssb_device *sdev)
 	if (!netif_running(dev))
 		return 0;
 
+	spin_lock_irq(&bp->lock);
+	b44_init_rings(bp);
+	b44_init_hw(bp, B44_FULL_RESET);
+	spin_unlock_irq(&bp->lock);
+
 	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc) {
 		netdev_err(dev, "request_irq failed\n");
+		spin_lock_irq(&bp->lock);
+		b44_halt(bp);
+		b44_free_rings(bp);
+		spin_unlock_irq(&bp->lock);
 		return rc;
 	}
 
 	spin_lock_irq(&bp->lock);
-
-	b44_init_rings(bp);
-	b44_init_hw(bp, B44_FULL_RESET);
 	netif_device_attach(bp->dev);
 	spin_unlock_irq(&bp->lock);
 
-- 
1.7.2.3

