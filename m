From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use __GFP_NORETRY for high order allocations
Date: Thu, 06 Feb 2014 18:09:56 -0800
Message-ID: <1391738996.10160.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391712162.10160.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87txcbisr8.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	David Rientjes <rientjes@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87txcbisr8.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-02-06 at 18:03 -0800, Eric W. Biederman wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > From: Eric Dumazet <edumazet@google.com>
> >
> > sock_alloc_send_pskb() & sk_page_frag_refill()
> > have a loop trying high order allocations to prepare
> > skb with low number of fragments as this increases performance.
> >
> > Problem is that under memory pressure/fragmentation, this can
> > trigger OOM while the intent was only to try the high order
> > allocations, then fallback to order-0 allocations.
> >
> > We had various reports from unexpected regressions.
> >
> > According to David, setting __GFP_NORETRY should be fine,
> > as the asynchronous compaction is still enabled, and this
> > will prevent OOM from kicking as in :
> >
> > CFSClientEventm invoked oom-killer: gfp_mask=0x42d0, order=3, oom_adj=0,
> > oom_score_adj=0, oom_score_badness=2 (enabled),memcg_scoring=disabled
> > CFSClientEventm 
> >
> > Call Trace:
> >  [<ffffffff8043766c>] dump_header+0xe1/0x23e
> >  [<ffffffff80437a02>] oom_kill_process+0x6a/0x323
> >  [<ffffffff80438443>] out_of_memory+0x4b3/0x50d
> >  [<ffffffff8043a4a6>] __alloc_pages_may_oom+0xa2/0xc7
> >  [<ffffffff80236f42>] __alloc_pages_nodemask+0x1002/0x17f0
> >  [<ffffffff8024bd23>] alloc_pages_current+0x103/0x2b0
> >  [<ffffffff8028567f>] sk_page_frag_refill+0x8f/0x160
> >  [<ffffffff80295fa0>] tcp_sendmsg+0x560/0xee0
> >  [<ffffffff802a5037>] inet_sendmsg+0x67/0x100
> >  [<ffffffff80283c9c>] __sock_sendmsg_nosec+0x6c/0x90
> >  [<ffffffff80283e85>] sock_sendmsg+0xc5/0xf0
> >  [<ffffffff802847b6>] __sys_sendmsg+0x136/0x430
> >  [<ffffffff80284ec8>] sys_sendmsg+0x88/0x110
> >  [<ffffffff80711472>] system_call_fastpath+0x16/0x1b
> > Out of Memory: Kill process 2856 (bash) score 9999 or sacrifice child
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> I have seen similiar order 3 allocation failures as well and reached the
> same conclusion that __GFP_NORETRY was the solution.

Thanks Eric !
