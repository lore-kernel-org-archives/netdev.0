From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] random: introduce get_random_bytes_busy_wait_initialized
Date: Wed, 2 Oct 2013 19:18:40 +0200
Message-ID: <20131002171839.GQ10771@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop> <20130924023038.GA22393@order.stressinduktion.org> <20130924033505.GB22393@order.stressinduktion.org> <1380001118.3165.41.camel@edumazet-glaptop> <20130924054532.GA24446@order.stressinduktion.org> <1380028797.3165.65.camel@edumazet-glaptop> <20130925090034.GC4904@order.stressinduktion.org> <20131002151018.GA31579@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Theodore Ts'o <tytso@mit.edu>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131002151018.GA31579@thunk.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Thanks for looking into this!

On Wed, Oct 02, 2013 at 11:10:18AM -0400, Theodore Ts'o wrote:
> On Wed, Sep 25, 2013 at 11:00:34AM +0200, Hannes Frederic Sowa wrote:
> > [PATCH RFC] random: introduce get_random_bytes_busy_wait_initialized
> > 
> > We want to use good entropy for initializing the secret keys used for
> > hashing in the core network stack. So busy wait before extracting random
> > data until the nonblocking_pool is initialized.
> > 
> > Further entropy is also gathered by interrupts, so we are guaranteed to
> > make progress here.
> 
> One thing that makes me a bit worried is that on certain
> architectures, it may take quite a while before we get enough entropy
> such that the non-blocking pool gets initialized.

Yes, I understand. My main concern is that we would feed instruction
addresses of limited randomness into the entropy pool while busy looping
until the pool is initialized on uni-processor machines. It would only be
helpful on multiprocessor machines I guess.

So, I am currently a bit skeptic if this change does improve things and
have to think about this again.

> Speaking more generally, there are many different reasons why
> different parts of the kernel needs randomness.  I've found a number
> of places (mostly in various file systems so far because I know that
> subsystem better) because we are trying to use a random number
> generator with a higher level of guarantees than what was really
> required.
> 
> What's not completely clear to me is what's the potential danger if
> build_ehash_secret() is initialized with a value that might be known
> to an adversary.  I'll note that inet_ehash_secret() is a 32-bit uint.
> A 32-bit number isn't all that hard for an adversary to brute force.
> If the answer is there's now oracle that can be used so an adversary
> can tell whether or not they have correctly figured out the ehash
> secret, then it's not that clear that it's worth blocking until the
> urandom pool has 128 bits of entropy, when ehash_secret is only a
> 32-bit value.

It may be possible to find multicollisions if the hash is known which could
lead to a DoS against the hash table if the lookups become linear (and someone
finds a fast way to do this for jash in this case, also depending if one
hashes variable or static size data). So this is minor issue currently.

But this is not my main concern:

We currently initialize the syncookie secrets pretty early on boot-up:
http://lxr.free-electrons.com/source/net/ipv4/syncookies.c#L31

Because of this problem I came up with another solution. My plan is to
introduce a macro 'net_get_random_once' which could be used to initialize
secret keys used for hashing as late as possible:
http://patchwork.ozlabs.org/patch/278308/

David Miller suggested that I should use static_keys to reduce overhead in the
fast-path and I am currently testing this change. I'll send it for review
maybe tomorrow. Otherwise I have to come up with another solution, maybe only
specific for syncookies in the beginning.

> Speaking even more generally, any time you have subsystems grabbing
> random entropy very shortly after boot, especially if it's less than
> 64 bits, it's really good idea of the secret gets periodically
> rekeyed.  I understand why that may be hard in this case, since it
> would require rehashing all of the currently open sockets, and maybe
> in this case the security requirements are such that it's not really
> necessary.  But it's something we should definitely keep in mind for
> situations where we are generating random session keys for CIFS,
> ipsec, etc.

I agree. I will look if this is easily possible for secure_seq and
syncookies but depending on the data structure and its size it is a much
harder thing to do. I wanted to try the low-hanging fruits first. ;)

Thanks,

  Hannes
