From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next 05/15] bpf: Support for setting initial receive window
Date: Tue, 13 Jun 2017 10:59:54 -0700
Message-ID: <20170613180004.3008403-6-brakmo@fb.com>
References: <20170613180004.3008403-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32996 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753103AbdFMSAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:00:10 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DHxX9X007864
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b2m6109tw-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:09 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 231bb50c506211e782e50002c99293a0-8cd358f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 11:00:08 -0700
In-Reply-To: <20170613180004.3008403-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds suppport for setting the initial advertized window from
within a BPF_SOCKET_OPS program. This can be used to support larger
initial cwnd values in environments where it is known to be safe.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/net/tcp.h        | 10 ++++++++++
 include/uapi/linux/bpf.h |  4 ++++
 net/ipv4/tcp_minisocks.c |  9 ++++++++-
 net/ipv4/tcp_output.c    |  7 ++++++-
 4 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8353563..dc20e86 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -2030,4 +2030,14 @@ static inline u32 tcp_timeout_init(struct sock *sk, bool is_req_sock)
 	return timeout;
 }
 
+static inline u32 tcp_rwnd_init_bpf(struct sock *sk, bool is_req_sock)
+{
+	int rwnd;
+
+	rwnd = tcp_call_bpf(sk, is_req_sock, BPF_SOCKET_OPS_RWND_INIT);
+
+	if (rwnd < 0)
+		rwnd = 0;
+	return rwnd;
+}
 #endif	/* _TCP_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index c9da55d..b2af839 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -702,6 +702,10 @@ enum {
 	BPF_SOCKET_OPS_TIMEOUT_INIT,	/* Should return SYN-RTO value to use or
 					 * -1 if default value should be used
 					 */
+	BPF_SOCKET_OPS_RWND_INIT,	/* Should return initial advertized
+					 * window (in packets) or -1 if default
+					 * value should be used
+					 */
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index d0642df..a0032ea 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -352,6 +352,7 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 	u32 window_clamp;
 	__u8 rcv_wscale;
 	int mss;
+	u32 rcv_wnd;
 
 	mss = tcp_mss_clamp(tp, dst_metric_advmss(dst));
 	window_clamp = READ_ONCE(tp->window_clamp);
@@ -363,6 +364,12 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 	    (req->rsk_window_clamp > full_space || req->rsk_window_clamp == 0))
 		req->rsk_window_clamp = full_space;
 
+	rcv_wnd = tcp_rwnd_init_bpf((struct sock *)req, true);
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
index 503e478..972a985 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3267,6 +3267,7 @@ static void tcp_connect_init(struct sock *sk)
 	const struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u8 rcv_wscale;
+	u32 rcv_wnd;
 
 	/* We'll fix this up when we get a response from the other end.
 	 * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
@@ -3299,13 +3300,17 @@ static void tcp_connect_init(struct sock *sk)
 	    (tp->window_clamp > tcp_full_space(sk) || tp->window_clamp == 0))
 		tp->window_clamp = tcp_full_space(sk);
 
+	rcv_wnd = tcp_rwnd_init_bpf(sk, false);
+	if (rcv_wnd == 0)
+		rcv_wnd = dst_metric(dst, RTAX_INITRWND);
+
 	tcp_select_initial_window(tcp_full_space(sk),
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
 				  sysctl_tcp_window_scaling,
 				  &rcv_wscale,
-				  dst_metric(dst, RTAX_INITRWND));
+				  rcv_wnd);
 
 	tp->rx_opt.rcv_wscale = rcv_wscale;
 	tp->rcv_ssthresh = tp->rcv_wnd;
-- 
2.9.3
