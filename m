From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] random32: mix in entropy from core to late initcall
Date: Mon, 28 Jul 2014 14:01:38 +0200
Message-ID: <1406548898-9438-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982AbaG1MBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 08:01:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

Currently, we have a 3-stage seeding process in prandom():

Phase 1 is from the early actual initialization of prandom()
subsystem which happens during core_initcall() and remains
most likely until the beginning of late_initcall() phase.
Here, the system might not have enough entropy available
for seeding with strong randomness from the random driver.
That means, we currently have a 32bit weak LCG() seeding
the PRNG status register 1 and mixing that successively
into the other 3 registers just to get it up and running.

Phase 2 starts with late_initcall() phase resp. when the
random driver has initialized its non-blocking pool with
enough entropy. At that time, we throw away *all* inner
state from its 4 registers and do a full reseed with strong
randomness.

Phase 3 starts right after that and does a periodic reseed
with random slack of status register 1 by a strong random
source again.

A problem in phase 1 is that during bootup data structures
can be initialized, e.g. on module load time, and thus access
a weakly seeded prandom and are never changed for the rest
of their live-time, thus carrying along the results from a
week seed. Lets make sure that current but also future users
access a possibly better early seeded prandom.

This patch therefore improves phase 1 by trying to make it
more 'unpredictable' through mixing in seed from a possible
hardware source. Now, the mix-in xors inner state with the
outcome of either of the two functions arch_get_random_{,seed}_int(),
preferably arch_get_random_seed_int() as it likely represents
a non-deterministic random bit generator in hw rather than
a cryptographically secure PRNG in hw. However, not all might
have the first one, so we use the PRNG as a fallback if
available. As we xor the seed into the current state, the
worst case would be that a hardware source could be unverifiable
compromised or backdoored. In that case nevertheless it
would be as good as our original early seeding function
prandom_seed_very_weak() since we mix through xor which is
entropy preserving.

Joint work with Daniel Borkmann.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 lib/random32.c | 49 ++++++++++++++++++++++++++++---------------------
 1 file changed, 28 insertions(+), 21 deletions(-)

diff --git a/lib/random32.c b/lib/random32.c
index fa5da61..c9b6bf3 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -40,6 +40,10 @@
 
 #ifdef CONFIG_RANDOM32_SELFTEST
 static void __init prandom_state_selftest(void);
+#else
+static inline void prandom_state_selftest(void)
+{
+}
 #endif
 
 static DEFINE_PER_CPU(struct rnd_state, net_rand_state);
@@ -53,8 +57,7 @@ static DEFINE_PER_CPU(struct rnd_state, net_rand_state);
  */
 u32 prandom_u32_state(struct rnd_state *state)
 {
-#define TAUSWORTHE(s,a,b,c,d) ((s&c)<<d) ^ (((s <<a) ^ s)>>b)
-
+#define TAUSWORTHE(s, a, b, c, d) ((s & c) << d) ^ (((s << a) ^ s) >> b)
 	state->s1 = TAUSWORTHE(state->s1,  6U, 13U, 4294967294U, 18U);
 	state->s2 = TAUSWORTHE(state->s2,  2U, 27U, 4294967288U,  2U);
 	state->s3 = TAUSWORTHE(state->s3, 13U, 21U, 4294967280U,  7U);
@@ -147,21 +150,25 @@ static void prandom_warmup(struct rnd_state *state)
 	prandom_u32_state(state);
 }
 
-static void prandom_seed_very_weak(struct rnd_state *state, u32 seed)
+static u32 __extract_hwseed(void)
 {
-	/* Note: This sort of seeding is ONLY used in test cases and
-	 * during boot at the time from core_initcall until late_initcall
-	 * as we don't have a stronger entropy source available yet.
-	 * After late_initcall, we reseed entire state, we have to (!),
-	 * otherwise an attacker just needs to search 32 bit space to
-	 * probe for our internal 128 bit state if he knows a couple
-	 * of prandom32 outputs!
-	 */
-#define LCG(x)	((x) * 69069U)	/* super-duper LCG */
-	state->s1 = __seed(LCG(seed),        2U);
-	state->s2 = __seed(LCG(state->s1),   8U);
-	state->s3 = __seed(LCG(state->s2),  16U);
-	state->s4 = __seed(LCG(state->s3), 128U);
+	u32 val = 0;
+
+	(void)(arch_get_random_seed_int(&val) ||
+	       arch_get_random_int(&val));
+
+	return val;
+}
+
+static void prandom_seed_early(struct rnd_state *state, u32 seed,
+			       bool mix_with_hwseed)
+{
+#define LCG(x)	 ((x) * 69069U)	/* super-duper LCG */
+#define HWSEED() (mix_with_hwseed ? __extract_hwseed() : 0)
+	state->s1 = __seed(HWSEED() ^ LCG(seed),        2U);
+	state->s2 = __seed(HWSEED() ^ LCG(state->s1),   8U);
+	state->s3 = __seed(HWSEED() ^ LCG(state->s2),  16U);
+	state->s4 = __seed(HWSEED() ^ LCG(state->s3), 128U);
 }
 
 /**
@@ -194,14 +201,13 @@ static int __init prandom_init(void)
 {
 	int i;
 
-#ifdef CONFIG_RANDOM32_SELFTEST
 	prandom_state_selftest();
-#endif
 
 	for_each_possible_cpu(i) {
 		struct rnd_state *state = &per_cpu(net_rand_state,i);
+		u32 weak_seed = (i + jiffies) ^ random_get_entropy();
 
-		prandom_seed_very_weak(state, (i + jiffies) ^ random_get_entropy());
+		prandom_seed_early(state, weak_seed, true);
 		prandom_warmup(state);
 	}
 
@@ -210,6 +216,7 @@ static int __init prandom_init(void)
 core_initcall(prandom_init);
 
 static void __prandom_timer(unsigned long dontcare);
+
 static DEFINE_TIMER(seed_timer, __prandom_timer, 0, 0);
 
 static void __prandom_timer(unsigned long dontcare)
@@ -419,7 +426,7 @@ static void __init prandom_state_selftest(void)
 	for (i = 0; i < ARRAY_SIZE(test1); i++) {
 		struct rnd_state state;
 
-		prandom_seed_very_weak(&state, test1[i].seed);
+		prandom_seed_early(&state, test1[i].seed, false);
 		prandom_warmup(&state);
 
 		if (test1[i].result != prandom_u32_state(&state))
@@ -434,7 +441,7 @@ static void __init prandom_state_selftest(void)
 	for (i = 0; i < ARRAY_SIZE(test2); i++) {
 		struct rnd_state state;
 
-		prandom_seed_very_weak(&state, test2[i].seed);
+		prandom_seed_early(&state, test2[i].seed, false);
 		prandom_warmup(&state);
 
 		for (j = 0; j < test2[i].iteration - 1; j++)
-- 
1.7.11.7
