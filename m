From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Mon, 18 May 2015 23:33:29 +0200
Message-ID: <20150518213329.GA2335@breakpoint.cc>
References: <20150518200637.GB20709@breakpoint.cc>
 <20150518.162854.1116793790405432801.davem@davemloft.net>
 <20150518204049.GC20709@breakpoint.cc>
 <20150518.165550.359134808190719687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, hannes@stressinduktion.org,
	edumazet@google.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54836 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752016AbbERVdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 17:33:32 -0400
Content-Disposition: inline
In-Reply-To: <20150518.165550.359134808190719687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 18 May 2015 22:40:49 +0200
> 
> > But, to the best of my understanding, what you ask will push a lot of
> > non-trivial code into the kernel for no functional gain over
> > what has been proposed.
> 
> The functional gain is that we stop linearizing the packet, which
> involves memory allocation and copying the entire packet.

AFAICS ipv4 and ipv6 defragmentations do not perform linearizations or
reallocations?

> I am very confident that the performance gains would be non-trivial
> and quite measurable.

Are fragmented packets that common?
I don't have any real data on this, the box sending this email has

55965898 incoming packets delivered
62 reassemblies required

... but it is just an end host.

TCP shouldn't be a problem thanks to pmtud, and for high-volume
fragmented ipv4 flows i'd expect poor performance due to the 16 bit ID space
limitations long before processing bottleneck.

> You'd also be able to trivially respect the geometry of the original
> incoming packet stream.

True.  OTOH, the patch proposed in this thread would have done the same
with a lot less code (I admit that removing the optimization from Eric
once nf_defrag is loaded is not desirable; but I did not find a solution
to this problem aside from doing route lookup or tentative 'forward is
off') check, which I did not like.

Another alternative might be to delay Erics 'coalescing' step and move
it into the ip stack, after 'local delivery' decision was taken.

I can investigate this if you think its worth it.

> Every objection has been of the form "this special case" (this time
> SIP) is not easy.

Yes, but these objections are not some random hand-waving gesture.
It presents us with certain dilemmas, e.g. single udp packet:

1280 1280 1280 542

sip nat helper has to do nat/pat and replaces 10.2.3.4 with 192.168.2.3
(lets assume we'd have helpers that deal with addresses split over 2
 fragmented skbs so we can deal with 10.2 appearing in fragment #2
  and .3.4 in fragment #3)

We can then end up with something like
1283 1281 1282 542

... and what should we do then?

shuffe payload via memcpy/memmove() to only grow last frag?
This will not be hot path or common by any means.
But nervertheless, this can happen, and we need to deal with it.

> If I were doing this, I would implement something that handles the
> normal cases properly.  And then take it from there.

What is a 'normal case'?
And how do you propose we deal with the 'non-normal' cases?

I assume you mean to e.g. linearize for edge cases + then refragment?

If thats true, then we'd still need one of the proposed solutions to handle
this to get packets we can send out without breaking geometry/growing
fragments to a larger mtu.

> If you try to imagine the totality of it and all the edge cases
> and details from the beginning, yes it will look impossible.

Hmm...  correct, but I still believe we're talking immense pain
for very little gain.

Thanks for spending time on this.
