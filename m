From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next v2 13/15] bpf: Sample BPF program to set initial cwnd
Date: Thu, 15 Jun 2017 13:08:42 -0700
Message-ID: <20170615200844.2752485-14-brakmo@fb.com>
References: <20170615200844.2752485-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38878 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752271AbdFOUJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:09:01 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v5FK7cte006826
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 13:09:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2b3cjxk6et-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 13:09:01 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 72996a8e520611e79e620002c9931860-47328f0 for <netdev@vger.kernel.org>; Thu,
 15 Jun 2017 13:08:50 -0700
In-Reply-To: <20170615200844.2752485-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sample BPF program that assumes hosts are far away (i.e. large RTTs)
and sets initial cwnd and initial receive window to 40 packets,
send and receive buffers to 1.5MB.

In practice there would be a test to insure the hosts are actually
far enough away.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile      |  1 +
 samples/bpf/tcp_iw_kern.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+)
 create mode 100644 samples/bpf/tcp_iw_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index eb324e0..3ec96a0 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -117,6 +117,7 @@ always += tcp_synrto_kern.o
 always += tcp_rwnd_kern.o
 always += tcp_bufs_kern.o
 always += tcp_cong_kern.o
+always += tcp_iw_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
diff --git a/samples/bpf/tcp_iw_kern.c b/samples/bpf/tcp_iw_kern.c
new file mode 100644
index 0000000..07962c8
--- /dev/null
+++ b/samples/bpf/tcp_iw_kern.c
@@ -0,0 +1,73 @@
+/*
+ * BPF program to set initial congestion window and initial receive
+ * window to 40 packets and send and receive buffers to 1.5MB. This
+ * would usually be done after doing appropriate checks that indicate
+ * the hosts are far enough away (i.e. large RTT).
+ */
+
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/if_packet.h>
+#include <uapi/linux/ip.h>
+#include <linux/socket.h>
+#include "bpf_helpers.h"
+
+#define DEBUG 1
+
+SEC("sockops")
+int bpf_iw(struct bpf_socket_ops *skops)
+{
+	char fmt1[] = "BPF command: %d\n";
+	char fmt2[] = "  Returning %d\n";
+	int bufsize = 1500000;
+	int rwnd_init = 40;
+	int iw = 40;
+	int rv = 0;
+	int op;
+
+	/* For testing purposes, only execute rest of BPF program
+	 * if neither port numberis 55601
+	 */
+	if (skops->remote_port != 55601 && skops->local_port != 55601)
+		return -1;
+
+	op = (int) skops->op;
+
+#ifdef DEBUG
+	bpf_trace_printk(fmt1, sizeof(fmt1), op);
+#endif
+
+	/* Usually there would be a check to insure the hosts are far
+	 * from each other so it makes sense to increase buffer sizes
+	 */
+	switch (op) {
+	case BPF_SOCKET_OPS_RWND_INIT:
+		rv = rwnd_init;
+		break;
+	case BPF_SOCKET_OPS_TCP_CONNECT_CB:
+		/* Set sndbuf and rcvbuf of active connections */
+		rv = bpf_setsockopt(skops, SOL_SOCKET, SO_SNDBUF, &bufsize,
+				    sizeof(bufsize));
+		rv = -rv*100 + bpf_setsockopt(skops, SOL_SOCKET, SO_RCVBUF,
+					      &bufsize, sizeof(bufsize));
+		break;
+	case BPF_SOCKET_OPS_ACTIVE_ESTABLISHED_CB:
+		rv = bpf_setsockopt(skops, SOL_TCP, TCP_BPF_IW, &iw,
+				    sizeof(iw));
+		break;
+	case BPF_SOCKET_OPS_PASSIVE_ESTABLISHED_CB:
+		/* Set sndbuf and rcvbuf of passive connections */
+		rv = bpf_setsockopt(skops, SOL_SOCKET, SO_SNDBUF, &bufsize,
+				    sizeof(bufsize));
+		rv = -rv*100 + bpf_setsockopt(skops, SOL_SOCKET, SO_RCVBUF,
+					      &bufsize, sizeof(bufsize));
+		break;
+	default:
+		rv = -1;
+	}
+#ifdef DEBUG
+	bpf_trace_printk(fmt2, sizeof(fmt2), rv);
+#endif
+	return rv;
+}
+char _license[] SEC("license") = "GPL";
-- 
2.9.3
