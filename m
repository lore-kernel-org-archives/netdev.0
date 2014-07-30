From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] random32: mix in entropy from core to late
 initcall
Date: Wed, 30 Jul 2014 13:55:48 -0700 (PDT)
Message-ID: <20140730.135548.612455468946510168.davem@davemloft.net>
References: <1406548898-9438-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbaG3Uzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 16:55:51 -0400
In-Reply-To: <1406548898-9438-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 28 Jul 2014 14:01:38 +0200

> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Currently, we have a 3-stage seeding process in prandom():
> 
> Phase 1 is from the early actual initialization of prandom()
> subsystem which happens during core_initcall() and remains
> most likely until the beginning of late_initcall() phase.
> Here, the system might not have enough entropy available
> for seeding with strong randomness from the random driver.
> That means, we currently have a 32bit weak LCG() seeding
> the PRNG status register 1 and mixing that successively
> into the other 3 registers just to get it up and running.
> 
> Phase 2 starts with late_initcall() phase resp. when the
> random driver has initialized its non-blocking pool with
> enough entropy. At that time, we throw away *all* inner
> state from its 4 registers and do a full reseed with strong
> randomness.
> 
> Phase 3 starts right after that and does a periodic reseed
> with random slack of status register 1 by a strong random
> source again.
> 
> A problem in phase 1 is that during bootup data structures
> can be initialized, e.g. on module load time, and thus access
> a weakly seeded prandom and are never changed for the rest
> of their live-time, thus carrying along the results from a
> week seed. Lets make sure that current but also future users
> access a possibly better early seeded prandom.
> 
> This patch therefore improves phase 1 by trying to make it
> more 'unpredictable' through mixing in seed from a possible
> hardware source. Now, the mix-in xors inner state with the
> outcome of either of the two functions arch_get_random_{,seed}_int(),
> preferably arch_get_random_seed_int() as it likely represents
> a non-deterministic random bit generator in hw rather than
> a cryptographically secure PRNG in hw. However, not all might
> have the first one, so we use the PRNG as a fallback if
> available. As we xor the seed into the current state, the
> worst case would be that a hardware source could be unverifiable
> compromised or backdoored. In that case nevertheless it
> would be as good as our original early seeding function
> prandom_seed_very_weak() since we mix through xor which is
> entropy preserving.
> 
> Joint work with Daniel Borkmann.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks great, applied, thanks everyone.
