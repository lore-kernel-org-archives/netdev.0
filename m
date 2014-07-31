From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] random32: improvements to prandom_bytes
Date: Thu, 31 Jul 2014 22:11:16 +0200
Message-ID: <1406837476-13776-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10081 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300AbaGaULV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 16:11:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses a couple of minor items, mostly addressing
prandom_bytes(): 1) prandom_bytes{,_state}() should use size_t
for length arguments, 2) We can use put_unaligned() when filling
the array instead of open coding it [ perhaps some archs will
further benefit from their own arch specific implementation when
GCC cannot make up for it ], 3) Fix a typo, 4) Better use unsigned
int as type for getting the arch seed, 5) Make use of
prandom_u32_max() for timer slack.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/random.h |  4 ++--
 lib/random32.c         | 39 ++++++++++++++++++---------------------
 2 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/include/linux/random.h b/include/linux/random.h
index 57fbbff..b05856e 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -26,7 +26,7 @@ unsigned int get_random_int(void);
 unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
 
 u32 prandom_u32(void);
-void prandom_bytes(void *buf, int nbytes);
+void prandom_bytes(void *buf, size_t nbytes);
 void prandom_seed(u32 seed);
 void prandom_reseed_late(void);
 
@@ -35,7 +35,7 @@ struct rnd_state {
 };
 
 u32 prandom_u32_state(struct rnd_state *state);
-void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
+void prandom_bytes_state(struct rnd_state *state, void *buf, size_t nbytes);
 
 /**
  * prandom_u32_max - returns a pseudo-random number in interval [0, ep_ro)
diff --git a/lib/random32.c b/lib/random32.c
index c9b6bf3..ce29432 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -37,6 +37,7 @@
 #include <linux/jiffies.h>
 #include <linux/random.h>
 #include <linux/sched.h>
+#include <asm/unaligned.h>
 
 #ifdef CONFIG_RANDOM32_SELFTEST
 static void __init prandom_state_selftest(void);
@@ -96,27 +97,23 @@ EXPORT_SYMBOL(prandom_u32);
  *	This is used for pseudo-randomness with no outside seeding.
  *	For more random results, use prandom_bytes().
  */
-void prandom_bytes_state(struct rnd_state *state, void *buf, int bytes)
+void prandom_bytes_state(struct rnd_state *state, void *buf, size_t bytes)
 {
-	unsigned char *p = buf;
-	int i;
-
-	for (i = 0; i < round_down(bytes, sizeof(u32)); i += sizeof(u32)) {
-		u32 random = prandom_u32_state(state);
-		int j;
+	u8 *ptr = buf;
 
-		for (j = 0; j < sizeof(u32); j++) {
-			p[i + j] = random;
-			random >>= BITS_PER_BYTE;
-		}
+	while (bytes > sizeof(u32)) {
+		put_unaligned(prandom_u32_state(state), (u32 *) ptr);
+		ptr += sizeof(u32);
+		bytes -= sizeof(u32);
 	}
-	if (i < bytes) {
-		u32 random = prandom_u32_state(state);
 
-		for (; i < bytes; i++) {
-			p[i] = random;
-			random >>= BITS_PER_BYTE;
-		}
+	if (bytes > 0) {
+		u32 rem = prandom_u32_state(state);
+		do {
+			*ptr++ = (u8) rem;
+			bytes--;
+			rem >>= BITS_PER_BYTE;
+		} while (bytes > 0);
 	}
 }
 EXPORT_SYMBOL(prandom_bytes_state);
@@ -126,7 +123,7 @@ EXPORT_SYMBOL(prandom_bytes_state);
  *	@buf: where to copy the pseudo-random bytes to
  *	@bytes: the requested number of bytes
  */
-void prandom_bytes(void *buf, int bytes)
+void prandom_bytes(void *buf, size_t bytes)
 {
 	struct rnd_state *state = &get_cpu_var(net_rand_state);
 
@@ -137,7 +134,7 @@ EXPORT_SYMBOL(prandom_bytes);
 
 static void prandom_warmup(struct rnd_state *state)
 {
-	/* Calling RNG ten times to satify recurrence condition */
+	/* Calling RNG ten times to satisfy recurrence condition */
 	prandom_u32_state(state);
 	prandom_u32_state(state);
 	prandom_u32_state(state);
@@ -152,7 +149,7 @@ static void prandom_warmup(struct rnd_state *state)
 
 static u32 __extract_hwseed(void)
 {
-	u32 val = 0;
+	unsigned int val = 0;
 
 	(void)(arch_get_random_seed_int(&val) ||
 	       arch_get_random_int(&val));
@@ -228,7 +225,7 @@ static void __prandom_timer(unsigned long dontcare)
 	prandom_seed(entropy);
 
 	/* reseed every ~60 seconds, in [40 .. 80) interval with slack */
-	expires = 40 + (prandom_u32() % 40);
+	expires = 40 + prandom_u32_max(40);
 	seed_timer.expires = jiffies + msecs_to_jiffies(expires * MSEC_PER_SEC);
 
 	add_timer(&seed_timer);
-- 
1.7.11.7
