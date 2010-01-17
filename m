From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: account SYN-ACK timeouts & retransmissions
Date: Sun, 17 Jan 2010 21:27:03 +0200
Message-ID: <201001172127.03713.opurdila@ixiacom.com>
References: <20100111.161537.85213244.davem@davemloft.net> <201001132307.59472.opurdila@ixiacom.com> <20100114.020322.168786392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpyatkovskiy@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:7136 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754509Ab0AQTa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 14:30:29 -0500
In-Reply-To: <20100114.020322.168786392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 14 January 2010 12:03:22 you wrote:
> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Wed, 13 Jan 2010 23:07:59 +0200
> 
> > I think we lost the SynAck accounting with this commit from the
> > netdev-vger- cvs tree, where tcp_syn_recv_timer was introduced:
> >
> > commit 2248761e5cfcb8687563b29c77064185e7604947
> > Author: davem <davem>
> > Date:   Sun Nov 10 21:25:00 1996 +0000
> >
> >     Merge to 2.1.8, IPV6 is here.  Also fix
> >     a stupid bug in the kernel unaligned trap handler
> >     where st %g0, [foo] would fail miserably.
> >
> >
> > Before this, both Syns and SynAcks seems to be accounted for.
> 
> I'm convinced.
> 
> Please spin your patch with the "doing TCP socket specific
> stuff in generic inet connection socket code" part fixed.
> 

Hi David,

Here it is. I've based this against net-next since it is more intrusive then the original one. I can rebase it against net-2.6 if you think it can make it there.

Also, please let me know if you think I should split it up (maybe is worth having syn_ack_timeout in a separate patch, but to me it looks too small).

[net-next PATCH v2] tcp: account SYN-ACK timeouts & retransmissions

Currently we don't increment SYN-ACK timeouts & retransmissions
although we do increment the same stats for SYN. We seem to have lost
the SYN-ACK accounting with the introduction of tcp_syn_recv_timer
(commit 2248761e in the netdev-vger-cvs tree).

This patch fixes this issue. In the process we also rename the v4/v6
syn/ack retransmit functions for clarity. We also add a new
request_socket operations (syn_ack_timeout) so we can keep code in
inet_connection_sock.c protocol agnostic.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/request_sock.h      |    2 ++
 include/net/tcp.h               |    2 ++
 net/ipv4/inet_connection_sock.c |    2 ++
 net/ipv4/tcp_ipv4.c             |   18 ++++++++++--------
 net/ipv4/tcp_timer.c            |    6 ++++++
 net/ipv6/tcp_ipv6.c             |   12 ++++++++++--
 6 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index c9b50eb..99e6e19 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -45,6 +45,8 @@ struct request_sock_ops {
 	void		(*send_reset)(struct sock *sk,
 				      struct sk_buff *skb);
 	void		(*destructor)(struct request_sock *req);
+	void		(*syn_ack_timeout)(struct sock *sk,
+					   struct request_sock *req);
 };
 
 /* struct request_sock - mini sock to represent a connection request
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 788c99f..87d164b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -400,6 +400,8 @@ extern int			compat_tcp_setsockopt(struct sock *sk,
 					int level, int optname,
 					char __user *optval, unsigned int optlen);
 extern void			tcp_set_keepalive(struct sock *sk, int val);
+extern void			tcp_syn_ack_timeout(struct sock *sk,
+						    struct request_sock *req);
 extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 					    struct msghdr *msg,
 					    size_t len, int nonblock, 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ee16475..8da6429 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -529,6 +529,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 				syn_ack_recalc(req, thresh, max_retries,
 					       queue->rskq_defer_accept,
 					       &expire, &resend);
+				if (req->rsk_ops->syn_ack_timeout)
+					req->rsk_ops->syn_ack_timeout(parent, req);
 				if (!expire &&
 				    (!resend ||
 				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 382f667..356f544 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -742,9 +742,9 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  *	This still operates on a request_sock only, not on a big
  *	socket.
  */
-static int __tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
-				struct request_sock *req,
-				struct request_values *rvp)
+static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
+			      struct request_sock *req,
+			      struct request_values *rvp)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	int err = -1;
@@ -775,10 +775,11 @@ static int __tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	return err;
 }
 
-static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
+static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req,
 			      struct request_values *rvp)
 {
-	return __tcp_v4_send_synack(sk, NULL, req, rvp);
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
+	return tcp_v4_send_synack(sk, NULL, req, rvp);
 }
 
 /*
@@ -1192,10 +1193,11 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 	.family		=	PF_INET,
 	.obj_size	=	sizeof(struct tcp_request_sock),
-	.rtx_syn_ack	=	tcp_v4_send_synack,
+	.rtx_syn_ack	=	tcp_v4_rtx_synack,
 	.send_ack	=	tcp_v4_reqsk_send_ack,
 	.destructor	=	tcp_v4_reqsk_destructor,
 	.send_reset	=	tcp_v4_send_reset,
+	.syn_ack_timeout = 	tcp_syn_ack_timeout,
 };
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -1373,8 +1375,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-	if (__tcp_v4_send_synack(sk, dst, req,
-				 (struct request_values *)&tmp_ext) ||
+	if (tcp_v4_send_synack(sk, dst, req,
+			       (struct request_values *)&tmp_ext) ||
 	    want_cookie)
 		goto drop_and_free;
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 8816a20..de7d1bf 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -474,6 +474,12 @@ static void tcp_synack_timer(struct sock *sk)
 				   TCP_TIMEOUT_INIT, TCP_RTO_MAX);
 }
 
+void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req)
+{
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPTIMEOUTS);
+}
+EXPORT_SYMBOL(tcp_syn_ack_timeout);
+
 void tcp_set_keepalive(struct sock *sk, int val)
 {
 	if ((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1c832bf..82f2dea 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -520,6 +520,13 @@ done:
 	return err;
 }
 
+static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req,
+			     struct request_values *rvp)
+{
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
+	return tcp_v6_send_synack(sk, req, rvp);
+}
+
 static inline void syn_flood_warning(struct sk_buff *skb)
 {
 #ifdef CONFIG_SYN_COOKIES
@@ -890,10 +897,11 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 	.family		=	AF_INET6,
 	.obj_size	=	sizeof(struct tcp6_request_sock),
-	.rtx_syn_ack	=	tcp_v6_send_synack,
+	.rtx_syn_ack	=	tcp_v6_rtx_synack,
 	.send_ack	=	tcp_v6_reqsk_send_ack,
 	.destructor	=	tcp_v6_reqsk_destructor,
-	.send_reset	=	tcp_v6_send_reset
+	.send_reset	=	tcp_v6_send_reset,
+	.syn_ack_timeout = 	tcp_syn_ack_timeout,
 };
 
 #ifdef CONFIG_TCP_MD5SIG
-- 
1.5.6.5

