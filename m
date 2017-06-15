From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next v2 11/15] bpf: Sample BPF program to set congestion control
Date: Thu, 15 Jun 2017 13:08:40 -0700
Message-ID: <20170615200844.2752485-12-brakmo@fb.com>
References: <20170615200844.2752485-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58449 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752044AbdFOUIw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:08:52 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5FK3Uub005082
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 13:08:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b3v6g126y-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 13:08:51 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 72780b8c520611e78fc80002c9dfb610-f473d8f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 13:08:50 -0700
In-Reply-To: <20170615200844.2752485-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sample BPF program that sets congestion control to dctcp when both hosts
are within the same datacenter. In this example that is assumed to be
when they have the first 5.5 bytes of their IPv6 address are the same.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile        |  1 +
 samples/bpf/tcp_cong_kern.c | 68 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+)
 create mode 100644 samples/bpf/tcp_cong_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 942c7c7..eb324e0 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -116,6 +116,7 @@ always += cookie_uid_helper_example.o
 always += tcp_synrto_kern.o
 always += tcp_rwnd_kern.o
 always += tcp_bufs_kern.o
+always += tcp_cong_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
diff --git a/samples/bpf/tcp_cong_kern.c b/samples/bpf/tcp_cong_kern.c
new file mode 100644
index 0000000..24a3bc4
--- /dev/null
+++ b/samples/bpf/tcp_cong_kern.c
@@ -0,0 +1,68 @@
+/*
+ * BPF program to set congestion control to dctcp when both hosts are
+ * in the same datacenter (as deteremined by IPv6 prefix).
+ */
+
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/tcp.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/if_packet.h>
+#include <uapi/linux/ip.h>
+#include <linux/socket.h>
+#include "bpf_helpers.h"
+
+#define DEBUG 1
+
+SEC("sockops")
+int bpf_cong(struct bpf_socket_ops *skops)
+{
+	char fmt1[] = "BPF command: %d\n";
+	char fmt2[] = "  Returning %d\n";
+	char cong[] = "dctcp";
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
+	/* Check if both hosts are in the same datacenter. For this
+	 * example they are if the 1st 5.5 bytes in the IPv6 address
+	 * are the same.
+	 */
+	if (skops->family == AF_INET6 &&
+	    skops->local_ip6[0] == skops->remote_ip6[0] &&
+	    (skops->local_ip6[1] & 0xfff00000) ==
+	    (skops->remote_ip6[1] & 0xfff00000)) {
+		switch (op) {
+		case BPF_SOCKET_OPS_NEEDS_ECN:
+			rv = 1;
+			break;
+		case BPF_SOCKET_OPS_ACTIVE_ESTABLISHED_CB:
+			rv = bpf_setsockopt(skops, SOL_TCP, TCP_CONGESTION,
+					    cong, sizeof(cong));
+			break;
+		case BPF_SOCKET_OPS_PASSIVE_ESTABLISHED_CB:
+			rv = bpf_setsockopt(skops, SOL_TCP, TCP_CONGESTION,
+					    cong, sizeof(cong));
+			break;
+		default:
+			rv = -1;
+		}
+	} else {
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
