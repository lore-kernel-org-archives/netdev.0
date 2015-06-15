From: Craig Gallek <kraig@google.com>
Subject: [PATCH net-next 3/3] sock_diag: implement a get_info handler for inet
Date: Mon, 15 Jun 2015 11:26:20 -0400
Message-ID: <1434381980-20588-4-git-send-email-kraig@google.com>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
Cc: edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org,
	Craig Gallek <kraig@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:33941 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbbFOP1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 11:27:22 -0400
Received: by yhid80 with SMTP id d80so45139981yhi.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 08:27:22 -0700 (PDT)
In-Reply-To: <1434381980-20588-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This get_info handler will simply dispatch to the appropriate
existing inet protocol handler.

This patch also includes a new netlink attribute
(INET_DIAG_PROTOCOL).  This attribute is currently only used
for multicast messages.  Without this attribute, there is no
way of knowing the IP protocol used by the socket information
being broadcast.  This attribute is not necessary in the 'dump'
variant of this protocol (though it could easily be added)
because dump requests are issued for specific family/protocol
pairs.

Tested: ss -E (note, the -E option has not yet been merged into
the upstream version of ss).

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/uapi/linux/inet_diag.h |  3 ++-
 net/ipv4/inet_diag.c           | 46 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c                 |  4 +++-
 net/ipv4/tcp_diag.c            |  5 +++--
 4 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index c7093c7..b629fc5 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -111,9 +111,10 @@ enum {
 	INET_DIAG_SKMEMINFO,
 	INET_DIAG_SHUTDOWN,
 	INET_DIAG_DCTCPINFO,
+	INET_DIAG_PROTOCOL,  /* response attribute only */
 };
 
-#define INET_DIAG_MAX INET_DIAG_DCTCPINFO
+#define INET_DIAG_MAX INET_DIAG_PROTOCOL
 
 /* INET_DIAG_MEM */
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index b1f01174..21985d8 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -1078,14 +1078,60 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 	return inet_diag_get_exact(skb, h, nlmsg_data(h));
 }
 
+static
+int inet_diag_handler_get_info(struct sk_buff *skb, struct sock *sk)
+{
+	const struct inet_diag_handler *handler;
+	struct nlmsghdr *nlh;
+	struct nlattr *attr;
+	struct inet_diag_msg *r;
+	void *info = NULL;
+	int err = 0;
+
+	nlh = nlmsg_put(skb, 0, 0, SOCK_DIAG_BY_FAMILY, sizeof(*r), 0);
+	if (!nlh)
+		return -ENOMEM;
+
+	r = nlmsg_data(nlh);
+	memset(r, 0, sizeof(*r));
+	inet_diag_msg_common_fill(r, sk);
+	r->idiag_state = sk->sk_state;
+
+	if ((err = nla_put_u8(skb, INET_DIAG_PROTOCOL, sk->sk_protocol))) {
+		nlmsg_cancel(skb, nlh);
+		return err;
+	}
+
+	handler = inet_diag_lock_handler(sk->sk_protocol);
+	if (IS_ERR(handler)) {
+		inet_diag_unlock_handler(handler);
+		nlmsg_cancel(skb, nlh);
+		return PTR_ERR(handler);
+	}
+
+	attr = handler->idiag_info_size
+		? nla_reserve(skb, INET_DIAG_INFO, handler->idiag_info_size)
+		: NULL;
+	if (attr)
+		info = nla_data(attr);
+
+	handler->idiag_get_info(sk, r, info);
+	inet_diag_unlock_handler(handler);
+
+	nlmsg_end(skb, nlh);
+	return 0;
+}
+
 static const struct sock_diag_handler inet_diag_handler = {
 	.family = AF_INET,
 	.dump = inet_diag_handler_dump,
+	.get_info = inet_diag_handler_get_info,
 };
 
 static const struct sock_diag_handler inet6_diag_handler = {
 	.family = AF_INET6,
 	.dump = inet_diag_handler_dump,
+	.get_info = inet_diag_handler_get_info,
 };
 
 int inet_diag_register(const struct inet_diag_handler *h)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 65f791f..697b86d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2624,13 +2624,15 @@ EXPORT_SYMBOL(compat_tcp_setsockopt);
 /* Return information about state of tcp endpoint in API format. */
 void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
-	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk); /* iff sk_type == SOCK_STREAM */
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 now = tcp_time_stamp;
 	unsigned int start;
 	u32 rate;
 
 	memset(info, 0, sizeof(*info));
+	if (sk->sk_type != SOCK_STREAM)
+		return;
 
 	info->tcpi_state = sk->sk_state;
 	info->tcpi_ca_state = icsk->icsk_ca_state;
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 423e388..479f349 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -19,13 +19,14 @@
 static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 			      void *_info)
 {
-	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_info *info = _info;
 
 	if (sk->sk_state == TCP_LISTEN) {
 		r->idiag_rqueue = sk->sk_ack_backlog;
 		r->idiag_wqueue = sk->sk_max_ack_backlog;
-	} else {
+	} else if (sk->sk_type == SOCK_STREAM) {
+		const struct tcp_sock *tp = tcp_sk(sk);
+
 		r->idiag_rqueue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 		r->idiag_wqueue = tp->write_seq - tp->snd_una;
 	}
-- 
2.2.0.rc0.207.ga3a616c
