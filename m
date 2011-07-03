From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH next] netfilter: nfqueue: batch verdict support
Date: Sun, 3 Jul 2011 21:23:26 +0200
Message-ID: <20110703192326.GU16021@Chamillionaire.breakpoint.cc>
References: <1307657659-30266-1-git-send-email-fw@strlen.de>
 <1309688655.2523.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, Eric Leblond <eric@regit.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309688655.2523.16.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Introduces a new nfnetlink type that applies a given
> > verdict to all queued packets with an id <= the id in the verdict
> > message.
> > 
> > If a mark is provided it is applied to all matched packets.
> > 
> > This reduces the number of verdicts that have to be sent.
> > Applications that make use of this feature need to maintain
> > a timeout to send a batchverdict periodically to avoid starvation.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> The real question hidden here is : "Should packet ids be monotonic" in
> current implementation and all future ones ?
> 
> Before we accept this patch, we should make sure packets id are
> monotonic, and I am afraid its not the case right now.

You're right, good catch.

I was fooled by atomic_inc being monotonically increasing, but since
packet building is not protected by the queue spin lock
reordering can indeed happen.

> [PATCH] netfilter: nfqueue: assert monotonic packet ids
> 
> Packet identifier is currently setup in nfqnl_build_packet_message(),
> using one atomic_inc_return().
> 
> Problem is that since several cpus might concurrently call
> nfqnl_enqueue_packet() for the same queue, we can deliver packets to
> consumer in non monotonic way (packet N+1 being delivered after packet
> N)

I would actually consider your patch a bug fix...

Thanks a lot for spending time on this!
