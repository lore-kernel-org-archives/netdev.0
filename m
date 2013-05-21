From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sk_page_frag_refill OOM killing spree
Date: Tue, 21 May 2013 08:31:20 -0700
Message-ID: <1369150280.3301.230.camel@edumazet-glaptop>
References: <20130521122845.GD16412@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130521122845.GD16412@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 14:28 +0200, Florian Westphal wrote:
> Hi Eric,
> 
> seems like sk_page_frag_refill() can cause oom-killer invocation:
> 
> postgres invoked oom-killer: gfp_mask=0x42d0, order=3, oom_score_adj=0
> Pid: 10551, comm: postgres Tainted: G           O 3.8.6-5.g613ca40-smp #1
> Call Trace:
>  [<c106dbd5>] ? dump_header+0x60/0x191
>  [<c1133d3a>] ? ___ratelimit+0xb2/0xc4
>  [<c106dfd3>] ? oom_kill_process+0x61/0x2d1
>  [<c1030042>] ? has_capability_noaudit+0x1c/0x23
>  [<c106df0f>] ? oom_badness+0x8c/0xef
>  [<c106e446>] ? out_of_memory+0x203/0x247
>  [<c107128a>] ? __alloc_pages_nodemask+0x42b/0x4c3
>  [<c11fa66a>] ? sk_page_frag_refill+0x6a/0xd2
>  [<c1233548>] ? tcp_sendmsg+0x3e8/0x7c6
>  [<c124f34b>] ? inet_sendmsg+0x6b/0x75
>  [<c11f74d8>] ? sock_sendmsg+0x8d/0xa6
>  [<c11f7b83>] ? sys_sendto+0x105/0x130
>  [<c1025927>] ? __kunmap_atomic+0x62/0x8a
>  [<c1025940>] ? __kunmap_atomic+0x7b/0x8a
>  [<c1073d78>] ? __lru_cache_add+0x18/0x47
>  [<c10812f9>] ? handle_pte_fault+0x745/0x751
>  [<c1025a2d>] ? kmap_atomic_prot+0xd3/0xf1
>  [<c10817da>] ? handle_mm_fault+0x112/0x121
>  [<c11f7be5>] ? sys_send+0x37/0x3b
> 
> The system is busy, so, order-3 alloc failure doesn't strike me as odd.
> 
> There are no allocation failures with order != 3.
> 
> Sometimes this can happen in very short sucession, i.e.
> and oom-killer did end up zapping 30 processes or so.
> 
> My question is, should sk_page_frag_refill use __GFP_NORETRY, at least
> for order 3 requests?

Yes, you may be right, but I prefer some mm expertise here, so I CC lkml
