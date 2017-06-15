From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next v2 14/15] bpf: Adds support for setting sndcwnd clamp
Date: Thu, 15 Jun 2017 13:08:43 -0700
Message-ID: <20170615200844.2752485-15-brakmo@fb.com>
References: <20170615200844.2752485-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36699 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752041AbdFOUIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:08:51 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5FK4b14009197
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 13:08:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b3xfp8nm6-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 13:08:51 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 7293a2b6520611e78fc80002c9dfb610-f473d8f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 13:08:50 -0700
In-Reply-To: <20170615200844.2752485-1-brakmo@fb.com>
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
index ecb28e2..4d033eb 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -782,5 +782,6 @@ enum {
 };
 
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
+#define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index a1d9214..f484fef 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2733,6 +2733,13 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_socket_ops_kern *, bpf_socket,
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
