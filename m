From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v3 06/15] bpf: Sample bpf program to set initial window
Date: Mon, 19 Jun 2017 20:00:39 -0700
Message-ID: <20170620030048.3275347-7-brakmo@fb.com>
References: <20170620030048.3275347-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51760 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751265AbdFTDAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 23:00:55 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K2w3rH024384
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:54 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b6nvx8r6q-6
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:54 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 ab7e9926556411e7a2b00002c991e86a-2d9fa8f0 for <netdev@vger.kernel.org>;        Mon,
 19 Jun 2017 20:00:52 -0700
In-Reply-To: <20170620030048.3275347-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sample bpf program, tcp_rwnd_kern.c, sets the initial
advertized window to 40 packets in an environment where
distinct IPv6 prefixes indicate that both hosts are not
in the same data center.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile        |  1 +
 samples/bpf/tcp_rwnd_kern.c | 60 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+)
 create mode 100644 samples/bpf/tcp_rwnd_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 21cb016..9aca209 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -114,6 +114,7 @@ always += xdp_tx_iptunnel_kern.o
 always += test_map_in_map_kern.o
 always += cookie_uid_helper_example.o
 always += tcp_synrto_kern.o
+always += tcp_rwnd_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
diff --git a/samples/bpf/tcp_rwnd_kern.c b/samples/bpf/tcp_rwnd_kern.c
new file mode 100644
index 0000000..26c1370
--- /dev/null
+++ b/samples/bpf/tcp_rwnd_kern.c
@@ -0,0 +1,60 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * BPF program to set initial receive window to 40 packets when using IPv6
+ * and the first 5.5 bytes of the IPv6 addresses are not the same (in this
+ * example that means both hosts are not the same datacenter.
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
+int bpf_rwnd(struct bpf_sock_ops *skops)
+{
+	char fmt1[] = "BPF command: %d\n";
+	char fmt2[] = "  Returning %d\n";
+	int rv = -1;
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
+	/* Check for RWND_INIT operation and IPv6 addresses */
+	if (op == BPF_SOCK_OPS_RWND_INIT &&
+		skops->family == AF_INET6) {
+
+		/* If the first 5.5 bytes of the IPv6 address are not the same
+		 * then both hosts are not in the same datacenter
+		 * so use a larger initial advertized window (40 packets)
+		 */
+		if (skops->local_ip6[0] != skops->remote_ip6[0] ||
+		    (skops->local_ip6[1] & 0xfffff000) !=
+		    (skops->remote_ip6[1] & 0xfffff000))
+			bpf_trace_printk(fmt2, sizeof(fmt2), -1);
+			rv = 40;
+	}
+#ifdef DEBUG
+	bpf_trace_printk(fmt2, sizeof(fmt2), rv);
+#endif
+	return rv;
+}
+char _license[] SEC("license") = "GPL";
-- 
2.9.3
