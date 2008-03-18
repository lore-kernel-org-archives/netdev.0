From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/2][RAW]: Add raw_hashinfo member on struct proto.
Date: Tue, 18 Mar 2008 16:52:18 +0300
Message-ID: <47DFC912.2000106@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46377 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbYCRNxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2008 09:53:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the patch sequence confusion :| but I found that the
similar thing can be done for raw sockets easily too late.

Expand the proto.h union with the raw_hashinfo member and use
it in raw_prot and rawv6_prot. This allows to drop the protocol
specific versions of hash and unhash callbacks.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/raw.h  |    4 ++--
 include/net/sock.h |    2 ++
 net/ipv4/raw.c     |   22 ++++++++--------------
 net/ipv6/raw.c     |   16 +++-------------
 4 files changed, 15 insertions(+), 29 deletions(-)

diff --git a/include/net/raw.h b/include/net/raw.h
index 1828f81..6c14a65 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -53,7 +53,7 @@ int raw_seq_open(struct inode *ino, struct file *file,
 
 #endif
 
-void raw_hash_sk(struct sock *sk, struct raw_hashinfo *h);
-void raw_unhash_sk(struct sock *sk, struct raw_hashinfo *h);
+void raw_hash_sk(struct sock *sk);
+void raw_unhash_sk(struct sock *sk);
 
 #endif	/* _RAW_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index b2d7fa1..068feee 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -498,6 +498,7 @@ extern int sk_wait_data(struct sock *sk, long *timeo);
 struct request_sock_ops;
 struct timewait_sock_ops;
 struct inet_hashinfo;
+struct raw_hashinfo;
 
 /* Networking protocol blocks we attach to sockets.
  * socket layer -> transport layer interface
@@ -583,6 +584,7 @@ struct proto {
 	union {
 		struct inet_hashinfo	*hashinfo;
 		struct hlist_head	*udp_hash;
+		struct raw_hashinfo	*raw_hash;
 	} h;
 
 	struct module		*owner;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index e10ef6c..b433b48 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -84,8 +84,9 @@ static struct raw_hashinfo raw_v4_hashinfo = {
 	.lock = __RW_LOCK_UNLOCKED(raw_v4_hashinfo.lock),
 };
 
-void raw_hash_sk(struct sock *sk, struct raw_hashinfo *h)
+void raw_hash_sk(struct sock *sk)
 {
+	struct raw_hashinfo *h = sk->sk_prot->h.raw_hash;
 	struct hlist_head *head;
 
 	head = &h->ht[inet_sk(sk)->num & (RAW_HTABLE_SIZE - 1)];
@@ -97,8 +98,10 @@ void raw_hash_sk(struct sock *sk, struct raw_hashinfo *h)
 }
 EXPORT_SYMBOL_GPL(raw_hash_sk);
 
-void raw_unhash_sk(struct sock *sk, struct raw_hashinfo *h)
+void raw_unhash_sk(struct sock *sk)
 {
+	struct raw_hashinfo *h = sk->sk_prot->h.raw_hash;
+
 	write_lock_bh(&h->lock);
 	if (sk_del_node_init(sk))
 		sock_prot_inuse_add(sk->sk_prot, -1);
@@ -106,16 +109,6 @@ void raw_unhash_sk(struct sock *sk, struct raw_hashinfo *h)
 }
 EXPORT_SYMBOL_GPL(raw_unhash_sk);
 
-static void raw_v4_hash(struct sock *sk)
-{
-	raw_hash_sk(sk, &raw_v4_hashinfo);
-}
-
-static void raw_v4_unhash(struct sock *sk)
-{
-	raw_unhash_sk(sk, &raw_v4_hashinfo);
-}
-
 static struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
 		unsigned short num, __be32 raddr, __be32 laddr, int dif)
 {
@@ -841,9 +834,10 @@ struct proto raw_prot = {
 	.recvmsg	   = raw_recvmsg,
 	.bind		   = raw_bind,
 	.backlog_rcv	   = raw_rcv_skb,
-	.hash		   = raw_v4_hash,
-	.unhash		   = raw_v4_unhash,
+	.hash		   = raw_hash_sk,
+	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw_sock),
+	.h.raw_hash	   = &raw_v4_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_raw_setsockopt,
 	.compat_getsockopt = compat_raw_getsockopt,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d6afa02..a9e4235 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -65,17 +65,6 @@ static struct raw_hashinfo raw_v6_hashinfo = {
 	.lock = __RW_LOCK_UNLOCKED(raw_v6_hashinfo.lock),
 };
 
-static void raw_v6_hash(struct sock *sk)
-{
-	raw_hash_sk(sk, &raw_v6_hashinfo);
-}
-
-static void raw_v6_unhash(struct sock *sk)
-{
-	raw_unhash_sk(sk, &raw_v6_hashinfo);
-}
-
-
 static struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 		unsigned short num, struct in6_addr *loc_addr,
 		struct in6_addr *rmt_addr, int dif)
@@ -1201,9 +1190,10 @@ struct proto rawv6_prot = {
 	.recvmsg	   = rawv6_recvmsg,
 	.bind		   = rawv6_bind,
 	.backlog_rcv	   = rawv6_rcv_skb,
-	.hash		   = raw_v6_hash,
-	.unhash		   = raw_v6_unhash,
+	.hash		   = raw_hash_sk,
+	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw6_sock),
+	.h.raw_hash	   = &raw_v6_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_rawv6_setsockopt,
 	.compat_getsockopt = compat_rawv6_getsockopt,
-- 
1.5.3.4

