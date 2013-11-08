From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Fri, 08 Nov 2013 06:03:38 -0800
Message-ID: <1383919418.9412.234.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108130244.GE5876@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33043 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757248Ab3KHODn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 09:03:43 -0500
Received: by mail-pa0-f43.google.com with SMTP id hz1so2243516pad.2
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 06:03:42 -0800 (PST)
In-Reply-To: <20131108130244.GE5876@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 14:02 +0100, Hannes Frederic Sowa wrote:

> If I understand the code correctly the UDP ports are fully randomized? This
> is good as per-peer randomization and then incrementation seems to be
> theoretically broken:
> 
> <https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf>
> 
> Looking at the code I somehow would like to check the use of net_random there.
> The prandom function is reseeded as late_initcall and then only seeded by some
> network addresses.
> 
> At the time the late_initcall reseeds the PRNG my tests have shown that
> the nonblockingpool was still not fully initialized where the PRNG gets
> reseeded from.
> 
> Hm, I propose a patch which does reseed the pool as soon as the nonblocking
> pool got credited enough entropy in credit_entropy_bits. This should help
> later binds().

Or even better have a reseed every XX seconds.

Something like :

diff --git a/lib/random32.c b/lib/random32.c
index 52280d5526be..4af2d72281e3 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -60,6 +60,8 @@ u32 prandom_u32_state(struct rnd_state *state)
 }
 EXPORT_SYMBOL(prandom_u32_state);
 
+static DEFINE_PER_CPU(unsigned long, net_rand_shuffle);
+
 /**
  *	prandom_u32 - pseudo random number generator
  *
@@ -71,6 +73,19 @@ u32 prandom_u32(void)
 {
 	unsigned long r;
 	struct rnd_state *state = &get_cpu_var(net_rand_state);
+
+	if (unlikely(time_after(jiffies, net_rand_shuffle))) {
+		unsigned long delay;
+		u32 entropy;
+
+		get_random_bytes_arch(&entropy, sizeof(entropy));
+
+		/* reseed every ~20 seconds, in [10 .. 30] interval */
+		delay = 10 * HZ + (entropy % (20 * HZ));
+		__this_cpu_write(net_rand_shuffle, jiffies + delay);
+
+		state->s1 = __seed(state->s1 ^ entropy, 1);
+	}
 	r = prandom_u32_state(state);
 	put_cpu_var(state);
 	return r;
@@ -169,6 +184,7 @@ static int __init prandom_init(void)
 		prandom_u32_state(state);
 		prandom_u32_state(state);
 		prandom_u32_state(state);
+		per_cpu(net_rand_shuffle, i) = jiffies;
 	}
 	return 0;
 }
