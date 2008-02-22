From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET] sock.c: sk_dst_lock lockdep keys and names per
	af_family
Date: Fri, 22 Feb 2008 14:16:05 +0000
Message-ID: <20080222141605.GA2633@ff.dom.local>
References: <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local> <47BCABC5.9080204@katalix.com> <20080221085959.GA12944@ff.dom.local> <47BD4A34.7070606@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:6212 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758733AbYBVOPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 09:15:16 -0500
Received: by nf-out-0910.google.com with SMTP id g13so249371nfb.21
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 06:15:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47BD4A34.7070606@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2008 at 09:53:56AM +0000, James Chapman wrote:
...
> The lockups still happen, but I think they are now due to a different  
> problem, as you say.
...

I hope, this patch should help to remove some possibly false lockdep
warnings during this current testing.

Regards,
Jarek P.

------------------->

Subject: [NET] sock.c: sk_dst_lock lockdep keys and names per af_family

Initialize sk_dst_lock lockdep keys and names per af_family.

Additionally some reorder is done in lockdep related code to keep
it in one place and to use static key tables only when needed.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

[not tested]
---

 net/core/sock.c |   79 +++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 56 insertions(+), 23 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 433715f..18c33d2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -131,14 +131,17 @@
 #include <net/tcp.h>
 #endif
 
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+
 /*
- * Each address family might have different locking rules, so we have
- * one slock key per address family:
+ * Each address family might have different locking rules, so we have one:
+ * sk_lock, slock, sk_callback_lock and sk_dst_lock key per address family:
  */
 static struct lock_class_key af_family_keys[AF_MAX];
 static struct lock_class_key af_family_slock_keys[AF_MAX];
+static struct lock_class_key af_family_callback_keys[AF_MAX];
+static struct lock_class_key af_family_dst_keys[AF_MAX];
 
-#ifdef CONFIG_DEBUG_LOCK_ALLOC
 /*
  * Make lock validator output more readable. (we pre-construct these
  * strings build-time, so that runtime initialization of socket
@@ -186,13 +189,52 @@ static const char *af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_MAX"
 };
-#endif
+static const char *af_family_dst_key_strings[AF_MAX+1] = {
+  "sk_dst-AF_UNSPEC", "sk_dst-AF_UNIX"     , "sk_dst-AF_INET"     ,
+  "sk_dst-AF_AX25"  , "sk_dst-AF_IPX"      , "sk_dst-AF_APPLETALK",
+  "sk_dst-AF_NETROM", "sk_dst-AF_BRIDGE"   , "sk_dst-AF_ATMPVC"   ,
+  "sk_dst-AF_X25"   , "sk_dst-AF_INET6"    , "sk_dst-AF_ROSE"     ,
+  "sk_dst-AF_DECnet", "sk_dst-AF_NETBEUI"  , "sk_dst-AF_SECURITY" ,
+  "sk_dst-AF_KEY"   , "sk_dst-AF_NETLINK"  , "sk_dst-AF_PACKET"   ,
+  "sk_dst-AF_ASH"   , "sk_dst-AF_ECONET"   , "sk_dst-AF_ATMSVC"   ,
+  "sk_dst-21"       , "sk_dst-AF_SNA"      , "sk_dst-AF_IRDA"     ,
+  "sk_dst-AF_PPPOX" , "sk_dst-AF_WANPIPE"  , "sk_dst-AF_LLC"      ,
+  "sk_dst-27"       , "sk_dst-28"          , "sk_dst-29"          ,
+  "sk_dst-AF_TIPC"  , "sk_dst-AF_BLUETOOTH", "sk_dst-AF_IUCV"     ,
+  "sk_dst-AF_RXRPC" , "sk_dst-AF_MAX"
+};
 
-/*
- * sk_callback_lock locking rules are per-address-family,
- * so split the lock classes by using a per-AF key:
- */
-static struct lock_class_key af_callback_keys[AF_MAX];
+
+static inline void sock_lock_init(struct sock *sk)
+{
+	sock_lock_init_class_and_name(sk,
+			af_family_slock_key_strings[sk->sk_family],
+			af_family_slock_keys + sk->sk_family,
+			af_family_key_strings[sk->sk_family],
+			af_family_keys + sk->sk_family);
+}
+
+#define lockdep_set_sk_callback_lock(lock, family) \
+		lockdep_set_class_and_name(lock, \
+					af_family_callback_keys + (family), \
+					af_family_clock_key_strings[(family)])
+
+#define lockdep_set_sk_dst_lock(lock, family) \
+		lockdep_set_class_and_name(lock, \
+					af_family_dst_keys + (family), \
+					af_family_dst_key_strings[(family)])
+
+#else
+
+static inline void sock_lock_init(struct sock *sk)
+{
+	sock_lock_init_class_and_name(sk, 0, 0, 0, 0);
+}
+
+#define lockdep_set_sk_callback_lock(lock, family)	do {} while (0)
+#define lockdep_set_sk_dst_lock(lock, family)		do {} while (0)
+
+#endif	/* CONFIG_DEBUG_LOCK_ALLOC */
 
 /* Take into consideration the size of the struct sk_buff overhead in the
  * determination of these values, since that is non-constant across
@@ -866,14 +908,6 @@ lenout:
  *
  * (We also register the sk_lock with the lock validator.)
  */
-static inline void sock_lock_init(struct sock *sk)
-{
-	sock_lock_init_class_and_name(sk,
-			af_family_slock_key_strings[sk->sk_family],
-			af_family_slock_keys + sk->sk_family,
-			af_family_key_strings[sk->sk_family],
-			af_family_keys + sk->sk_family);
-}
 
 static void sock_copy(struct sock *nsk, const struct sock *osk)
 {
@@ -1014,10 +1048,10 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 #endif
 
 		rwlock_init(&newsk->sk_dst_lock);
+		lockdep_set_sk_dst_lock(&newsk->sk_dst_lock, newsk->sk_family);
 		rwlock_init(&newsk->sk_callback_lock);
-		lockdep_set_class_and_name(&newsk->sk_callback_lock,
-				af_callback_keys + newsk->sk_family,
-				af_family_clock_key_strings[newsk->sk_family]);
+		lockdep_set_sk_callback_lock(&newsk->sk_callback_lock,
+					     newsk->sk_family);
 
 		newsk->sk_dst_cache	= NULL;
 		newsk->sk_wmem_queued	= 0;
@@ -1703,10 +1737,9 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 		sk->sk_sleep	=	NULL;
 
 	rwlock_init(&sk->sk_dst_lock);
+	lockdep_set_sk_dst_lock(&sk->sk_dst_lock, sk->sk_family);
 	rwlock_init(&sk->sk_callback_lock);
-	lockdep_set_class_and_name(&sk->sk_callback_lock,
-			af_callback_keys + sk->sk_family,
-			af_family_clock_key_strings[sk->sk_family]);
+	lockdep_set_sk_callback_lock(&sk->sk_callback_lock, sk->sk_family);
 
 	sk->sk_state_change	=	sock_def_wakeup;
 	sk->sk_data_ready	=	sock_def_readable;
