From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v5 08/16] bpf: Add TCP connection BPF callbacks
Date: Fri, 30 Jun 2017 13:06:58 -0700
Message-ID: <20170630200706.4183158-9-brakmo@fb.com>
References: <20170630200706.4183158-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59281 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752720AbdF3UHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 16:07:14 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UK4AuM031655
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bdvs10573-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:13 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 b3f55fd65dcf11e787371f53bdcd5fbc-7bb3f8f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 13:07:11 -0700
In-Reply-To: <20170630200706.4183158-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added callbacks to BPF SOCK_OPS type program before an active
connection is intialized and after a passive or active connection is
established.

The following patch demostrates how they can be used to set send and
receive buffer sizes.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/uapi/linux/bpf.h | 11 +++++++++++
 net/ipv4/tcp_fastopen.c  |  1 +
 net/ipv4/tcp_input.c     |  3 ++-
 net/ipv4/tcp_output.c    |  1 +
 4 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index dd43b22..2405fe3 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -767,6 +767,17 @@ enum {
 					 * window (in packets) or -1 if default
 					 * value should be used
 					 */
+	BPF_SOCK_OPS_TCP_CONNECT_CB,	/* Calls BPF program right before an
+					 * active connection is initialized
+					 */
+	BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB,	/* Calls BPF program when an
+						 * active connection is
+						 * established
+						 */
+	BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB,	/* Calls BPF program when a
+						 * passive connection is
+						 * established
+						 */
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 4af82b9..fcb6273 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -221,6 +221,7 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 	tcp_init_congestion_control(child);
 	tcp_mtup_init(child);
 	tcp_init_metrics(child);
+	tcp_call_bpf(child, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
 	tcp_init_buffer_space(child);
 
 	tp->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bcc9665..664210e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5571,7 +5571,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	icsk->icsk_af_ops->rebuild_header(sk);
 
 	tcp_init_metrics(sk);
-
+	tcp_call_bpf(sk, BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB);
 	tcp_init_congestion_control(sk);
 
 	/* Prevent spurious tcp_cwnd_restart() on first data
@@ -5977,6 +5977,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		} else {
 			/* Make sure socket is routed, for correct metrics. */
 			icsk->icsk_af_ops->rebuild_header(sk);
+			tcp_call_bpf(sk, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
 			tcp_init_congestion_control(sk);
 
 			tcp_mtup_init(sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5345d61..76a1a0e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3445,6 +3445,7 @@ int tcp_connect(struct sock *sk)
 	struct sk_buff *buff;
 	int err;
 
+	tcp_call_bpf(sk, BPF_SOCK_OPS_TCP_CONNECT_CB);
 	tcp_connect_init(sk);
 
 	if (unlikely(tp->repair)) {
-- 
2.9.3
