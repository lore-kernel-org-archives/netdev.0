From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PING^2] [PATCH] srandom32 fixes for networking
Date: Wed, 2 Apr 2008 11:44:37 +0200
Message-ID: <20080402094437.GO29105@one.firstfloor.org>
References: <20080402075011.GL29105@one.firstfloor.org> <20080402.010324.121433616.davem@davemloft.net> <20080402082103.GN29105@one.firstfloor.org> <20080402.012022.106064938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52098 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbYDBJkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 05:40:46 -0400
Content-Disposition: inline
In-Reply-To: <20080402.012022.106064938.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You have to decide how to submit this without introducing
> the build failure then.
> 
> I would suggest getting your first change in, and when that
> happens, resubmit this one.

I did a new version that just updates all CPUs without the rename,
so no dependency.

I will resubmit the rename later after the x86 maintainers
apply the patch to remove the call in pageattr-test.c (they unfortunately 
usually need at least three pings too..)

--- 
srandom32 fixes for networking v2

- Let it update the state of all CPUs. The network stack goes
into pains to feed the current IP addresses in, but it is not very
effective if that is only done for some random CPU instead of all.
So change it to feed bits into all CPUs.  I decided to do that lockless 
because well somewhat random results are ok.

v2: Dropped rename for now

Signed-off-by: Andi Kleen <ak@suse.de>
---
 include/linux/net.h    |    2 +-
 include/linux/random.h |    2 +-
 lib/random32.c         |   19 ++++++++++++-------
 3 files changed, 14 insertions(+), 9 deletions(-)

Index: linux/lib/random32.c
===================================================================
--- linux.orig/lib/random32.c
+++ linux/lib/random32.c
@@ -97,13 +97,18 @@ EXPORT_SYMBOL(random32);
  *	@seed: seed value
  *
  *	Add some additional seeding to the random32() pool.
- *	Note: this pool is per cpu so it only affects current CPU.
  */
 void srandom32(u32 entropy)
 {
-	struct rnd_state *state = &get_cpu_var(net_rand_state);
-	__set_random32(state, state->s1 ^ entropy);
-	put_cpu_var(state);
+	int i;
+	/*
+	 * No locking on the CPUs, but then somewhat random results are, well,
+	 * expected.
+	 */
+	for_each_possible_cpu (i) {
+		struct rnd_state *state = &per_cpu(net_rand_state, i);
+		__set_random32(state, state->s1 ^ entropy);
+	}
 }
 EXPORT_SYMBOL(srandom32);
 


