From: akpm@linux-foundation.org
Subject: [patch 01/11] random32: seeding improvement
Date: Wed, 30 Jul 2008 12:37:33 -0700
Message-ID: <200807301937.m6UJbXZk012423@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	shemminger@linux-foundation.org, ak@suse.de, bboissin@gmail.com,
	lloyd@randombit.net, mpm@selenic.com, shemminger@vyatta.com,
	tytso@mit.edu
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54697 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754496AbYG3Tic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:38:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>

The rationale is:
   * use u32 consistently
   * no need to do LCG on values from (better) get_random_bytes
   * use more data from get_random_bytes for secondary seeding
   * don't reduce state space on srandom32()
   * enforce state variable initialization restrictions

Note: the second paper has a version of random32() with even longer period
and a version of random64() if needed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jack Lloyd <lloyd@randombit.net>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Matt Mackall <mpm@selenic.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Andi Kleen <ak@suse.de>
Cc: Benoit Boissinot <bboissin@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 lib/random32.c |   48 ++++++++++++++++++++++++++---------------------
 1 file changed, 27 insertions(+), 21 deletions(-)

diff -puN lib/random32.c~random32-seeding-improvement lib/random32.c
--- a/lib/random32.c~random32-seeding-improvement
+++ a/lib/random32.c
@@ -56,23 +56,12 @@ static u32 __random32(struct rnd_state *
 	return (state->s1 ^ state->s2 ^ state->s3);
 }
 
-static void __set_random32(struct rnd_state *state, unsigned long s)
+/*
+ * Handle minimum values for seeds
+ */
+static inline u32 __seed(u32 x, u32 m)
 {
-	if (s == 0)
-		s = 1;      /* default seed is 1 */
-
-#define LCG(n) (69069 * n)
-	state->s1 = LCG(s);
-	state->s2 = LCG(state->s1);
-	state->s3 = LCG(state->s2);
-
-	/* "warm it up" */
-	__random32(state);
-	__random32(state);
-	__random32(state);
-	__random32(state);
-	__random32(state);
-	__random32(state);
+	return (x < m) ? x + m : x;
 }
 
 /**
@@ -107,7 +96,7 @@ void srandom32(u32 entropy)
 	 */
 	for_each_possible_cpu (i) {
 		struct rnd_state *state = &per_cpu(net_rand_state, i);
-		__set_random32(state, state->s1 ^ entropy);
+		state->s1 = __seed(state->s1 ^ entropy, 1);
 	}
 }
 EXPORT_SYMBOL(srandom32);
@@ -122,7 +111,19 @@ static int __init random32_init(void)
 
 	for_each_possible_cpu(i) {
 		struct rnd_state *state = &per_cpu(net_rand_state,i);
-		__set_random32(state, i + jiffies);
+
+#define LCG(x)	((x) * 69069)	/* super-duper LCG */
+		state->s1 = __seed(LCG(i + jiffies), 1);
+		state->s2 = __seed(LCG(state->s1), 7);
+		state->s3 = __seed(LCG(state->s2), 15);
+
+		/* "warm it up" */
+		__random32(state);
+		__random32(state);
+		__random32(state);
+		__random32(state);
+		__random32(state);
+		__random32(state);
 	}
 	return 0;
 }
@@ -135,13 +136,18 @@ core_initcall(random32_init);
 static int __init random32_reseed(void)
 {
 	int i;
-	unsigned long seed;
 
 	for_each_possible_cpu(i) {
 		struct rnd_state *state = &per_cpu(net_rand_state,i);
+		u32 seeds[3];
+
+		get_random_bytes(&seeds, sizeof(seeds));
+		state->s1 = __seed(seeds[0], 1);
+		state->s2 = __seed(seeds[1], 7);
+		state->s3 = __seed(seeds[2], 15);
 
-		get_random_bytes(&seed, sizeof(seed));
-		__set_random32(state, seed);
+		/* mix it in */
+		__random32(state);
 	}
 	return 0;
 }
_
