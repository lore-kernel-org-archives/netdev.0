From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/6] random32: add periodic reseeding
Date: Mon, 11 Nov 2013 12:20:33 +0100
Message-ID: <72e3f0b5d2dff4cfe700544dc680aa0727fcab37.1384160397.git.dborkman@redhat.com>
References: <cover.1384160397.git.dborkman@redhat.com>
Cc: shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Theodore Ts'o" <tytso@mit.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59944 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418Ab3KKLUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 06:20:52 -0500
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
In-Reply-To: <cover.1384160397.git.dborkman@redhat.com>
References: <cover.1384160397.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

The current Tausworthe PRNG is never reseeded with truly random data after
the first attempt in late_initcall. As this PRNG is used for some critical
random data as e.g. UDP port randomization we should try better and reseed
the PRNG once in a while with truly random data from get_random_bytes().

When we reseed with prandom_seed we now make also sure to throw the first
output away. This suffices the reseeding procedure.

The delay calculation is based on a proposal from Eric Dumazet.

Joint work with Daniel Borkmann.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 lib/random32.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/lib/random32.c b/lib/random32.c
index 01e8890..165d0a5f 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -142,6 +142,7 @@ void prandom_seed(u32 entropy)
 	for_each_possible_cpu (i) {
 		struct rnd_state *state = &per_cpu(net_rand_state, i);
 		state->s1 = __seed(state->s1 ^ entropy, 2);
+		prandom_u32_state(state);
 	}
 }
 EXPORT_SYMBOL(prandom_seed);
@@ -174,6 +175,27 @@ static int __init prandom_init(void)
 }
 core_initcall(prandom_init);
 
+static void __prandom_timer(unsigned long dontcare);
+static DEFINE_TIMER(seed_timer, __prandom_timer, 0, 0);
+
+static void __prandom_timer(unsigned long dontcare)
+{
+	u32 entropy;
+
+	get_random_bytes(&entropy, sizeof(entropy));
+	prandom_seed(entropy);
+	/* reseed every ~60 seconds, in [40 .. 80) interval with slack */
+	seed_timer.expires = jiffies + (40 * HZ + (prandom_u32() % (40 * HZ)));
+	add_timer(&seed_timer);
+}
+
+static void prandom_start_seed_timer(void)
+{
+	set_timer_slack(&seed_timer, HZ);
+	seed_timer.expires = jiffies + 40 * HZ;
+	add_timer(&seed_timer);
+}
+
 /*
  *	Generate better values after random number generator
  *	is fully initialized.
@@ -194,6 +216,7 @@ static int __init prandom_reseed(void)
 		/* mix it in */
 		prandom_u32_state(state);
 	}
+	prandom_start_seed_timer();
 	return 0;
 }
 late_initcall(prandom_reseed);
-- 
1.8.3.1
