From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 7/13] inet_diag: Introduce the inet socket dumping routine
Date: Fri, 09 Dec 2011 20:23:00 +0400
Message-ID: <4EE235E4.1090809@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39997 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199Ab1LIQXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:23:06 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing inet_csk_diag_fill dumps the inet connection sock info
into the netlink inet_diag_message. Prepare this routine to be able
to dump only the inet_sock part of a socket if the icsk part is missing.

This will be used by UDP diag module when dumping UDP sockets.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    7 ++++++
 net/ipv4/inet_diag.c      |   53 ++++++++++++++++++++++++++++----------------
 2 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 907c899..eaf5865 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -136,6 +136,8 @@ struct tcpvegas_info {
 struct sock;
 struct inet_hashinfo;
 struct nlattr;
+struct nlmsghdr;
+struct sk_buff;
 
 struct inet_diag_handler {
 	struct inet_hashinfo    *idiag_hashinfo;
@@ -145,6 +147,11 @@ struct inet_diag_handler {
 	__u16                   idiag_type;
 };
 
+struct inet_connection_sock;
+int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
+			      struct sk_buff *skb, struct inet_diag_req *req,
+			      u32 pid, u32 seq, u16 nlmsg_flags,
+			      const struct nlmsghdr *unlh);
 int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
 int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req);
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 08e5498..dc8611e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -70,13 +70,12 @@ static inline void inet_diag_unlock_handler(
 	mutex_unlock(&inet_diag_table_mutex);
 }
 
-static int inet_csk_diag_fill(struct sock *sk,
+int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			      struct sk_buff *skb, struct inet_diag_req *req,
 			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_diag_msg *r;
 	struct nlmsghdr  *nlh;
 	void *info = NULL;
@@ -97,16 +96,6 @@ static int inet_csk_diag_fill(struct sock *sk,
 	if (ext & (1 << (INET_DIAG_MEMINFO - 1)))
 		minfo = INET_DIAG_PUT(skb, INET_DIAG_MEMINFO, sizeof(*minfo));
 
-	if (ext & (1 << (INET_DIAG_INFO - 1)))
-		info = INET_DIAG_PUT(skb, INET_DIAG_INFO, sizeof(struct tcp_info));
-
-	if ((ext & (1 << (INET_DIAG_CONG - 1))) && icsk->icsk_ca_ops) {
-		const size_t len = strlen(icsk->icsk_ca_ops->name);
-
-		strcpy(INET_DIAG_PUT(skb, INET_DIAG_CONG, len + 1),
-		       icsk->icsk_ca_ops->name);
-	}
-
 	r->idiag_family = sk->sk_family;
 	r->idiag_state = sk->sk_state;
 	r->idiag_timer = 0;
@@ -138,6 +127,21 @@ static int inet_csk_diag_fill(struct sock *sk,
 	}
 #endif
 
+	r->idiag_uid = sock_i_uid(sk);
+	r->idiag_inode = sock_i_ino(sk);
+
+	if (minfo) {
+		minfo->idiag_rmem = sk_rmem_alloc_get(sk);
+		minfo->idiag_wmem = sk->sk_wmem_queued;
+		minfo->idiag_fmem = sk->sk_forward_alloc;
+		minfo->idiag_tmem = sk_wmem_alloc_get(sk);
+	}
+
+	if (icsk == NULL) {
+		r->idiag_rqueue = r->idiag_wqueue = 0;
+		goto out;
+	}
+
 #define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
@@ -158,14 +162,14 @@ static int inet_csk_diag_fill(struct sock *sk,
 	}
 #undef EXPIRES_IN_MS
 
-	r->idiag_uid = sock_i_uid(sk);
-	r->idiag_inode = sock_i_ino(sk);
+	if (ext & (1 << (INET_DIAG_INFO - 1)))
+		info = INET_DIAG_PUT(skb, INET_DIAG_INFO, sizeof(struct tcp_info));
 
-	if (minfo) {
-		minfo->idiag_rmem = sk_rmem_alloc_get(sk);
-		minfo->idiag_wmem = sk->sk_wmem_queued;
-		minfo->idiag_fmem = sk->sk_forward_alloc;
-		minfo->idiag_tmem = sk_wmem_alloc_get(sk);
+	if ((ext & (1 << (INET_DIAG_CONG - 1))) && icsk->icsk_ca_ops) {
+		const size_t len = strlen(icsk->icsk_ca_ops->name);
+
+		strcpy(INET_DIAG_PUT(skb, INET_DIAG_CONG, len + 1),
+		       icsk->icsk_ca_ops->name);
 	}
 
 	handler->idiag_get_info(sk, r, info);
@@ -174,6 +178,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 	    icsk->icsk_ca_ops && icsk->icsk_ca_ops->get_info)
 		icsk->icsk_ca_ops->get_info(sk, ext, skb);
 
+out:
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
@@ -182,6 +187,16 @@ nlmsg_failure:
 	nlmsg_trim(skb, b);
 	return -EMSGSIZE;
 }
+EXPORT_SYMBOL_GPL(inet_sk_diag_fill);
+
+static int inet_csk_diag_fill(struct sock *sk,
+			      struct sk_buff *skb, struct inet_diag_req *req,
+			      u32 pid, u32 seq, u16 nlmsg_flags,
+			      const struct nlmsghdr *unlh)
+{
+	return inet_sk_diag_fill(sk, inet_csk(sk),
+			skb, req, pid, seq, nlmsg_flags, unlh);
+}
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 			       struct sk_buff *skb, struct inet_diag_req *req,
-- 
1.5.5.6
