From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] deinline sock_i_uid,sock_i_ino
Date: Wed, 7 Jul 2004 09:54:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707095443.7b54b63d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The sock_i_uid and sock_i_ino functions are only called by /proc type interfaces,
so they don't need to be inlined. 

Also, the inline functions writeable, rcvtimeo, sndtimeo are test for value functions
that don't change their argument.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2004-07-06 13:41:40 -07:00
+++ b/include/net/sock.h	2004-07-06 13:41:40 -07:00
@@ -917,25 +917,8 @@
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
-static inline int sock_i_uid(struct sock *sk)
-{
-	int uid;
-
-	read_lock(&sk->sk_callback_lock);
-	uid = sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : 0;
-	read_unlock(&sk->sk_callback_lock);
-	return uid;
-}
-
-static inline unsigned long sock_i_ino(struct sock *sk)
-{
-	unsigned long ino;
-
-	read_lock(&sk->sk_callback_lock);
-	ino = sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_ino : 0;
-	read_unlock(&sk->sk_callback_lock);
-	return ino;
-}
+extern int sock_i_uid(struct sock *sk);
+extern unsigned long sock_i_ino(struct sock *sk);
 
 static inline struct dst_entry *
 __sk_dst_get(struct sock *sk)
@@ -1219,7 +1202,7 @@
 /*
  *	Default write policy as shown to user space via poll/select/SIGIO
  */
-static inline int sock_writeable(struct sock *sk) 
+static inline int sock_writeable(const struct sock *sk) 
 {
 	return atomic_read(&sk->sk_wmem_alloc) < (sk->sk_sndbuf / 2);
 }
@@ -1229,17 +1212,17 @@
 	return in_softirq() ? GFP_ATOMIC : GFP_KERNEL;
 }
 
-static inline long sock_rcvtimeo(struct sock *sk, int noblock)
+static inline long sock_rcvtimeo(const struct sock *sk, int noblock)
 {
 	return noblock ? 0 : sk->sk_rcvtimeo;
 }
 
-static inline long sock_sndtimeo(struct sock *sk, int noblock)
+static inline long sock_sndtimeo(const struct sock *sk, int noblock)
 {
 	return noblock ? 0 : sk->sk_sndtimeo;
 }
 
-static inline int sock_rcvlowat(struct sock *sk, int waitall, int len)
+static inline int sock_rcvlowat(const struct sock *sk, int waitall, int len)
 {
 	return (waitall ? len : min_t(int, sk->sk_rcvlowat, len)) ? : 1;
 }
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	2004-07-06 13:41:40 -07:00
+++ b/net/core/sock.c	2004-07-06 13:41:40 -07:00
@@ -711,6 +711,27 @@
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
 }
 
+
+int sock_i_uid(struct sock *sk)
+{
+	int uid;
+
+	read_lock(&sk->sk_callback_lock);
+	uid = sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : 0;
+	read_unlock(&sk->sk_callback_lock);
+	return uid;
+}
+
+unsigned long sock_i_ino(struct sock *sk)
+{
+	unsigned long ino;
+
+	read_lock(&sk->sk_callback_lock);
+	ino = sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_ino : 0;
+	read_unlock(&sk->sk_callback_lock);
+	return ino;
+}
+
 /*
  * Allocate a skb from the socket's send buffer.
  */
@@ -1379,6 +1400,8 @@
 EXPORT_SYMBOL(sock_setsockopt);
 EXPORT_SYMBOL(sock_wfree);
 EXPORT_SYMBOL(sock_wmalloc);
+EXPORT_SYMBOL(sock_i_uid);
+EXPORT_SYMBOL(sock_i_ino);
 #ifdef CONFIG_SYSCTL
 EXPORT_SYMBOL(sysctl_optmem_max);
 EXPORT_SYMBOL(sysctl_rmem_max);
