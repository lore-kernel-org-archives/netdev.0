From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Tue, 03 Nov 2009 17:38:10 -0500
Message-ID: <4AF0B0D2.4030905@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060704040403000705010805"
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755290AbZKCWiP@vger.kernel.org>
In-Reply-To: <4AEDCD7C.2010403@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060704040403000705010805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Eric Dumazet wrote:
> This patch looks fine, but I dont see how this new function is used.
> 
> Some points :
> 
> 1) We are working hard to remove rwlocks from network stack, so please dont
> add a new one. You probably can use a seqlock or RCU, or a server handling 
> 10.000 connections request per second on many NIC will hit this rwlock.
> 
This is my attempt at using RCU, as seqlock didn't seem to apply (and is
missing any Documentation.)

After the discussion about context, one question that I have is the need
for the _bh suffix?

+		rcu_read_lock_bh();
+		memcpy(&xvp->cookie_bakery[0],
+		       &rcu_dereference(tcp_secret_generating)->secrets[0],
+		       sizeof(tcp_secret_generating->secrets));
+		rcu_read_unlock_bh();


Documentation/RCU/checklist.txt #7 says:

   One exception to this rule: rcu_read_lock() and rcu_read_unlock()
   may be substituted for rcu_read_lock_bh() and rcu_read_unlock_bh()
   in cases where local bottom halves are already known to be
   disabled, for example, in irq or softirq context.  Commenting
   such cases is a must, of course!  And the jury is still out on
   whether the increased speed is worth it.

--------------060704040403000705010805
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1d1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1d1.patch"

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
index 12409df..a8c5d99 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -264,6 +264,7 @@
 #include <linux/cache.h>
 #include <linux/err.h>
 #include <linux/crypto.h>
+#include <linux/time.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -2933,6 +2934,126 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
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
+/* Fill cookie_bakery with current generator, updating as needed.
+ * Only called in softirq context.
+ * Returns: 0 for success.
+ */
+int tcp_cookie_generator(struct tcp_extend_values *xvp)
+{
+	unsigned long jiffy = jiffies;
+
+	if (unlikely(time_after(jiffy, tcp_secret_generating->expires))) {
+		u32 secrets[COOKIE_WORKSPACE_WORDS];
+
+		spin_lock(&tcp_secret_locker);
+		if (!time_after(jiffy, tcp_secret_generating->expires)) {
+			/* refreshed by another */
+			spin_unlock(&tcp_secret_locker);
+			memcpy(&xvp->cookie_bakery[0],
+			       &tcp_secret_generating->secrets[0],
+			       sizeof(tcp_secret_generating->secrets));
+		} else {
+			/* still needs refreshing */
+			get_random_bytes(secrets, sizeof(secrets));
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
+				secrets[COOKIE_DIGEST_WORDS+0] ^= (u32)tv.tv_nsec;
+				tcp_secret_secondary->expires = jiffy
+							      + TCP_SECRET_1MSL;
+			} else {
+				tcp_secret_secondary->expires = jiffy
+							      + TCP_SECRET_LIFE;
+				tcp_secret_primary->expires = jiffy
+							    + TCP_SECRET_2MSL;
+			}
+			memcpy(&tcp_secret_secondary->secrets[0],
+			       &secrets[0],
+			       sizeof(secrets));
+
+			rcu_assign_pointer(tcp_secret_generating,
+					   tcp_secret_secondary);
+			rcu_assign_pointer(tcp_secret_retiring,
+					   tcp_secret_primary);
+			spin_unlock(&tcp_secret_locker);
+			/* call_rcu() or synchronize_rcu() not needed. */
+
+			memcpy(&xvp->cookie_bakery[0],
+			       &secrets[0],
+			       sizeof(secrets));
+		}
+	} else {
+		rcu_read_lock_bh();
+		memcpy(&xvp->cookie_bakery[0],
+		       &rcu_dereference(tcp_secret_generating)->secrets[0],
+		       sizeof(tcp_secret_generating->secrets));
+		rcu_read_unlock_bh();
+	}
+	return 0;
+}
+EXPORT_SYMBOL(tcp_cookie_generator);
+
 void tcp_done(struct sock *sk)
 {
 	if (sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
@@ -2967,6 +3088,7 @@ void __init tcp_init(void)
 	struct sk_buff *skb = NULL;
 	unsigned long nr_pages, limit;
 	int order, i, max_share;
+	unsigned long jiffy = jiffies;
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
@@ -3060,6 +3182,15 @@ void __init tcp_init(void)
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

--------------060704040403000705010805--
