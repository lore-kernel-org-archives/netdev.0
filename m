From: Ilya Pashkovsky <ilya.pashkovsky@gmail.com>
Subject: [PATCH] fixed patch for sk_reuse
Date: Wed, 8 Dec 2004 15:12:59 +0200
Message-ID: <fcb9aa2904120805126204ef1f@mail.gmail.com>
Reply-To: Ilya Pashkovsky <ilya.pashkovsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ah, it seems the sk_reuse > 1 is really used... 
do not try the previous patch.
http://puding.mine.nu/patches/patch-reuse

--- linux/net/ipv4/tcp_ipv4.c.orig2004-12-07 14:54:12.597084704 +0200
+++ linux/net/ipv4/tcp_ipv4.c2004-12-08 15:07:51.985722208 +0200
@@ -50,6 +50,7 @@
  *YOSHIFUJI Hideaki @USAGI and:Support IPV6_V6ONLY socket option, which
  *Alexey Kuznetsovallow both IPv4 and IPv6 sockets to bind
  *a single port at the same time.
+ *Ilya Pashkovsky:fix TCP_LISTEN check on reuse
  */
 
 #include <linux/config.h>
@@ -184,7 +185,8 @@ static inline int tcp_bind_conflict(stru
 const u32 sk_rcv_saddr = tcp_v4_rcv_saddr(sk);
 struct sock *sk2;
 struct hlist_node *node;
-int reuse = sk->sk_reuse;
+unsigned char reuse = sk->sk_reuse;
+unsigned char state = sk->sk_state;
 
 sk_for_each_bound(sk2, node, &tb->owners) {
 if (sk != sk2 &&
@@ -193,7 +195,7 @@ static inline int tcp_bind_conflict(stru
      !sk2->sk_bound_dev_if ||
      sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
 if (!reuse || !sk2->sk_reuse ||
-    sk2->sk_state == TCP_LISTEN) {
+    (state == TCP_LISTEN && sk2->sk_state == TCP_LISTEN)) {
 const u32 sk2_rcv_saddr = tcp_v4_rcv_saddr(sk2);
 if (!sk2_rcv_saddr || !sk_rcv_saddr ||
     sk2_rcv_saddr == sk_rcv_saddr)
