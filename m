From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next 12/15] bpf: Adds support for setting initial cwnd
Date: Tue, 13 Jun 2017 11:00:01 -0700
Message-ID: <20170613180004.3008403-13-brakmo@fb.com>
References: <20170613180004.3008403-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44268 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753342AbdFMSAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:00:12 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DHvBH9000951
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2b29g4bt3a-9
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:11 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 2375416c506211e79a800002c99331b0-78d3a8f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 11:00:08 -0700
In-Reply-To: <20170613180004.3008403-1-brakmo@fb.com>
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
index b86aacc..9895672 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -734,4 +734,6 @@ enum {
 					 */
 };
 
+#define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 5e0cb4e..7b4458d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2705,7 +2705,19 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_socket_ops_kern *, bpf_socket,
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
 	} else {
 		ret = -EINVAL;
-- 
2.9.3
