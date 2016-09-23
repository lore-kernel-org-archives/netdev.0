From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH RFC 1/2] samples/bpf: ilarouter for tc
Date: Fri, 23 Sep 2016 10:16:34 -0700
Message-ID: <1474650995-2031928-2-git-send-email-ast@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49416 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754951AbcIWRTU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 13:19:20 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8NHHJM1013690
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:19:19 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 25mqaxs0t5-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:19:19 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 7b24a94681b111e68cd80002c9dfb610-3c7fba50 for <netdev@vger.kernel.org>;        Fri,
 23 Sep 2016 10:16:35 -0700
In-Reply-To: <1474650995-2031928-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Yue <haoxuany@andrew.cmu.edu>

From: Aaron Yue <haoxuany@fb.com>

Requires a userspace program to insert ila mappings to the ila map.

Signed-off-by: Aaron Yue <haoxuany@fb.com>
Signed-off-by: Aaron Yue <haoxuany@andrew.cmu.edu>
---
 samples/bpf/Makefile       |   1 +
 samples/bpf/ila.h          |  80 +++++++++++++++++++++++++++++
 samples/bpf/ilarouter_tc.c | 124 +++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/inet_helper.h  |  38 ++++++++++++++
 4 files changed, 243 insertions(+)
 create mode 100644 samples/bpf/ila.h
 create mode 100644 samples/bpf/ilarouter_tc.c
 create mode 100644 samples/bpf/inet_helper.h

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 90ebf7d..15e19bb 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -74,6 +74,7 @@ always += parse_varlen.o parse_simple.o parse_ldabs.o
 always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
 always += xdp2_kern.o
+always += ilarouter_tc.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
diff --git a/samples/bpf/ila.h b/samples/bpf/ila.h
new file mode 100644
index 0000000..39a11f8
--- /dev/null
+++ b/samples/bpf/ila.h
@@ -0,0 +1,80 @@
+#ifndef _SIR_H
+#define _SIR_H
+
+#include <linux/types.h>
+#include <linux/in6.h>
+#include <asm/byteorder.h>
+
+#define SIR_T_LOCAL 0x1
+#define SIR_T_VIRTUAL 0x3
+
+struct in6_addr_sir {
+	__be64 prefix;
+	__be64 identifier_c_type;
+} __packed;
+
+struct in6_addr_ila {
+	__be64 locator;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8 identifier:4,
+	     c:1,
+	     type:3;
+	__u8  identifier2;
+	__be16 identifier3;
+	__be16 identifier4;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	__be32 type:3,
+	       c:1,
+	       identifier:28;
+	__be16 identifier2;
+#else
+#error "Fix asm/byteorder.h"
+#endif
+	__be16 checksum;
+} __packed;
+
+struct sirhdr {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u16 traffic_class:4,
+	version:4,
+	flow_label:4,
+	traffic_class2:4;
+	__be16 flow_label2;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	__u32 version:4,
+	      traffic_class:8,
+	      flow_label:20;
+#else
+#error "Fix asm/byteorder.h"
+#endif
+	__be16 payload_length;
+	__u8   next_header;
+	__u8   hop_limit;
+
+	struct in6_addr source_address;
+	struct in6_addr_sir destination_address;
+} __packed;
+
+struct ilahdr {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u16 traffic_class:4,
+	version:4,
+	flow_label:4,
+	traffic_class2:4;
+	__be16 flow_label2;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	__u32 version:4,
+	      traffic_class:8,
+	      flow_label:20;
+#else
+#error "Fix asm/byteorder.h"
+#endif
+	__be16 payload_length;
+	__u8   next_header;
+	__u8   hop_limit;
+
+	struct in6_addr source_address;
+	struct in6_addr_ila destination_address;
+} __packed;
+
+#endif
diff --git a/samples/bpf/ilarouter_tc.c b/samples/bpf/ilarouter_tc.c
new file mode 100644
index 0000000..277322e
--- /dev/null
+++ b/samples/bpf/ilarouter_tc.c
@@ -0,0 +1,124 @@
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
+#include <linux/if_ether.h>
+#include <linux/ipv6.h>
+#include <uapi/linux/bpf.h>
+#include "ila.h"
+#include "inet_helper.h"
+#include "bpf_helpers.h"
+
+char _license[] SEC("license") = "GPL";
+unsigned int version SEC("version") = 1;
+
+struct bpf_map_def SEC("maps") ila_lookup_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct in6_addr),
+	.value_size = sizeof(struct in6_addr),
+	.max_entries = MAP_SIZE,
+};
+
+#define IPV6_DEST_OFF (ETH_HLEN + offsetof(struct ipv6hdr, daddr))
+
+struct addr {
+	__u64 addr_hi;
+	__u64 addr_lo;
+} __packed;
+
+SEC("classifier")
+int ila_lookup(struct __sk_buff *skb)
+{
+	unsigned long dataptr = (unsigned long)skb->data;
+	struct ethhdr *eth;
+	struct ipv6hdr *sir;
+	struct addr *pkt_addr;
+	struct addr stack_addr;
+	struct addr *reply;
+#ifdef DEBUG
+	char lookup_request[] = "Lookup request for sir: %llx, iden: %llx\n";
+	char lookup_fail[] = "Lookup failed\n";
+	char lookup_success[] = "Lookup success. hi: %llx, lo: %llx\n";
+#endif
+
+	/* Invalid packet: length too short
+	 * compiler optimization/verifier bypass: this way it won't assume
+	 * that we copied over a pkt_ptr,
+	 * which has register range of 0 (from (r1 + 0))
+	 */
+	if (dataptr + sizeof(struct ethhdr) +
+	    sizeof(struct ipv6hdr) > skb->data_end)
+		goto redirect;
+
+	/* Ethernet header */
+	eth = (struct ethhdr *)dataptr;
+
+	/* Irrelevant packet: not IPv6 */
+	if (eth->h_proto != htons(ETH_P_IPV6))
+		goto redirect;
+
+	/* SIR Address header */
+	sir = (struct ipv6hdr *)(dataptr + sizeof(struct ethhdr));
+#ifdef DEBUG
+	{
+		/* ILA Address header */
+		struct ilahdr *ila = (struct ilahdr *)sir;
+
+		/* For debugging purposes,
+		 * we don't care about non-SIR/ILA addresses
+		 */
+		if (ila->destination_address.c)
+			goto redirect;
+
+		switch (ila->destination_address.type) {
+		case SIR_T_LOCAL:
+		case SIR_T_VIRTUAL:
+			break;
+		default:
+			goto redirect;
+		}
+	}
+#endif
+
+	pkt_addr = (struct addr *)&(sir->daddr);
+
+	stack_addr.addr_hi = pkt_addr->addr_hi;
+	stack_addr.addr_lo = pkt_addr->addr_lo;
+
+	reply = bpf_map_lookup_elem(&ila_lookup_map, &stack_addr);
+	if (!reply) {
+#ifdef DEBUG
+		/* Comment out if too noisy */
+		bpf_trace_printk(lookup_request, sizeof(lookup_request),
+				 _ntohll(pkt_addr->addr_hi),
+				 _ntohll(pkt_addr->addr_lo));
+
+		bpf_trace_printk(lookup_fail, sizeof(lookup_fail));
+#endif
+		goto redirect;
+	}
+
+#ifdef DEBUG
+	bpf_trace_printk(lookup_request, sizeof(lookup_request),
+			 _ntohll(pkt_addr->addr_hi),
+			 _ntohll(pkt_addr->addr_lo));
+
+	bpf_trace_printk(lookup_success, sizeof(lookup_success),
+			 _ntohll(reply->addr_hi), _ntohll(reply->addr_lo));
+#endif
+
+	stack_addr.addr_hi = reply->addr_hi;
+	stack_addr.addr_lo = reply->addr_lo;
+
+	bpf_skb_store_bytes(skb, IPV6_DEST_OFF, &stack_addr,
+			    sizeof(struct in6_addr), 0);
+
+redirect:
+	return bpf_redirect(skb->ifindex, 1);
+}
diff --git a/samples/bpf/inet_helper.h b/samples/bpf/inet_helper.h
new file mode 100644
index 0000000..d5fc281
--- /dev/null
+++ b/samples/bpf/inet_helper.h
@@ -0,0 +1,38 @@
+#ifndef __INET_HELPER_H
+#define __INET_HELPER_H
+
+#include <linux/inet.h>
+
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+#define _htonl(A) __builtin_bswap32(A)
+#elif defined(__BIG_ENDIAN_BITFIELD)
+#define _htonl(A) (A)
+#else
+#error "Fix asm/byteorder.h"
+#endif
+
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+#define _ntohl(A) __builtin_bswap32(A)
+#elif defined(__BIG_ENDIAN_BITFIELD)
+#define _ntohl(A) (A)
+#else
+#error "Fix asm/byteorder.h"
+#endif
+
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+#define _htonll(A) __builtin_bswap64(A)
+#elif defined(__BIG_ENDIAN_BITFIELD)
+#define _htonll(A) (A)
+#else
+#error "Fix asm/byteorder.h"
+#endif
+
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+#define _ntohll(A) __builtin_bswap64(A)
+#elif defined(__BIG_ENDIAN_BITFIELD)
+#define _ntohll(A) (A)
+#else
+#error "Fix asm/byteorder.h"
+#endif
+
+#endif
-- 
2.8.0.rc2
