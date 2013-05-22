From: Florian Westphal <fw@strlen.de>
Subject: Re: sk_page_frag_refill OOM killing spree
Date: Wed, 22 May 2013 10:26:39 +0200
Message-ID: <20130522082639.GB32299@breakpoint.cc>
References: <20130521122845.GD16412@breakpoint.cc>
 <1369150280.3301.230.camel@edumazet-glaptop>
 <alpine.DEB.2.02.1305211309100.31504@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Rientjes <rientjes@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44303 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753295Ab3EVI0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 04:26:43 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305211309100.31504@chino.kir.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Rientjes <rientjes@google.com> wrote:
> > On Tue, 2013-05-21 at 14:28 +0200, Florian Westphal wrote:
> > > seems like sk_page_frag_refill() can cause oom-killer invocation:
> > > 
> > > postgres invoked oom-killer: gfp_mask=0x42d0, order=3, oom_score_adj=0
> > > Pid: 10551, comm: postgres Tainted: G           O 3.8.6-5.g613ca40-smp #1
> > > Call Trace:
> > >  [<c106dbd5>] ? dump_header+0x60/0x191
> > >  [<c1133d3a>] ? ___ratelimit+0xb2/0xc4
> > >  [<c106dfd3>] ? oom_kill_process+0x61/0x2d1
> > >  [<c1030042>] ? has_capability_noaudit+0x1c/0x23
> > >  [<c106df0f>] ? oom_badness+0x8c/0xef
> > >  [<c106e446>] ? out_of_memory+0x203/0x247
> > >  [<c107128a>] ? __alloc_pages_nodemask+0x42b/0x4c3
> > >  [<c11fa66a>] ? sk_page_frag_refill+0x6a/0xd2
> > >  [<c1233548>] ? tcp_sendmsg+0x3e8/0x7c6
> > >  [<c124f34b>] ? inet_sendmsg+0x6b/0x75
> > >  [<c11f74d8>] ? sock_sendmsg+0x8d/0xa6
> > >  [<c11f7b83>] ? sys_sendto+0x105/0x130
> > >  [<c1025927>] ? __kunmap_atomic+0x62/0x8a
> > >  [<c1025940>] ? __kunmap_atomic+0x7b/0x8a
> > >  [<c1073d78>] ? __lru_cache_add+0x18/0x47
> > >  [<c10812f9>] ? handle_pte_fault+0x745/0x751
> > >  [<c1025a2d>] ? kmap_atomic_prot+0xd3/0xf1
> > >  [<c10817da>] ? handle_mm_fault+0x112/0x121
> > >  [<c11f7be5>] ? sys_send+0x37/0x3b
> > > 
> > > The system is busy, so, order-3 alloc failure doesn't strike me as odd.
> > > 
> > > There are no allocation failures with order != 3.
> > > 
> > > Sometimes this can happen in very short sucession, i.e.
> > > and oom-killer did end up zapping 30 processes or so.
> 
> Aside from the __GFP_NORETRY issue, could you post the full oom killer log 
> where it kills more than one process with /proc/sys/vm/oom_dump_tasks 
> enabled?  That shouldn't happen unless you have a memory leak.

http://strlen.de/fw/oom.txt

HOWEVER, before you spend time on this:
I don't think there is an issue with oom killer, I only noticed
that after kernel update oom killer invocations are
 a) more frequent than before
 b) often show above backtrace (sk_page_frag_refill).

I'm not even saying "sk_page_frag_refill is broken", since I don't know if
adding GFP_NORETRY might add silent performance degradation, etc.

Its very well possible that everything is working as intended :-)
