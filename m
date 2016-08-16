From: William Tu <u9012063@gmail.com>
Subject: [PATCH] samples/bpf: Add tunnel set/get tests.
Date: Tue, 16 Aug 2016 07:03:01 -0700
Message-ID: <1471356181-32069-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35648 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbcHPODK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 10:03:10 -0400
Received: by mail-pf0-f193.google.com with SMTP id h186so5546445pfg.2
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 07:03:09 -0700 (PDT)
Received: from vm-dev.localdomain ([73.109.61.46])
        by smtp.gmail.com with ESMTPSA id o8sm39872610pav.5.2016.08.16.07.03.07
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Aug 2016 07:03:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch creates sample code exercising bpf_skb_{set,get}_tunnel_key,
and bpf_skb_{set,get}_tunnel_opt for GRE, VXLAN, and GENEVE.  A native
tunnel device is created in a namespace to interact with a lwtunnel
device out of the namespace, with metadata enabled.  The bpf_skb_set_*
program is attached to tc egress and bpf_skb_get_* is attached to egress
qdisc.  A ping between two tunnels is used to verify correctness and
the result of bpf_skb_get_* printed by bpf_trace_printk.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 samples/bpf/Makefile           |   1 +
 samples/bpf/bpf_helpers.h      |   8 ++
 samples/bpf/tcbpf2_kern.c      | 191 +++++++++++++++++++++++++++++++++++++++++
 samples/bpf/test_tunnel_bpf.sh | 121 ++++++++++++++++++++++++++
 4 files changed, 321 insertions(+)
 create mode 100644 samples/bpf/tcbpf2_kern.c
 create mode 100755 samples/bpf/test_tunnel_bpf.sh

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 90ebf7d..1070075 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -64,6 +64,7 @@ always += tracex6_kern.o
 always += test_probe_write_user_kern.o
 always += trace_output_kern.o
 always += tcbpf1_kern.o
+always += tcbpf2_kern.o
 always += lathist_kern.o
 always += offwaketime_kern.o
 always += spintest_kern.o
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 217c8d5..3af8320 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -43,6 +43,14 @@ static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
 static int (*bpf_probe_write_user)(void *dst, void *src, int size) =
 	(void *) BPF_FUNC_probe_write_user;
+static int (*bpf_skb_get_tunnel_key)(void *ctx, void *key, int size, int flags) =
+	(void *) BPF_FUNC_skb_get_tunnel_key;
+static int (*bpf_skb_set_tunnel_key)(void *ctx, void *key, int size, int flags) =
+	(void *) BPF_FUNC_skb_set_tunnel_key;
+static int (*bpf_skb_get_tunnel_opt)(void *ctx, void *md, int size) =
+	(void *) BPF_FUNC_skb_get_tunnel_opt;
+static int (*bpf_skb_set_tunnel_opt)(void *ctx, void *md, int size) =
+	(void *) BPF_FUNC_skb_set_tunnel_opt;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/tcbpf2_kern.c b/samples/bpf/tcbpf2_kern.c
new file mode 100644
index 0000000..6c94af9
--- /dev/null
+++ b/samples/bpf/tcbpf2_kern.c
@@ -0,0 +1,191 @@
+/* Copyright (c) 2016 VMware
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/if_packet.h>
+#include <uapi/linux/ip.h>
+#include <uapi/linux/in.h>
+#include <uapi/linux/tcp.h>
+#include <uapi/linux/filter.h>
+#include <uapi/linux/pkt_cls.h>
+#include "bpf_helpers.h"
+
+#define ERROR(ret) do {\
+		char fmt[] = "ERROR line:%d ret:%d\n";\
+		bpf_trace_printk(fmt, sizeof(fmt), __LINE__, ret); \
+	} while(0)
+
+struct geneve_opt {
+	__be16	opt_class;
+	u8	type;
+	u8	length:5;
+	u8	r3:1;
+	u8	r2:1;
+	u8	r1:1;
+	u8	opt_data[8]; /* hard-coded to 8 byte */
+};
+
+struct vxlan_metadata {
+	u32     gbp;
+};
+
+SEC("gre_set_tunnel")
+int _gre_set_tunnel(struct __sk_buff *skb)
+{
+	int ret;
+	struct bpf_tunnel_key key;
+
+	__builtin_memset(&key, 0x0, sizeof(key));
+	key.remote_ipv4 = 0xac100164; /* 172.16.1.100 */
+	key.tunnel_id = 2;
+	key.tunnel_tos = 0;
+	key.tunnel_ttl = 64;
+
+	ret = bpf_skb_set_tunnel_key(skb, &key, sizeof(key), BPF_F_ZERO_CSUM_TX);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	return TC_ACT_OK;
+}
+
+SEC("gre_get_tunnel")
+int _gre_get_tunnel(struct __sk_buff *skb)
+{
+	int ret;
+	struct bpf_tunnel_key key;
+	char fmt[] = "key %d remote ip 0x%x\n";
+
+	ret = bpf_skb_get_tunnel_key(skb, &key, sizeof(key), 0);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	bpf_trace_printk(fmt, sizeof(fmt), key.tunnel_id, key.remote_ipv4);
+	return TC_ACT_OK;
+}
+
+SEC("vxlan_set_tunnel")
+int _vxlan_set_tunnel(struct __sk_buff *skb)
+{
+	int ret;
+	struct bpf_tunnel_key key;
+	struct vxlan_metadata md;
+
+	__builtin_memset(&key, 0x0, sizeof(key));
+	key.remote_ipv4 = 0xac100164; /* 172.16.1.100 */
+	key.tunnel_id = 2;
+	key.tunnel_tos = 0;
+	key.tunnel_ttl = 64;
+
+	ret = bpf_skb_set_tunnel_key(skb, &key, sizeof(key), BPF_F_ZERO_CSUM_TX);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	md.gbp = 0x800FF; /* Set VXLAN Group Policy extension */
+	ret = bpf_skb_set_tunnel_opt(skb, &md, sizeof(md));
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	return TC_ACT_OK;
+}
+
+SEC("vxlan_get_tunnel")
+int _vxlan_get_tunnel(struct __sk_buff *skb)
+{
+	int ret;
+	struct bpf_tunnel_key key;
+	struct vxlan_metadata md;
+	char fmt[] = "key %d remote ip 0x%x vxlan gbp 0x%x\n";
+
+	ret = bpf_skb_get_tunnel_key(skb, &key, sizeof(key), 0);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	ret = bpf_skb_get_tunnel_opt(skb, &md, sizeof(md));
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_OK;
+	}
+
+	bpf_trace_printk(fmt, sizeof(fmt),
+			key.tunnel_id, key.remote_ipv4, md.gbp);
+
+	return TC_ACT_OK;
+}
+
+SEC("geneve_set_tunnel")
+int _geneve_set_tunnel(struct __sk_buff *skb)
+{
+	int ret, ret2;
+	struct bpf_tunnel_key key;
+	struct geneve_opt gopt;
+
+	__builtin_memset(&key, 0x0, sizeof(key));
+	key.remote_ipv4 = 0xac100164; /* 172.16.1.100 */
+	key.tunnel_id = 2;
+	key.tunnel_tos = 0;
+	key.tunnel_ttl = 64;
+
+	__builtin_memset(&gopt, 0x0, sizeof(gopt));
+	gopt.opt_class = 0x102; /* Open Virtual Networking (OVN) */
+	gopt.type = 0x08;
+	gopt.r1 = 1;
+	gopt.r2 = 0;
+	gopt.r3 = 1;
+	gopt.length = 2; /* 4-byte multiple */
+	*(int *) &gopt.opt_data = 0xdeadbeef;
+
+	ret = bpf_skb_set_tunnel_key(skb, &key, sizeof(key), BPF_F_ZERO_CSUM_TX);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	ret = bpf_skb_set_tunnel_opt(skb, &gopt, sizeof(gopt));
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	return TC_ACT_OK;
+}
+
+SEC("geneve_get_tunnel")
+int _geneve_get_tunnel(struct __sk_buff *skb)
+{
+	int ret;
+	struct bpf_tunnel_key key;
+	struct geneve_opt gopt;
+	char fmt[] = "key %d remote ip 0x%x geneve class 0x%x\n";
+
+	ret = bpf_skb_get_tunnel_key(skb, &key, sizeof(key), 0);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	ret = bpf_skb_get_tunnel_opt(skb, &gopt, sizeof(gopt));
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	bpf_trace_printk(fmt, sizeof(fmt),
+			key.tunnel_id, key.remote_ipv4, gopt.opt_class);
+	return TC_ACT_OK;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/test_tunnel_bpf.sh b/samples/bpf/test_tunnel_bpf.sh
new file mode 100755
index 0000000..e4208ba
--- /dev/null
+++ b/samples/bpf/test_tunnel_bpf.sh
@@ -0,0 +1,121 @@
+#!/bin/bash
+# In Namespace 0 (at_ns0) using native tunnel
+# Overlay IP: 10.1.1.100
+# local 192.16.1.100 remote 192.16.1.200
+# veth0 IP: 172.16.1.100, tunnel dev <type>00
+
+# Out of Namespace using BPF set/get on lwtunnel
+# Overlay IP: 10.1.1.200
+# local 172.16.1.200 remote 172.16.1.100
+# veth1 IP: 172.16.1.200, tunnel dev <type>11
+
+set -e
+
+function config_device {
+	ip netns add at_ns0
+	ip link add veth0 type veth peer name veth1
+	ip link set veth0 netns at_ns0
+	ip netns exec at_ns0 ip addr add 172.16.1.100/24 dev veth0
+	ip netns exec at_ns0 ip link set dev veth0 up
+	ip link set dev veth1 up
+	ip addr add dev veth1 172.16.1.200/24
+}
+
+function add_gre_tunnel {
+	# in namespace
+	ip netns exec at_ns0 \
+		ip link add dev $DEV_NS type $TYPE key 2 local 172.16.1.100 remote 172.16.1.200
+	ip netns exec at_ns0 ip link set dev $DEV_NS up
+	ip netns exec at_ns0 ip addr add dev $DEV_NS 10.1.1.100/24
+
+	# out of namespace
+	ip link add dev $DEV type $TYPE key 2 external
+	ip link set dev $DEV up
+	ip addr add dev $DEV 10.1.1.200/24
+}
+
+function add_vxlan_tunnel {
+	# in namespace
+	ip netns exec at_ns0 \
+		ip link add dev $DEV_NS type $TYPE id 2 dstport 4789 gbp remote 172.16.1.200
+	ip netns exec at_ns0 ip link set dev $DEV_NS up
+	ip netns exec at_ns0 ip addr add dev $DEV_NS 10.1.1.100/24
+	ip netns exec at_ns0 iptables -A OUTPUT -j MARK --set-mark 0x800FF
+
+	# out of namespace
+	ip link add dev $DEV type $TYPE external gbp dstport 4789
+	ip link set dev $DEV up
+	ip addr add dev $DEV 10.1.1.200/24
+}
+
+function add_geneve_tunnel {
+	# in namespace
+	ip netns exec at_ns0 \
+		ip link add dev $DEV_NS type $TYPE id 2 dstport 6081 remote 172.16.1.200
+	ip netns exec at_ns0 ip link set dev $DEV_NS up
+	ip netns exec at_ns0 ip addr add dev $DEV_NS 10.1.1.100/24
+
+	# out of namespace
+	ip link add dev $DEV type $TYPE dstport 6081 external
+	ip link set dev $DEV up
+	ip addr add dev $DEV 10.1.1.200/24
+}
+
+function attach_bpf {
+	DEV=$1
+	SET_TUNNEL=$2
+	GET_TUNNEL=$3
+	tc qdisc add dev $DEV clsact
+	tc filter add dev $DEV egress bpf da obj tcbpf2_kern.o sec $SET_TUNNEL
+	tc filter add dev $DEV ingress bpf da obj tcbpf2_kern.o sec $GET_TUNNEL
+}
+
+function test_gre {
+	TYPE=gretap
+	DEV_NS=gretap00
+	DEV=gretap11
+	config_device
+	add_gre_tunnel
+	attach_bpf $DEV gre_set_tunnel gre_get_tunnel
+	ping -c 1 10.1.1.100
+	ip netns exec at_ns0 ping -c 1 10.1.1.200
+}
+
+function test_vxlan {
+	TYPE=vxlan
+	DEV_NS=vxlan00
+	DEV=vxlan11
+	config_device
+	add_vxlan_tunnel
+	attach_bpf $DEV vxlan_set_tunnel vxlan_get_tunnel
+	ping -c 1 10.1.1.100
+	ip netns exec at_ns0 ping -c 1 10.1.1.200
+}
+
+function test_geneve {
+	TYPE=geneve
+	DEV_NS=geneve00
+	DEV=geneve11
+	config_device
+	add_geneve_tunnel
+	attach_bpf $DEV geneve_set_tunnel geneve_get_tunnel
+	ping -c 1 10.1.1.100
+	ip netns exec at_ns0 ping -c 1 10.1.1.200
+}
+
+function cleanup {
+	ip netns delete at_ns0
+	ip link del veth1
+	ip link del $DEV
+}
+
+echo "Testing GRE tunnel..."
+test_gre
+cleanup
+echo "Testing VXLAN tunnel..."
+test_vxlan
+cleanup
+echo "Testing GENEVE tunnel..."
+test_geneve
+cleanup
+echo "Success"
-- 
2.5.0
