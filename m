From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/5] random32: add prandom_init_once helper for own rngs
Date: Wed,  7 Oct 2015 15:43:55 +0200
Message-ID: <b96539c3efda908e3a347ff15de5eaf894548a5c.1444224502.git.daniel@iogearbox.net>
References: <cover.1444224502.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45120 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbJGNoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 09:44:03 -0400
In-Reply-To: <cover.1444224502.git.daniel@iogearbox.net>
In-Reply-To: <cover.1444224502.git.daniel@iogearbox.net>
References: <cover.1444224502.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a prandom_init_once() facility that works on the rnd_state, so that
users that are keeping their own state independent from prandom_u32() can
initialize their taus113 per cpu states.

The motivation here is similar to net_get_random_once(): initialize the
state as late as possible in the hope that enough entropy has been
collected for the seeding. prandom_init_once() makes use of the recently
introduced prandom_seed_full_state() helper and is generic enough so that
it could also be used on fast-paths due to the do_once().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/random.h | 6 ++++++
 lib/random32.c         | 5 +++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/random.h b/include/linux/random.h
index e651874..86d4aa7 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -7,6 +7,8 @@
 #define _LINUX_RANDOM_H
 
 #include <linux/list.h>
+#include <linux/once.h>
+
 #include <uapi/linux/random.h>
 
 struct random_ready_callback {
@@ -45,6 +47,10 @@ struct rnd_state {
 
 u32 prandom_u32_state(struct rnd_state *state);
 void prandom_bytes_state(struct rnd_state *state, void *buf, size_t nbytes);
+void prandom_init_state_once(void *pcpu_state);
+
+#define prandom_init_once(pcpu_state)				\
+	({ do_once(prandom_init_state_once, (pcpu_state)); })
 
 /**
  * prandom_u32_max - returns a pseudo-random number in interval [0, ep_ro)
diff --git a/lib/random32.c b/lib/random32.c
index 36c09fb..b166237 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -256,6 +256,11 @@ static void prandom_seed_full_state(struct rnd_state __percpu *pcpu_state)
 	}
 }
 
+void prandom_init_state_once(void *pcpu_state)
+{
+	prandom_seed_full_state((struct rnd_state __percpu *)pcpu_state);
+}
+
 /*
  *	Generate better values after random number generator
  *	is fully initialized.
-- 
1.9.3
