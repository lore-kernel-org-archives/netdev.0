From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in skb_page_frag_refill
Date: Thu, 2 Jan 2014 20:59:13 -0500
Message-ID: <CAATkVEyL-7W4aa_U+_7ZsqnyR0AnAskBNejzeUZD+jE8CmRdhw@mail.gmail.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<20131224.174647.2276571374631580479.davem@davemloft.net>
	<CAATkVExsrzKyx3da=sApxdR5DJRTWBw1MOcLE9WiWQN56WfcdA@mail.gmail.com>
	<1388710591.12212.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<1388712396.12212.112.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, mwdalton@google.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	rusty@rustcorp.com.au, mst@redhat.com, jasowang@redhat.com,
	virtualization@lists.linux-foundation.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>, jbaron@akamai.com,
	Joshua Hunt <johunt@akamai.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:56030 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaACB7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 20:59:16 -0500
Received: by mail-ob0-f170.google.com with SMTP id wp18so15213701obc.1
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 17:59:13 -0800 (PST)
In-Reply-To: <1388712396.12212.112.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 8:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-01-02 at 16:56 -0800, Eric Dumazet wrote:
>
>>
>> My suggestion is to use a recent kernel, and/or eventually backport the
>> mm fixes if any.
>>
>> order-3 allocations should not reclaim 2GB out of 8GB.
>>
>> There is a reason PAGE_ALLOC_COSTLY_ORDER exists and is 3

Sorry 2GB cache out of 8GB phys, ~1GB gets reclaimed. Regardless the
reclaimation of cache is minor compared to the compaction event that
precedes it, I haven't spotted something addressing that yet -
isolate_migratepages_range ()/compact_checklock_irqsave(). If even
more of memory was unmoveable, the compaction routines would be hit
even harder as reclaimation wouldn't do anything - mm would have to
get very very smart about unmoveable pages being freed and just fail
allocations/oom kill if nothing has changed without running through
compaction/reclaim fruitlessly.

I guess this is a bit of a tangent since what I'm saying proves the
patch from Michael doesn't make this behavior worse.

>
> Hmm... it looks like I missed __GFP_NORETRY
>
>
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5393b4b719d7..5f42a4d70cb2 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1872,7 +1872,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
>                 gfp_t gfp = prio;
>
>                 if (order)
> -                       gfp |= __GFP_COMP | __GFP_NOWARN;
> +                       gfp |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
>                 pfrag->page = alloc_pages(gfp, order);
>                 if (likely(pfrag->page)) {
>                         pfrag->offset = 0;
>
>
>

Yes this seems like it will make the situation better, but one send()
may still cause a direct_compact and direct_reclaim() cycle to happen,
followed immediately by another direct_compact() if direct_reclaim()
didn't free an order-3. Now have all cpu's doing a send(), you can
still get heavy spinlock contention in the routines described above.
The major change I see here is that allocations > order-0 used to be
rare, now it's on every send().

I can try your patch to see how much things improve.

-Debabrata
