From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH RFC 2/2] samples/bpf: ilarouter for xdp
Date: Fri, 23 Sep 2016 10:16:35 -0700
Message-ID: <1474650995-2031928-3-git-send-email-ast@fb.com>
References: <1474650995-2031928-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Tom Herbert <tom@herbertland.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44069 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755989AbcIWRQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 13:16:56 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8NHF816032318
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:16:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25n74bgj0n-20
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:16:55 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 7b258ee281b111e6af6e0002c99331b0-f35e6a50 for <netdev@vger.kernel.org>;        Fri,
 23 Sep 2016 10:16:35 -0700
In-Reply-To: <1474650995-2031928-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Yue <haoxuany@andrew.cmu.edu>

From: Aaron Yue <haoxuany@fb.com>

Requires a userspace program to insert ila mappings and mac addresses to
the ila map. Needs a verifier patch to directly allow access to the pkt
from the bpf map.

Signed-off-by: Aaron Yue <haoxuany@fb.com>
Signed-off-by: Aaron Yue <haoxuany@andrew.cmu.edu>
---
 samples/bpf/Makefile        |  1 +
 samples/bpf/ilarouter_xdp.c | 88 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 89 insertions(+)
 create mode 100644 samples/bpf/ilarouter_xdp.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 15e19bb..827e6e8 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -75,6 +75,7 @@ always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
 always += xdp2_kern.o
 always += ilarouter_tc.o
+always += ilarouter_xdp.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
diff --git a/samples/bpf/ilarouter_xdp.c b/samples/bpf/ilarouter_xdp.c
new file mode 100644
index 0000000..24749c4
--- /dev/null
+++ b/samples/bpf/ilarouter_xdp.c
@@ -0,0 +1,88 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+
+#define MAP_SIZE (1 << 20)
+
+#define KBUILD_MODNAME "ilarouter"
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/ipv6.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+struct ila_addr {
+	u64 addr_hi;
+	u64 addr_lo;
+} __packed;
+
+struct ila_info {
+	struct ila_addr addr;
+	u16 mac[3];
+} __packed;
+
+char _license[] SEC("license") = "GPL";
+unsigned int version SEC("version") = 1;
+
+struct bpf_map_def SEC("map_ila_lookup_map") ila_lookup_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct in6_addr),
+	.value_size = sizeof(struct ila_info),
+	.max_entries = MAP_SIZE,
+};
+
+SEC("xdp_ila_lookup")
+int ila_lookup(struct xdp_md *ctx)
+{
+	unsigned long dataptr = (unsigned long)ctx->data;
+	struct ethhdr *eth;
+	struct ipv6hdr *sir;
+	struct ila_addr *pkt_addr;
+	struct ila_info *reply;
+	u16 *dst_mac;
+
+	/* Invalid packet: length too short
+	 * compiler optimization/verifier bypass:
+	 * this way it won't assume that we copied over a pkt_ptr,
+	 * which has register range of 0 (from (r1 + 0))
+	 */
+	if (dataptr + sizeof(struct ethhdr) + sizeof(struct ipv6hdr) >
+	    (unsigned long)ctx->data_end)
+		return XDP_PASS;
+
+	/* Ethernet header */
+	eth = (struct ethhdr *)dataptr;
+
+	/* Irrelevant packet: not IPv6 */
+	if (eth->h_proto != htons(ETH_P_IPV6))
+		return XDP_PASS;
+
+	/* Sir Address header */
+	sir = (struct ipv6hdr *)(dataptr + sizeof(struct ethhdr));
+
+	/* We don't have to check for C bit or Type, since
+	 * userspace mapping inserts guarantees that only valid values
+	 * will be inserted into the map in network byte-order.
+	 * Hence, a lookup fail implies either C bit/Type is invalid,
+	 * or mapping does not exist, in both cases we pass the packet without
+	 * modifications.
+	 */
+	pkt_addr = (struct ila_addr *)&(sir->daddr);
+	reply = bpf_map_lookup_elem(&ila_lookup_map, pkt_addr);
+
+	if (!reply)
+		return XDP_PASS;
+
+	pkt_addr->addr_hi = reply->addr.addr_hi;
+	pkt_addr->addr_lo = reply->addr.addr_lo;
+
+	dst_mac = (u16 *)eth;
+	dst_mac[0] = reply->mac[0];
+	dst_mac[1] = reply->mac[1];
+	dst_mac[2] = reply->mac[2];
+
+	return XDP_TX;
+}
+
-- 
2.8.0.rc2
