From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/6] random32: fix off-by-one in seeding requirement
Date: Mon, 11 Nov 2013 12:20:32 +0100
Message-ID: <9b88904fc7821fb8db2829a2bc0ac4df641d0387.1384160397.git.dborkman@redhat.com>
References: <cover.1384160397.git.dborkman@redhat.com>
Cc: shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab3KKLUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 06:20:50 -0500
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
References: <cover.1384160397.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For properly initialising the Tausworthe generator [1], we have
a strict seeding requirement, that is, s1 > 1, s2 > 7, s3 > 15.

Commit 697f8d0348 ("random32: seeding improvement") introduced
a __seed() function that imposes boundary checks proposed by the
errata paper [2] to properly ensure above conditions.

However, we're off by one, as the function is implemented as:
"return (x < m) ? x + m : x;", and called with __seed(X, 1),
__seed(X, 7), __seed(X, 15). Thus, an unwanted seed of 1, 7, 15
would be possible, whereas the lower boundary should actually
be of at least 2, 8, 16, just as GSL does. Fix this, as otherwise
an initialization with an unwanted seed could have the effect
that Tausworthe's PRNG properties cannot not be ensured.

Note that this PRNG is *not* used for cryptography in the kernel.

 [1] http://www.iro.umontreal.ca/~lecuyer/myftp/papers/tausme.ps
 [2] http://www.iro.umontreal.ca/~lecuyer/myftp/papers/tausme2.ps

Joint work with Hannes Frederic Sowa.

Fixes: 697f8d0348a6 ("random32: seeding improvement")
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Florian Weimer <fweimer@redhat.com>
Cc: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/random.h |  6 +++---
 lib/random32.c         | 14 +++++++-------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/random.h b/include/linux/random.h
index 6312dd9..bf9085e 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -50,9 +50,9 @@ static inline void prandom_seed_state(struct rnd_state *state, u64 seed)
 {
 	u32 i = (seed >> 32) ^ (seed << 10) ^ seed;
 
-	state->s1 = __seed(i, 1);
-	state->s2 = __seed(i, 7);
-	state->s3 = __seed(i, 15);
+	state->s1 = __seed(i, 2);
+	state->s2 = __seed(i, 8);
+	state->s3 = __seed(i, 16);
 }
 
 #ifdef CONFIG_ARCH_RANDOM
diff --git a/lib/random32.c b/lib/random32.c
index 52280d5..01e8890 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -141,7 +141,7 @@ void prandom_seed(u32 entropy)
 	 */
 	for_each_possible_cpu (i) {
 		struct rnd_state *state = &per_cpu(net_rand_state, i);
-		state->s1 = __seed(state->s1 ^ entropy, 1);
+		state->s1 = __seed(state->s1 ^ entropy, 2);
 	}
 }
 EXPORT_SYMBOL(prandom_seed);
@@ -158,9 +158,9 @@ static int __init prandom_init(void)
 		struct rnd_state *state = &per_cpu(net_rand_state,i);
 
 #define LCG(x)	((x) * 69069)	/* super-duper LCG */
-		state->s1 = __seed(LCG(i + jiffies), 1);
-		state->s2 = __seed(LCG(state->s1), 7);
-		state->s3 = __seed(LCG(state->s2), 15);
+		state->s1 = __seed(LCG(i + jiffies), 2);
+		state->s2 = __seed(LCG(state->s1), 8);
+		state->s3 = __seed(LCG(state->s2), 16);
 
 		/* "warm it up" */
 		prandom_u32_state(state);
@@ -187,9 +187,9 @@ static int __init prandom_reseed(void)
 		u32 seeds[3];
 
 		get_random_bytes(&seeds, sizeof(seeds));
-		state->s1 = __seed(seeds[0], 1);
-		state->s2 = __seed(seeds[1], 7);
-		state->s3 = __seed(seeds[2], 15);
+		state->s1 = __seed(seeds[0], 2);
+		state->s2 = __seed(seeds[1], 8);
+		state->s3 = __seed(seeds[2], 16);
 
 		/* mix it in */
 		prandom_u32_state(state);
-- 
1.8.3.1
