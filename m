From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next 1/5] bpf: add support for BPF_SOCK_OPS_BASE_RTT
Date: Fri, 20 Oct 2017 11:05:39 -0700
Message-ID: <20171020180543.4156833-2-brakmo@fb.com>
References: <20171020180543.4156833-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>,
        "Daniel Borkmann" <daniel@iogearbox.net>,
        Blake Matheny <bmatheny@fb.com>,
        "Lawrence Brakmo" <brakmo@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58100 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753220AbdJTSGJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:06:09 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KI4X11005145
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:06:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dqmbgrd3f-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:06:09 -0700
In-Reply-To: <20171020180543.4156833-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A congestion control algorithm can make a call to the BPF socket_ops
program to request the base RTT. The base RTT can be congestion control
dependent and is meant to represent a congestion threshold such that
RTTs above it indicate congestion. This is especially useful for flows
within a DC where the base RTT is easy to obtain.

Being provided a base RTT solves a basic problem in RTT based congestion
avoidance algorithms (such as Vegas, NV and BBR). Although it is easy
to get the base RTT when the network is not congested, it is very
diffcult to do when it is very congested. Newer connections get an
inflated value of the base RTT leading to unfariness (newer flows with a
larger base RTT get more bandwidth). As a result, RTT based congestion
avoidance algorithms tend to update their base RTTs to improve fairness.
In very congested networks this can lead to base RTT inflation, reducing
the ability of these RTT based congestion control algorithms to prevent
congestion.

Note that in my experiments with TCP-NV, the base RTT provided can be
much larger than the actual hardware RTT. For example, experimenting
with hosts within a rack where the hardware RTT is 16-20us, I've used
base RTTs up to 150us. The effect of using a larger base RTT is that the
congestion avoidance algorithm will allow more queueing. When there are
only a few flows the main effect is larger measured RTTs and RPC
latencies due to the increased queueing. When there are a lot of flows,
a larger base RTT can lead to more congestion and more packet drops.
For this case, where the hardware RTT is 20us, a base RTT of 80us
produces good results.

This patch only introduces BPF_SOCK_OPS_BASE_RTT, a later patch in this
set adds support for using it in TCP-NV. Further study and testing is
needed before support can be added to other delay based congestion
avoidance algorithms.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index d83f95e..1aca744 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -955,6 +955,13 @@ enum {
 	BPF_SOCK_OPS_NEEDS_ECN,		/* If connection's congestion control
 					 * needs ECN
 					 */
+	BPF_SOCK_OPS_BASE_RTT,		/* Get base RTT. The correct value is
+					 * based on the path and may be
+					 * dependent on the congestion control
+					 * algorithm. In general it indicates
+					 * a congestion threshold. RTTs above
+					 * this indicate congestion
+					 */
 };
 
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
-- 
2.9.5
