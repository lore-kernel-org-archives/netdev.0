From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/6] random32: add prandom_reseed_late() and call when nonblocking pool becomes initialized
Date: Tue, 12 Nov 2013 01:03:07 +0100
Message-ID: <20131112000307.GB14929@order.stressinduktion.org>
References: <cover.1384160397.git.dborkman@redhat.com> <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com> <20131111134357.GC10104@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-wireless@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36635 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab3KLADJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 19:03:09 -0500
Content-Disposition: inline
In-Reply-To: <20131111134357.GC10104@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 08:43:57AM -0500, Theodore Ts'o wrote:
> On Mon, Nov 11, 2013 at 12:20:34PM +0100, Daniel Borkmann wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > 
> > The Tausworthe PRNG is initialized at late_initcall time. At that time the
> > entropy pool serving get_random_bytes is not filled sufficiently. This
> > patch adds an additional reseeding step as soon as the nonblocking pool
> > gets marked as initialized.
> > 
> > On some machines it might be possible that late_initcall gets called after
> > the pool has been initialized. In this situation we won't reseed again.
> > 
> > (A call to prandom_seed_late blocks later invocations of early reseed
> > attempts.)
> > 
> > Joint work with Daniel Borkmann.
> 
> Acked-by: "Theodore Ts'o" <tytso@mit.edu>
> 
> I wasn't cc'ed on the full series (I didn't see the 0/3 or the 4/6
> messages) but there are two other things that you might want to
> consider.
> 
> 1)  I'm pretty sure, but it would be good to get netdev confirmation,
> that the call to get_random_bytes() in
> net/mac80211/rc80211_minstrel.c's init_sample_table() can be replaced
> by calls to prandom_u32().

Would make sense. I added wireless-devel to confirm.

[...]
[    0.673260] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
[    0.674024] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
[    0.675012] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
[    0.676032] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
[    0.677020] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
[    0.678011] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
[    0.679011] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
[...]

In total 80 calls to get_random_bytes.

Normally this initialization is called at module load time, so with most
distributions it runs much later. I had it built-in.

> That is, I don't believe cryptographic strength randomness is needed
> --- which is good, because my debugging indicates on a test system
> indicates that it gets called so early that there is typically less
> than two dozen bits of entropy collected in the non-blocking pool
> before it calls get_random_bytes().  If we can move away from using
> get_random_bytes(), those two dozen bits of entropy can be used to
> make sure the urandom pool is initialized much more quickly.
> 
> 2) Since the minstrel code apparently uses this information for
> initializing a machine learning algorithm for backoff purposes, I
> suspect it might be good if the numbers it gets are different from
> machine to machine --- and right now prandom_init() does not mix in
> any kind of personalization information, so calls to prandom_u32()
> will be the same across machines until it gets initialized from the
> /dev/random subsysem.

Yes, I agree.

We are much too early to enumerate hardware, so it would be hard to
integrate something like mac addresses etc.

On x86 it would be easy to seed the cpu type and model from a cpuid call,
but I fear we could not easily extend it to all architectures. And it
does not differ that much between systems.

> Currently, the way we get personlization information which uniquifies
> the randomness in early boot is via add_device_randomness().  Yes,
> some of the function names are a bit misleading; maybe we should try
> to fix this at some point.  So perhaps we should add a hook to
> add_device_randomness() so that each time it gets called, if the
> random32.c state hasn't been strongly initialized by the call to
> prandom_reseed_late(), we also use that information add some per-host
> uniqueness into prandom32.c.  (Note: I'd prefer that we do this via
> some interface other than get_random_bytes(), so we don't end up
> draining entropy from the non_blocking pool, and thus delay the point
> where we can strongly initialize the non_blocking pool, and thus
> strongly initialize prandom32.c)
> 
> Does this make sense to folks?

Totally! That was also the reason why I left the late_initcall intact
in this patch.

Btw. do you see problems regarding get_random_int on architectures without
hardware offloading?

We are initializing random_int_secret really late (after all the init
calls) and I wonder if we should also use a two stage initialization
there, so we have a more unpredictable MD5 hash at early boot.

Greetings,

  Hannes
