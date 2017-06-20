From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v3 14/15] bpf: Adds support for setting sndcwnd clamp
Date: Mon, 19 Jun 2017 20:00:47 -0700
Message-ID: <20170620030048.3275347-15-brakmo@fb.com>
References: <20170620030048.3275347-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60643 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751754AbdFTDAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 23:00:55 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v5K2uWaM018199
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2b6pkp0mkh-8
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:55 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 ac5311a6556411e7a2b00002c991e86a-2d9fa8f0 for <netdev@vger.kernel.org>;        Mon,
 19 Jun 2017 20:00:53 -0700
In-Reply-To: <20170620030048.3275347-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a new bpf_setsockopt for TCP sockets, TCP_BPF_SNDCWND_CLAMP, which
sets the initial congestion window. It is useful to limit the sndcwnd
when the host are close to each other (small RTT).

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/uapi/linux/bpf.h | 1 +
 net/core/filter.c        | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index a07acc6..47189e5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -782,5 +782,6 @@ enum {
 };
 
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
+#define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index db6d30c0..664bb9f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2733,6 +2733,13 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 				else
 					tp->snd_cwnd = val;
 				break;
+			case TCP_BPF_SNDCWND_CLAMP:
+				if (val <= 0) {
+					ret = -EINVAL;
+				} else {
+					tp->snd_cwnd_clamp = val;
+					tp->snd_ssthresh = val;
+				}
 			default:
 				ret = -EINVAL;
 			}
-- 
2.9.3
