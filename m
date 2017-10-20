From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next 4/5] bpf: sample BPF_SOCKET_OPS_BASE_RTT program
Date: Fri, 20 Oct 2017 11:05:42 -0700
Message-ID: <20171020180543.4156833-5-brakmo@fb.com>
References: <20171020180543.4156833-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>,
        "Daniel Borkmann" <daniel@iogearbox.net>,
        Blake Matheny <bmatheny@fb.com>,
        "Lawrence Brakmo" <brakmo@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48654 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753206AbdJTSGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:06:10 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KI4qZI019219
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:06:10 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dqmuhg9sw-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:06:10 -0700
In-Reply-To: <20171020180543.4156833-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sample socket_ops BPF program to test the BPF helper function
bpf_getsocketops and the new socket_ops op BPF_SOCKET_OPS_BASE_RTT.

The program provides a base RTT of 80us when the calling flow is
within a DC (as determined by the IPV6 prefix) and the congestion
algorithm is "nv".

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked_by: Alexei Starovoitov <ast@fb.com>
---
 samples/bpf/Makefile           |  1 +
 samples/bpf/tcp_basertt_kern.c | 78 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)
 create mode 100644 samples/bpf/tcp_basertt_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 3534ccf..ea2b9e6 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -129,6 +129,7 @@ always += tcp_bufs_kern.o
 always += tcp_cong_kern.o
 always += tcp_iw_kern.o
 always += tcp_clamp_kern.o
+always += tcp_basertt_kern.o
 always += xdp_redirect_kern.o
 always += xdp_redirect_map_kern.o
 always += xdp_redirect_cpu_kern.o
diff --git a/samples/bpf/tcp_basertt_kern.c b/samples/bpf/tcp_basertt_kern.c
new file mode 100644
index 0000000..4bf4fc5
--- /dev/null
+++ b/samples/bpf/tcp_basertt_kern.c
@@ -0,0 +1,78 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * BPF program to set base_rtt to 80us when host is running TCP-NV and
+ * both hosts are in the same datacenter (as determined by IPv6 prefix).
+ *
+ * Use load_sock_ops to load this BPF program.
+ */
+
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/tcp.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/if_packet.h>
+#include <uapi/linux/ip.h>
+#include <linux/socket.h>
+#include "bpf_helpers.h"
+#include "bpf_endian.h"
+
+#define DEBUG 1
+
+#define bpf_printk(fmt, ...)					\
+({								\
+	       char ____fmt[] = fmt;				\
+	       bpf_trace_printk(____fmt, sizeof(____fmt),	\
+				##__VA_ARGS__);			\
+})
+
+SEC("sockops")
+int bpf_basertt(struct bpf_sock_ops *skops)
+{
+	char cong[20];
+	char nv[] = "nv";
+	int rv = 0, n;
+	int op;
+
+	op = (int) skops->op;
+
+#ifdef DEBUG
+	bpf_printk("BPF command: %d\n", op);
+#endif
+
+	/* Check if both hosts are in the same datacenter. For this
+	 * example they are if the 1st 5.5 bytes in the IPv6 address
+	 * are the same.
+	 */
+	if (skops->family == AF_INET6 &&
+	    skops->local_ip6[0] == skops->remote_ip6[0] &&
+	    (bpf_ntohl(skops->local_ip6[1]) & 0xfff00000) ==
+	    (bpf_ntohl(skops->remote_ip6[1]) & 0xfff00000)) {
+		switch (op) {
+		case BPF_SOCK_OPS_BASE_RTT:
+			n = bpf_getsockopt(skops, SOL_TCP, TCP_CONGESTION,
+					   cong, sizeof(cong));
+			if (!n && !__builtin_memcmp(cong, nv, sizeof(nv)+1)) {
+				/* Set base_rtt to 80us */
+				rv = 80;
+			} else if (n) {
+				rv = n;
+			} else {
+				rv = -1;
+			}
+			break;
+		default:
+			rv = -1;
+		}
+	} else {
+		rv = -1;
+	}
+#ifdef DEBUG
+	bpf_printk("Returning %d\n", rv);
+#endif
+	skops->reply = rv;
+	return 1;
+}
+char _license[] SEC("license") = "GPL";
-- 
2.9.5
