From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v6 10/16] bpf: Add support for changing congestion control
Date: Fri, 30 Jun 2017 20:02:49 -0700
Message-ID: <20170701030255.1931076-11-brakmo@fb.com>
References: <20170701030255.1931076-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34353 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752172AbdGADDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 23:03:03 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v6131veX002643
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 20:03:02 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2bdyqkgrc2-7
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 20:03:02 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 ca334c245e0911e787371f53bdcd5fbc-7bb3f8f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 20:03:00 -0700
In-Reply-To: <20170701030255.1931076-1-brakmo@fb.com>
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
 net/core/filter.c        | 18 +++++++++++++++++-
 net/ipv4/tcp.c           |  2 +-
 net/ipv4/tcp_cong.c      | 32 ++++++++++++++++++++++----------
 net/ipv4/tcp_input.c     |  3 ++-
 net/ipv4/tcp_output.c    |  8 +++++---
 7 files changed, 58 insertions(+), 17 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d6bb394..7048329 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1004,7 +1004,9 @@ void tcp_get_default_congestion_control(char *name);
 void tcp_get_available_congestion_control(char *buf, size_t len);
 void tcp_get_allowed_congestion_control(char *buf, size_t len);
 int tcp_set_allowed_congestion_control(char *allowed);
-int tcp_set_congestion_control(struct sock *sk, const char *name);
+int tcp_set_congestion_control(struct sock *sk, const char *name, bool load);
+void tcp_reinit_congestion_control(struct sock *sk,
+				   const struct tcp_congestion_ops *ca);
 u32 tcp_slow_start(struct tcp_sock *tp, u32 acked);
 void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked);
 
@@ -2078,4 +2080,9 @@ static inline u32 tcp_rwnd_init_bpf(struct sock *sk)
 		rwnd = 0;
 	return rwnd;
 }
+
+static inline bool tcp_bpf_ca_needs_ecn(struct sock *sk)
+{
+	return (tcp_call_bpf(sk, BPF_SOCK_OPS_NEEDS_ECN) == 1);
+}
 #endif	/* _TCP_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2405fe3..cc47259 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -778,6 +778,9 @@ enum {
 						 * passive connection is
 						 * established
 						 */
+	BPF_SOCK_OPS_NEEDS_ECN,		/* If connection's congestion control
+					 * needs ECN
+					 */
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index ca033e15..12df527 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2719,8 +2719,24 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 		}
 	} else if (level == SOL_TCP &&
 		   sk->sk_prot->setsockopt == tcp_setsockopt) {
-		/* Place holder */
+#ifdef CONFIG_INET
+		if (optname == TCP_CONGESTION) {
+			char name[TCP_CA_NAME_MAX];
+
+			strncpy(name, optval, min_t(long, optlen,
+						    TCP_CA_NAME_MAX-1));
+			name[TCP_CA_NAME_MAX-1] = 0;
+			ret = tcp_set_congestion_control(sk, name, false);
+			if (!ret && bpf_sock->op > BPF_SOCK_OPS_NEEDS_ECN)
+				/* replacing an existing ca */
+				tcp_reinit_congestion_control(sk,
+					inet_csk(sk)->icsk_ca_ops);
+		} else {
+			ret = -EINVAL;
+		}
+#else
 		ret = -EINVAL;
+#endif
 	} else {
 		ret = -EINVAL;
 	}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4c88d20..5199952 100644
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
index 664210e..2920e0c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6191,7 +6191,8 @@ static void tcp_ecn_create_request(struct request_sock *req,
 	ecn_ok = net->ipv4.sysctl_tcp_ecn || ecn_ok_dst;
 
 	if ((!ect && ecn_ok) || tcp_ca_needs_ecn(listen_sk) ||
-	    (ecn_ok_dst & DST_FEATURE_ECN_CA))
+	    (ecn_ok_dst & DST_FEATURE_ECN_CA) ||
+	    tcp_bpf_ca_needs_ecn((struct sock *)req))
 		inet_rsk(req)->ecn_ok = 1;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 76a1a0e..772a4f6 100644
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
