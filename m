From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Tue, 24 Jun 2014 17:26:16 -0700 (PDT)
Message-ID: <20140624.172616.757600677169858458.davem@davemloft.net>
References: <20140616234254.GA15332@redhat.com>
	<20140623234759.GA19138@redhat.com>
	<CA+55aFx--+YxUWX5SGet0QxfDo2PcJj3x5tcwqiCTA9yiyi_bQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	therbert@google.com
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx--+YxUWX5SGet0QxfDo2PcJj3x5tcwqiCTA9yiyi_bQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 24 Jun 2014 17:04:41 -0700

> Ping?

Tom please help look at this.

> This is all related to the new checksumming code by Tom Herbert.
> 
> The oops seems to be "gso_make_checksum()" taking a checksum of
> something that isn't mapped. Either the math for 'plen' is simply
> wrong (maybe "csum_start" is not properly initialized), or maybe there
> is a missing skb_pull() or similar, or the skb is fragmented and/or
> needs kmapping.
> 
> It's not a NULL pointer dereference, the faulting address is
> ffff8800aa1a8000, so it's some kind of invalid pointer arithmetic
> found by DEBUG_PAGEALLOC.
> 
> The register information all looks reasonably sane (ie we have 11
> 64-byte blocks to go - so it looks like the length of the csum is
> reasonable), and the starting address was clearly ok too, so this is
> the copying just traversing into a page that isn't allocated. That
> really smells like a skb with multiple fragments to me. Can that
> happen for the GSO code?

This is the forwarding path and what's happening is:

1) r8169 is allocating linear packets for rx and passing those into
   the stack

2) those rx packets are being accumulated by the GRO layer into a GRO
   packet, likely the GRO skb has segments composed of the data areas
   of the second and subsequent accumulated rx frames

3) The gro packet passes through IP forwarding then back out for
   TX

4) The destination device doesn't support TSO, so the GSO layer
   starts segmenting it back into MTU sized frames

And this is where the csum crash is happening.

tcp_gso_segment() seems to call skb_segment before doing checksumming stuff
such as gso_make_checksum, so SKB_GSO_CB()->csum_start should be initialized
properly.

tcp_gso_segment() makes sure that the headers are reachable in the linear
area with the pskb_may_pull(skb, sizeof(*th)) call, and gso_make_checksum()
is only working with the area up to SKB_GSO_CB()->csum_start which should
be within this area for sure.

Well, that's the precondition we seem to be relying upon, I suppose an
assert is in order.
