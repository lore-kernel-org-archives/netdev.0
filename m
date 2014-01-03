From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in
	skb_page_frag_refill
Date: Fri, 03 Jan 2014 14:54:53 -0800
Message-ID: <1388789693.12212.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<20131224.174647.2276571374631580479.davem@davemloft.net>
	<CAATkVExsrzKyx3da=sApxdR5DJRTWBw1MOcLE9WiWQN56WfcdA@mail.gmail.com>
	<1388710591.12212.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<1388712396.12212.112.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAATkVEyL-7W4aa_U+_7ZsqnyR0AnAskBNejzeUZD+jE8CmRdhw@mail.gmail.com>
	<CAATkVExrpHZHDFFdfR2ab7SeFSBLyAm0BLoVqLDGHF1ZPwEBZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Banerjee, Debabrata" <dbanerje@akamai.com>,
	Michael Dalton <mwdalton@google.com>, mst@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jbaron@akamai.com, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, Joshua Hunt <johunt@akamai.com>,
	David Miller <davem@davemloft.net>
To: Debabrata Banerjee <dbavatar@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAATkVExrpHZHDFFdfR2ab7SeFSBLyAm0BLoVqLDGHF1ZPwEBZA@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-03 at 17:47 -0500, Debabrata Banerjee wrote:
> >> On Thu, 2014-01-02 at 16:56 -0800, Eric Dumazet wrote:
> >>
> >> Hmm... it looks like I missed __GFP_NORETRY
> >>
> >>
> >>
> >> diff --git a/net/core/sock.c b/net/core/sock.c
> >> index 5393b4b719d7..5f42a4d70cb2 100644
> >> --- a/net/core/sock.c
> >> +++ b/net/core/sock.c
> >> @@ -1872,7 +1872,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
> >>                 gfp_t gfp = prio;
> >>
> >>                 if (order)
> >> -                       gfp |= __GFP_COMP | __GFP_NOWARN;
> >> +                       gfp |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
> >>                 pfrag->page = alloc_pages(gfp, order);
> >>                 if (likely(pfrag->page)) {
> >>                         pfrag->offset = 0;
> >>
> >>
> >>
> 
> There is another patch needed (looks like good stable fixes):
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 06e72d3..d42d48c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -378,7 +378,7 @@ refill:
>                         gfp_t gfp = gfp_mask;
> 
>                         if (order)
> -                               gfp |= __GFP_COMP | __GFP_NOWARN;
> +                               gfp |= __GFP_COMP | __GFP_NOWARN |
> __GFP_NORETRY;
>                         nc->frag.page = alloc_pages(gfp, order);
>                         if (likely(nc->frag.page))
>                                 break;
> 

This is in GFP_ATOMIC cases, I dont think it can ever start compaction.

> This reduces the really pathological compact/reclaim behavior but
> doesn't fix it. Actually it still really quite bad because the whole
> thing loops until it gets to order-0 so it's effectively trying the
> allocation 4 times anyway. I typically see non-zero order allocations
> very rarely without these two pieces of code. I hotpatched a running
> system to get results from this quickly. Even setting the max order to
> order-1 I still see bad behavior. If anything this behavior should be
> conditional until this is ironed out.
> 
> Performance data: http://pastebin.ubuntu.com/6687527/

It seems that you shoot the messenger : If memory is fragmented, then
one order-1 allocation is going to start compaction.

It can be a simple fork().

If your workload never fork(), then yes, you never needed compaction.

It doesn't really matter to say that which memory allocation triggered
compaction, which is a normal step in mm layer.

If you believe its badly done, you should ask to mm guys to fix/improve
it, not netdev...

We are not trying to optimize the kernel behavior for hosts in deep
memory pressure.

Using order-3 pages in TCP stack improves performance for 99% of the
hosts, there might be something wrong on your side ?
