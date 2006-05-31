From: David Miller <davem@davemloft.net>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 02:02:39 -0700 (PDT)
Message-ID: <20060531.020239.00305778.davem@davemloft.net>
References: <20060531014540.A1319@openss7.org>
	<20060531.004953.91760903.davem@davemloft.net>
	<20060531024954.A2458@openss7.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50646
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751577AbWEaJCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 05:02:12 -0400
To: bidulock@openss7.org
In-Reply-To: <20060531024954.A2458@openss7.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Date: Wed, 31 May 2006 02:49:54 -0600

> This would be faster than a Jenkins hash approach because it
> would not be necessary to calculate the hash function at all for
> in-window segments.  Per packet overheads would decrease and
> better small packet performance would be experienced (i.e. your
> http server).  It has better hash coverage because MD4 and other
> cryptographic algorithms used for initial sequence number
> selection have far better properties than Jenkins.
> 
> What do you think?

I don't know how practical this is.  The 4GB sequence space
wraps very fast on 10 gigabit, so we'd be rehashing a bit
and 100 gigabit would make things worse whenever that shows
up.

It is, however, definitely an interesting idea.

We also need the pure traditional hashes for net channels.  I don't
see how we could use your scheme for net channels, because we are just
hashing in the interrupt handler of the network device driver in order
to get a queue to tack the packet onto, we're not interpreting the
sequence numbers and thus would not able to maintain the sequence
space based hashing state.

On a 3ghz cpu, the jenkins hash is essentially free.  Even on slower
cpus, jhash_2words for example is just 20 cycles on a sparc64 chip.
It's ~40 integer instructions and they all pair up perfectly to
dual issue.  We'd probably use jhash_3words() for TCP ipv4 which
would get us into the 30 cycle range.

A few years ago when I introduced jenkins into the tree, I thought
it's execution cost might be an issue.  I really don't anymore.
