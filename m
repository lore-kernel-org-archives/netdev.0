From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netem: the reorder discussion
Date: Fri, 23 Aug 2013 08:12:36 -0700
Message-ID: <1377270756.8828.5.camel@edumazet-glaptop>
References: <766825FB-5295-4C5C-ABA0-CC520EFE2EA6@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ferry Huberts <mailings@hupie.com>,
	Netem <netem@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"core-users@pf.itd.nrl.navy.mil" <core-users@pf.itd.nrl.navy.mil>
To: Teco Boot <teco@inf-net.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:35048 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812Ab3HWPMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 11:12:47 -0400
Received: by mail-la0-f50.google.com with SMTP id es20so488731lab.37
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 08:12:46 -0700 (PDT)
In-Reply-To: <766825FB-5295-4C5C-ABA0-CC520EFE2EA6@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-23 at 16:16 +0200, Teco Boot wrote:
> I had reorder problems with netem qdisc. I make use of the NRL CORE
> network emulator, which sets up virtual routers and links, build with
> network namespaces and netem. Typical CORE config for a n1<-->n2 link
> with rate (1024Kbps), delay (50ms) and no jitter:
>   qdisc tbf 1: dev n1.eth0.222 root refcnt 2 rate 1024Kbit burst 2999b
> lat 488.6ms 
>   qdisc netem 10: dev n1.eth0.222 parent 1:1 limit 1000 delay 50.0ms
>   qdisc tbf 1: dev n2.eth0.222 root refcnt 2 rate 1024Kbit burst 2999b
> lat 488.6ms 
>   qdisc netem 10: dev n2.eth0.222 parent 1:1 limit 1000 delay 50.0ms
> 
> I added jitter to this bi-directional link, e.g. 20ms. Now the delay
> for each packet is 50ms +/- 20ms is 30ms to 70ms.
> However, this has some unexpected results: packets may be reordered.
> That is because the actual delay is calculated for each packet. Some
> packets have a larger delay, some have a smaller. If the inter-packet
> spacing is smaller than the time differences set by netem (up to 2x
> configured jitter), packets are reordered. In this example with
> +/20ms, this is the case with packet rate larger than 25pps.
> Reordering has bad effects on transport protocol throughputs.
> Reordering is less common on the Internet, so I don't want to emulate
> such. I don't say there is no reordering, I just say I don't want this
> netem behavior.
> 
> The netem guide mentions this unexpected results. It was caused by a
> change in version 1.1 (2.6.15). For people like me that do not want
> this, there is a work-around mentioned. However, this doesn't work
> anymore since somewhere before 2.6.31.
> http://www.linuxfoundation.org/collaborate/workgroups/networking/netem
> https://lists.linux-foundation.org/pipermail/netem/2011-April/001507.html
> 
> So what to do? The recent patch from Eric Dumazet eliminates
> jitter_reordering when netem rate is configured. Maybe not the clean
> approach, but acceptable. Ferry his patch eliminates
> jitter_reordering. Some people may use reorder by jitter, so this
> "feature" should not get removed. So Ferry his patch is not accepted.
> On the other hand, people like me are very confused by current
> behavior.
> 
> What we could do is keep existing features and describe what netem
> currently does. That is:
>  - netem with delay and jitter may reorder packets, if inter packet
> spacing is smaller than jitter
>  - reordering caused by delay and jitter can be turned off by using
> netem rate. rate can be set to very high value is no shaping is
> wanted.

As long as one can define the expected behavior, you can add whatever
new netem parameter.

One could envision adding flow separation (skb->sk or rxhashing), so
that each flow can have his own local queue, to guarantee no reorders
per flow _if_ this is needed, even if per flow delays/jitter is/are
configured.

We also use netem to test on large scale, where the reordering stuff
needs fixes in transport stacks (And yes, we are working on TCP stack
to permit higher levels of reorders)
