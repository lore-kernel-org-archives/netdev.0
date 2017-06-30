From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v5 12/16] bpf: Adds support for setting initial cwnd
Date: Fri, 30 Jun 2017 13:07:02 -0700
Message-ID: <20170630200706.4183158-13-brakmo@fb.com>
References: <20170630200706.4183158-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46142 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752772AbdF3UHX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 16:07:23 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UK7GwH012323
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bduwy0b91-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:17 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 b462c6985dcf11e787371f53bdcd5fbc-7bb3f8f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 13:07:12 -0700
In-Reply-To: <20170630200706.4183158-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a new bpf_setsockopt for TCP sockets, TCP_BPF_IW, which sets the
initial congestion window. This can be used when the hosts are far
apart (large RTTs) and it is safe to start with a large inital cwnd.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/uapi/linux/bpf.h |  2 ++
 net/core/filter.c        | 14 +++++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index cc47259..32755b5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -783,4 +783,6 @@ enum {
 					 */
 };
 
+#define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 96ceded..a4695cf 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2725,7 +2725,19 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 				tcp_reinit_congestion_control(sk,
 					inet_csk(sk)->icsk_ca_ops);
 		} else {
-			ret = -EINVAL;
+			struct tcp_sock *tp = tcp_sk(sk);
+
+			val = *((int *)optval);
+			switch (optname) {
+			case TCP_BPF_IW:
+				if (val <= 0 || tp->data_segs_out > 0)
+					ret = -EINVAL;
+				else
+					tp->snd_cwnd = val;
+				break;
+			default:
+				ret = -EINVAL;
+			}
 		}
 #else
 		ret = -EINVAL;
-- 
2.9.3
