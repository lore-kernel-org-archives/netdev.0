From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 02/11] prandom: introduce prandom_bytes() and prandom_bytes_state()
Date: Tue, 13 Nov 2012 22:37:01 +0900
Message-ID: <1352813830-4624-3-git-send-email-akinobu.mita@gmail.com>
References: <1352813830-4624-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Artem Bityutskiy <dedekind1@gmail.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-mtd@lists.infradead.org,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352813830-4624-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add functions to get the requested number of pseudo-random bytes.

The difference from get_random_bytes() is that it generates pseudo-random
numbers by prandom_u32().  It doesn't consume the entropy pool, and the
sequence is reproducible if the same rnd_state is used.  So it is suitable
for generating random bytes for testing.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Adrian Hunter <adrian.hunter@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: linux-mtd@lists.infradead.org
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
---
* v3
- rename random32_get_bytes_state to prandom_bytes_state
- ensure prandom_bytes_state() generates same bytes with same rnd_state

* v2
- rename prandom32_get_bytes to random32_get_bytes_state

 include/linux/random.h |  2 ++
 lib/random32.c         | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

diff --git a/include/linux/random.h b/include/linux/random.h
index db6debc..d984608 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -26,6 +26,7 @@ unsigned int get_random_int(void);
 unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
 
 u32 prandom_u32(void);
+void prandom_bytes(void *buf, int nbytes);
 void prandom_seed(u32 seed);
 
 /*
@@ -36,6 +37,7 @@ void prandom_seed(u32 seed);
 #define srandom32(seed) prandom_seed(seed)
 
 u32 prandom_u32_state(struct rnd_state *);
+void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
 
 /*
  * Handle minimum values for seeds
diff --git a/lib/random32.c b/lib/random32.c
index d1830fa..52280d5 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -77,6 +77,55 @@ u32 prandom_u32(void)
 }
 EXPORT_SYMBOL(prandom_u32);
 
+/*
+ *	prandom_bytes_state - get the requested number of pseudo-random bytes
+ *
+ *	@state: pointer to state structure holding seeded state.
+ *	@buf: where to copy the pseudo-random bytes to
+ *	@bytes: the requested number of bytes
+ *
+ *	This is used for pseudo-randomness with no outside seeding.
+ *	For more random results, use prandom_bytes().
+ */
+void prandom_bytes_state(struct rnd_state *state, void *buf, int bytes)
+{
+	unsigned char *p = buf;
+	int i;
+
+	for (i = 0; i < round_down(bytes, sizeof(u32)); i += sizeof(u32)) {
+		u32 random = prandom_u32_state(state);
+		int j;
+
+		for (j = 0; j < sizeof(u32); j++) {
+			p[i + j] = random;
+			random >>= BITS_PER_BYTE;
+		}
+	}
+	if (i < bytes) {
+		u32 random = prandom_u32_state(state);
+
+		for (; i < bytes; i++) {
+			p[i] = random;
+			random >>= BITS_PER_BYTE;
+		}
+	}
+}
+EXPORT_SYMBOL(prandom_bytes_state);
+
+/**
+ *	prandom_bytes - get the requested number of pseudo-random bytes
+ *	@buf: where to copy the pseudo-random bytes to
+ *	@bytes: the requested number of bytes
+ */
+void prandom_bytes(void *buf, int bytes)
+{
+	struct rnd_state *state = &get_cpu_var(net_rand_state);
+
+	prandom_bytes_state(state, buf, bytes);
+	put_cpu_var(state);
+}
+EXPORT_SYMBOL(prandom_bytes);
+
 /**
  *	prandom_seed - add entropy to pseudo random number generator
  *	@seed: seed value
-- 
1.7.11.7
