From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v3 10/15] bpf: Add support for changing congestion control
Date: Mon, 19 Jun 2017 20:00:43 -0700
Message-ID: <20170620030048.3275347-11-brakmo@fb.com>
References: <20170620030048.3275347-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51764 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751706AbdFTDAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 23:00:55 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K2w3rJ024384
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b6nvx8r6q-8
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:55 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 abe3d610556411e7a2b00002c991e86a-2d9fa8f0 for <netdev@vger.kernel.org>;        Mon,
 19 Jun 2017 20:00:52 -0700
In-Reply-To: <20170620030048.3275347-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added support for changing congestion control for SOCK_OPS bpf
programs through the setsockopt bpf helper function. It also adds
a new SOCK_OPS op, BPF_SOCK_OPS_NEEDS_ECN, that is needed for
congestion controls, like dctcp, that need to enable ECN in the
SYN packets.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/net/tcp.h        |  9 ++++++++-
 include/uapi/linux/bpf.h |  3 +++
 net/core/filter.c        | 11 +++++++++--
 net/ipv4/tcp.c           |  2 +-
 net/ipv4/tcp_cong.c      | 32 ++++++++++++++++++++++----------
 net/ipv4/tcp_input.c     |  3 ++-
 net/ipv4/tcp_output.c    |  8 +++++---
 7 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index ff806d7..58d67be 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1003,7 +1003,9 @@ void tcp_get_default_congestion_control(char *name);
 void tcp_get_available_congestion_control(char *buf, size_t len);
 void tcp_get_allowed_congestion_control(char *buf, size_t len);
 int tcp_set_allowed_congestion_control(char *allowed);
-int tcp_set_congestion_control(struct sock *sk, const char *name);
+int tcp_set_congestion_control(struct sock *sk, const char *name, bool load);
+void tcp_reinit_congestion_control(struct sock *sk,
+				   const struct tcp_congestion_ops *ca);
 u32 tcp_slow_start(struct tcp_sock *tp, u32 acked);
 void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked);
 
@@ -2072,4 +2074,9 @@ static inline u32 tcp_rwnd_init_bpf(struct sock *sk, bool is_req_sock)
 		rwnd = 0;
 	return rwnd;
 }
+
+static inline bool tcp_bpf_ca_needs_ecn(struct sock *sk)
+{
+	return (tcp_call_bpf(sk, true, BPF_SOCK_OPS_NEEDS_ECN) == 1);
+}
 #endif	/* _TCP_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 4856d16..c222059 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -776,6 +776,9 @@ enum {
 						 * passive connection is
 						 * established
 						 */
+	BPF_SOCK_OPS_NEEDS_ECN,		/* If connection's congestion control
+					 * needs ECN
+					 */
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index b114ae1..bbf8f78 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2716,8 +2716,15 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 		}
 	} else if (level == SOL_TCP &&
 		   sk->sk_prot->setsockopt == tcp_setsockopt) {
-		/* Place holder */
-		ret = -EINVAL;
+		if (optname == TCP_CONGESTION) {
+			ret = tcp_set_congestion_control(sk, optval, false);
+			if (!ret && bpf_sock->op > BPF_SOCK_OPS_NEEDS_ECN)
+				/* replacing an existing ca */
+				tcp_reinit_congestion_control(sk,
+					inet_csk(sk)->icsk_ca_ops);
+		} else {
+			ret = -EINVAL;
+		}
 	} else {
 		ret = -EINVAL;
 	}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 058f509..9476fd6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2479,7 +2479,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		name[val] = 0;
 
 		lock_sock(sk);
-		err = tcp_set_congestion_control(sk, name);
+		err = tcp_set_congestion_control(sk, name, true);
 		release_sock(sk);
 		return err;
 	}
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 324c9bc..fde983f 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -189,8 +189,8 @@ void tcp_init_congestion_control(struct sock *sk)
 		INET_ECN_dontxmit(sk);
 }
 
-static void tcp_reinit_congestion_control(struct sock *sk,
-					  const struct tcp_congestion_ops *ca)
+void tcp_reinit_congestion_control(struct sock *sk,
+				   const struct tcp_congestion_ops *ca)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
@@ -333,8 +333,12 @@ int tcp_set_allowed_congestion_control(char *val)
 	return ret;
 }
 
-/* Change congestion control for socket */
-int tcp_set_congestion_control(struct sock *sk, const char *name)
+/* Change congestion control for socket. If load is false, then it is the
+ * responsibility of the caller to call tcp_init_congestion_control or
+ * tcp_reinit_congestion_control (if the current congestion control was
+ * already initialized.
+ */
+int tcp_set_congestion_control(struct sock *sk, const char *name, bool load)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_congestion_ops *ca;
@@ -344,21 +348,29 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
 		return -EPERM;
 
 	rcu_read_lock();
-	ca = __tcp_ca_find_autoload(name);
+	if (!load)
+		ca = tcp_ca_find(name);
+	else
+		ca = __tcp_ca_find_autoload(name);
 	/* No change asking for existing value */
 	if (ca == icsk->icsk_ca_ops) {
 		icsk->icsk_ca_setsockopt = 1;
 		goto out;
 	}
-	if (!ca)
+	if (!ca) {
 		err = -ENOENT;
-	else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) ||
-		   ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)))
+	} else if (!load) {
+		icsk->icsk_ca_ops = ca;
+		if (!try_module_get(ca->owner))
+			err = -EBUSY;
+	} else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) ||
+		     ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))) {
 		err = -EPERM;
-	else if (!try_module_get(ca->owner))
+	} else if (!try_module_get(ca->owner)) {
 		err = -EBUSY;
-	else
+	} else {
 		tcp_reinit_congestion_control(sk, ca);
+	}
  out:
 	rcu_read_unlock();
 	return err;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1b868ae..23f9707 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6192,7 +6192,8 @@ static void tcp_ecn_create_request(struct request_sock *req,
 	ecn_ok = net->ipv4.sysctl_tcp_ecn || ecn_ok_dst;
 
 	if ((!ect && ecn_ok) || tcp_ca_needs_ecn(listen_sk) ||
-	    (ecn_ok_dst & DST_FEATURE_ECN_CA))
+	    (ecn_ok_dst & DST_FEATURE_ECN_CA) ||
+	    tcp_bpf_ca_needs_ecn((struct sock *)req))
 		inet_rsk(req)->ecn_ok = 1;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 958edc8..a273117 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -316,7 +316,8 @@ static void tcp_ecn_send_synack(struct sock *sk, struct sk_buff *skb)
 	TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_CWR;
 	if (!(tp->ecn_flags & TCP_ECN_OK))
 		TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_ECE;
-	else if (tcp_ca_needs_ecn(sk))
+	else if (tcp_ca_needs_ecn(sk) ||
+		 tcp_bpf_ca_needs_ecn(sk))
 		INET_ECN_xmit(sk);
 }
 
@@ -324,8 +325,9 @@ static void tcp_ecn_send_synack(struct sock *sk, struct sk_buff *skb)
 static void tcp_ecn_send_syn(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	bool bpf_needs_ecn = tcp_bpf_ca_needs_ecn(sk);
 	bool use_ecn = sock_net(sk)->ipv4.sysctl_tcp_ecn == 1 ||
-		       tcp_ca_needs_ecn(sk);
+		tcp_ca_needs_ecn(sk) || bpf_needs_ecn;
 
 	if (!use_ecn) {
 		const struct dst_entry *dst = __sk_dst_get(sk);
@@ -339,7 +341,7 @@ static void tcp_ecn_send_syn(struct sock *sk, struct sk_buff *skb)
 	if (use_ecn) {
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
-		if (tcp_ca_needs_ecn(sk))
+		if (tcp_ca_needs_ecn(sk) || bpf_needs_ecn)
 			INET_ECN_xmit(sk);
 	}
 }
-- 
2.9.3
