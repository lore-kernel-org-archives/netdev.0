From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in skb_page_frag_refill
Date: Fri, 3 Jan 2014 18:27:11 -0500
Message-ID: <CAATkVExrEiETydLxuHjpy9hwXhNx9Cq1jP1-4f_2TiGiZZ=qCQ@mail.gmail.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<20131224.174647.2276571374631580479.davem@davemloft.net>
	<CAATkVExsrzKyx3da=sApxdR5DJRTWBw1MOcLE9WiWQN56WfcdA@mail.gmail.com>
	<1388710591.12212.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<1388712396.12212.112.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAATkVEyL-7W4aa_U+_7ZsqnyR0AnAskBNejzeUZD+jE8CmRdhw@mail.gmail.com>
	<CAATkVExrpHZHDFFdfR2ab7SeFSBLyAm0BLoVqLDGHF1ZPwEBZA@mail.gmail.com>
	<1388789693.12212.149.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mail-oa0-f41.google.com ([209.85.219.41]:51838 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbaACX1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 18:27:12 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so16752105oag.14
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 15:27:11 -0800 (PST)
In-Reply-To: <1388789693.12212.149.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 3, 2014 at 5:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> This is in GFP_ATOMIC cases, I dont think it can ever start compaction.

I think that's right I probably finally got it back to normal behavior
with order-0 allocations.

>
> It seems that you shoot the messenger : If memory is fragmented, then
> one order-1 allocation is going to start compaction.
>
> It can be a simple fork().
>
> If your workload never fork(), then yes, you never needed compaction.
>

Sure but the rate of network packets in and out and subsequent
allocations would be more equivalent to a fork bomb than normal
forking. I understand mm should work more sanely in this scenario but
at the same time we see a bad regression with this code, I see we're
not alone.

>
> We are not trying to optimize the kernel behavior for hosts in deep
> memory pressure.

We're leaving about half for the kernel so I wouldn't call it "deep".
Any server application that is using page cache and mlocked memory
will run into similar issues.

> It doesn't really matter to say that which memory allocation triggered
> compaction, which is a normal step in mm layer.
>
> If you believe its badly done, you should ask to mm guys to fix/improve
> it, not netdev...
>
> Using order-3 pages in TCP stack improves performance for 99% of the
> hosts, there might be something wrong on your side ?
>

Having lots of memory mlocked is bad right now yes, but not
necessarily an uncommon scenario. We're handing mm an almost
intractable problem. I see compaction of mlocked pages has been
discussed a few times over there, but no patch has actually made it
in.

-Debabrata
