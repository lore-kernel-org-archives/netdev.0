From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 03:39:47 -0600
Message-ID: <20060531033947.A3065@openss7.org>
References: <20060531014540.A1319@openss7.org> <20060531.004953.91760903.davem@davemloft.net> <20060531024954.A2458@openss7.org> <20060531.020239.00305778.davem@davemloft.net>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:26861 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S964921AbWEaJjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 05:39:48 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060531.020239.00305778.davem@davemloft.net>; from davem@davemloft.net on Wed, May 31, 2006 at 02:02:39AM -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On Wed, 31 May 2006, David Miller wrote:
> 
> I don't know how practical this is.  The 4GB sequence space
> wraps very fast on 10 gigabit, so we'd be rehashing a bit
> and 100 gigabit would make things worse whenever that shows
> up.

It works better for SCTP, because the vtags are constant.  No
rehashing is required there.

But, also consider that rehashing is only required for senders
sending at a high data rate.  (http clients will likely never
have to be rehashed.)  These packets will typically be large and
per-packet overheads will be overwhelmed by per-byte overheads.

Also, the rehashing is orderly and simple, the entry is simply
bumped to the next sequential hash slot and the socket hash
structure can already be cached at the time the action is
performed.  Rehashing, although a bother, would take little
time, and could simply be added as part of TCP's existing window
calculations.

> 
> It is, however, definitely an interesting idea.
> 
> We also need the pure traditional hashes for net channels.  I don't
> see how we could use your scheme for net channels, because we are just
> hashing in the interrupt handler of the network device driver in order
> to get a queue to tack the packet onto, we're not interpreting the
> sequence numbers and thus would not able to maintain the sequence
> space based hashing state.

Under SCTP I still have the traditional established hash for
lookups of out of the blue packets and packets containing
invalid verification tags.  Really long lookups would invite DoS
attacks on these.

> 
> On a 3ghz cpu, the jenkins hash is essentially free.  Even on slower
> cpus, jhash_2words for example is just 20 cycles on a sparc64 chip.
> It's ~40 integer instructions and they all pair up perfectly to
> dual issue.  We'd probably use jhash_3words() for TCP ipv4 which
> would get us into the 30 cycle range.

But you could throw away all 30 cycles, plus the stacking and
unstacking of registers to get in and out of the algorithm.
Some architectures might benefit more.

Well, I thought you might find it interesting.  Perhaps somebody
reading this will experiment with it.  For SCTP it is one of a
number of techniques that allows OpenSS7 SCTP to drastically
outperform lksctp.

--brian
