From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH net-next 3/6] random32: add prandom_reseed_late() and
 call when nonblocking pool becomes initialized
Date: Mon, 11 Nov 2013 08:43:57 -0500
Message-ID: <20131111134357.GC10104@thunk.org>
References: <cover.1384160397.git.dborkman@redhat.com>
 <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@networkplumber.org,
	fweimer@redhat.com, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:56677 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064Ab3KKNoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 08:44:07 -0500
Content-Disposition: inline
In-Reply-To: <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 12:20:34PM +0100, Daniel Borkmann wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> The Tausworthe PRNG is initialized at late_initcall time. At that time the
> entropy pool serving get_random_bytes is not filled sufficiently. This
> patch adds an additional reseeding step as soon as the nonblocking pool
> gets marked as initialized.
> 
> On some machines it might be possible that late_initcall gets called after
> the pool has been initialized. In this situation we won't reseed again.
> 
> (A call to prandom_seed_late blocks later invocations of early reseed
> attempts.)
> 
> Joint work with Daniel Borkmann.

Acked-by: "Theodore Ts'o" <tytso@mit.edu>

I wasn't cc'ed on the full series (I didn't see the 0/3 or the 4/6
messages) but there are two other things that you might want to
consider.

1)  I'm pretty sure, but it would be good to get netdev confirmation,
that the call to get_random_bytes() in
net/mac80211/rc80211_minstrel.c's init_sample_table() can be replaced
by calls to prandom_u32().  

That is, I don't believe cryptographic strength randomness is needed
--- which is good, because my debugging indicates on a test system
indicates that it gets called so early that there is typically less
than two dozen bits of entropy collected in the non-blocking pool
before it calls get_random_bytes().  If we can move away from using
get_random_bytes(), those two dozen bits of entropy can be used to
make sure the urandom pool is initialized much more quickly.

2) Since the minstrel code apparently uses this information for
initializing a machine learning algorithm for backoff purposes, I
suspect it might be good if the numbers it gets are different from
machine to machine --- and right now prandom_init() does not mix in
any kind of personalization information, so calls to prandom_u32()
will be the same across machines until it gets initialized from the
/dev/random subsysem.

Currently, the way we get personlization information which uniquifies
the randomness in early boot is via add_device_randomness().  Yes,
some of the function names are a bit misleading; maybe we should try
to fix this at some point.  So perhaps we should add a hook to
add_device_randomness() so that each time it gets called, if the
random32.c state hasn't been strongly initialized by the call to
prandom_reseed_late(), we also use that information add some per-host
uniqueness into prandom32.c.  (Note: I'd prefer that we do this via
some interface other than get_random_bytes(), so we don't end up
draining entropy from the non_blocking pool, and thus delay the point
where we can strongly initialize the non_blocking pool, and thus
strongly initialize prandom32.c)

Does this make sense to folks?

Cheers,

						- Ted
