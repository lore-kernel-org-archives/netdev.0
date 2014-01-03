From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in skb_page_frag_refill
Date: Fri, 3 Jan 2014 17:47:20 -0500
Message-ID: <CAATkVExrpHZHDFFdfR2ab7SeFSBLyAm0BLoVqLDGHF1ZPwEBZA@mail.gmail.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<20131224.174647.2276571374631580479.davem@davemloft.net>
	<CAATkVExsrzKyx3da=sApxdR5DJRTWBw1MOcLE9WiWQN56WfcdA@mail.gmail.com>
	<1388710591.12212.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<1388712396.12212.112.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAATkVEyL-7W4aa_U+_7ZsqnyR0AnAskBNejzeUZD+jE8CmRdhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Michael Dalton <mwdalton@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com,
	jasowang@redhat.com, virtualization@lists.linux-foundation.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>, jbaron@akamai.com,
	Joshua Hunt <johunt@akamai.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:41502 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181AbaACWrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 17:47:21 -0500
Received: by mail-oa0-f50.google.com with SMTP id n16so16873076oag.9
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 14:47:20 -0800 (PST)
In-Reply-To: <CAATkVEyL-7W4aa_U+_7ZsqnyR0AnAskBNejzeUZD+jE8CmRdhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> On Thu, 2014-01-02 at 16:56 -0800, Eric Dumazet wrote:
>>
>> Hmm... it looks like I missed __GFP_NORETRY
>>
>>
>>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 5393b4b719d7..5f42a4d70cb2 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1872,7 +1872,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
>>                 gfp_t gfp = prio;
>>
>>                 if (order)
>> -                       gfp |= __GFP_COMP | __GFP_NOWARN;
>> +                       gfp |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
>>                 pfrag->page = alloc_pages(gfp, order);
>>                 if (likely(pfrag->page)) {
>>                         pfrag->offset = 0;
>>
>>
>>

There is another patch needed (looks like good stable fixes):
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 06e72d3..d42d48c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -378,7 +378,7 @@ refill:
                        gfp_t gfp = gfp_mask;

                        if (order)
-                               gfp |= __GFP_COMP | __GFP_NOWARN;
+                               gfp |= __GFP_COMP | __GFP_NOWARN |
__GFP_NORETRY;
                        nc->frag.page = alloc_pages(gfp, order);
                        if (likely(nc->frag.page))
                                break;

This reduces the really pathological compact/reclaim behavior but
doesn't fix it. Actually it still really quite bad because the whole
thing loops until it gets to order-0 so it's effectively trying the
allocation 4 times anyway. I typically see non-zero order allocations
very rarely without these two pieces of code. I hotpatched a running
system to get results from this quickly. Even setting the max order to
order-1 I still see bad behavior. If anything this behavior should be
conditional until this is ironed out.

Performance data: http://pastebin.ubuntu.com/6687527/

-Debabrata
