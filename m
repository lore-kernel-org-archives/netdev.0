From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v4 14/16] bpf: Adds support for setting sndcwnd clamp
Date: Wed, 28 Jun 2017 10:31:22 -0700
Message-ID: <20170628173124.3299500-15-brakmo@fb.com>
References: <20170628173124.3299500-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43820 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751941AbdF1Rbf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 13:31:35 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5SHU4D5011325
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 10:31:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bcchks0yt-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 10:31:34 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 a116aa5e5c2711e7ab3b0002c992ebde-65b3c8f0 for <netdev@vger.kernel.org>;        Wed,
 28 Jun 2017 10:31:33 -0700
In-Reply-To: <20170628173124.3299500-1-brakmo@fb.com>
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
index 0d9ff6d..284b366 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -782,5 +782,6 @@ enum {
 };
 
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
+#define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 147b637..516353e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2734,6 +2734,13 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
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
