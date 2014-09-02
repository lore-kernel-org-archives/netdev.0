From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: truesize for pages shared between SKBs
Date: Tue, 02 Sep 2014 18:00:47 +0200
Message-ID: <1409673647.1808.25.camel@jlt4.sipsolutions.net>
References: <1409660440.1808.17.camel@jlt4.sipsolutions.net>
	 <1409673113.3173.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 (sfid-20140902_175158_801970_DEB54693)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Ido Yariv <ido@wizery.com>,
	Emmanuel Grumbach <egrumbach@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56312 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754624AbaIBQAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 12:00:52 -0400
In-Reply-To: <1409673113.3173.114.camel@edumazet-glaptop2.roam.corp.google.com> (sfid-20140902_175158_801970_DEB54693)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-02 at 08:51 -0700, Eric Dumazet wrote:

> > In our driver, we have 4k receive buffers, but usually ~1500 byte
> > packets.
> 
> Which driver exactly is that ?

iwlwifi/iwlmvm, of course :)

> Can you elaborate on 'they share the page' ?
> 
> If a 4K page is really split into 2 2KB subpages, then yes, truesize can
> be 2KB + skb->head + sizeof(struct sk_buff)

What do you mean by "split"?

There could be any number of packets (though usually two in the
interesting case) in the page, and we call skb_add_rx_frag() for both
packets, pointing to the same page, with different offsets.

> Some drivers do that (Intel IGBVF for example)

It seems to split into two unconditionally, which is interesting.

> If a single 4KB page can be used by a single 1500 frame, then its not
> shared ;)

Right, obviously :)

> > How do other drivers handle this? Should the truesize maybe be aware of
> > this kind of sharing? Should we just lie about it and risk that the
> > truesize is accounted erroneously if some but not all of the packets are
> > freed?
> 
> Lies are not worth crashing hosts under memory pressure.
> 
> skb->truesize is really how many bytes are consumed by an skb. This
> serves in TCP stack to trigger collapses when a socket reaches its
> limits.

Right - the question is more what "consumed" means in this case. Should
it be correct at the time of SKB creation (in which case we should split
by the number of packets created from the page) or should it be correct
for the worst case (all but one packet are freed quickly, one remains
stuck on some socket with the full 4k page allocated to it) ...

Or maybe we should make it even more complex and check the page sharing
in conjunction with GRO...

> Your performance is better when you lie, because for the same
> sk->sk_rcvbuf value (typically tcp_rmem[2]), TCP window can be bigger,
> and allows TCP sender to send more packets (bigger cwnd)
> 
> Workaround : make tcp_rmem[2] larger, so that we still have an
> appropriate memory limit per socket, acting for OOM prevention, and
> allowing better performance for large BDP flows.
> 
> Current value is 6MB, which is already quite big IMO for well behaving
> drivers.
> 
> Real fix would be to make your skb as slim as possible of course.
> It helps even if GRO or TCP coalescing can reduce the memory
> requirements for bulk flows.

Sure, it's always a trade-off though. If we want to *actually* make it
smaller we'd have to copy the data, which doesn't buy us much either.
The hardware is limited in the RX buffer handling, and there's actually
a chance we might receive close to 4k in a single frame with A-MSDU.

If you wanted to use the medium more efficiently you'd set the MTU
higher, for better page utilisation to a little under 2000 (a perfectly
valid value for 802.11). Nobody really does that though :-)

johannes
