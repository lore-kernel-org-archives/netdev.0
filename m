From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v5 06/16] bpf: Sample bpf program to set initial window
Date: Fri, 30 Jun 2017 13:06:56 -0700
Message-ID: <20170630200706.4183158-7-brakmo@fb.com>
References: <20170630200706.4183158-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52546 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752687AbdF3UHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 16:07:19 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v5UK6nwd027619
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2bdkyahy75-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:13 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 b388b58e5dcf11e787371f53bdcd5fbc-7bb3f8f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 13:07:11 -0700
In-Reply-To: <20170630200706.4183158-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sample bpf program, tcp_rwnd_kern.c, sets the initial
advertized window to 40 packets in an environment where
distinct IPv6 prefixes indicate that both hosts are not
in the same data center.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile        |  1 +
 samples/bpf/tcp_rwnd_kern.c | 69 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 70 insertions(+)
 create mode 100644 samples/bpf/tcp_rwnd_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index e29370a..ca95528 100644
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
index 0000000..3f2a228
--- /dev/null
+++ b/samples/bpf/tcp_rwnd_kern.c
@@ -0,0 +1,69 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * BPF program to set initial receive window to 40 packets when using IPv6
+ * and the first 5.5 bytes of the IPv6 addresses are not the same (in this
+ * example that means both hosts are not the same datacenter).
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
+int bpf_rwnd(struct bpf_sock_ops *skops)
+{
+	int rv = -1;
+	int op;
+
+	/* For testing purposes, only execute rest of BPF program
+	 * if neither port numberis 55601
+	 */
+	if (bpf_ntohl(skops->remote_port) !=
+	    55601 && skops->local_port != 55601)
+		return -1;
+
+	op = (int) skops->op;
+
+#ifdef DEBUG
+	bpf_printk("BPF command: %d\n", op);
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
+		    (bpf_ntohl(skops->local_ip6[1]) & 0xfffff000) !=
+		    (bpf_ntohl(skops->remote_ip6[1]) & 0xfffff000))
+			rv = 40;
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
