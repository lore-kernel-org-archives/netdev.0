From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v5 05/16] bpf: Support for setting initial receive window
Date: Fri, 30 Jun 2017 13:06:55 -0700
Message-ID: <20170630200706.4183158-6-brakmo@fb.com>
References: <20170630200706.4183158-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59277 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752689AbdF3UHN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 16:07:13 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UK4HjC031996
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bdvs10572-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:13 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 b3830c6a5dcf11e7976609cabd64a484-9e53b8f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 13:07:11 -0700
In-Reply-To: <20170630200706.4183158-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds suppport for setting the initial advertized window from
within a BPF_SOCK_OPS program. This can be used to support larger
initial cwnd values in environments where it is known to be safe.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/net/tcp.h        | 10 ++++++++++
 include/uapi/linux/bpf.h |  4 ++++
 net/ipv4/tcp_minisocks.c |  9 ++++++++-
 net/ipv4/tcp_output.c    |  7 ++++++-
 4 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 564af2d..d6bb394 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -2068,4 +2068,14 @@ static inline u32 tcp_timeout_init(struct sock *sk)
 	return timeout;
 }
 
+static inline u32 tcp_rwnd_init_bpf(struct sock *sk)
+{
+	int rwnd;
+
+	rwnd = tcp_call_bpf(sk, BPF_SOCK_OPS_RWND_INIT);
+
+	if (rwnd < 0)
+		rwnd = 0;
+	return rwnd;
+}
 #endif	/* _TCP_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 00702b2..94d7ded 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -751,6 +751,10 @@ enum {
 	BPF_SOCK_OPS_TIMEOUT_INIT,	/* Should return SYN-RTO value to use or
 					 * -1 if default value should be used
 					 */
+	BPF_SOCK_OPS_RWND_INIT,		/* Should return initial advertized
+					 * window (in packets) or -1 if default
+					 * value should be used
+					 */
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index d30ee31..0ff83c1 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -351,6 +351,7 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 	int full_space = tcp_full_space(sk_listener);
 	u32 window_clamp;
 	__u8 rcv_wscale;
+	u32 rcv_wnd;
 	int mss;
 
 	mss = tcp_mss_clamp(tp, dst_metric_advmss(dst));
@@ -363,6 +364,12 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 	    (req->rsk_window_clamp > full_space || req->rsk_window_clamp == 0))
 		req->rsk_window_clamp = full_space;
 
+	rcv_wnd = tcp_rwnd_init_bpf((struct sock *)req);
+	if (rcv_wnd == 0)
+		rcv_wnd = dst_metric(dst, RTAX_INITRWND);
+	else if (full_space < rcv_wnd * mss)
+		full_space = rcv_wnd * mss;
+
 	/* tcp_full_space because it is guaranteed to be the first packet */
 	tcp_select_initial_window(full_space,
 		mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
@@ -370,7 +377,7 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 		&req->rsk_window_clamp,
 		ireq->wscale_ok,
 		&rcv_wscale,
-		dst_metric(dst, RTAX_INITRWND));
+		rcv_wnd);
 	ireq->rcv_wscale = rcv_wscale;
 }
 EXPORT_SYMBOL(tcp_openreq_init_rwin);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d60ae44..5345d61 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3267,6 +3267,7 @@ static void tcp_connect_init(struct sock *sk)
 	const struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u8 rcv_wscale;
+	u32 rcv_wnd;
 
 	/* We'll fix this up when we get a response from the other end.
 	 * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
@@ -3300,13 +3301,17 @@ static void tcp_connect_init(struct sock *sk)
 	    (tp->window_clamp > tcp_full_space(sk) || tp->window_clamp == 0))
 		tp->window_clamp = tcp_full_space(sk);
 
+	rcv_wnd = tcp_rwnd_init_bpf(sk);
+	if (rcv_wnd == 0)
+		rcv_wnd = dst_metric(dst, RTAX_INITRWND);
+
 	tcp_select_initial_window(tcp_full_space(sk),
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
 				  sock_net(sk)->ipv4.sysctl_tcp_window_scaling,
 				  &rcv_wscale,
-				  dst_metric(dst, RTAX_INITRWND));
+				  rcv_wnd);
 
 	tp->rx_opt.rcv_wscale = rcv_wscale;
 	tp->rcv_ssthresh = tp->rcv_wnd;
-- 
2.9.3
