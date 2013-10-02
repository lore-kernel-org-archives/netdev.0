From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH RFC] random: introduce
 get_random_bytes_busy_wait_initialized
Date: Wed, 2 Oct 2013 11:10:18 -0400
Message-ID: <20131002151018.GA31579@thunk.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
 <1379980991.3165.37.camel@edumazet-glaptop>
 <20130924023038.GA22393@order.stressinduktion.org>
 <20130924033505.GB22393@order.stressinduktion.org>
 <1380001118.3165.41.camel@edumazet-glaptop>
 <20130924054532.GA24446@order.stressinduktion.org>
 <1380028797.3165.65.camel@edumazet-glaptop>
 <20130925090034.GC4904@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:41249 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121Ab3JBPKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Oct 2013 11:10:24 -0400
Content-Disposition: inline
In-Reply-To: <20130925090034.GC4904@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 11:00:34AM +0200, Hannes Frederic Sowa wrote:
> [PATCH RFC] random: introduce get_random_bytes_busy_wait_initialized
> 
> We want to use good entropy for initializing the secret keys used for
> hashing in the core network stack. So busy wait before extracting random
> data until the nonblocking_pool is initialized.
> 
> Further entropy is also gathered by interrupts, so we are guaranteed to
> make progress here.

One thing that makes me a bit worried is that on certain
architectures, it may take quite a while before we get enough entropy
such that the non-blocking pool gets initialized.

Speaking more generally, there are many different reasons why
different parts of the kernel needs randomness.  I've found a number
of places (mostly in various file systems so far because I know that
subsystem better) because we are trying to use a random number
generator with a higher level of guarantees than what was really
required.

What's not completely clear to me is what's the potential danger if
build_ehash_secret() is initialized with a value that might be known
to an adversary.  I'll note that inet_ehash_secret() is a 32-bit uint.
A 32-bit number isn't all that hard for an adversary to brute force.
If the answer is there's now oracle that can be used so an adversary
can tell whether or not they have correctly figured out the ehash
secret, then it's not that clear that it's worth blocking until the
urandom pool has 128 bits of entropy, when ehash_secret is only a
32-bit value.

Speaking even more generally, any time you have subsystems grabbing
random entropy very shortly after boot, especially if it's less than
64 bits, it's really good idea of the secret gets periodically
rekeyed.  I understand why that may be hard in this case, since it
would require rehashing all of the currently open sockets, and maybe
in this case the security requirements are such that it's not really
necessary.  But it's something we should definitely keep in mind for
situations where we are generating random session keys for CIFS,
ipsec, etc.

Regards,

						- Ted
