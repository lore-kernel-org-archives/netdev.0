From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/3] kcm: Remove TCP specific references from kcm and strparser
Date: Sun, 28 Aug 2016 14:43:19 -0700
Message-ID: <1472420599-510735-4-git-send-email-tom@herbertland.com>
References: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <davejwatson@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39069 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932346AbcH1Vnq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 17:43:46 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7SLZ4Ia013928
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 14:43:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2538j7cpmk-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 14:43:45 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 7e2c7d066d6811e691850002c9931860-378edaa0 for <netdev@vger.kernel.org>;        Sun,
 28 Aug 2016 14:43:44 -0700
In-Reply-To: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kcm and strparser need to work with any type of stream socket not just
TCP. Eliminate references to TCP and call generic proto_ops functions of
read_sock and peek_len. Also in strp_init check if the socket support
the proto_ops read_sock and peek_len.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/strparser.h   |  2 +-
 net/kcm/kcmsock.c         | 30 +++++++++++++----------------
 net/strparser/strparser.c | 48 ++++++++++++++++++++++++++++-------------------
 3 files changed, 43 insertions(+), 37 deletions(-)

diff --git a/include/net/strparser.h b/include/net/strparser.h
index 91fa0b9..0c28ad9 100644
--- a/include/net/strparser.h
+++ b/include/net/strparser.h
@@ -137,6 +137,6 @@ void strp_stop(struct strparser *strp);
 void strp_check_rcv(struct strparser *strp);
 int strp_init(struct strparser *strp, struct sock *csk,
 	      struct strp_callbacks *cb);
-void strp_tcp_data_ready(struct strparser *strp);
+void strp_data_ready(struct strparser *strp);
 
 #endif /* __NET_STRPARSER_H_ */
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index eb731ca..2632ac7 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -26,7 +26,6 @@
 #include <net/kcm.h>
 #include <net/netns/generic.h>
 #include <net/sock.h>
-#include <net/tcp.h>
 #include <uapi/linux/kcm.h>
 
 unsigned int kcm_net_id;
@@ -340,7 +339,7 @@ static void unreserve_rx_kcm(struct kcm_psock *psock,
 }
 
 /* Lower sock lock held */
-static void psock_tcp_data_ready(struct sock *sk)
+static void psock_data_ready(struct sock *sk)
 {
 	struct kcm_psock *psock;
 
@@ -348,7 +347,7 @@ static void psock_tcp_data_ready(struct sock *sk)
 
 	psock = (struct kcm_psock *)sk->sk_user_data;
 	if (likely(psock))
-		strp_tcp_data_ready(&psock->strp);
+		strp_data_ready(&psock->strp);
 
 	read_unlock_bh(&sk->sk_callback_lock);
 }
@@ -392,7 +391,7 @@ static int kcm_read_sock_done(struct strparser *strp, int err)
 	return err;
 }
 
-static void psock_tcp_state_change(struct sock *sk)
+static void psock_state_change(struct sock *sk)
 {
 	/* TCP only does a POLLIN for a half close. Do a POLLHUP here
 	 * since application will normally not poll with POLLIN
@@ -402,7 +401,7 @@ static void psock_tcp_state_change(struct sock *sk)
 	report_csk_error(sk, EPIPE);
 }
 
-static void psock_tcp_write_space(struct sock *sk)
+static void psock_write_space(struct sock *sk)
 {
 	struct kcm_psock *psock;
 	struct kcm_mux *mux;
@@ -1383,19 +1382,12 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	struct list_head *head;
 	int index = 0;
 	struct strp_callbacks cb;
-
-	if (csock->ops->family != PF_INET &&
-	    csock->ops->family != PF_INET6)
-		return -EINVAL;
+	int err;
 
 	csk = csock->sk;
 	if (!csk)
 		return -EINVAL;
 
-	/* Only support TCP for now */
-	if (csk->sk_protocol != IPPROTO_TCP)
-		return -EINVAL;
-
 	psock = kmem_cache_zalloc(kcm_psockp, GFP_KERNEL);
 	if (!psock)
 		return -ENOMEM;
@@ -1409,7 +1401,11 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	cb.parse_msg = kcm_parse_func_strparser;
 	cb.read_sock_done = kcm_read_sock_done;
 
-	strp_init(&psock->strp, csk, &cb);
+	err = strp_init(&psock->strp, csk, &cb);
+	if (err) {
+		kmem_cache_free(kcm_psockp, psock);
+		return err;
+	}
 
 	sock_hold(csk);
 
@@ -1418,9 +1414,9 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	psock->save_write_space = csk->sk_write_space;
 	psock->save_state_change = csk->sk_state_change;
 	csk->sk_user_data = psock;
-	csk->sk_data_ready = psock_tcp_data_ready;
-	csk->sk_write_space = psock_tcp_write_space;
-	csk->sk_state_change = psock_tcp_state_change;
+	csk->sk_data_ready = psock_data_ready;
+	csk->sk_write_space = psock_write_space;
+	csk->sk_state_change = psock_state_change;
 	write_unlock_bh(&csk->sk_callback_lock);
 
 	/* Finished initialization, now add the psock to the MUX. */
diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
index 4ecfc10..5c7549b 100644
--- a/net/strparser/strparser.c
+++ b/net/strparser/strparser.c
@@ -26,7 +26,6 @@
 #include <net/strparser.h>
 #include <net/netns/generic.h>
 #include <net/sock.h>
-#include <net/tcp.h>
 
 static struct workqueue_struct *strp_wq;
 
@@ -80,9 +79,16 @@ static void strp_parser_err(struct strparser *strp, int err,
 	strp->cb.abort_parser(strp, err);
 }
 
+static inline int strp_peek_len(struct strparser *strp)
+{
+	struct socket *sock = strp->sk->sk_socket;
+
+	return sock->ops->peek_len(sock);
+}
+
 /* Lower socket lock held */
-static int strp_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
-			 unsigned int orig_offset, size_t orig_len)
+static int strp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
+		     unsigned int orig_offset, size_t orig_len)
 {
 	struct strparser *strp = (struct strparser *)desc->arg.data;
 	struct _strp_rx_msg *rxm;
@@ -266,12 +272,12 @@ static int strp_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		if (extra < 0) {
 			/* Message not complete yet. */
 			if (rxm->strp.full_len - rxm->accum_len >
-			    tcp_inq(strp->sk)) {
+			    strp_peek_len(strp)) {
 				/* Don't have the whole messages in the socket
 				 * buffer. Set strp->rx_need_bytes to wait for
 				 * the rest of the message. Also, set "early
 				 * eaten" since we've already buffered the skb
-				 * but don't consume yet per tcp_read_sock.
+				 * but don't consume yet per strp_read_sock.
 				 */
 
 				if (!rxm->accum_len) {
@@ -329,16 +335,17 @@ static int default_read_sock_done(struct strparser *strp, int err)
 }
 
 /* Called with lock held on lower socket */
-static int strp_tcp_read_sock(struct strparser *strp)
+static int strp_read_sock(struct strparser *strp)
 {
+	struct socket *sock = strp->sk->sk_socket;
 	read_descriptor_t desc;
 
 	desc.arg.data = strp;
 	desc.error = 0;
 	desc.count = 1; /* give more than one skb per call */
 
-	/* sk should be locked here, so okay to do tcp_read_sock */
-	tcp_read_sock(strp->sk, &desc, strp_tcp_recv);
+	/* sk should be locked here, so okay to do read_sock */
+	sock->ops->read_sock(strp->sk, &desc, strp_recv);
 
 	desc.error = strp->cb.read_sock_done(strp, desc.error);
 
@@ -346,10 +353,8 @@ static int strp_tcp_read_sock(struct strparser *strp)
 }
 
 /* Lower sock lock held */
-void strp_tcp_data_ready(struct strparser *strp)
+void strp_data_ready(struct strparser *strp)
 {
-	struct sock *csk = strp->sk;
-
 	if (unlikely(strp->rx_stopped))
 		return;
 
@@ -360,7 +365,7 @@ void strp_tcp_data_ready(struct strparser *strp)
 	 * allows a thread in BH context to safely check if the process
 	 * lock is held. In this case, if the lock is held, queue work.
 	 */
-	if (sock_owned_by_user(csk)) {
+	if (sock_owned_by_user(strp->sk)) {
 		queue_work(strp_wq, &strp->rx_work);
 		return;
 	}
@@ -369,24 +374,24 @@ void strp_tcp_data_ready(struct strparser *strp)
 		return;
 
 	if (strp->rx_need_bytes) {
-		if (tcp_inq(csk) >= strp->rx_need_bytes)
+		if (strp_peek_len(strp) >= strp->rx_need_bytes)
 			strp->rx_need_bytes = 0;
 		else
 			return;
 	}
 
-	if (strp_tcp_read_sock(strp) == -ENOMEM)
+	if (strp_read_sock(strp) == -ENOMEM)
 		queue_work(strp_wq, &strp->rx_work);
 }
-EXPORT_SYMBOL_GPL(strp_tcp_data_ready);
+EXPORT_SYMBOL_GPL(strp_data_ready);
 
 static void do_strp_rx_work(struct strparser *strp)
 {
 	read_descriptor_t rd_desc;
 	struct sock *csk = strp->sk;
 
-	/* We need the read lock to synchronize with strp_tcp_data_ready. We
-	 * need the socket lock for calling tcp_read_sock.
+	/* We need the read lock to synchronize with strp_data_ready. We
+	 * need the socket lock for calling strp_read_sock.
 	 */
 	lock_sock(csk);
 
@@ -398,7 +403,7 @@ static void do_strp_rx_work(struct strparser *strp)
 
 	rd_desc.arg.data = strp;
 
-	if (strp_tcp_read_sock(strp) == -ENOMEM)
+	if (strp_read_sock(strp) == -ENOMEM)
 		queue_work(strp_wq, &strp->rx_work);
 
 out:
@@ -424,9 +429,14 @@ static void strp_rx_msg_timeout(unsigned long arg)
 int strp_init(struct strparser *strp, struct sock *csk,
 	      struct strp_callbacks *cb)
 {
+	struct socket *sock = csk->sk_socket;
+
 	if (!cb || !cb->rcv_msg || !cb->parse_msg)
 		return -EINVAL;
 
+	if (!sock->ops->read_sock || !sock->ops->peek_len)
+		return -EAFNOSUPPORT;
+
 	memset(strp, 0, sizeof(*strp));
 
 	strp->sk = csk;
@@ -456,7 +466,7 @@ void strp_unpause(struct strparser *strp)
 }
 EXPORT_SYMBOL_GPL(strp_unpause);
 
-/* strp must already be stopped so that strp_tcp_recv will no longer be called.
+/* strp must already be stopped so that strp_recv will no longer be called.
  * Note that strp_done is not called with the lower socket held.
  */
 void strp_done(struct strparser *strp)
-- 
2.8.0.rc2
