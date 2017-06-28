From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v4 15/16] bpf: Sample bpf program to set sndcwnd clamp
Date: Wed, 28 Jun 2017 10:31:23 -0700
Message-ID: <20170628173124.3299500-16-brakmo@fb.com>
References: <20170628173124.3299500-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41138 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751619AbdF1Rbf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 13:31:35 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5SHSs6r032386
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 10:31:35 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bcf508g2k-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 10:31:35 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 a1433f385c2711e78e380002c991e86a-2233c8f0 for <netdev@vger.kernel.org>;        Wed,
 28 Jun 2017 10:31:33 -0700
In-Reply-To: <20170628173124.3299500-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sample BPF program, tcp_clamp_kern.c, to demostrate the use
of setting the sndcwnd clamp. This program assumes that if the
first 5.5 bytes of the host's IPv6 addresses are the same, then
the hosts are in the same datacenter and sets sndcwnd clamp to
100 packets, SYN and SYN-ACK RTOs to 10ms and send/receive buffer
sizes to 150KB.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile         |  1 +
 samples/bpf/tcp_clamp_kern.c | 94 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+)
 create mode 100644 samples/bpf/tcp_clamp_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 242d76e..9c65058 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -118,6 +118,7 @@ always += tcp_rwnd_kern.o
 always += tcp_bufs_kern.o
 always += tcp_cong_kern.o
 always += tcp_iw_kern.o
+always += tcp_clamp_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
diff --git a/samples/bpf/tcp_clamp_kern.c b/samples/bpf/tcp_clamp_kern.c
new file mode 100644
index 0000000..07e334e
--- /dev/null
+++ b/samples/bpf/tcp_clamp_kern.c
@@ -0,0 +1,94 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * Sample BPF program to set send and receive buffers to 150KB, sndcwnd clamp
+ * to 100 packets and SYN and SYN_ACK RTOs to 10ms when both hosts are within
+ * the same datacenter. For his example, we assume they are within the same
+ * datacenter when the first 5.5 bytes of their IPv6 addresses are the same.
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
+int bpf_clamp(struct bpf_sock_ops *skops)
+{
+	char fmt1[] = "BPF command: %d\n";
+	char fmt2[] = "  Returning %d\n";
+	int bufsize = 150000;
+	int to_init = 10;
+	int clamp = 100;
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
+	/* Check that both hosts are within same datacenter. For this example
+	 * it is the case when the first 5.5 bytes of their IPv6 addresses are
+	 * the same.
+	 */
+	if (skops->family == AF_INET6 &&
+	    skops->local_ip6[0] == skops->remote_ip6[0] &&
+	    (skops->local_ip6[1] & 0xfff00000) ==
+	    (skops->remote_ip6[1] & 0xfff00000)) {
+		switch (op) {
+		case BPF_SOCK_OPS_TIMEOUT_INIT:
+			rv = to_init;
+			break;
+		case BPF_SOCK_OPS_TCP_CONNECT_CB:
+			/* Set sndbuf and rcvbuf of active connections */
+			rv = bpf_setsockopt(skops, SOL_SOCKET, SO_SNDBUF,
+					    &bufsize, sizeof(bufsize));
+			rv = rv*100 + bpf_setsockopt(skops, SOL_SOCKET,
+						      SO_RCVBUF, &bufsize,
+						      sizeof(bufsize));
+			break;
+		case BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB:
+			rv = bpf_setsockopt(skops, SOL_TCP,
+					    TCP_BPF_SNDCWND_CLAMP,
+					    &clamp, sizeof(clamp));
+			break;
+		case BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB:
+			/* Set sndbuf and rcvbuf of passive connections */
+			rv = bpf_setsockopt(skops, SOL_TCP,
+					    TCP_BPF_SNDCWND_CLAMP,
+					    &clamp, sizeof(clamp));
+			rv = rv*100 + bpf_setsockopt(skops, SOL_SOCKET,
+						      SO_SNDBUF, &bufsize,
+						      sizeof(bufsize));
+			rv = rv*100 + bpf_setsockopt(skops, SOL_SOCKET,
+						      SO_RCVBUF, &bufsize,
+						      sizeof(bufsize));
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
+	skops->reply = rv;
+	return 1;
+}
+char _license[] SEC("license") = "GPL";
-- 
2.9.3
