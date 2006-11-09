From: akpm@osdl.org
Subject: [patch 4/9] lockdep: annotate sk_lock nesting in AF_BLUETOOTH
Date: Wed, 08 Nov 2006 19:51:05 -0800
Message-ID: <200611090351.kA93p5R3003687@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, a.p.zijlstra@chello.nl,
	marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17327 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965943AbWKIDvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 22:51:18 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

=============================================
[ INFO: possible recursive locking detected ]
2.6.18-1.2726.fc6 #1
---------------------------------------------
hidd/2271 is trying to acquire lock:
 (sk_lock-AF_BLUETOOTH){--..}, at: [<f8d16241>] bt_accept_dequeue+0x26/0xc6
[bluetooth]

but task is already holding lock:
 (sk_lock-AF_BLUETOOTH){--..}, at: [<f8bce088>] l2cap_sock_accept+0x41/0x11e [l2cap]

other info that might help us debug this:
1 lock held by hidd/2271:
 #0:  (sk_lock-AF_BLUETOOTH){--..}, at: [<f8bce088>]
l2cap_sock_accept+0x41/0x11e [l2cap]

stack backtrace:
 [<c04051ed>] show_trace_log_lvl+0x58/0x16a
 [<c04057fa>] show_trace+0xd/0x10
 [<c0405913>] dump_stack+0x19/0x1b
 [<c043b7dc>] __lock_acquire+0x6ea/0x90d
 [<c043bf70>] lock_acquire+0x4b/0x6b
 [<c05b203b>] lock_sock+0xac/0xbc
 [<f8d16241>] bt_accept_dequeue+0x26/0xc6 [bluetooth]
 [<f8bce129>] l2cap_sock_accept+0xe2/0x11e [l2cap]
 [<c05b142e>] sys_accept+0xd8/0x179
 [<c05b1576>] sys_socketcall+0xa7/0x186
 [<c0403fb7>] syscall_call+0x7/0xb

classical case of nesting; bt_accept_dequeue() locks the children of the object
locked by l2cap_sock_accept().

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/net/sock.h    |    8 +++++++-
 net/bluetooth/l2cap.c |    4 ++--
 net/core/sock.c       |    6 +++---
 3 files changed, 12 insertions(+), 6 deletions(-)

diff -puN include/net/sock.h~lockdep-annotate-sk_lock-nesting-in-af_bluetooth-v2 include/net/sock.h
--- a/include/net/sock.h~lockdep-annotate-sk_lock-nesting-in-af_bluetooth-v2
+++ a/include/net/sock.h
@@ -745,7 +745,13 @@ static inline int sk_stream_wmem_schedul
  */
 #define sock_owned_by_user(sk)	((sk)->sk_lock.owner)
 
-extern void FASTCALL(lock_sock(struct sock *sk));
+extern void FASTCALL(lock_sock_nested(struct sock *sk, int subclass));
+
+static inline void lock_sock(struct sock *sk)
+{
+	lock_sock_nested(sk, 0);
+}
+
 extern void FASTCALL(release_sock(struct sock *sk));
 
 /* BH context may only use the following locking interface. */
diff -puN net/bluetooth/l2cap.c~lockdep-annotate-sk_lock-nesting-in-af_bluetooth-v2 net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c~lockdep-annotate-sk_lock-nesting-in-af_bluetooth-v2
+++ a/net/bluetooth/l2cap.c
@@ -770,7 +770,7 @@ static int l2cap_sock_accept(struct sock
 	long timeo;
 	int err = 0;
 
-	lock_sock(sk);
+	lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
 
 	if (sk->sk_state != BT_LISTEN) {
 		err = -EBADFD;
@@ -792,7 +792,7 @@ static int l2cap_sock_accept(struct sock
 
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
-		lock_sock(sk);
+		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
 
 		if (sk->sk_state != BT_LISTEN) {
 			err = -EBADFD;
diff -puN net/core/sock.c~lockdep-annotate-sk_lock-nesting-in-af_bluetooth-v2 net/core/sock.c
--- a/net/core/sock.c~lockdep-annotate-sk_lock-nesting-in-af_bluetooth-v2
+++ a/net/core/sock.c
@@ -1527,7 +1527,7 @@ void sock_init_data(struct socket *sock,
 	atomic_set(&sk->sk_refcnt, 1);
 }
 
-void fastcall lock_sock(struct sock *sk)
+void fastcall lock_sock_nested(struct sock *sk, int subclass)
 {
 	might_sleep();
 	spin_lock_bh(&sk->sk_lock.slock);
@@ -1538,11 +1538,11 @@ void fastcall lock_sock(struct sock *sk)
 	/*
 	 * The sk_lock has mutex_lock() semantics here:
 	 */
-	mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
+	mutex_acquire(&sk->sk_lock.dep_map, subclass, 0, _RET_IP_);
 	local_bh_enable();
 }
 
-EXPORT_SYMBOL(lock_sock);
+EXPORT_SYMBOL(lock_sock_nested);
 
 void fastcall release_sock(struct sock *sk)
 {
_
