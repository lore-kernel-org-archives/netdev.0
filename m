From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ax25: Stop using sock->sk_protinfo.
Date: Thu, 25 Jun 2015 06:19:07 -0700 (PDT)
Message-ID: <20150625.061907.1258416005349767495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, edumazet@google.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbFYNHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 09:07:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just make a ax25_sock structure that provides the ax25_cb pointer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ax25.h |   16 +++++++++++++++-
 net/ax25/af_ax25.c |   30 +++++++++++++++---------------
 net/ax25/ax25_in.c |    2 +-
 3 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 16a923a..e602f81 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/atomic.h>
 #include <net/neighbour.h>
+#include <net/sock.h>
 
 #define	AX25_T1CLAMPLO  		1
 #define	AX25_T1CLAMPHI 			(30 * HZ)
@@ -246,7 +247,20 @@ typedef struct ax25_cb {
 	atomic_t		refcount;
 } ax25_cb;
 
-#define ax25_sk(__sk) ((ax25_cb *)(__sk)->sk_protinfo)
+struct ax25_sock {
+	struct sock		sk;
+	struct ax25_cb		*cb;
+};
+
+static inline struct ax25_sock *ax25_sk(const struct sock *sk)
+{
+	return (struct ax25_sock *) sk;
+}
+
+static inline struct ax25_cb *sk_to_ax25(const struct sock *sk)
+{
+	return ax25_sk(sk)->cb;
+}
 
 #define ax25_for_each(__ax25, list) \
 	hlist_for_each_entry(__ax25, list, ax25_node)
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 9c891d0..ae3a47f 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -57,7 +57,7 @@ static const struct proto_ops ax25_proto_ops;
 
 static void ax25_free_sock(struct sock *sk)
 {
-	ax25_cb_put(ax25_sk(sk));
+	ax25_cb_put(sk_to_ax25(sk));
 }
 
 /*
@@ -306,7 +306,7 @@ void ax25_destroy_socket(ax25_cb *ax25)
 		while ((skb = skb_dequeue(&ax25->sk->sk_receive_queue)) != NULL) {
 			if (skb->sk != ax25->sk) {
 				/* A pending connection */
-				ax25_cb *sax25 = ax25_sk(skb->sk);
+				ax25_cb *sax25 = sk_to_ax25(skb->sk);
 
 				/* Queue the unaccepted socket for death */
 				sock_orphan(skb->sk);
@@ -551,7 +551,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 		return -EFAULT;
 
 	lock_sock(sk);
-	ax25 = ax25_sk(sk);
+	ax25 = sk_to_ax25(sk);
 
 	switch (optname) {
 	case AX25_WINDOW:
@@ -697,7 +697,7 @@ static int ax25_getsockopt(struct socket *sock, int level, int optname,
 	length = min_t(unsigned int, maxlen, sizeof(int));
 
 	lock_sock(sk);
-	ax25 = ax25_sk(sk);
+	ax25 = sk_to_ax25(sk);
 
 	switch (optname) {
 	case AX25_WINDOW:
@@ -796,7 +796,7 @@ out:
 static struct proto ax25_proto = {
 	.name	  = "AX25",
 	.owner	  = THIS_MODULE,
-	.obj_size = sizeof(struct sock),
+	.obj_size = sizeof(struct ax25_sock),
 };
 
 static int ax25_create(struct net *net, struct socket *sock, int protocol,
@@ -858,7 +858,7 @@ static int ax25_create(struct net *net, struct socket *sock, int protocol,
 	if (sk == NULL)
 		return -ENOMEM;
 
-	ax25 = sk->sk_protinfo = ax25_create_cb();
+	ax25 = ax25_sk(sk)->cb = ax25_create_cb();
 	if (!ax25) {
 		sk_free(sk);
 		return -ENOMEM;
@@ -910,7 +910,7 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 	sk->sk_state    = TCP_ESTABLISHED;
 	sock_copy_flags(sk, osk);
 
-	oax25 = ax25_sk(osk);
+	oax25 = sk_to_ax25(osk);
 
 	ax25->modulus = oax25->modulus;
 	ax25->backoff = oax25->backoff;
@@ -938,7 +938,7 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 		}
 	}
 
-	sk->sk_protinfo = ax25;
+	ax25_sk(sk)->cb = ax25;
 	sk->sk_destruct = ax25_free_sock;
 	ax25->sk    = sk;
 
@@ -956,7 +956,7 @@ static int ax25_release(struct socket *sock)
 	sock_hold(sk);
 	sock_orphan(sk);
 	lock_sock(sk);
-	ax25 = ax25_sk(sk);
+	ax25 = sk_to_ax25(sk);
 
 	if (sk->sk_type == SOCK_SEQPACKET) {
 		switch (ax25->state) {
@@ -1066,7 +1066,7 @@ static int ax25_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	lock_sock(sk);
 
-	ax25 = ax25_sk(sk);
+	ax25 = sk_to_ax25(sk);
 	if (!sock_flag(sk, SOCK_ZAPPED)) {
 		err = -EINVAL;
 		goto out;
@@ -1113,7 +1113,7 @@ static int __must_check ax25_connect(struct socket *sock,
 	struct sockaddr *uaddr, int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
-	ax25_cb *ax25 = ax25_sk(sk), *ax25t;
+	ax25_cb *ax25 = sk_to_ax25(sk), *ax25t;
 	struct full_sockaddr_ax25 *fsa = (struct full_sockaddr_ax25 *)uaddr;
 	ax25_digi *digi = NULL;
 	int ct = 0, err = 0;
@@ -1394,7 +1394,7 @@ static int ax25_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	memset(fsa, 0, sizeof(*fsa));
 	lock_sock(sk);
-	ax25 = ax25_sk(sk);
+	ax25 = sk_to_ax25(sk);
 
 	if (peer != 0) {
 		if (sk->sk_state != TCP_ESTABLISHED) {
@@ -1446,7 +1446,7 @@ static int ax25_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		return -EINVAL;
 
 	lock_sock(sk);
-	ax25 = ax25_sk(sk);
+	ax25 = sk_to_ax25(sk);
 
 	if (sock_flag(sk, SOCK_ZAPPED)) {
 		err = -EADDRNOTAVAIL;
@@ -1621,7 +1621,7 @@ static int ax25_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 	if (skb == NULL)
 		goto out;
 
-	if (!ax25_sk(sk)->pidincl)
+	if (!sk_to_ax25(sk)->pidincl)
 		skb_pull(skb, 1);		/* Remove PID */
 
 	skb_reset_transport_header(skb);
@@ -1762,7 +1762,7 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 	case SIOCAX25GETINFO:
 	case SIOCAX25GETINFOOLD: {
-		ax25_cb *ax25 = ax25_sk(sk);
+		ax25_cb *ax25 = sk_to_ax25(sk);
 		struct ax25_info_struct ax25_info;
 
 		ax25_info.t1        = ax25->t1   / HZ;
diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 29a3687..bb5a0e4 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -353,7 +353,7 @@ static int ax25_rcv(struct sk_buff *skb, struct net_device *dev,
 			return 0;
 		}
 
-		ax25 = ax25_sk(make);
+		ax25 = sk_to_ax25(make);
 		skb_set_owner_r(skb, make);
 		skb_queue_head(&sk->sk_receive_queue, skb);
 
-- 
1.7.10.4
