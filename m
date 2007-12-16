From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Fw: [PACKET]: Fix /proc/net/packet crash due to bogus private
 pointer
Date: Sun, 16 Dec 2007 14:23:44 -0800
Message-ID: <20071216142344.802ceaf4.akpm@linux-foundation.org>
References: <20071215203637.179878aa.akpm@linux-foundation.org>
	<a44ae5cd0712152237y2f6a17fcu6a718757c7c021a3@mail.gmail.com>
	<20071215235604.1a3f970a.akpm@linux-foundation.org>
	<20071216081936.GA3042@gondor.apana.org.au>
	<a44ae5cd0712161210h4908f39coe3b5cdb346b8d632@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Miles Lane" <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34005 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756535AbXLPWYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 17:24:50 -0500
In-Reply-To: <a44ae5cd0712161210h4908f39coe3b5cdb346b8d632@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 15:10:14 -0500 "Miles Lane" <miles.lane@gmail.com> wrote:

> On Dec 16, 2007 3:19 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > On Sat, Dec 15, 2007 at 11:56:04PM -0800, Andrew Morton wrote:
> > > On Sun, 16 Dec 2007 01:37:01 -0500 "Miles Lane" <miles.lane@gmail.com> wrote:
> > >
> > > > > On Sun, Dec 16, 2007 at 11:07:07AM +0800, Herbert Xu wrote:
> >
> > So I posted this patch after 19:00 PST on 15 Dec.
> >
> > > > Dec 15 13:44:39 syntropy kernel:  #0:  (&p->lock){--..}, at:
> > > > [crypto_algapi:seq_read+0x25/0x191c1] seq_read+0x25/0x26f
> > >
> > > So your kernel is still feeding garbage into lockdep.
> > >
> > > Are you really really sure that kernel had Herbert's patch applied?
> >
> > The above log message is stamped as 13:44 PST.  I gotta say
> > this doesn't look good :)
> 
> Yes, I did have the patch applied, but I had reenabled LOCKDEP_DEBUG.
> I just tried with the LOCKDEP_DEBUG stuff turned off, and with this
> configuration, the problem is resolved.  It seems that the patch
> you made does fix the problem with /proc/net/packet. This new issue
> seems to be a different problem.
> 
> So, I tried building another kernel with LOCKDEP enabled (.config attached):
> With this kernel, I got:
> 
> Dec 16 11:21:39 syntropy kernel: [  278.723108] process `tail' is
> using deprecated sysctl (syscall) net.ipv6.neigh.default.retrans_time;
> Use net.ipv6.neigh.default.retrans_time_ms instead.
> Dec 16 11:21:40 syntropy kernel: [  279.226103] in_atomic():1, irqs_disabled():0
> Dec 16 11:21:40 syntropy kernel: [  279.226106] no locks held by tail/6208.
> Dec 16 11:21:40 syntropy kernel: [  279.226109] Pid: 6208, comm: tail
> Not tainted 2.6.24-rc5-mm1 #5
> Dec 16 11:21:40 syntropy kernel: [  279.226112]
> [show_trace_log_lvl+0x12/0x25] show_trace_log_lvl+0x12/0x25
> Dec 16 11:21:40 syntropy kernel: [  279.226121]  [show_trace+0xd/0x10]
> show_trace+0xd/0x10
> Dec 16 11:21:40 syntropy kernel: [  279.226126]
> [sbp2:dump_stack+0x57/0x17c1] dump_stack+0x57/0x5f
> Dec 16 11:21:40 syntropy kernel: [  279.226130]
> [firewire_core:__might_sleep+0xd7/0x29a] __might_sleep+0xd7/0xde
> Dec 16 11:21:40 syntropy kernel: [  279.226136]
> [parport:copy_to_user+0x32/0xd13f] copy_to_user+0x32/0x47
> Dec 16 11:21:40 syntropy kernel: [  279.226141]
> [add_to_pagemap+0x29/0x56] add_to_pagemap+0x29/0x56
> Dec 16 11:21:40 syntropy kernel: [  279.226147]
> [pagemap_pte_range+0x74/0xb1] pagemap_pte_range+0x74/0xb1
> Dec 16 11:21:40 syntropy kernel: [  279.226151]
> [walk_page_range+0x115/0x1dc] walk_page_range+0x115/0x1dc
> Dec 16 11:21:40 syntropy kernel: [  279.226157]
> [pagemap_read+0x154/0x1e8] pagemap_read+0x154/0x1e8
> Dec 16 11:21:40 syntropy kernel: [  279.226161]  [vfs_read+0xa2/0x11e]
> vfs_read+0xa2/0x11e
> Dec 16 11:21:40 syntropy kernel: [  279.226166]  [sys_read+0x3b/0x60]
> sys_read+0x3b/0x60
> Dec 16 11:21:40 syntropy kernel: [  279.226170]
> [sysenter_past_esp+0x6b/0xc1] sysenter_past_esp+0x6b/0xc1

(Can you find a way to fix that wordwrapping please?)

Yes, this is a different bug - the pagemap stuff is doing userspace access
under kmap_atomic() - we discovered this a couple of days ago and Matt has
been informed.

It's relatively harmless and if that's the only problem you're observing
then I think we're OK here.

