From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next 15/15] bpf: Sample bpf program to set sndcwnd clamp
Date: Tue, 13 Jun 2017 11:00:04 -0700
Message-ID: <20170613180004.3008403-16-brakmo@fb.com>
References: <20170613180004.3008403-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33003 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753217AbdFMSAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:00:10 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DHxZed008176
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:10 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b2m6109tv-6
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:10 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 239082c4506211e79a800002c99331b0-78d3a8f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 11:00:09 -0700
In-Reply-To: <20170613180004.3008403-1-brakmo@fb.com>
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
 samples/bpf/tcp_clamp_kern.c | 86 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 87 insertions(+)
 create mode 100644 samples/bpf/tcp_clamp_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 59ba879..22f2d84 100644
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
index 0000000..edbdff3
--- /dev/null
+++ b/samples/bpf/tcp_clamp_kern.c
@@ -0,0 +1,86 @@
+/*
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
+int bpf_clamp(struct __sk_buff *skb)
+{
+	struct bpf_socket_ops *skops = (struct bpf_socket_ops *) skb;
+	char fmt1[] = "BPF command: %d\n";
+	char fmt2[] = "  Returning %d\n";
+	int op;
+	int rv = 0;
+	int bufsize = 150000;
+	int clamp = 100;
+	int to_init = 10;
+
+	// For testing purposes, only execute rest of BPF program
+	// if neither port numberis 55601
+	if (skops->remote_port != 55601 && skops->local_port != 55601)
+		return -1;
+
+	op = (int) skops->op;
+
+#ifdef DEBUG
+	bpf_trace_printk(fmt1, sizeof(fmt1), op);
+#endif
+
+	// Check that both hosts are within same datacenter. For this example
+	// it is the case when the first 5.5 bytes of their IPv6 addresses are
+	// the same.
+
+	if (skops->family == AF_INET6 &&
+	    skops->local_ip6[0] == skops->remote_ip6[0] &&
+	    (skops->local_ip6[1] & 0xfff00000) ==
+	    (skops->remote_ip6[1] & 0xfff00000)) {
+		switch (op) {
+		case BPF_SOCKET_OPS_TIMEOUT_INIT:
+			rv = to_init;
+			break;
+		case BPF_SOCKET_OPS_TCP_CONNECT_CB:
+			// Set sndbuf and rcvbuf of active connections
+			rv = bpf_setsockopt(skb, SOL_SOCKET, SO_SNDBUF,
+					    &bufsize, sizeof(bufsize));
+			rv = -rv*100 + bpf_setsockopt(skb, SOL_SOCKET,
+						      SO_RCVBUF, &bufsize,
+						      sizeof(bufsize));
+			break;
+		case BPF_SOCKET_OPS_ACTIVE_ESTABLISHED_CB:
+			rv = bpf_setsockopt(skb, SOL_TCP, TCP_BPF_SNDCWND_CLAMP,
+					    &clamp, sizeof(clamp));
+			break;
+		case BPF_SOCKET_OPS_PASSIVE_ESTABLISHED_CB:
+			// Set sndbuf and rcvbuf of passive connections
+			rv = bpf_setsockopt(skb, SOL_TCP, TCP_BPF_SNDCWND_CLAMP,
+					    &clamp, sizeof(clamp));
+			rv = -rv*100 + bpf_setsockopt(skb, SOL_SOCKET,
+						      SO_SNDBUF, &bufsize,
+						      sizeof(bufsize));
+			rv = -rv*200 + bpf_setsockopt(skb, SOL_SOCKET,
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
+	return rv;
+}
+char _license[] SEC("license") = "GPL";
-- 
2.9.3
