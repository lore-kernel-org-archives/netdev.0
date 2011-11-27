From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 54/62] rds: remove the second argument of k[un]map_atomic()
Date: Sun, 27 Nov 2011 13:27:34 +0800
Message-ID: <1322371662-26166-55-git-send-email-amwang@redhat.com>
References: <1322371662-26166-1-git-send-email-amwang@redhat.com>
Cc: akpm@linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46287 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755632Ab1K0FiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 00:38:10 -0500
In-Reply-To: <1322371662-26166-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/rds/ib_recv.c  |    7 +++----
 net/rds/info.c     |    6 +++---
 net/rds/iw_recv.c  |    7 +++----
 net/rds/loop.c     |    2 +-
 net/rds/rds.h      |    2 +-
 net/rds/recv.c     |    2 +-
 net/rds/tcp_recv.c |   11 ++++-------
 7 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index e29e0ca..744a00d 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -763,7 +763,7 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
 		to_copy = min(RDS_FRAG_SIZE - frag_off, PAGE_SIZE - map_off);
 		BUG_ON(to_copy & 7); /* Must be 64bit aligned. */
 
-		addr = kmap_atomic(sg_page(&frag->f_sg), KM_SOFTIRQ0);
+		addr = kmap_atomic(sg_page(&frag->f_sg));
 
 		src = addr + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
@@ -773,7 +773,7 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
 			uncongested |= ~(*src) & *dst;
 			*dst++ = *src++;
 		}
-		kunmap_atomic(addr, KM_SOFTIRQ0);
+		kunmap_atomic(addr);
 
 		copied += to_copy;
 
@@ -919,8 +919,7 @@ static void rds_ib_process_recv(struct rds_connection *conn,
 			rds_ib_cong_recv(conn, ibinc);
 		else {
 			rds_recv_incoming(conn, conn->c_faddr, conn->c_laddr,
-					  &ibinc->ii_inc, GFP_ATOMIC,
-					  KM_SOFTIRQ0);
+					  &ibinc->ii_inc, GFP_ATOMIC);
 			state->ack_next = be64_to_cpu(hdr->h_sequence);
 			state->ack_next_valid = 1;
 		}
diff --git a/net/rds/info.c b/net/rds/info.c
index f1c016c..9a6b4f6 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -104,7 +104,7 @@ EXPORT_SYMBOL_GPL(rds_info_deregister_func);
 void rds_info_iter_unmap(struct rds_info_iterator *iter)
 {
 	if (iter->addr) {
-		kunmap_atomic(iter->addr, KM_USER0);
+		kunmap_atomic(iter->addr);
 		iter->addr = NULL;
 	}
 }
@@ -119,7 +119,7 @@ void rds_info_copy(struct rds_info_iterator *iter, void *data,
 
 	while (bytes) {
 		if (!iter->addr)
-			iter->addr = kmap_atomic(*iter->pages, KM_USER0);
+			iter->addr = kmap_atomic(*iter->pages);
 
 		this = min(bytes, PAGE_SIZE - iter->offset);
 
@@ -134,7 +134,7 @@ void rds_info_copy(struct rds_info_iterator *iter, void *data,
 		iter->offset += this;
 
 		if (iter->offset == PAGE_SIZE) {
-			kunmap_atomic(iter->addr, KM_USER0);
+			kunmap_atomic(iter->addr);
 			iter->addr = NULL;
 			iter->offset = 0;
 			iter->pages++;
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index 5e57347..0bd9b5e 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -598,7 +598,7 @@ static void rds_iw_cong_recv(struct rds_connection *conn,
 		to_copy = min(RDS_FRAG_SIZE - frag_off, PAGE_SIZE - map_off);
 		BUG_ON(to_copy & 7); /* Must be 64bit aligned. */
 
-		addr = kmap_atomic(frag->f_page, KM_SOFTIRQ0);
+		addr = kmap_atomic(frag->f_page);
 
 		src = addr + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
@@ -608,7 +608,7 @@ static void rds_iw_cong_recv(struct rds_connection *conn,
 			uncongested |= ~(*src) & *dst;
 			*dst++ = *src++;
 		}
-		kunmap_atomic(addr, KM_SOFTIRQ0);
+		kunmap_atomic(addr);
 
 		copied += to_copy;
 
@@ -754,8 +754,7 @@ static void rds_iw_process_recv(struct rds_connection *conn,
 			rds_iw_cong_recv(conn, iwinc);
 		else {
 			rds_recv_incoming(conn, conn->c_faddr, conn->c_laddr,
-					  &iwinc->ii_inc, GFP_ATOMIC,
-					  KM_SOFTIRQ0);
+					  &iwinc->ii_inc, GFP_ATOMIC);
 			state->ack_next = be64_to_cpu(hdr->h_sequence);
 			state->ack_next_valid = 1;
 		}
diff --git a/net/rds/loop.c b/net/rds/loop.c
index bca6761..87ff2a8 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -79,7 +79,7 @@ static int rds_loop_xmit(struct rds_connection *conn, struct rds_message *rm,
 	rds_message_addref(rm);
 
 	rds_recv_incoming(conn, conn->c_laddr, conn->c_faddr, &rm->m_inc,
-			  GFP_KERNEL, KM_USER0);
+			  GFP_KERNEL);
 
 	rds_send_drop_acked(conn, be64_to_cpu(rm->m_inc.i_hdr.h_sequence),
 			    NULL);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 7eaba18..ec1d731 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -704,7 +704,7 @@ void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 		  __be32 saddr);
 void rds_inc_put(struct rds_incoming *inc);
 void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
-		       struct rds_incoming *inc, gfp_t gfp, enum km_type km);
+		       struct rds_incoming *inc, gfp_t gfp);
 int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		size_t size, int msg_flags);
 void rds_clear_recv_queue(struct rds_sock *rs);
diff --git a/net/rds/recv.c b/net/rds/recv.c
index bc3f8cd..5c6e9f1 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -155,7 +155,7 @@ static void rds_recv_incoming_exthdrs(struct rds_incoming *inc, struct rds_sock
  * tell us which roles the addrs in the conn are playing for this message.
  */
 void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
-		       struct rds_incoming *inc, gfp_t gfp, enum km_type km)
+		       struct rds_incoming *inc, gfp_t gfp)
 {
 	struct rds_sock *rs = NULL;
 	struct sock *sk;
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index 78205e2..6243258 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -169,7 +169,6 @@ static void rds_tcp_cong_recv(struct rds_connection *conn,
 struct rds_tcp_desc_arg {
 	struct rds_connection *conn;
 	gfp_t gfp;
-	enum km_type km;
 };
 
 static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
@@ -255,7 +254,7 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 			else
 				rds_recv_incoming(conn, conn->c_faddr,
 						  conn->c_laddr, &tinc->ti_inc,
-						  arg->gfp, arg->km);
+						  arg->gfp);
 
 			tc->t_tinc_hdr_rem = sizeof(struct rds_header);
 			tc->t_tinc_data_rem = 0;
@@ -272,8 +271,7 @@ out:
 }
 
 /* the caller has to hold the sock lock */
-static int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp,
-			     enum km_type km)
+static int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp)
 {
 	struct rds_tcp_connection *tc = conn->c_transport_data;
 	struct socket *sock = tc->t_sock;
@@ -283,7 +281,6 @@ static int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp,
 	/* It's like glib in the kernel! */
 	arg.conn = conn;
 	arg.gfp = gfp;
-	arg.km = km;
 	desc.arg.data = &arg;
 	desc.error = 0;
 	desc.count = 1; /* give more than one skb per call */
@@ -311,7 +308,7 @@ int rds_tcp_recv(struct rds_connection *conn)
 	rdsdebug("recv worker conn %p tc %p sock %p\n", conn, tc, sock);
 
 	lock_sock(sock->sk);
-	ret = rds_tcp_read_sock(conn, GFP_KERNEL, KM_USER0);
+	ret = rds_tcp_read_sock(conn, GFP_KERNEL);
 	release_sock(sock->sk);
 
 	return ret;
@@ -336,7 +333,7 @@ void rds_tcp_data_ready(struct sock *sk, int bytes)
 	ready = tc->t_orig_data_ready;
 	rds_tcp_stats_inc(s_tcp_data_ready_calls);
 
-	if (rds_tcp_read_sock(conn, GFP_ATOMIC, KM_SOFTIRQ0) == -ENOMEM)
+	if (rds_tcp_read_sock(conn, GFP_ATOMIC) == -ENOMEM)
 		queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
 out:
 	read_unlock_bh(&sk->sk_callback_lock);
-- 
1.7.4.4
