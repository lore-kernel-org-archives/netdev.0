From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] make lock/release_sock fast calls
Date: Wed, 31 Mar 2004 11:24:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331112407.66309027@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

lock_sock and release_sock are no longer inline, but they are called in
the critical path of many operations, so it makes sense to use register based
fastcall.

diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	Wed Mar 31 11:13:36 2004
+++ b/include/net/sock.h	Wed Mar 31 11:13:36 2004
@@ -561,8 +561,8 @@
 extern void __release_sock(struct sock *sk);
 #define sock_owned_by_user(sk)	((sk)->sk_lock.owner)
 
-extern void lock_sock(struct sock *sk);
-extern void release_sock(struct sock *sk);
+extern void FASTCALL(lock_sock(struct sock *sk));
+extern void FASTCALL(release_sock(struct sock *sk));
 
 /* BH context may only use the following locking interface. */
 #define bh_lock_sock(__sk)	spin_lock(&((__sk)->sk_lock.slock))
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	Wed Mar 31 11:13:36 2004
+++ b/net/core/sock.c	Wed Mar 31 11:13:36 2004
@@ -1151,7 +1151,7 @@
 	atomic_set(&sk->sk_refcnt, 1);
 }
 
-void lock_sock(struct sock *sk)
+void fastcall lock_sock(struct sock *sk)
 {
 	might_sleep();
 	spin_lock_bh(&(sk->sk_lock.slock));
@@ -1163,7 +1163,7 @@
 
 EXPORT_SYMBOL(lock_sock);
 
-void release_sock(struct sock *sk)
+void fastcall release_sock(struct sock *sk)
 {
 	spin_lock_bh(&(sk->sk_lock.slock));
 	if (sk->sk_backlog.tail)
