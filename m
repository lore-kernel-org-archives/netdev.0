From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 8/9] tcp: switch tcp_fastopen key generation to net_get_random_once
Date: Sat, 19 Oct 2013 21:48:58 +0200
Message-ID: <1382212139-20301-9-git-send-email-hannes@stressinduktion.org>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changed key initialization of tcp_fastopen cookies to net_get_random_once.

If the user sets a custom key net_get_random_once must be called at
least once to ensure we don't overwrite the user provided key when the
first cookie is generated later on.

Cc: Yuchung Cheng <ycheng@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/tcp.h          |  2 +-
 net/ipv4/sysctl_net_ipv4.c |  5 +++++
 net/ipv4/tcp_fastopen.c    | 27 ++++++++++++++++-----------
 3 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f30326f..b12e29a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1322,7 +1322,7 @@ extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 int tcp_fastopen_reset_cipher(void *key, unsigned int len);
 void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
 			     struct tcp_fastopen_cookie *foc);
-
+void tcp_fastopen_init_key_once(bool publish);
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
 /* Fastopen key context */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c08f096..4b161d5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -274,6 +274,11 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 			ret = -EINVAL;
 			goto bad_key;
 		}
+		/* Generate a dummy secret but don't publish it. This
+		 * is needed so we don't regenerate a new key on the
+		 * first invocation of tcp_fastopen_cookie_gen
+		 */
+		tcp_fastopen_init_key_once(false);
 		tcp_fastopen_reset_cipher(user_key, TCP_FASTOPEN_KEY_LENGTH);
 	}
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index ab7bd35..766032b 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -14,6 +14,20 @@ struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 
 static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
 
+void tcp_fastopen_init_key_once(bool publish)
+{
+	static u8 key[TCP_FASTOPEN_KEY_LENGTH];
+
+	/* tcp_fastopen_reset_cipher publishes the new context
+	 * atomically, so we allow this race happening here.
+	 *
+	 * All call sites of tcp_fastopen_cookie_gen also check
+	 * for a valid cookie, so this is an acceptable risk.
+	 */
+	if (net_get_random_once(key, sizeof(key)) && publish)
+		tcp_fastopen_reset_cipher(key, sizeof(key));
+}
+
 static void tcp_fastopen_ctx_free(struct rcu_head *head)
 {
 	struct tcp_fastopen_context *ctx =
@@ -70,6 +84,8 @@ void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
 	__be32 path[4] = { src, dst, 0, 0 };
 	struct tcp_fastopen_context *ctx;
 
+	tcp_fastopen_init_key_once(true);
+
 	rcu_read_lock();
 	ctx = rcu_dereference(tcp_fastopen_ctx);
 	if (ctx) {
@@ -78,14 +94,3 @@ void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
 	}
 	rcu_read_unlock();
 }
-
-static int __init tcp_fastopen_init(void)
-{
-	__u8 key[TCP_FASTOPEN_KEY_LENGTH];
-
-	get_random_bytes(key, sizeof(key));
-	tcp_fastopen_reset_cipher(key, sizeof(key));
-	return 0;
-}
-
-late_initcall(tcp_fastopen_init);
-- 
1.8.3.1
