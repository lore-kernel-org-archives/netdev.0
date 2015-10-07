From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 3/5] random32: add prandom_seed_full_state helper
Date: Thu,  8 Oct 2015 01:20:37 +0200
Message-ID: <50d520dd9e123a893fcddfb76f7645ebc49ee4bd.1444258406.git.daniel@iogearbox.net>
References: <cover.1444258405.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37260 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbJGXUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 19:20:48 -0400
In-Reply-To: <cover.1444258405.git.daniel@iogearbox.net>
In-Reply-To: <cover.1444258405.git.daniel@iogearbox.net>
References: <cover.1444258405.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out the full reseed handling code that populates the state
through get_random_bytes() and runs prandom_warmup(). The resulting
prandom_seed_full_state() will be used later on in more than the
current __prandom_reseed() user. Fix also two minor whitespace
issues along the way.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 lib/random32.c | 37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/lib/random32.c b/lib/random32.c
index 0bee183..36c09fb 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -181,7 +181,7 @@ void prandom_seed(u32 entropy)
 	 * No locking on the CPUs, but then somewhat random results are, well,
 	 * expected.
 	 */
-	for_each_possible_cpu (i) {
+	for_each_possible_cpu(i) {
 		struct rnd_state *state = &per_cpu(net_rand_state, i);
 
 		state->s1 = __seed(state->s1 ^ entropy, 2U);
@@ -201,7 +201,7 @@ static int __init prandom_init(void)
 	prandom_state_selftest();
 
 	for_each_possible_cpu(i) {
-		struct rnd_state *state = &per_cpu(net_rand_state,i);
+		struct rnd_state *state = &per_cpu(net_rand_state, i);
 		u32 weak_seed = (i + jiffies) ^ random_get_entropy();
 
 		prandom_seed_early(state, weak_seed, true);
@@ -238,13 +238,30 @@ static void __init __prandom_start_seed_timer(void)
 	add_timer(&seed_timer);
 }
 
+static void prandom_seed_full_state(struct rnd_state __percpu *pcpu_state)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct rnd_state *state = per_cpu_ptr(pcpu_state, i);
+		u32 seeds[4];
+
+		get_random_bytes(&seeds, sizeof(seeds));
+		state->s1 = __seed(seeds[0],   2U);
+		state->s2 = __seed(seeds[1],   8U);
+		state->s3 = __seed(seeds[2],  16U);
+		state->s4 = __seed(seeds[3], 128U);
+
+		prandom_warmup(state);
+	}
+}
+
 /*
  *	Generate better values after random number generator
  *	is fully initialized.
  */
 static void __prandom_reseed(bool late)
 {
-	int i;
 	unsigned long flags;
 	static bool latch = false;
 	static DEFINE_SPINLOCK(lock);
@@ -266,19 +283,7 @@ static void __prandom_reseed(bool late)
 		goto out;
 
 	latch = true;
-
-	for_each_possible_cpu(i) {
-		struct rnd_state *state = &per_cpu(net_rand_state,i);
-		u32 seeds[4];
-
-		get_random_bytes(&seeds, sizeof(seeds));
-		state->s1 = __seed(seeds[0],   2U);
-		state->s2 = __seed(seeds[1],   8U);
-		state->s3 = __seed(seeds[2],  16U);
-		state->s4 = __seed(seeds[3], 128U);
-
-		prandom_warmup(state);
-	}
+	prandom_seed_full_state(&net_rand_state);
 out:
 	spin_unlock_irqrestore(&lock, flags);
 }
-- 
1.9.3
