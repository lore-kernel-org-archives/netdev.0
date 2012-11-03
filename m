From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v2 02/11] random32: introduce random32_get_bytes() and random32_get_bytes_state()
Date: Sun,  4 Nov 2012 00:43:33 +0900
Message-ID: <1351957422-23243-3-git-send-email-akinobu.mita@gmail.com>
References: <1351957422-23243-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Artem Bityutskiy <dedekind1@gmail.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-mtd@lists.infradead.org,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351957422-23243-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add functions to get the requested number of pseudo-random bytes.

The difference from get_random_bytes() is that it generates pseudo-random
numbers by random32().  It is fast, suitable for generating random bytes
for testing, and reproducible if random32_get_bytes_state() is used.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Adrian Hunter <adrian.hunter@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: linux-mtd@lists.infradead.org
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
---
* v2
- rename prandom32_get_bytes to random32_get_bytes_state

 include/linux/random.h |  2 ++
 lib/random32.c         | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/include/linux/random.h b/include/linux/random.h
index bb96f79..4176762 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -27,8 +27,10 @@ unsigned long randomize_range(unsigned long start, unsigned long end, unsigned l
 
 u32 random32(void);
 void srandom32(u32 seed);
+void random32_get_bytes(void *buf, int nbytes);
 
 u32 random32_state(struct rnd_state *);
+void random32_get_bytes_state(struct rnd_state *state, void *buf, int nbytes);
 
 /*
  * Handle minimum values for seeds
diff --git a/lib/random32.c b/lib/random32.c
index 7a3e0c7..9557417 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -61,6 +61,44 @@ u32 random32_state(struct rnd_state *state)
 EXPORT_SYMBOL(random32_state);
 
 /**
+ *	random32_get_bytes_state - get the pseudo-random bytes
+ *	@state: pointer to state structure holding seeded state.
+ *	@buf: where to copy the pseudo-random bytes to
+ *	@bytes: the requested number of bytes
+ *
+ *	This is used for pseudo-randomness with no outside seeding.
+ *	For more random results, use random32_get_bytes().
+ */
+void random32_get_bytes_state(struct rnd_state *state, void *buf, int bytes)
+{
+	unsigned char *p = buf;
+
+	for (; bytes > 0 && ((unsigned long)p) % sizeof(u32); bytes--, p++)
+		*p = random32_state(state);
+
+	for (; bytes > sizeof(u32) - 1; bytes -= sizeof(u32), p += sizeof(u32))
+		*(u32 *)p = random32_state(state);
+
+	for (; bytes > 0; bytes--, p++)
+		*p = random32_state(state);
+}
+EXPORT_SYMBOL(random32_get_bytes_state);
+
+/**
+ *	random32_get_bytes - get the requested number of pseudo-random bytes
+ *	@buf: where to copy the pseudo-random bytes to
+ *	@bytes: the requested number of bytes
+ */
+void random32_get_bytes(void *buf, int bytes)
+{
+	struct rnd_state *state = &get_cpu_var(net_rand_state);
+
+	random32_get_bytes_state(state, buf, bytes);
+	put_cpu_var(state);
+}
+EXPORT_SYMBOL(random32_get_bytes);
+
+/**
  *	random32 - pseudo random number generator
  *
  *	A 32 bit pseudo-random number is generated using a fast
-- 
1.7.11.7
