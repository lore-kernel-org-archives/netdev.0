From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Thu, 19 Oct 2006 11:27:50 +0200
Message-ID: <200610191127.50831.dada1@cosmosbay.com>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu> <20061016.223513.35356292.davem@davemloft.net> <200610171458.37636.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_WU0NFlk0I1hkKSu"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:38084 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1030368AbWJSJ1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 05:27:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <200610171458.37636.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_WU0NFlk0I1hkKSu
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David

Here is the second try for this patch. Many thanks for your feedback.

[PATCH] [NET] Size listen hash tables using backlog hint

We currently allocate =C2=A0a fixed size 512 (TCP_SYNQ_HSIZE) slots hash ta=
ble for=20
each LISTEN socket, regardless of various parameters (listen backlog for=20
example)

On x86_64, this means order-1 allocations (might fail), even for 'small'=20
sockets, expecting few connections. On the contrary, a huge server wanting =
a=20
backlog of 50000 is slowed down a bit because of this fixed limit.

This patch makes the sizing of listen hash table a dynamic parameter,=20
depending of :
=2D net.core.somaxconn tunable (default is 128)
=2D net.ipv4.tcp_max_syn_backlog tunable (default : 256, 1024 or 128)
=2D backlog value given by user application =C2=A0(2nd parameter of listen(=
))

=46or large allocations (bigger than PAGE_SIZE), we use vmalloc() instead o=
f=20
kmalloc().

We still limit memory allocation with the two existing tunables (somaxconn =
&=20
tcp_max_syn_backlog).

 include/net/request_sock.h      |    8 ++++----
 include/net/tcp.h               |    1 -
 net/core/request_sock.c         |   38 +++++++++++++++++++++++++++++------=
=2D--
 net/dccp/ipv4.c                 |    2 +-
 net/dccp/proto.c                |    6 +++---
 net/ipv4/af_inet.c              |    2 +-
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/tcp_ipv4.c             |    6 +++---
 net/ipv6/tcp_ipv6.c             |    2 +-
 9 files changed, 43 insertions(+), 24 deletions(-)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_WU0NFlk0I1hkKSu
Content-Type: text/plain;
  charset="utf-8";
  name="size_listen_hash_table.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="size_listen_hash_table.patch"

--- linux-2.6.19-rc2/net/core/request_sock.c	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/net/core/request_sock.c	2006-10-19 11:05:56.000000000 +0200
@@ -15,6 +15,7 @@
 #include <linux/random.h>
 #include <linux/slab.h>
 #include <linux/string.h>
+#include <linux/vmalloc.h>
 
 #include <net/request_sock.h>
 
@@ -29,22 +30,31 @@
  * it is absolutely not enough even at 100conn/sec. 256 cures most
  * of problems. This value is adjusted to 128 for very small machines
  * (<=32Mb of memory) and to 1024 on normal or better ones (>=256Mb).
- * Further increasing requires to change hash table size.
+ * Note : Dont forget somaxconn that may limit backlog too.
  */
 int sysctl_max_syn_backlog = 256;
 
 int reqsk_queue_alloc(struct request_sock_queue *queue,
-		      const int nr_table_entries)
+		      unsigned int nr_table_entries)
 {
-	const int lopt_size = sizeof(struct listen_sock) +
-			      nr_table_entries * sizeof(struct request_sock *);
-	struct listen_sock *lopt = kzalloc(lopt_size, GFP_KERNEL);
+	size_t lopt_size = sizeof(struct listen_sock);
+	struct listen_sock *lopt;
 
+	nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
+	nr_table_entries = max_t(u32, nr_table_entries, 8);
+	nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
+	lopt_size += nr_table_entries * sizeof(struct request_sock *);
+	if (lopt_size > PAGE_SIZE)
+		lopt = __vmalloc(lopt_size,
+			GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
+			PAGE_KERNEL);
+	else
+		lopt = kzalloc(lopt_size, GFP_KERNEL);
 	if (lopt == NULL)
 		return -ENOMEM;
 
-	for (lopt->max_qlen_log = 6;
-	     (1 << lopt->max_qlen_log) < sysctl_max_syn_backlog;
+	for (lopt->max_qlen_log = 3;
+	     (1 << lopt->max_qlen_log) < nr_table_entries;
 	     lopt->max_qlen_log++);
 
 	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
@@ -52,6 +62,11 @@
 	queue->rskq_accept_head = NULL;
 	lopt->nr_table_entries = nr_table_entries;
 
+	/*
+	 * This write_lock_bh()/write_unlock_bh() pair forces this CPU to commit
+	 * its memory changes and let readers (which acquire syn_wait_lock in
+	 * reader mode) operate without seeing random content.
+	 */
 	write_lock_bh(&queue->syn_wait_lock);
 	queue->listen_opt = lopt;
 	write_unlock_bh(&queue->syn_wait_lock);
@@ -65,9 +80,11 @@
 {
 	/* make all the listen_opt local to us */
 	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
+	size_t lopt_size = sizeof(struct listen_sock) +
+		lopt->nr_table_entries * sizeof(struct request_sock *);
 
 	if (lopt->qlen != 0) {
-		int i;
+		unsigned int i;
 
 		for (i = 0; i < lopt->nr_table_entries; i++) {
 			struct request_sock *req;
@@ -81,7 +98,10 @@
 	}
 
 	BUG_TRAP(lopt->qlen == 0);
-	kfree(lopt);
+	if (lopt_size > PAGE_SIZE)
+		vfree(lopt);
+	else
+		kfree(lopt);
 }
 
 EXPORT_SYMBOL(reqsk_queue_destroy);
--- linux-2.6.19-rc2/net/ipv4/af_inet.c	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/net/ipv4/af_inet.c	2006-10-17 10:32:22.000000000 +0200
@@ -204,7 +204,7 @@
 	 * we can only allow the backlog to be adjusted.
 	 */
 	if (old_state != TCP_LISTEN) {
-		err = inet_csk_listen_start(sk, TCP_SYNQ_HSIZE);
+		err = inet_csk_listen_start(sk, backlog);
 		if (err)
 			goto out;
 	}
--- linux-2.6.19-rc2/net/ipv4/tcp_ipv4.c	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/net/ipv4/tcp_ipv4.c	2006-10-17 12:19:38.000000000 +0200
@@ -715,7 +715,7 @@
 	return dopt;
 }
 
-struct request_sock_ops tcp_request_sock_ops = {
+struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 	.family		=	PF_INET,
 	.obj_size	=	sizeof(struct tcp_request_sock),
 	.rtx_syn_ack	=	tcp_v4_send_synack,
@@ -1385,7 +1385,7 @@
 	if (st->state == TCP_SEQ_STATE_OPENREQ) {
 		struct request_sock *req = cur;
 
-	       	icsk = inet_csk(st->syn_wait_sk);
+		icsk = inet_csk(st->syn_wait_sk);
 		req = req->dl_next;
 		while (1) {
 			while (req) {
@@ -1395,7 +1395,7 @@
 				}
 				req = req->dl_next;
 			}
-			if (++st->sbucket >= TCP_SYNQ_HSIZE)
+			if (++st->sbucket >= icsk->icsk_accept_queue.listen_opt->nr_table_entries)
 				break;
 get_req:
 			req = icsk->icsk_accept_queue.listen_opt->syn_table[st->sbucket];
--- linux-2.6.19-rc2/net/dccp/proto.c	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/net/dccp/proto.c	2006-10-17 10:32:22.000000000 +0200
@@ -262,12 +262,12 @@
 
 EXPORT_SYMBOL_GPL(dccp_destroy_sock);
 
-static inline int dccp_listen_start(struct sock *sk)
+static inline int dccp_listen_start(struct sock *sk, int backlog)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
 	dp->dccps_role = DCCP_ROLE_LISTEN;
-	return inet_csk_listen_start(sk, TCP_SYNQ_HSIZE);
+	return inet_csk_listen_start(sk, backlog);
 }
 
 int dccp_disconnect(struct sock *sk, int flags)
@@ -788,7 +788,7 @@
 		 * FIXME: here it probably should be sk->sk_prot->listen_start
 		 * see tcp_listen_start
 		 */
-		err = dccp_listen_start(sk);
+		err = dccp_listen_start(sk, backlog);
 		if (err)
 			goto out;
 	}
--- linux-2.6.19-rc2/net/dccp/ipv4.c	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/net/dccp/ipv4.c	2006-10-17 10:44:21.000000000 +0200
@@ -1020,7 +1020,7 @@
 	kfree(inet_rsk(req)->opt);
 }
 
-static struct request_sock_ops dccp_request_sock_ops = {
+static struct request_sock_ops dccp_request_sock_ops _read_mostly = {
 	.family		= PF_INET,
 	.obj_size	= sizeof(struct dccp_request_sock),
 	.rtx_syn_ack	= dccp_v4_send_response,
--- linux-2.6.19-rc2/net/ipv6/tcp_ipv6.c	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/net/ipv6/tcp_ipv6.c	2006-10-17 10:44:21.000000000 +0200
@@ -526,7 +526,7 @@
 		kfree_skb(inet6_rsk(req)->pktopts);
 }
 
-static struct request_sock_ops tcp6_request_sock_ops = {
+static struct request_sock_ops tcp6_request_sock_ops _read_mostly = {
 	.family		=	AF_INET6,
 	.obj_size	=	sizeof(struct tcp6_request_sock),
 	.rtx_syn_ack	=	tcp_v6_send_synack,
--- linux-2.6.19-rc2/net/ipv4/inet_connection_sock.c	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/net/ipv4/inet_connection_sock.c	2006-10-19 10:51:26.000000000 +0200
@@ -343,7 +343,7 @@
 EXPORT_SYMBOL_GPL(inet_csk_route_req);
 
 static inline u32 inet_synq_hash(const __be32 raddr, const __be16 rport,
-				 const u32 rnd, const u16 synq_hsize)
+				 const u32 rnd, const u32 synq_hsize)
 {
 	return jhash_2words((__force u32)raddr, (__force u32)rport, rnd) & (synq_hsize - 1);
 }
--- linux-2.6.19-rc2/include/net/tcp.h	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/include/net/tcp.h	2006-10-17 10:51:51.000000000 +0200
@@ -138,7 +138,6 @@
 #define MAX_TCP_SYNCNT		127
 
 #define TCP_SYNQ_INTERVAL	(HZ/5)	/* Period of SYNACK timer */
-#define TCP_SYNQ_HSIZE		512	/* Size of SYNACK hash table */
 
 #define TCP_PAWS_24DAYS	(60 * 60 * 24 * 24)
 #define TCP_PAWS_MSL	60		/* Per-host timestamps are invalidated
--- linux-2.6.19-rc2/include/net/request_sock.h	2006-10-13 18:25:04.000000000 +0200
+++ linux-2.6.19-rc2-ed/include/net/request_sock.h	2006-10-17 12:33:18.000000000 +0200
@@ -28,8 +28,8 @@
 
 struct request_sock_ops {
 	int		family;
-	kmem_cache_t	*slab;
 	int		obj_size;
+	kmem_cache_t	*slab;
 	int		(*rtx_syn_ack)(struct sock *sk,
 				       struct request_sock *req,
 				       struct dst_entry *dst);
@@ -51,12 +51,12 @@
 	u32				rcv_wnd;	  /* rcv_wnd offered first time */
 	u32				ts_recent;
 	unsigned long			expires;
-	struct request_sock_ops		*rsk_ops;
+	const struct request_sock_ops		*rsk_ops;
 	struct sock			*sk;
 	u32				secid;
 };
 
-static inline struct request_sock *reqsk_alloc(struct request_sock_ops *ops)
+static inline struct request_sock *reqsk_alloc(const struct request_sock_ops *ops)
 {
 	struct request_sock *req = kmem_cache_alloc(ops->slab, SLAB_ATOMIC);
 
@@ -120,7 +120,7 @@
 };
 
 extern int reqsk_queue_alloc(struct request_sock_queue *queue,
-			     const int nr_table_entries);
+			     unsigned int nr_table_entries);
 
 static inline struct listen_sock *reqsk_queue_yank_listen_sk(struct request_sock_queue *queue)
 {

--Boundary-00=_WU0NFlk0I1hkKSu--
