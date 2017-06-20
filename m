From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v3 04/15] bpf: Sample bpf program to set SYN/SYN-ACK RTOs
Date: Mon, 19 Jun 2017 20:00:37 -0700
Message-ID: <20170620030048.3275347-5-brakmo@fb.com>
References: <20170620030048.3275347-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43572 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750925AbdFTDAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 23:00:53 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K307iO003920
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b6nh290kk-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:53 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 ab690e08556411e7a3da0002c992ebde-4d1408f0 for <netdev@vger.kernel.org>;        Mon,
 19 Jun 2017 20:00:52 -0700
In-Reply-To: <20170620030048.3275347-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sample BPF program, tcp_synrto_kern.c, sets the SYN and SYN-ACK
RTOs to 10ms when both hosts are within the same datacenter (i.e.
small RTTs) in an environment where common IPv6 prefixes indicate
both hosts are in the same data center.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile          |  1 +
 samples/bpf/tcp_synrto_kern.c | 59 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)
 create mode 100644 samples/bpf/tcp_synrto_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index ed6bc75..21cb016 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -113,6 +113,7 @@ always += lwt_len_hist_kern.o
 always += xdp_tx_iptunnel_kern.o
 always += test_map_in_map_kern.o
 always += cookie_uid_helper_example.o
+always += tcp_synrto_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
diff --git a/samples/bpf/tcp_synrto_kern.c b/samples/bpf/tcp_synrto_kern.c
new file mode 100644
index 0000000..b11efd8
--- /dev/null
+++ b/samples/bpf/tcp_synrto_kern.c
@@ -0,0 +1,59 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * BPF program to set SYN and SYN-ACK RTOs to 10ms when using IPv6 addresses
+ * and the first 5.5 bytes of the IPv6 addresses are the same (in this example
+ * that means both hosts are in the same datacenter.
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
+int bpf_synrto(struct bpf_sock_ops *skops)
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
+	/* Check for TIMEOUT_INIT operation and IPv6 addresses */
+	if (op == BPF_SOCK_OPS_TIMEOUT_INIT &&
+		skops->family == AF_INET6) {
+
+		/* If the first 5.5 bytes of the IPv6 address are the same
+		 * then both hosts are in the same datacenter
+		 * so use an RTO of 10ms
+		 */
+		if (skops->local_ip6[0] == skops->remote_ip6[0] &&
+		    (skops->local_ip6[1] & 0xfff00000) ==
+		    (skops->remote_ip6[1] & 0xfff00000))
+			rv = 10;
+	}
+#ifdef DEBUG
+	bpf_trace_printk(fmt2, sizeof(fmt2), rv);
+#endif
+	return rv;
+}
+char _license[] SEC("license") = "GPL";
-- 
2.9.3
