From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: softirq warnings when calling dev_kfree_skb_irq - bug in
 conntrack?
Date: Tue, 03 Aug 2010 09:04:34 +0200
Message-ID: <1280819074.3874.8.camel@jlt3.sipsolutions.net>
References: <4C571476.7070301@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	"Xu, Dongxiao" <dongxiao.xu@intel.com>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:36168 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755245Ab0HCHEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 03:04:46 -0400
In-Reply-To: <4C571476.7070301@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-02 at 11:54 -0700, Jeremy Fitzhardinge wrote:

> ------------[ cut here ]------------
> WARNING: at kernel/softirq.c:143 local_bh_enable+0x40/0x87()
> Modules linked in: xt_state dm_mirror dm_region_hash dm_log microcode [last unloaded: scsi_wait_scan]
> Pid: 0, comm: swapper Not tainted 2.6.35-rc6-next-20100729+ #29
> Call Trace:
>   <IRQ>   [<ffffffff81030de3>] warn_slowpath_common+0x80/0x98
>   [<ffffffff81030e10>] warn_slowpath_null+0x15/0x17
>   [<ffffffff81035ff3>] local_bh_enable+0x40/0x87
>   [<ffffffff814236e5>] destroy_conntrack+0x78/0x9e
>   [<ffffffff810bea55>] ? __kmalloc_track_caller+0xc3/0x135
>   [<ffffffff814203b4>] nf_conntrack_destroy+0x16/0x18
>   [<ffffffff813fadee>] skb_release_head_state+0x97/0xd9
>   [<ffffffff813fabbe>] __kfree_skb+0x11/0x7a
>   [<ffffffff813fac4e>] consume_skb+0x27/0x29
>   [<ffffffff81402d3a>] dev_kfree_skb_irq+0x18/0x62
>   [<ffffffff8130a762>] xennet_tx_buf_gc+0xfc/0x192
>   [<ffffffff8130a8fb>] smart_poll_function+0x50/0x121
>   [<ffffffff8130a8ab>] ? smart_poll_function+0x0/0x121
>   [<ffffffff8104b8d1>] __run_hrtimer+0xcc/0x127
>   [<ffffffff8104bad3>] hrtimer_interrupt+0x9c/0x17b

> It seems the basic problem is that xennet_tx_buf_gc() is being called in 
> interrupt context - with smartpoll it's from the timer interrupt, but 
> even without it is being called from xennet_interrupt(), which in turn 
> calls dev_kfree_skb_irq().
> 
> Since this should be perfectly OK, it appears the problem is actually in 
> conntrack.  I'm not sure where this bug started happening, but its 
> relatively recently I think.

I had this too:
http://article.gmane.org/gmane.linux.network/167590

But I'm not convinced it's conntrack, I'd think it's

commit 15e83ed78864d0625e87a85f09b297c0919a4797
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed May 19 23:16:03 2010 +0000

    net: remove zap_completion_queue

which, from the looks of it, ought to be reverted because it failed to
take into account that dev_kfree_skb() can do more things that require
non-irq-context than just calling skb->destructor, like for instance the
conntrack thing we see here.

johannes

