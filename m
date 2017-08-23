From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next 3/3] samples/bpf: extend test_tunnel_bpf.sh with ERSPAN
Date: Wed, 23 Aug 2017 07:55:57 -0700
Message-ID: <1503500157-3717-3-git-send-email-u9012063@gmail.com>
References: <1503500157-3717-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37844 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932134AbdHWO4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:56:14 -0400
Received: by mail-pf0-f193.google.com with SMTP id r62so252670pfj.4
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 07:56:14 -0700 (PDT)
Received: from localhost.localdomain ([73.93.152.207])
        by smtp.gmail.com with ESMTPSA id o18sm4416209pgd.51.2017.08.23.07.56.12
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 07:56:13 -0700 (PDT)
In-Reply-To: <1503500157-3717-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend existing tests for vxlan, gre, geneve, ipip to
include ERSPAN tunnel.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 samples/bpf/tcbpf2_kern.c      | 63 +++++++++++++++++++++++++++++++++++++++++-
 samples/bpf/test_tunnel_bpf.sh | 29 +++++++++++++++++++
 2 files changed, 91 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/tcbpf2_kern.c b/samples/bpf/tcbpf2_kern.c
index 270edcc149a1..370b749f5ee6 100644
--- a/samples/bpf/tcbpf2_kern.c
+++ b/samples/bpf/tcbpf2_kern.c
@@ -17,6 +17,7 @@
 #include <uapi/linux/pkt_cls.h>
 #include <net/ipv6.h>
 #include "bpf_helpers.h"
+#include "bpf_endian.h"
 
 #define _htonl __builtin_bswap32
 #define ERROR(ret) do {\
@@ -38,6 +39,10 @@ struct vxlan_metadata {
 	u32     gbp;
 };
 
+struct erspan_metadata {
+	__be32 index;
+};
+
 SEC("gre_set_tunnel")
 int _gre_set_tunnel(struct __sk_buff *skb)
 {
@@ -76,6 +81,63 @@ int _gre_get_tunnel(struct __sk_buff *skb)
 	return TC_ACT_OK;
 }
 
+SEC("erspan_set_tunnel")
+int _erspan_set_tunnel(struct __sk_buff *skb)
+{
+	struct bpf_tunnel_key key;
+	struct erspan_metadata md;
+	int ret;
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
+	md.index = htonl(123);
+	ret = bpf_skb_set_tunnel_opt(skb, &md, sizeof(md));
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	return TC_ACT_OK;
+}
+
+SEC("erspan_get_tunnel")
+int _erspan_get_tunnel(struct __sk_buff *skb)
+{
+	char fmt[] = "key %d remote ip 0x%x erspan index 0x%x\n";
+	struct bpf_tunnel_key key;
+	struct erspan_metadata md;
+	u32 index;
+	int ret;
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
+		return TC_ACT_SHOT;
+	}
+
+	index = bpf_ntohl(md.index);
+	bpf_trace_printk(fmt, sizeof(fmt),
+			key.tunnel_id, key.remote_ipv4, index);
+
+	return TC_ACT_OK;
+}
+
 SEC("vxlan_set_tunnel")
 int _vxlan_set_tunnel(struct __sk_buff *skb)
 {
@@ -378,5 +440,4 @@ int _ip6ip6_get_tunnel(struct __sk_buff *skb)
 	return TC_ACT_OK;
 }
 
-
 char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/test_tunnel_bpf.sh b/samples/bpf/test_tunnel_bpf.sh
index a70d2ea90313..410052d9fc37 100755
--- a/samples/bpf/test_tunnel_bpf.sh
+++ b/samples/bpf/test_tunnel_bpf.sh
@@ -32,6 +32,19 @@ function add_gre_tunnel {
 	ip addr add dev $DEV 10.1.1.200/24
 }
 
+function add_erspan_tunnel {
+	# in namespace
+	ip netns exec at_ns0 \
+		ip link add dev $DEV_NS type $TYPE seq key 2 local 172.16.1.100 remote 172.16.1.200 erspan 123
+	ip netns exec at_ns0 ip link set dev $DEV_NS up
+	ip netns exec at_ns0 ip addr add dev $DEV_NS 10.1.1.100/24
+
+	# out of namespace
+	ip link add dev $DEV type $TYPE external
+	ip link set dev $DEV up
+	ip addr add dev $DEV 10.1.1.200/24
+}
+
 function add_vxlan_tunnel {
 	# Set static ARP entry here because iptables set-mark works
 	# on L3 packet, as a result not applying to ARP packets,
@@ -99,6 +112,18 @@ function test_gre {
 	cleanup
 }
 
+function test_erspan {
+	TYPE=erspan
+	DEV_NS=erspan00
+	DEV=erspan11
+	config_device
+	add_erspan_tunnel
+	attach_bpf $DEV erspan_set_tunnel erspan_get_tunnel
+	ping -c 1 10.1.1.100
+	ip netns exec at_ns0 ping -c 1 10.1.1.200
+	cleanup
+}
+
 function test_vxlan {
 	TYPE=vxlan
 	DEV_NS=vxlan00
@@ -151,14 +176,18 @@ function cleanup {
 	ip link del gretap11
 	ip link del vxlan11
 	ip link del geneve11
+	ip link del erspan11
 	pkill tcpdump
 	pkill cat
 	set -ex
 }
 
+trap cleanup 0 2 3 6 9
 cleanup
 echo "Testing GRE tunnel..."
 test_gre
+echo "Testing ERSPAN tunnel..."
+test_erspan
 echo "Testing VXLAN tunnel..."
 test_vxlan
 echo "Testing GENEVE tunnel..."
-- 
2.7.4
