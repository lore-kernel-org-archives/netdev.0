From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/6] random32: add prandom_reseed_late() and call when nonblocking pool becomes initialized
Date: Mon, 11 Nov 2013 12:20:34 +0100
Message-ID: <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
References: <cover.1384160397.git.dborkman@redhat.com>
Cc: shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Theodore Ts'o" <tytso@mit.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab3KKLUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 06:20:54 -0500
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
References: <cover.1384160397.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

The Tausworthe PRNG is initialized at late_initcall time. At that time the
entropy pool serving get_random_bytes is not filled sufficiently. This
patch adds an additional reseeding step as soon as the nonblocking pool
gets marked as initialized.

On some machines it might be possible that late_initcall gets called after
the pool has been initialized. In this situation we won't reseed again.

(A call to prandom_seed_late blocks later invocations of early reseed
attempts.)

Joint work with Daniel Borkmann.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/char/random.c  |  5 ++++-
 include/linux/random.h |  1 +
 lib/random32.c         | 23 ++++++++++++++++++++++-
 3 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 7a744d3..4fe5609 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -603,8 +603,11 @@ retry:
 
 	if (!r->initialized && nbits > 0) {
 		r->entropy_total += nbits;
-		if (r->entropy_total > 128)
+		if (r->entropy_total > 128) {
 			r->initialized = 1;
+			if (r == &nonblocking_pool)
+				prandom_reseed_late();
+		}
 	}
 
 	trace_credit_entropy_bits(r->name, nbits, entropy_count,
diff --git a/include/linux/random.h b/include/linux/random.h
index bf9085e..5117ae3 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -29,6 +29,7 @@ unsigned long randomize_range(unsigned long start, unsigned long end, unsigned l
 u32 prandom_u32(void);
 void prandom_bytes(void *buf, int nbytes);
 void prandom_seed(u32 seed);
+void prandom_reseed_late(void);
 
 u32 prandom_u32_state(struct rnd_state *);
 void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
diff --git a/lib/random32.c b/lib/random32.c
index 165d0a5f..e048416 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -200,9 +200,18 @@ static void prandom_start_seed_timer(void)
  *	Generate better values after random number generator
  *	is fully initialized.
  */
-static int __init prandom_reseed(void)
+static void __prandom_reseed(bool late)
 {
 	int i;
+	unsigned long flags;
+	static bool latch = false;
+	static DEFINE_SPINLOCK(lock);
+
+	/* only allow initial seeding (late == false) once */
+	spin_lock_irqsave(&lock, flags);
+	if (latch && !late)
+		goto out;
+	latch = true;
 
 	for_each_possible_cpu(i) {
 		struct rnd_state *state = &per_cpu(net_rand_state,i);
@@ -216,6 +225,18 @@ static int __init prandom_reseed(void)
 		/* mix it in */
 		prandom_u32_state(state);
 	}
+out:
+	spin_unlock_irqrestore(&lock, flags);
+}
+
+void prandom_reseed_late(void)
+{
+	__prandom_reseed(true);
+}
+
+static int __init prandom_reseed(void)
+{
+	__prandom_reseed(false);
 	prandom_start_seed_timer();
 	return 0;
 }
-- 
1.8.3.1
