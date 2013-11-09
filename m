From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Sat, 9 Nov 2013 21:54:24 +0100
Message-ID: <20131109205424.GC1963@order.stressinduktion.org>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com> <20131108130244.GE5876@order.stressinduktion.org> <1383919418.9412.234.camel@edumazet-glaptop2.roam.corp.google.com> <20131108142856.GA28330@order.stressinduktion.org> <1383923478.9412.240.camel@edumazet-glaptop2.roam.corp.google.com> <20131109044724.GB1963@order.stressinduktion.org> <527E7BEA.1070904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60845 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756462Ab3KIUyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 15:54:25 -0500
Content-Disposition: inline
In-Reply-To: <527E7BEA.1070904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 09, 2013 at 07:16:10PM +0100, Daniel Borkmann wrote:
> On 11/09/2013 05:47 AM, Hannes Frederic Sowa wrote:
> >On Fri, Nov 08, 2013 at 07:11:18AM -0800, Eric Dumazet wrote:
> >>On Fri, 2013-11-08 at 15:28 +0100, Hannes Frederic Sowa wrote:
> >>
> >>>What do you think about using a timer to keep the reseed out of fast-path
> >>>and switch to the non-arch get_random_bytes instead?
> >>
> >>Well, the initial seed value is get_random_bytes(). I felt that using a
> >>xor with the _arch() version would be safe enough.
> >>
> >>For the timer, I do not think its worth the pain : Do you want a per cpu
> >>timer, or a global one ?
> >
> >This untested diff came to my mind (it is based on the random tree). I
> >actually consider to propose something like this for 3.13. UDP port
> >randomization is really critical.
> >
> >In 3.14 timeframe I suggest abandon net_random and use prandom_u32
> >directly so code gets easier to audit.
> >
> >Would it hurt to use "proper" get_random_byte calls for port randomization?
> >
> >diff --git a/drivers/char/random.c b/drivers/char/random.c
> >index cdf4cfb..e9d0136 100644
> >--- a/drivers/char/random.c
> >+++ b/drivers/char/random.c
> >@@ -657,9 +657,11 @@ retry:
> >  	r->entropy_total += nbits;
> >  	if (!r->initialized && nbits > 0) {
> >  		if (r->entropy_total > 128) {
> >-			if (r == &nonblocking_pool)
> >+			if (r == &nonblocking_pool) {
> >  				pr_notice("random: %s pool is initialized\n",
> >  					  r->name);
> >+				prandom_reseed();
> >+			}
> >  			r->initialized = 1;
> >  			r->entropy_total = 0;

I rearranged the code so get_random_bytes does not emit a warning when called
from prandom_reseed().

> >  		}
> >diff --git a/include/linux/random.h b/include/linux/random.h
> >index 6312dd9..4f878c0 100644
> >--- a/include/linux/random.h
> >+++ b/include/linux/random.h
> >@@ -29,6 +29,7 @@ unsigned long randomize_range(unsigned long start, 
> >unsigned long end, unsigned l
> >  u32 prandom_u32(void);
> >  void prandom_bytes(void *buf, int nbytes);
> >  void prandom_seed(u32 seed);
> >+void prandom_reseed(void);
> >
> >  u32 prandom_u32_state(struct rnd_state *);
> >  void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
> >diff --git a/lib/random32.c b/lib/random32.c
> >index 52280d5..1ee611f 100644
> >--- a/lib/random32.c
> >+++ b/lib/random32.c
> >@@ -174,11 +174,31 @@ static int __init prandom_init(void)
> >  }
> >  core_initcall(prandom_init);
> >
> >+static void __prandom_timer(unsigned long dontcare);
> >+static DEFINE_TIMER(seed_timer, __prandom_timer, 0, 0);
> >+
> >+static void __prandom_timer(unsigned long dontcare)
> >+{
> >+	u32 entropy;
> >+	get_random_bytes(&entropy, sizeof(entropy));
> >+	prandom_seed(entropy);
> >+	seed_timer.expires = jiffies + 60 * HZ;
> >+	add_timer(&seed_timer);
> >+}
> >+
> >+static int prandom_start_seed_timer(void)
> 
>       ^^^^^^ __init

Also fixed in my commit. Thanks!

> >+{
> 	prandom_reseed();
> 
> What are the objectives against initializing prandom here in
> the late initcall [instead of doing so in drivers/char/random.c]
> as it was the case before?

IMHO even the late initcall is way too early to seed the prng properly.
Later reseeds never touch s2 and s3 of rnd_state again, so I want to
make sure we have a proper initialized entropy pool when we do the
initial prandom_reseed().

> Probably for security reasons, I think you actually don't want
> anyone (incl. external 3rd party modules) to call prandom_reseed()
> again after this has been done once initially. So I think it
> would be better to make this function not visible to anyone
> outside of random32.c.

It would be nice but a later call to prandom_reseed would not hurt that
much as a too early one. So I guess the tradeoff is worth it.

Maybe we can add runtime protection so it only will get called once.

I am also thinking about leaving the late_initcall in place and just
add the additional reseed from entropy_credit_bits.

I would also repace the net_random() calls with secure_ipv4/6_port_ephemeral.
Still need to check if I have all the needed input available to those
functions available.

Greetings,

  Hannes
