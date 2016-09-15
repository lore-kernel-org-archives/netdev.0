From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/4] samples/bpf: add comprehensive ipip, ipip6, ip6ip6 test
Date: Thu, 15 Sep 2016 13:00:32 -0700
Message-ID: <1473969632-2408261-5-git-send-email-ast@fb.com>
References: <1473969632-2408261-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43289 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755954AbcIOUAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:00:37 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8FJwYY1014383
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:00:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 25fwh12nt4-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:00:36 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 100e80067b7f11e69bb60002c95209d8-c92f9a50 for <netdev@vger.kernel.org>;        Thu,
 15 Sep 2016 13:00:34 -0700
In-Reply-To: <1473969632-2408261-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the test creates 3 namespaces with veth connected via bridge.
First two namespaces simulate two different hosts with the same
IPv4 and IPv6 addresses configured on the tunnel interface and they
communicate with outside world via standard tunnels.
Third namespace creates collect_md tunnel that is driven by BPF
program which selects different remote host (either first or
second namespace) based on tcp dest port number while tcp dst
ip is the same.
This scenario is rough approximation of load balancer use case.
The tests check both traditional tunnel configuration and collect_md mode.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/tcbpf2_kern.c | 132 ++++++++++++++++++++++++++++++++++
 samples/bpf/test_ipip.sh  | 178 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 310 insertions(+)
 create mode 100755 samples/bpf/test_ipip.sh

diff --git a/samples/bpf/tcbpf2_kern.c b/samples/bpf/tcbpf2_kern.c
index c1917d968fb4..3303bb85593b 100644
--- a/samples/bpf/tcbpf2_kern.c
+++ b/samples/bpf/tcbpf2_kern.c
@@ -9,12 +9,15 @@
 #include <uapi/linux/if_ether.h>
 #include <uapi/linux/if_packet.h>
 #include <uapi/linux/ip.h>
+#include <uapi/linux/ipv6.h>
 #include <uapi/linux/in.h>
 #include <uapi/linux/tcp.h>
 #include <uapi/linux/filter.h>
 #include <uapi/linux/pkt_cls.h>
+#include <net/ipv6.h>
 #include "bpf_helpers.h"
 
+#define _htonl __builtin_bswap32
 #define ERROR(ret) do {\
 		char fmt[] = "ERROR line:%d ret:%d\n";\
 		bpf_trace_printk(fmt, sizeof(fmt), __LINE__, ret); \
@@ -246,4 +249,133 @@ int _ipip_get_tunnel(struct __sk_buff *skb)
 	return TC_ACT_OK;
 }
 
+SEC("ipip6_set_tunnel")
+int _ipip6_set_tunnel(struct __sk_buff *skb)
+{
+	struct bpf_tunnel_key key = {};
+	void *data = (void *)(long)skb->data;
+	struct iphdr *iph = data;
+	struct tcphdr *tcp = data + sizeof(*iph);
+	void *data_end = (void *)(long)skb->data_end;
+	int ret;
+
+	/* single length check */
+	if (data + sizeof(*iph) + sizeof(*tcp) > data_end) {
+		ERROR(1);
+		return TC_ACT_SHOT;
+	}
+
+	key.remote_ipv6[0] = _htonl(0x2401db00);
+	key.tunnel_ttl = 64;
+
+	if (iph->protocol == IPPROTO_ICMP) {
+		key.remote_ipv6[3] = _htonl(1);
+	} else {
+		if (iph->protocol != IPPROTO_TCP || iph->ihl != 5) {
+			ERROR(iph->protocol);
+			return TC_ACT_SHOT;
+		}
+
+		if (tcp->dest == htons(5200)) {
+			key.remote_ipv6[3] = _htonl(1);
+		} else if (tcp->dest == htons(5201)) {
+			key.remote_ipv6[3] = _htonl(2);
+		} else {
+			ERROR(tcp->dest);
+			return TC_ACT_SHOT;
+		}
+	}
+
+	ret = bpf_skb_set_tunnel_key(skb, &key, sizeof(key), BPF_F_TUNINFO_IPV6);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	return TC_ACT_OK;
+}
+
+SEC("ipip6_get_tunnel")
+int _ipip6_get_tunnel(struct __sk_buff *skb)
+{
+	int ret;
+	struct bpf_tunnel_key key;
+	char fmt[] = "remote ip6 %x::%x\n";
+
+	ret = bpf_skb_get_tunnel_key(skb, &key, sizeof(key), BPF_F_TUNINFO_IPV6);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	bpf_trace_printk(fmt, sizeof(fmt), _htonl(key.remote_ipv6[0]),
+			 _htonl(key.remote_ipv6[3]));
+	return TC_ACT_OK;
+}
+
+SEC("ip6ip6_set_tunnel")
+int _ip6ip6_set_tunnel(struct __sk_buff *skb)
+{
+	struct bpf_tunnel_key key = {};
+	void *data = (void *)(long)skb->data;
+	struct ipv6hdr *iph = data;
+	struct tcphdr *tcp = data + sizeof(*iph);
+	void *data_end = (void *)(long)skb->data_end;
+	int ret;
+
+	/* single length check */
+	if (data + sizeof(*iph) + sizeof(*tcp) > data_end) {
+		ERROR(1);
+		return TC_ACT_SHOT;
+	}
+
+	key.remote_ipv6[0] = _htonl(0x2401db00);
+	key.tunnel_ttl = 64;
+
+	if (iph->nexthdr == NEXTHDR_ICMP) {
+		key.remote_ipv6[3] = _htonl(1);
+	} else {
+		if (iph->nexthdr != NEXTHDR_TCP) {
+			ERROR(iph->nexthdr);
+			return TC_ACT_SHOT;
+		}
+
+		if (tcp->dest == htons(5200)) {
+			key.remote_ipv6[3] = _htonl(1);
+		} else if (tcp->dest == htons(5201)) {
+			key.remote_ipv6[3] = _htonl(2);
+		} else {
+			ERROR(tcp->dest);
+			return TC_ACT_SHOT;
+		}
+	}
+
+	ret = bpf_skb_set_tunnel_key(skb, &key, sizeof(key), BPF_F_TUNINFO_IPV6);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	return TC_ACT_OK;
+}
+
+SEC("ip6ip6_get_tunnel")
+int _ip6ip6_get_tunnel(struct __sk_buff *skb)
+{
+	int ret;
+	struct bpf_tunnel_key key;
+	char fmt[] = "remote ip6 %x::%x\n";
+
+	ret = bpf_skb_get_tunnel_key(skb, &key, sizeof(key), BPF_F_TUNINFO_IPV6);
+	if (ret < 0) {
+		ERROR(ret);
+		return TC_ACT_SHOT;
+	}
+
+	bpf_trace_printk(fmt, sizeof(fmt), _htonl(key.remote_ipv6[0]),
+			 _htonl(key.remote_ipv6[3]));
+	return TC_ACT_OK;
+}
+
+
 char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/test_ipip.sh b/samples/bpf/test_ipip.sh
new file mode 100755
index 000000000000..196925403ab4
--- /dev/null
+++ b/samples/bpf/test_ipip.sh
@@ -0,0 +1,178 @@
+#!/bin/bash
+
+function config_device {
+	ip netns add at_ns0
+	ip netns add at_ns1
+	ip netns add at_ns2
+	ip link add veth0 type veth peer name veth0b
+	ip link add veth1 type veth peer name veth1b
+	ip link add veth2 type veth peer name veth2b
+	ip link set veth0b up
+	ip link set veth1b up
+	ip link set veth2b up
+	ip link set dev veth0b mtu 1500
+	ip link set dev veth1b mtu 1500
+	ip link set dev veth2b mtu 1500
+	ip link set veth0 netns at_ns0
+	ip link set veth1 netns at_ns1
+	ip link set veth2 netns at_ns2
+	ip netns exec at_ns0 ip addr add 172.16.1.100/24 dev veth0
+	ip netns exec at_ns0 ip addr add 2401:db00::1/64 dev veth0 nodad
+	ip netns exec at_ns0 ip link set dev veth0 up
+	ip netns exec at_ns1 ip addr add 172.16.1.101/24 dev veth1
+	ip netns exec at_ns1 ip addr add 2401:db00::2/64 dev veth1 nodad
+	ip netns exec at_ns1 ip link set dev veth1 up
+	ip netns exec at_ns2 ip addr add 172.16.1.200/24 dev veth2
+	ip netns exec at_ns2 ip addr add 2401:db00::3/64 dev veth2 nodad
+	ip netns exec at_ns2 ip link set dev veth2 up
+	ip link add br0 type bridge
+	ip link set br0 up
+	ip link set dev br0 mtu 1500
+	ip link set veth0b master br0
+	ip link set veth1b master br0
+	ip link set veth2b master br0
+}
+
+function add_ipip_tunnel {
+	ip netns exec at_ns0 \
+		ip link add dev $DEV_NS type ipip local 172.16.1.100 remote 172.16.1.200
+	ip netns exec at_ns0 ip link set dev $DEV_NS up
+	ip netns exec at_ns0 ip addr add dev $DEV_NS 10.1.1.100/24
+	ip netns exec at_ns1 \
+		ip link add dev $DEV_NS type ipip local 172.16.1.101 remote 172.16.1.200
+	ip netns exec at_ns1 ip link set dev $DEV_NS up
+	# same inner IP address in at_ns0 and at_ns1
+	ip netns exec at_ns1 ip addr add dev $DEV_NS 10.1.1.100/24
+
+	ip netns exec at_ns2 ip link add dev $DEV type ipip external
+	ip netns exec at_ns2 ip link set dev $DEV up
+	ip netns exec at_ns2 ip addr add dev $DEV 10.1.1.200/24
+}
+
+function add_ipip6_tunnel {
+	ip netns exec at_ns0 \
+		ip link add dev $DEV_NS type ip6tnl mode ipip6 local 2401:db00::1/64 remote 2401:db00::3/64
+	ip netns exec at_ns0 ip link set dev $DEV_NS up
+	ip netns exec at_ns0 ip addr add dev $DEV_NS 10.1.1.100/24
+	ip netns exec at_ns1 \
+		ip link add dev $DEV_NS type ip6tnl mode ipip6 local 2401:db00::2/64 remote 2401:db00::3/64
+	ip netns exec at_ns1 ip link set dev $DEV_NS up
+	# same inner IP address in at_ns0 and at_ns1
+	ip netns exec at_ns1 ip addr add dev $DEV_NS 10.1.1.100/24
+
+	ip netns exec at_ns2 ip link add dev $DEV type ip6tnl mode ipip6 external
+	ip netns exec at_ns2 ip link set dev $DEV up
+	ip netns exec at_ns2 ip addr add dev $DEV 10.1.1.200/24
+}
+
+function add_ip6ip6_tunnel {
+	ip netns exec at_ns0 \
+		ip link add dev $DEV_NS type ip6tnl mode ip6ip6 local 2401:db00::1/64 remote 2401:db00::3/64
+	ip netns exec at_ns0 ip link set dev $DEV_NS up
+	ip netns exec at_ns0 ip addr add dev $DEV_NS 2601:646::1/64
+	ip netns exec at_ns1 \
+		ip link add dev $DEV_NS type ip6tnl mode ip6ip6 local 2401:db00::2/64 remote 2401:db00::3/64
+	ip netns exec at_ns1 ip link set dev $DEV_NS up
+	# same inner IP address in at_ns0 and at_ns1
+	ip netns exec at_ns1 ip addr add dev $DEV_NS 2601:646::1/64
+
+	ip netns exec at_ns2 ip link add dev $DEV type ip6tnl mode ip6ip6 external
+	ip netns exec at_ns2 ip link set dev $DEV up
+	ip netns exec at_ns2 ip addr add dev $DEV 2601:646::2/64
+}
+
+function attach_bpf {
+	DEV=$1
+	SET_TUNNEL=$2
+	GET_TUNNEL=$3
+	ip netns exec at_ns2 tc qdisc add dev $DEV clsact
+	ip netns exec at_ns2 tc filter add dev $DEV egress bpf da obj tcbpf2_kern.o sec $SET_TUNNEL
+	ip netns exec at_ns2 tc filter add dev $DEV ingress bpf da obj tcbpf2_kern.o sec $GET_TUNNEL
+}
+
+function test_ipip {
+	DEV_NS=ipip_std
+	DEV=ipip_bpf
+	config_device
+#	tcpdump -nei br0 &
+	cat /sys/kernel/debug/tracing/trace_pipe &
+
+	add_ipip_tunnel
+	attach_bpf $DEV ipip_set_tunnel ipip_get_tunnel
+
+	ip netns exec at_ns0 ping -c 1 10.1.1.200
+	ip netns exec at_ns2 ping -c 1 10.1.1.100
+	ip netns exec at_ns0 iperf -sD -p 5200 > /dev/null
+	ip netns exec at_ns1 iperf -sD -p 5201 > /dev/null
+	sleep 0.2
+	# tcp check _same_ IP over different tunnels
+	ip netns exec at_ns2 iperf -c 10.1.1.100 -n 5k -p 5200
+	ip netns exec at_ns2 iperf -c 10.1.1.100 -n 5k -p 5201
+	cleanup
+}
+
+# IPv4 over IPv6 tunnel
+function test_ipip6 {
+	DEV_NS=ipip_std
+	DEV=ipip_bpf
+	config_device
+#	tcpdump -nei br0 &
+	cat /sys/kernel/debug/tracing/trace_pipe &
+
+	add_ipip6_tunnel
+	attach_bpf $DEV ipip6_set_tunnel ipip6_get_tunnel
+
+	ip netns exec at_ns0 ping -c 1 10.1.1.200
+	ip netns exec at_ns2 ping -c 1 10.1.1.100
+	ip netns exec at_ns0 iperf -sD -p 5200 > /dev/null
+	ip netns exec at_ns1 iperf -sD -p 5201 > /dev/null
+	sleep 0.2
+	# tcp check _same_ IP over different tunnels
+	ip netns exec at_ns2 iperf -c 10.1.1.100 -n 5k -p 5200
+	ip netns exec at_ns2 iperf -c 10.1.1.100 -n 5k -p 5201
+	cleanup
+}
+
+# IPv6 over IPv6 tunnel
+function test_ip6ip6 {
+	DEV_NS=ipip_std
+	DEV=ipip_bpf
+	config_device
+#	tcpdump -nei br0 &
+	cat /sys/kernel/debug/tracing/trace_pipe &
+
+	add_ip6ip6_tunnel
+	attach_bpf $DEV ip6ip6_set_tunnel ip6ip6_get_tunnel
+
+	ip netns exec at_ns0 ping -6 -c 1 2601:646::2
+	ip netns exec at_ns2 ping -6 -c 1 2601:646::1
+	ip netns exec at_ns0 iperf -6sD -p 5200 > /dev/null
+	ip netns exec at_ns1 iperf -6sD -p 5201 > /dev/null
+	sleep 0.2
+	# tcp check _same_ IP over different tunnels
+	ip netns exec at_ns2 iperf -6c 2601:646::1 -n 5k -p 5200
+	ip netns exec at_ns2 iperf -6c 2601:646::1 -n 5k -p 5201
+	cleanup
+}
+
+function cleanup {
+	set +ex
+	pkill iperf
+	ip netns delete at_ns0
+	ip netns delete at_ns1
+	ip netns delete at_ns2
+	ip link del veth0
+	ip link del veth1
+	ip link del veth2
+	ip link del br0
+	pkill tcpdump
+	pkill cat
+	set -ex
+}
+
+cleanup
+echo "Testing IP tunnels..."
+test_ipip
+test_ipip6
+test_ip6ip6
+echo "*** PASS ***"
-- 
2.8.0
