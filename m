From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH RFC] net/socket: use per af lockdep classes for sk queues
Date: Fri, 24 Feb 2017 14:29:11 +0100
Message-ID: <a6eb8644399fef96b27dae1a917274c394caab2f.1487942713.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51925 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751125AbdBXN3v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Feb 2017 08:29:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the sock queue's spin locks get their lockdep
classes by the default init_spin_lock() initializer:
all socket families get - usually, see below - a single
class for rx, another specific class for tx, etc.
This can lead to false positive lockdep splat, as
reported by Andrey.
Moreover there are two separate initialization points
for the sock queues, one in sk_clone_lock() and one
in sock_init_data(), so that e.g. the rx queue lock
can get one of two possible, different classes, depending
on the socket being cloned or not.
This change tries to address the above, setting explicitly
a per address family lockdep class for each queue's
spinlock. Also, move the duplicated initialization code to a
single location.

Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
Targeting the net-next tree since this a bit invasive

 net/core/sock.c | 96 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 78 insertions(+), 18 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index e7d7494..0c76524 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -258,12 +258,66 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_KCM"      ,
   "clock-AF_QIPCRTR", "clock-AF_SMC"     , "clock-AF_MAX"
 };
+static const char *const af_family_rlock_key_strings[AF_MAX+1] = {
+  "rlock-AF_UNSPEC", "rlock-AF_UNIX"     , "rlock-AF_INET"     ,
+  "rlock-AF_AX25"  , "rlock-AF_IPX"      , "rlock-AF_APPLETALK",
+  "rlock-AF_NETROM", "rlock-AF_BRIDGE"   , "rlock-AF_ATMPVC"   ,
+  "rlock-AF_X25"   , "rlock-AF_INET6"    , "rlock-AF_ROSE"     ,
+  "rlock-AF_DECnet", "rlock-AF_NETBEUI"  , "rlock-AF_SECURITY" ,
+  "rlock-AF_KEY"   , "rlock-AF_NETLINK"  , "rlock-AF_PACKET"   ,
+  "rlock-AF_ASH"   , "rlock-AF_ECONET"   , "rlock-AF_ATMSVC"   ,
+  "rlock-AF_RDS"   , "rlock-AF_SNA"      , "rlock-AF_IRDA"     ,
+  "rlock-AF_PPPOX" , "rlock-AF_WANPIPE"  , "rlock-AF_LLC"      ,
+  "rlock-27"       , "rlock-28"          , "rlock-AF_CAN"      ,
+  "rlock-AF_TIPC"  , "rlock-AF_BLUETOOTH", "rlock-AF_IUCV"     ,
+  "rlock-AF_RXRPC" , "rlock-AF_ISDN"     , "rlock-AF_PHONET"   ,
+  "rlock-AF_IEEE802154", "rlock-AF_CAIF" , "rlock-AF_ALG"      ,
+  "rlock-AF_NFC"   , "rlock-AF_VSOCK"    , "rlock-AF_KCM"      ,
+  "rlock-AF_QIPCRTR", "rlock-AF_SMC"     , "rlock-AF_MAX"
+};
+static const char *const af_family_wlock_key_strings[AF_MAX+1] = {
+  "wlock-AF_UNSPEC", "wlock-AF_UNIX"     , "wlock-AF_INET"     ,
+  "wlock-AF_AX25"  , "wlock-AF_IPX"      , "wlock-AF_APPLETALK",
+  "wlock-AF_NETROM", "wlock-AF_BRIDGE"   , "wlock-AF_ATMPVC"   ,
+  "wlock-AF_X25"   , "wlock-AF_INET6"    , "wlock-AF_ROSE"     ,
+  "wlock-AF_DECnet", "wlock-AF_NETBEUI"  , "wlock-AF_SECURITY" ,
+  "wlock-AF_KEY"   , "wlock-AF_NETLINK"  , "wlock-AF_PACKET"   ,
+  "wlock-AF_ASH"   , "wlock-AF_ECONET"   , "wlock-AF_ATMSVC"   ,
+  "wlock-AF_RDS"   , "wlock-AF_SNA"      , "wlock-AF_IRDA"     ,
+  "wlock-AF_PPPOX" , "wlock-AF_WANPIPE"  , "wlock-AF_LLC"      ,
+  "wlock-27"       , "wlock-28"          , "wlock-AF_CAN"      ,
+  "wlock-AF_TIPC"  , "wlock-AF_BLUETOOTH", "wlock-AF_IUCV"     ,
+  "wlock-AF_RXRPC" , "wlock-AF_ISDN"     , "wlock-AF_PHONET"   ,
+  "wlock-AF_IEEE802154", "wlock-AF_CAIF" , "wlock-AF_ALG"      ,
+  "wlock-AF_NFC"   , "wlock-AF_VSOCK"    , "wlock-AF_KCM"      ,
+  "wlock-AF_QIPCRTR", "wlock-AF_SMC"     , "wlock-AF_MAX"
+};
+static const char *const af_family_elock_key_strings[AF_MAX+1] = {
+  "elock-AF_UNSPEC", "elock-AF_UNIX"     , "elock-AF_INET"     ,
+  "elock-AF_AX25"  , "elock-AF_IPX"      , "elock-AF_APPLETALK",
+  "elock-AF_NETROM", "elock-AF_BRIDGE"   , "elock-AF_ATMPVC"   ,
+  "elock-AF_X25"   , "elock-AF_INET6"    , "elock-AF_ROSE"     ,
+  "elock-AF_DECnet", "elock-AF_NETBEUI"  , "elock-AF_SECURITY" ,
+  "elock-AF_KEY"   , "elock-AF_NETLINK"  , "elock-AF_PACKET"   ,
+  "elock-AF_ASH"   , "elock-AF_ECONET"   , "elock-AF_ATMSVC"   ,
+  "elock-AF_RDS"   , "elock-AF_SNA"      , "elock-AF_IRDA"     ,
+  "elock-AF_PPPOX" , "elock-AF_WANPIPE"  , "elock-AF_LLC"      ,
+  "elock-27"       , "elock-28"          , "elock-AF_CAN"      ,
+  "elock-AF_TIPC"  , "elock-AF_BLUETOOTH", "elock-AF_IUCV"     ,
+  "elock-AF_RXRPC" , "elock-AF_ISDN"     , "elock-AF_PHONET"   ,
+  "elock-AF_IEEE802154", "elock-AF_CAIF" , "elock-AF_ALG"      ,
+  "elock-AF_NFC"   , "elock-AF_VSOCK"    , "elock-AF_KCM"      ,
+  "elock-AF_QIPCRTR", "elock-AF_SMC"     , "elock-AF_MAX"
+};
 
 /*
- * sk_callback_lock locking rules are per-address-family,
+ * sk_callback_lock and sk queues locking rules are per-address-family,
  * so split the lock classes by using a per-AF key:
  */
 static struct lock_class_key af_callback_keys[AF_MAX];
+static struct lock_class_key af_rlock_keys[AF_MAX];
+static struct lock_class_key af_wlock_keys[AF_MAX];
+static struct lock_class_key af_elock_keys[AF_MAX];
 
 /* Take into consideration the size of the struct sk_buff overhead in the
  * determination of these values, since that is non-constant across
@@ -1478,6 +1532,27 @@ void sk_free(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_free);
 
+static void sk_init_locks(struct sock *sk)
+{
+	skb_queue_head_init(&sk->sk_receive_queue);
+	skb_queue_head_init(&sk->sk_write_queue);
+	skb_queue_head_init(&sk->sk_error_queue);
+
+	rwlock_init(&sk->sk_callback_lock);
+	lockdep_set_class_and_name(&sk->sk_receive_queue.lock,
+			af_rlock_keys + sk->sk_family,
+			af_family_rlock_key_strings[sk->sk_family]);
+	lockdep_set_class_and_name(&sk->sk_write_queue.lock,
+			af_wlock_keys + sk->sk_family,
+			af_family_wlock_key_strings[sk->sk_family]);
+	lockdep_set_class_and_name(&sk->sk_error_queue.lock,
+			af_elock_keys + sk->sk_family,
+			af_family_elock_key_strings[sk->sk_family]);
+	lockdep_set_class_and_name(&sk->sk_callback_lock,
+			af_callback_keys + sk->sk_family,
+			af_family_clock_key_strings[sk->sk_family]);
+}
+
 /**
  *	sk_clone_lock - clone a socket, and lock its clone
  *	@sk: the socket to clone
@@ -1511,13 +1586,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		 */
 		atomic_set(&newsk->sk_wmem_alloc, 1);
 		atomic_set(&newsk->sk_omem_alloc, 0);
-		skb_queue_head_init(&newsk->sk_receive_queue);
-		skb_queue_head_init(&newsk->sk_write_queue);
-
-		rwlock_init(&newsk->sk_callback_lock);
-		lockdep_set_class_and_name(&newsk->sk_callback_lock,
-				af_callback_keys + newsk->sk_family,
-				af_family_clock_key_strings[newsk->sk_family]);
+		sk_init_locks(newsk);
 
 		newsk->sk_dst_cache	= NULL;
 		newsk->sk_dst_pending_confirm = 0;
@@ -1528,7 +1597,6 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_userlocks	= sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
 
 		sock_reset_flag(newsk, SOCK_DONE);
-		skb_queue_head_init(&newsk->sk_error_queue);
 
 		filter = rcu_dereference_protected(newsk->sk_filter, 1);
 		if (filter != NULL)
@@ -2448,10 +2516,7 @@ EXPORT_SYMBOL(sk_stop_timer);
 
 void sock_init_data(struct socket *sock, struct sock *sk)
 {
-	skb_queue_head_init(&sk->sk_receive_queue);
-	skb_queue_head_init(&sk->sk_write_queue);
-	skb_queue_head_init(&sk->sk_error_queue);
-
+	sk_init_locks(sk);
 	sk->sk_send_head	=	NULL;
 
 	init_timer(&sk->sk_timer);
@@ -2474,11 +2539,6 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 		sk->sk_uid	=	make_kuid(sock_net(sk)->user_ns, 0);
 	}
 
-	rwlock_init(&sk->sk_callback_lock);
-	lockdep_set_class_and_name(&sk->sk_callback_lock,
-			af_callback_keys + sk->sk_family,
-			af_family_clock_key_strings[sk->sk_family]);
-
 	sk->sk_state_change	=	sock_def_wakeup;
 	sk->sk_data_ready	=	sock_def_readable;
 	sk->sk_write_space	=	sock_def_write_space;
-- 
2.9.3
