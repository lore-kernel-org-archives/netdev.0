From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 7/8] ipv4: dccp: handle ICMP messages on DCCP_NEW_SYN_RECV request sockets
Date: Sun, 22 Mar 2015 10:22:24 -0700
Message-ID: <1427044945-32608-8-git-send-email-edumazet@google.com>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:34049 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbbCVRXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:23:25 -0400
Received: by ykq142 with SMTP id 142so6106179ykq.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:23:24 -0700 (PDT)
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dccp_v4_err() can restrict lookups to ehash table, and not to listeners.

Note this patch creates the infrastructure, but this means that ICMP
messages for request sockets are ignored until complete conversion.

New dccp_req_err() helper is exported so that we can use it in IPv6
in following patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/dccp.h |  2 ++
 net/dccp/dccp.h      |  1 +
 net/dccp/ipv4.c      | 70 +++++++++++++++++++++++++---------------------------
 3 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 3dca24d3ac67..221025423e6c 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -43,6 +43,7 @@ enum dccp_state {
 	DCCP_CLOSING	     = TCP_CLOSING,
 	DCCP_TIME_WAIT	     = TCP_TIME_WAIT,
 	DCCP_CLOSED	     = TCP_CLOSE,
+	DCCP_NEW_SYN_RECV    = TCP_NEW_SYN_RECV,
 	DCCP_PARTOPEN	     = TCP_MAX_STATES,
 	DCCP_PASSIVE_CLOSEREQ,			/* clients receiving CloseReq */
 	DCCP_MAX_STATES
@@ -57,6 +58,7 @@ enum {
 	DCCPF_CLOSING	      = TCPF_CLOSING,
 	DCCPF_TIME_WAIT	      = TCPF_TIME_WAIT,
 	DCCPF_CLOSED	      = TCPF_CLOSE,
+	DCCPF_NEW_SYN_RECV    = TCPF_NEW_SYN_RECV,
 	DCCPF_PARTOPEN	      = (1 << DCCP_PARTOPEN),
 };
 
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 2396f50c5b04..bebc735f5afc 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -317,6 +317,7 @@ int inet_dccp_listen(struct socket *sock, int backlog);
 unsigned int dccp_poll(struct file *file, struct socket *sock,
 		       poll_table *wait);
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
+void dccp_req_err(struct sock *sk, u64 seq);
 
 struct sk_buff *dccp_ctl_make_reset(struct sock *sk, struct sk_buff *skb);
 int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 1f7161e05403..6310b8b19598 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -195,6 +195,32 @@ static void dccp_do_redirect(struct sk_buff *skb, struct sock *sk)
 		dst->ops->redirect(dst, sk, skb);
 }
 
+void dccp_req_err(struct sock *sk, u64 seq)
+	{
+	struct request_sock *req = inet_reqsk(sk);
+	struct net *net = sock_net(sk);
+
+	/*
+	 * ICMPs are not backlogged, hence we cannot get an established
+	 * socket here.
+	 */
+	WARN_ON(req->sk);
+
+	if (!between48(seq, dccp_rsk(req)->dreq_iss, dccp_rsk(req)->dreq_gss)) {
+		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
+	} else {
+		/*
+		 * Still in RESPOND, just remove it silently.
+		 * There is no good way to pass the error to the newly
+		 * created socket, and POSIX does not want network
+		 * errors returned from accept().
+		 */
+		inet_csk_reqsk_queue_drop(req->rsk_listener, req);
+	}
+	reqsk_put(req);
+}
+EXPORT_SYMBOL(dccp_req_err);
+
 /*
  * This routine is called by the ICMP module when it gets some sort of error
  * condition. If err < 0 then the socket should be closed and the error
@@ -227,10 +253,11 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		return;
 	}
 
-	sk = inet_lookup(net, &dccp_hashinfo,
-			iph->daddr, dh->dccph_dport,
-			iph->saddr, dh->dccph_sport, inet_iif(skb));
-	if (sk == NULL) {
+	sk = __inet_lookup_established(net, &dccp_hashinfo,
+				       iph->daddr, dh->dccph_dport,
+				       iph->saddr, ntohs(dh->dccph_sport),
+				       inet_iif(skb));
+	if (!sk) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
@@ -239,6 +266,9 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		inet_twsk_put(inet_twsk(sk));
 		return;
 	}
+	seq = dccp_hdr_seq(dh);
+	if (sk->sk_state == DCCP_NEW_SYN_RECV)
+		return dccp_req_err(sk, seq);
 
 	bh_lock_sock(sk);
 	/* If too many ICMPs get dropped on busy
@@ -251,7 +281,6 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		goto out;
 
 	dp = dccp_sk(sk);
-	seq = dccp_hdr_seq(dh);
 	if ((1 << sk->sk_state) & ~(DCCPF_REQUESTING | DCCPF_LISTEN) &&
 	    !between48(seq, dp->dccps_awl, dp->dccps_awh)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
@@ -288,37 +317,6 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	}
 
 	switch (sk->sk_state) {
-		struct request_sock *req;
-	case DCCP_LISTEN:
-		if (sock_owned_by_user(sk))
-			goto out;
-		req = inet_csk_search_req(sk, dh->dccph_dport,
-					  iph->daddr, iph->saddr);
-		if (!req)
-			goto out;
-
-		/*
-		 * ICMPs are not backlogged, hence we cannot get an established
-		 * socket here.
-		 */
-		WARN_ON(req->sk);
-
-		if (!between48(seq, dccp_rsk(req)->dreq_iss,
-				    dccp_rsk(req)->dreq_gss)) {
-			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
-			reqsk_put(req);
-			goto out;
-		}
-		/*
-		 * Still in RESPOND, just remove it silently.
-		 * There is no good way to pass the error to the newly
-		 * created socket, and POSIX does not want network
-		 * errors returned from accept().
-		 */
-		inet_csk_reqsk_queue_drop(sk, req);
-		reqsk_put(req);
-		goto out;
-
 	case DCCP_REQUESTING:
 	case DCCP_RESPOND:
 		if (!sock_owned_by_user(sk)) {
-- 
2.2.0.rc0.207.ga3a616c
