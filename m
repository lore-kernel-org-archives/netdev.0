From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v7 2/7 RFC] TCPCT part 1b: generate Responder
 Cookie secret
Date: Fri, 20 Nov 2009 09:23:21 -0500
Message-ID: <4B06A659.3020109@gmail.com>
References: <4B06A1FF.8000202@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090601000407070103080107"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:61652 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbZKTOX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 09:23:26 -0500
Received: by ywh40 with SMTP id 40so2245270ywh.33
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 06:23:32 -0800 (PST)
In-Reply-To: <4B06A1FF.8000202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090601000407070103080107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Define (missing) hash message size for SHA1.

Define hashing size constants specific to TCP cookies.

Add new function: tcp_cookie_generator().

Maintain global secret values for tcp_cookie_generator().

This is a significantly revised implementation of earlier (15-year-old)
Photuris [RFC-2522] code for the KA9Q cooperative multitasking platform.

Linux RCU technique appears to be well-suited to this application, though
neither of the circular queue items are freed.

These functions will also be used in subsequent patches that implement
additional features.

Signed-off-by: William.Allen.Simpson@gmail.com
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
  include/linux/cryptohash.h |    1 +
  include/net/tcp.h          |    8 +++
  net/ipv4/tcp.c             |  140 ++++++++++++++++++++++++++++++++++++++++++++
  3 files changed, 149 insertions(+), 0 deletions(-)

--------------090601000407070103080107
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1b7.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1b7.patch"

diff --git a/include/linux/cryptohash.h b/include/linux/cryptohash.h
index c118b2a..ec78a4b 100644
--- a/include/linux/cryptohash.h
+++ b/include/linux/cryptohash.h
@@ -2,6 +2,7 @@
 #define __CRYPTOHASH_H
 
 #define SHA_DIGEST_WORDS 5
+#define SHA_MESSAGE_BYTES (512 /*bits*/ / 8)
 #define SHA_WORKSPACE_WORDS 80
 
 void sha_init(__u32 *buf);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ec183fd..4a99a8e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1478,6 +1478,14 @@ struct tcp_request_sock_ops {
 #endif
 };
 
+/* Using SHA1 for now, define some constants.
+ */
+#define COOKIE_DIGEST_WORDS (SHA_DIGEST_WORDS)
+#define COOKIE_MESSAGE_WORDS (SHA_MESSAGE_BYTES / 4)
+#define COOKIE_WORKSPACE_WORDS (COOKIE_DIGEST_WORDS + COOKIE_MESSAGE_WORDS)
+
+extern int tcp_cookie_generator(u32 *bakery);
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 524f976..1356e3d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -264,6 +264,7 @@
 #include <linux/cache.h>
 #include <linux/err.h>
 #include <linux/crypto.h>
+#include <linux/time.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -2847,6 +2848,135 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
 #endif
 
+/**
+ * Each Responder maintains up to two secret values concurrently for
+ * efficient secret rollover.  Each secret value has 4 states:
+ *
+ * Generating.  (tcp_secret_generating != tcp_secret_primary)
+ *    Generates new Responder-Cookies, but not yet used for primary
+ *    verification.  This is a short-term state, typically lasting only
+ *    one round trip time (RTT).
+ *
+ * Primary.  (tcp_secret_generating == tcp_secret_primary)
+ *    Used both for generation and primary verification.
+ *
+ * Retiring.  (tcp_secret_retiring != tcp_secret_secondary)
+ *    Used for verification, until the first failure that can be
+ *    verified by the newer Generating secret.  At that time, this
+ *    cookie's state is changed to Secondary, and the Generating
+ *    cookie's state is changed to Primary.  This is a short-term state,
+ *    typically lasting only one round trip time (RTT).
+ *
+ * Secondary.  (tcp_secret_retiring == tcp_secret_secondary)
+ *    Used for secondary verification, after primary verification
+ *    failures.  This state lasts no more than twice the Maximum Segment
+ *    Lifetime (2MSL).  Then, the secret is discarded.
+ */
+struct tcp_cookie_secret {
+	/* The secret is divided into two parts.  The digest part is the
+	 * equivalent of previously hashing a secret and saving the state,
+	 * and serves as an initialization vector (IV).  The message part
+	 * serves as the trailing secret.
+	 */
+	u32				secrets[COOKIE_WORKSPACE_WORDS];
+	unsigned long			expires;
+};
+
+#define TCP_SECRET_1MSL (HZ * TCP_PAWS_MSL)
+#define TCP_SECRET_2MSL (HZ * TCP_PAWS_MSL * 2)
+#define TCP_SECRET_LIFE (HZ * 600)
+
+static struct tcp_cookie_secret tcp_secret_one;
+static struct tcp_cookie_secret tcp_secret_two;
+
+/* Essentially a circular list, without dynamic allocation. */
+static struct tcp_cookie_secret *tcp_secret_generating;
+static struct tcp_cookie_secret *tcp_secret_primary;
+static struct tcp_cookie_secret *tcp_secret_retiring;
+static struct tcp_cookie_secret *tcp_secret_secondary;
+
+static DEFINE_SPINLOCK(tcp_secret_locker);
+
+/* Select a pseudo-random word in the cookie workspace.
+ */
+static inline u32 tcp_cookie_work(const u32 *ws, const int n)
+{
+	return ws[COOKIE_DIGEST_WORDS + ((COOKIE_MESSAGE_WORDS-1) & ws[n])];
+}
+
+/* Fill bakery[COOKIE_WORKSPACE_WORDS] with generator, updating as needed.
+ * Called in softirq context.
+ * Returns: 0 for success.
+ */
+int tcp_cookie_generator(u32 *bakery)
+{
+	unsigned long jiffy = jiffies;
+
+	if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
+		spin_lock_bh(&tcp_secret_locker);
+		if (!time_after_eq(jiffy, tcp_secret_generating->expires)) {
+			/* refreshed by another */
+			memcpy(bakery,
+			       &tcp_secret_generating->secrets[0],
+			       COOKIE_WORKSPACE_WORDS);
+		} else {
+			/* still needs refreshing */
+			get_random_bytes(bakery, COOKIE_WORKSPACE_WORDS);
+
+			/* The first time, paranoia assumes that the
+			 * randomization function isn't as strong.  But,
+			 * this secret initialization is delayed until
+			 * the last possible moment (packet arrival).
+			 * Although that time is observable, it is
+			 * unpredictably variable.  Mash in the most
+			 * volatile clock bits available, and expire the
+			 * secret extra quickly.
+			 */
+			if (unlikely(tcp_secret_primary->expires ==
+				     tcp_secret_secondary->expires)) {
+				struct timespec tv;
+
+				getnstimeofday(&tv);
+				bakery[COOKIE_DIGEST_WORDS+0] ^=
+					(u32)tv.tv_nsec;
+
+				tcp_secret_secondary->expires = jiffy
+					+ TCP_SECRET_1MSL
+					+ (0x0f & tcp_cookie_work(bakery, 0));
+			} else {
+				tcp_secret_secondary->expires = jiffy
+					+ TCP_SECRET_LIFE
+					+ (0xff & tcp_cookie_work(bakery, 1));
+				tcp_secret_primary->expires = jiffy
+					+ TCP_SECRET_2MSL
+					+ (0x1f & tcp_cookie_work(bakery, 2));
+			}
+			memcpy(&tcp_secret_secondary->secrets[0],
+			       bakery, COOKIE_WORKSPACE_WORDS);
+
+			rcu_assign_pointer(tcp_secret_generating,
+					   tcp_secret_secondary);
+			rcu_assign_pointer(tcp_secret_retiring,
+					   tcp_secret_primary);
+			/*
+			 * Neither call_rcu() nor synchronize_rcu() needed.
+			 * Retiring data is not freed.  It is replaced after
+			 * further (locked) pointer updates, and a quiet time
+			 * (minimum 1MSL, maximum LIFE - 2MSL).
+			 */
+		}
+		spin_unlock_bh(&tcp_secret_locker);
+	} else {
+		rcu_read_lock_bh();
+		memcpy(bakery,
+		       &rcu_dereference(tcp_secret_generating)->secrets[0],
+		       COOKIE_WORKSPACE_WORDS);
+		rcu_read_unlock_bh();
+	}
+	return 0;
+}
+EXPORT_SYMBOL(tcp_cookie_generator);
+
 void tcp_done(struct sock *sk)
 {
 	if (sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
@@ -2881,6 +3011,7 @@ void __init tcp_init(void)
 	struct sk_buff *skb = NULL;
 	unsigned long nr_pages, limit;
 	int order, i, max_share;
+	unsigned long jiffy = jiffies;
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
@@ -2974,6 +3105,15 @@ void __init tcp_init(void)
 	       tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
 
 	tcp_register_congestion_control(&tcp_reno);
+
+	memset(&tcp_secret_one.secrets[0], 0, sizeof(tcp_secret_one.secrets));
+	memset(&tcp_secret_two.secrets[0], 0, sizeof(tcp_secret_two.secrets));
+	tcp_secret_one.expires = jiffy; /* past due */
+	tcp_secret_two.expires = jiffy; /* past due */
+	tcp_secret_generating = &tcp_secret_one;
+	tcp_secret_primary = &tcp_secret_one;
+	tcp_secret_retiring = &tcp_secret_two;
+	tcp_secret_secondary = &tcp_secret_two;
 }
 
 EXPORT_SYMBOL(tcp_close);
-- 
1.6.3.3


--------------090601000407070103080107--
