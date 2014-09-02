From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: truesize for pages shared between SKBs
Date: Tue, 02 Sep 2014 08:51:53 -0700
Message-ID: <1409673113.3173.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409660440.1808.17.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Ido Yariv <ido@wizery.com>,
	Emmanuel Grumbach <egrumbach@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:32876 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125AbaIBPv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 11:51:56 -0400
In-Reply-To: <1409660440.1808.17.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-02 at 14:20 +0200, Johannes Berg wrote:
> Hi,
> 
> In our driver, we have 4k receive buffers, but usually ~1500 byte
> packets.

Which driver exactly is that ?

> 
> How do other drivers handle this? We currently set up the truesize of
> each SKB to be its size plus the 4k page size, but we see performance
> improvements when we lie and pretend the truesize is just 4k/(# of
> packets in the page), which is correct as long as the packets are all
> pending in the stack since they share the page.

Can you elaborate on 'they share the page' ?

If a 4K page is really split into 2 2KB subpages, then yes, truesize can
be 2KB + skb->head + sizeof(struct sk_buff)

Some drivers do that (Intel IGBVF for example)

If a single 4KB page can be used by a single 1500 frame, then its not
shared ;)

> 
> How do other drivers handle this? Should the truesize maybe be aware of
> this kind of sharing? Should we just lie about it and risk that the
> truesize is accounted erroneously if some but not all of the packets are
> freed?

Lies are not worth crashing hosts under memory pressure.

skb->truesize is really how many bytes are consumed by an skb. This
serves in TCP stack to trigger collapses when a socket reaches its
limits.

Your performance is better when you lie, because for the same
sk->sk_rcvbuf value (typically tcp_rmem[2]), TCP window can be bigger,
and allows TCP sender to send more packets (bigger cwnd)

Workaround : make tcp_rmem[2] larger, so that we still have an
appropriate memory limit per socket, acting for OOM prevention, and
allowing better performance for large BDP flows.

Current value is 6MB, which is already quite big IMO for well behaving
drivers.

Real fix would be to make your skb as slim as possible of course.
It helps even if GRO or TCP coalescing can reduce the memory
requirements for bulk flows.
