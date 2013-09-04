From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 1/2] random: add prandom_u32_range and prandom_u32_max helpers
Date: Wed,  4 Sep 2013 14:37:26 +0200
Message-ID: <1378298247-29364-2-git-send-email-dborkman@redhat.com>
References: <1378298247-29364-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Theodore Ts'o" <tytso@mit.edu>, Joe Perches <joe@perches.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934680Ab3IDMhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 08:37:40 -0400
In-Reply-To: <1378298247-29364-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have implemented the same function over and over, so introduce
generic helpers that unify these implementations in order to migrate
such code to use them. Make the API similarly to randomize_range()
for consistency. prandom_u32_range() generates numbers in [start, end]
interval and prandom_u32_max() generates numbers in [0, end] interval.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org
---
 include/linux/random.h | 31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/include/linux/random.h b/include/linux/random.h
index 3b9377d..17c91c2 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -8,7 +8,6 @@
 
 #include <uapi/linux/random.h>
 
-
 extern void add_device_randomness(const void *, unsigned int);
 extern void add_input_randomness(unsigned int type, unsigned int code,
 				 unsigned int value);
@@ -32,6 +31,36 @@ void prandom_seed(u32 seed);
 u32 prandom_u32_state(struct rnd_state *);
 void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
 
+/**
+ * prandom_u32_range - return a random number in interval [start, end]
+ * @start: lower interval endpoint
+ * @end: higher interval endpoint
+ *
+ * Returns a number that is in the given interval:
+ *
+ *     [...... <range> .....]
+ *   start                  end
+ *
+ * Callers need to make sure that start <= end. Note that the result
+ * depends on PRNG being well distributed in [0, ~0U] space. Here we
+ * use maximally equidistributed combined Tausworthe generator.
+ */
+static inline u32 prandom_u32_range(u32 start, u32 end)
+{
+	return (u32)(((u64) prandom_u32() * (end + 1 - start)) >> 32) + start;
+}
+
+/**
+ * prandom_u32_max - return a random number in interval [0, max]
+ * @max: higher interval endpoint
+ *
+ * Returns a number that is in interval [0, end].
+ */
+static inline u32 prandom_u32_max(u32 end)
+{
+	return prandom_u32_range(0, end);
+}
+
 /*
  * Handle minimum values for seeds
  */
-- 
1.7.11.7
