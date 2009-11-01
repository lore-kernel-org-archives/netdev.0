From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Sun, 01 Nov 2009 08:01:33 -0500
Message-ID: <4AED86AD.6010906@gmail.com>
References: <4AEAC763.4070200@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060309030309020109080408"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:48931 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbZKANBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 08:01:32 -0500
In-Reply-To: <4AEAC763.4070200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060309030309020109080408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Since October 4th, I've repeatedly asked publicly for assistance with these
Linux-specific memory locking constructs and cryptography.  I've also sent
private messages.  No help has been forthcoming.  None.  Nada.

At this point, I've spent weeks re-spinning code that I'd understood was
approved a year ago.  The whole project should have been finished by now!

So, I'll try a larger audience.  Could somebody take a look at my usage of
read and write locking?

NB, I'm trying to port some 15-year-old fairly simple and straightforward
(single cpu) code from the KA9Q cooperative multitasking platform.

I've examined existing code used for syncookies and TCP MD5 authenticators.
Neither meets my needs, as this secret is updated every few minutes.  Both
have very different approaches.  They are rarely used.  My code will be
used on the order of tens of thousands of connections per second.

Moreover, it seems to my naive eye that the syncookie per cpu code simply
doesn't work properly.  The workspace is allocated per cpu, but the cpu
could change during the extensive SHA1 computations.  Bug?

Therefore, I'm approaching this as simply as possible.  I'm particularly
concerned about the initialization and cache state of memory pointers.

Does the locking handle this?  Or is there more to be done?


--------------060309030309020109080408
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1d.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1d.patch"

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
index 51b7426..f669c43 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1526,12 +1526,18 @@ static inline int tcp_s_data_size(const struct tcp_sock *tp)
 		: 0;
 }
 
+/* Using SHA1 for now, define some constants.
+ */
+#define COOKIE_DIGEST_WORDS (SHA_DIGEST_WORDS)
+#define COOKIE_MESSAGE_WORDS (SHA_MESSAGE_BYTES / 4)
+#define COOKIE_WORKSPACE_WORDS (COOKIE_DIGEST_WORDS + COOKIE_MESSAGE_WORDS)
+
 /* As tcp_request_sock has already been extended in other places, the
  * only remaining method is to pass stack values along as function
  * parameters.  These parameters are not needed after sending SYNACK.
  */
 struct tcp_extend_values {
-	u8				cookie_bakery[TCP_COOKIE_MAX];
+	u32				cookie_bakery[COOKIE_WORKSPACE_WORDS];
 	u8				cookie_plus;
 	u8				cookie_in_always:1,
 					cookie_out_never:1;
@@ -1542,6 +1548,8 @@ static inline struct tcp_extend_values *tcp_xv(const struct request_values *rvp)
 	return (struct tcp_extend_values *)rvp;
 }
 
+extern int tcp_cookie_generator(struct tcp_extend_values *xvp);
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 12409df..160b077 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -264,6 +264,7 @@
 #include <linux/cache.h>
 #include <linux/err.h>
 #include <linux/crypto.h>
+#include <linux/time.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -2933,6 +2934,146 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
 #endif
 
+/**
+ * Each Responder maintains up to two secret values concurrently for
+ * efficient secret rollover.  Each secret value has 4 states:
+ *
+ * Generating.
+ *    Generates new Responder-Cookies, but not yet used for primary
+ *    verification.  This is a short-term state, typically lasting only
+ *    one round trip time (RTT).
+ *
+ * Primary.
+ *    Used both for generation and primary verification.
+ *
+ * Retiring.
+ *    Used for verification, until the first failure that can be
+ *    verified by the newer Generating secret.  At that time, this
+ *    cookie's state is changed to Secondary, and the Generating
+ *    cookie's state is changed to Primary.  This is a short-term state,
+ *    typically lasting only one round trip time (RTT).
+ *
+ * Secondary.
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
+static struct tcp_cookie_secret *tcp_secret_generating;
+static struct tcp_cookie_secret *tcp_secret_primary;
+static struct tcp_cookie_secret *tcp_secret_retiring;
+static struct tcp_cookie_secret *tcp_secret_secondary;
+
+static DEFINE_RWLOCK(tcp_secret_locker);
+
+/* Fill cookie_bakery with current generator, updating as needed.
+ * Returns: 0 for success.
+ */
+int tcp_cookie_generator(struct tcp_extend_values *xvp)
+{
+	u32 secrets[COOKIE_WORKSPACE_WORDS];
+	unsigned long jiffy = jiffies;
+
+	if (unlikely(NULL == tcp_secret_primary)) {
+		struct timespec tv;
+
+		getnstimeofday(&tv);
+		get_random_bytes(secrets, sizeof(secrets));
+
+		/* The first time, paranoia assumes that the randomization
+		 * function isn't as strong.  But this secret initialization
+		 * is delayed until the last possible moment (packet arrival).
+		 * Although that time is observable, it is unpredictably
+		 * variable.  Mash in the most volatile clock bits available,
+		 * and expire the secret extra quickly.
+		 */
+		secrets[COOKIE_DIGEST_WORDS+0] ^= (u32)tv.tv_nsec;
+
+		write_lock(&tcp_secret_locker);
+		if (NULL != tcp_secret_primary) {
+			/* initializated by another */
+			memcpy(&xvp->cookie_bakery[0],
+			       &tcp_secret_primary->secrets[0],
+			       sizeof(tcp_secret_primary->secrets));
+		} else {
+			/* still needs initialization */
+			memcpy(&xvp->cookie_bakery[0],
+			       &secrets[0],
+			       sizeof(secrets));
+			memcpy(&tcp_secret_one.secrets[0],
+			       &secrets[0],
+			       sizeof(secrets));
+			memcpy(&tcp_secret_two.secrets[0],
+			       &secrets[0],
+			       sizeof(secrets));
+
+			tcp_secret_one.expires = jiffy + TCP_SECRET_1MSL;
+			tcp_secret_primary = &tcp_secret_one;
+
+			tcp_secret_two.expires = 0; /* past due */
+			tcp_secret_secondary = &tcp_secret_two;
+		}
+		write_unlock(&tcp_secret_locker);
+	} else if (unlikely(time_after(jiffy, tcp_secret_primary->expires))) {
+		get_random_bytes(secrets, sizeof(secrets));
+
+		write_lock(&tcp_secret_locker);
+		if (!time_after(jiffy, tcp_secret_primary->expires)) {
+			/* refreshed by another */
+			memcpy(&xvp->cookie_bakery[0],
+			       &tcp_secret_generating->secrets[0],
+			       sizeof(tcp_secret_generating->secrets));
+		} else {
+			/* still needs refreshing */
+			memcpy(&xvp->cookie_bakery[0],
+			       &secrets[0],
+			       sizeof(secrets));
+			memcpy(&tcp_secret_secondary->secrets[0],
+			       &secrets[0],
+			       sizeof(secrets));
+
+			tcp_secret_secondary->expires = jiffy
+						      + TCP_SECRET_LIFE;
+			tcp_secret_generating = tcp_secret_secondary;
+
+			tcp_secret_primary->expires = jiffy
+						    + TCP_SECRET_2MSL;
+			tcp_secret_retiring = tcp_secret_primary;
+		}
+		write_unlock(&tcp_secret_locker);
+	} else {
+		read_lock(&tcp_secret_locker);
+		if (unlikely(NULL != tcp_secret_generating)) {
+			memcpy(&xvp->cookie_bakery[0],
+			       &tcp_secret_generating->secrets[0],
+			       sizeof(tcp_secret_generating->secrets));
+		} else {
+			memcpy(&xvp->cookie_bakery[0],
+			       &tcp_secret_primary->secrets[0],
+			       sizeof(tcp_secret_primary->secrets));
+		}
+		read_unlock(&tcp_secret_locker);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(tcp_cookie_generator);
+
 void tcp_done(struct sock *sk)
 {
 	if (sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
@@ -3060,6 +3201,11 @@ void __init tcp_init(void)
 	       tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
 
 	tcp_register_congestion_control(&tcp_reno);
+
+	tcp_secret_generating = NULL;
+	tcp_secret_primary = NULL;
+	tcp_secret_retiring = NULL;
+	tcp_secret_secondary = NULL;
 }
 
 EXPORT_SYMBOL(tcp_close);

--------------060309030309020109080408--
