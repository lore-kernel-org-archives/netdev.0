From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next 03/15] bpf: Support for per connection  SYN/SYN-ACK RTOs
Date: Tue, 13 Jun 2017 10:59:52 -0700
Message-ID: <20170613180004.3008403-4-brakmo@fb.com>
References: <20170613180004.3008403-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52755 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752337AbdFMSAL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:00:11 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DHwnqC027973
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b2j3jh313-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:11 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 236a9f78506211e79f7d798f40080b9f-d3b3f8f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 11:00:09 -0700
In-Reply-To: <20170613180004.3008403-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for setting a per connection SYN and
SYN_ACK RTOs from within a BPF_SOCKET_OPS program. For example,
to set small RTOs when it is known both hosts are within a
datacenter.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/net/tcp.h        | 11 +++++++++++
 include/uapi/linux/bpf.h |  3 +++
 net/ipv4/tcp_input.c     |  3 ++-
 net/ipv4/tcp_output.c    |  2 +-
 4 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index bc1c92c..8353563 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -2019,4 +2019,15 @@ static inline int tcp_call_bpf(struct sock *sk, bool is_req_sock, int op)
 }
 #endif
 
+static inline u32 tcp_timeout_init(struct sock *sk, bool is_req_sock)
+{
+	int timeout;
+
+	timeout = tcp_call_bpf(sk, is_req_sock, BPF_SOCKET_OPS_TIMEOUT_INIT);
+
+	if (timeout <= 0)
+		timeout = TCP_TIMEOUT_INIT;
+	return timeout;
+}
+
 #endif	/* _TCP_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 06e7ee1..c9da55d 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -699,6 +699,9 @@ struct bpf_socket_ops {
  */
 enum {
 	BPF_SOCKET_OPS_VOID,
+	BPF_SOCKET_OPS_TIMEOUT_INIT,	/* Should return SYN-RTO value to use or
+					 * -1 if default value should be used
+					 */
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4ea8ec5..fefc062 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6405,7 +6405,8 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	} else {
 		tcp_rsk(req)->tfo_listener = false;
 		if (!want_cookie)
-			inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+			inet_csk_reqsk_queue_hash_add(sk, req,
+				tcp_timeout_init((struct sock *)req, true));
 		af_ops->send_synack(sk, dst, &fl, req, &foc,
 				    !want_cookie ? TCP_SYNACK_NORMAL :
 						   TCP_SYNACK_COOKIE);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e3aab1c..503e478 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3326,7 +3326,7 @@ static void tcp_connect_init(struct sock *sk)
 	tp->rcv_wup = tp->rcv_nxt;
 	tp->copied_seq = tp->rcv_nxt;
 
-	inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+	inet_csk(sk)->icsk_rto = tcp_timeout_init(sk, false);
 	inet_csk(sk)->icsk_retransmits = 0;
 	tcp_clear_retrans(tp);
 }
-- 
2.9.3
