From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v5 04/16] bpf: Sample bpf program to set SYN/SYN-ACK RTOs
Date: Fri, 30 Jun 2017 13:06:54 -0700
Message-ID: <20170630200706.4183158-5-brakmo@fb.com>
References: <20170630200706.4183158-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51233 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752751AbdF3UHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 16:07:19 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UK32n5015299
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bdtfqrtg2-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:13 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 b386c5da5dcf11e787371f53bdcd5fbc-7bb3f8f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 13:07:11 -0700
In-Reply-To: <20170630200706.4183158-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sample BPF program, tcp_synrto_kern.c, sets the SYN and SYN-ACK
RTOs to 10ms when both hosts are within the same datacenter (i.e.
small RTTs) in an environment where common IPv6 prefixes indicate
both hosts are in the same data center.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile          |  1 +
 samples/bpf/tcp_synrto_kern.c | 69 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 70 insertions(+)
 create mode 100644 samples/bpf/tcp_synrto_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 015589b..e29370a 100644
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
index 0000000..3c3fc83
--- /dev/null
+++ b/samples/bpf/tcp_synrto_kern.c
@@ -0,0 +1,69 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * BPF program to set SYN and SYN-ACK RTOs to 10ms when using IPv6 addresses
+ * and the first 5.5 bytes of the IPv6 addresses are the same (in this example
+ * that means both hosts are in the same datacenter).
+ *
+ * Use load_sock_ops to load this BPF program.
+ */
+
+#include <uapi/linux/bpf.h>
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
+int bpf_synrto(struct bpf_sock_ops *skops)
+{
+	int rv = -1;
+	int op;
+
+	/* For testing purposes, only execute rest of BPF program
+	 * if neither port numberis 55601
+	 */
+	if (bpf_ntohl(skops->remote_port) != 55601 &&
+	    skops->local_port != 55601)
+		return -1;
+
+	op = (int) skops->op;
+
+#ifdef DEBUG
+	bpf_printk("BPF command: %d\n", op);
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
+		    (bpf_ntohl(skops->local_ip6[1]) & 0xfff00000) ==
+		    (bpf_ntohl(skops->remote_ip6[1]) & 0xfff00000))
+			rv = 10;
+	}
+#ifdef DEBUG
+	bpf_printk("Returning %d\n", rv);
+#endif
+	skops->reply = rv;
+	return 1;
+}
+char _license[] SEC("license") = "GPL";
-- 
2.9.3
