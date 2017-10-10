From: Christina Jacob <christina.jacob.koikara@gmail.com>
Subject: [PATCH v2] xdp: Sample xdp program implementing ip forward
Date: Tue, 10 Oct 2017 12:58:52 +0530
Message-ID: <1507620532-25804-2-git-send-email-Christina.Jacob@cavium.com>
References: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        brouer@redhat.com, Sunil.Goutham@cavium.com, daniel@iogearbox.net,
        dsahern@gmail.com, Christina Jacob <Christina.Jacob@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implements port to port forwarding with route table and arp table
lookup for ipv4 packets using bpf_redirect helper function and
lpm_trie  map.

Signed-off-by: Christina Jacob <Christina.Jacob@cavium.com>
---
 samples/bpf/Makefile               |    4 +
 samples/bpf/xdp_router_ipv4_kern.c |  189 +++++++++++
 samples/bpf/xdp_router_ipv4_user.c |  655 ++++++++++++++++++++++++++++++++++++
 3 files changed, 848 insertions(+), 0 deletions(-)
 create mode 100644 samples/bpf/xdp_router_ipv4_kern.c
 create mode 100644 samples/bpf/xdp_router_ipv4_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index cf17c79..8504ebb 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -28,6 +28,7 @@ hostprogs-y += test_cgrp2_sock
 hostprogs-y += test_cgrp2_sock2
 hostprogs-y += xdp1
 hostprogs-y += xdp2
+hostprogs-y += xdp_router_ipv4
 hostprogs-y += test_current_task_under_cgroup
 hostprogs-y += trace_event
 hostprogs-y += sampleip
@@ -73,6 +74,7 @@ test_cgrp2_sock2-objs := bpf_load.o $(LIBBPF) test_cgrp2_sock2.o
 xdp1-objs := bpf_load.o $(LIBBPF) xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o $(LIBBPF) xdp1_user.o
+xdp_router_ipv4-objs := bpf_load.o $(LIBBPF) xdp_router_ipv4_user.o
 test_current_task_under_cgroup-objs := bpf_load.o $(LIBBPF) cgroup_helpers.o \
 				       test_current_task_under_cgroup_user.o
 trace_event-objs := bpf_load.o $(LIBBPF) trace_event_user.o
@@ -114,6 +116,7 @@ always += parse_varlen.o parse_simple.o parse_ldabs.o
 always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
 always += xdp2_kern.o
+always += xdp_router_ipv4_kern.o
 always += test_current_task_under_cgroup_kern.o
 always += trace_event_kern.o
 always += sampleip_kern.o
@@ -160,6 +163,7 @@ HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
 HOSTLOADLIBES_xdp1 += -lelf
 HOSTLOADLIBES_xdp2 += -lelf
+HOSTLOADLIBES_xdp_router_ipv4 += -lelf
 HOSTLOADLIBES_test_current_task_under_cgroup += -lelf
 HOSTLOADLIBES_trace_event += -lelf
 HOSTLOADLIBES_sampleip += -lelf
diff --git a/samples/bpf/xdp_router_ipv4_kern.c b/samples/bpf/xdp_router_ipv4_kern.c
new file mode 100644
index 0000000..c2bfe40
--- /dev/null
+++ b/samples/bpf/xdp_router_ipv4_kern.c
@@ -0,0 +1,189 @@
+/*
+ * Copyright (C) 2017 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ */
+#define KBUILD_MODNAME "foo"
+#include <uapi/linux/bpf.h>
+#include <linux/in.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <linux/if_vlan.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include "bpf_helpers.h"
+#include <linux/slab.h>
+#include <net/ip_fib.h>
+
+struct trie_value {
+	__u8 prefix[4];
+	long value;
+	int gw;
+	int ifindex;
+	int metric;
+};
+
+/*Key for lpm_trie*/
+union key_4 {
+	u32 b32[2];
+	u8 b8[8];
+};
+
+struct arp_entry {
+	int dst;
+	long mac;
+};
+
+struct direct_map {
+	long mac;
+	int ifindex;
+	struct arp_entry arp;
+};
+
+/* Map for trie implementation*/
+struct bpf_map_def SEC("maps") lpm_map = {
+	.type = BPF_MAP_TYPE_LPM_TRIE,
+	.key_size = 8,
+	.value_size = sizeof(struct trie_value),
+	.max_entries = 50,
+	.map_flags = BPF_F_NO_PREALLOC,
+};
+
+/* Map for counter*/
+struct bpf_map_def SEC("maps") rxcnt = {
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 256,
+};
+
+/* Map for ARP table*/
+struct bpf_map_def SEC("maps") arp_table = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(int),
+	.value_size = sizeof(long),
+	.max_entries = 50,
+};
+
+/* Map to keep the exact match entries in the route table*/
+struct bpf_map_def SEC("maps") exact_match = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(int),
+	.value_size = sizeof(struct direct_map),
+	.max_entries = 50,
+};
+
+/* Function to set source and destination mac of the packet */
+static inline void set_src_dst_mac(void *data, void *src, void *dst)
+{
+	unsigned short *p      = data;
+	unsigned short *dest   = dst;
+	unsigned short *source = src;
+
+	__builtin_memcpy(p, dest, 3);
+	__builtin_memcpy(p + 3, source, 3);
+}
+
+/* Parse IPV4 packet to get SRC, DST IP and protocol */
+static inline int parse_ipv4(void *data, u64 nh_off, void *data_end,
+			     __be32 *src, __be32 *dest)
+{
+	struct iphdr *iph = data + nh_off;
+
+	if (iph + 1 > data_end)
+		return 0;
+	*src = (__be32)iph->saddr;
+	*dest = (__be32)iph->daddr;
+	return iph->protocol;
+}
+
+SEC("xdp3")
+int xdp_prog3(struct xdp_md *ctx)
+{
+	void *data_end = (void *)(long)ctx->data_end;
+	void *data = (void *)(long)ctx->data;
+	struct ethhdr *eth = data;
+	int rc = XDP_DROP, forward_to;
+	long *value;
+	struct trie_value *prefix_value;
+	long *dest_mac = NULL, *src_mac = NULL;
+	u16 h_proto;
+	u64 nh_off;
+	u32 ipproto;
+	union key_4 key4;
+
+	nh_off = sizeof(*eth);
+	if (data + nh_off > data_end)
+		return rc;
+
+	h_proto = eth->h_proto;
+
+	if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
+		struct vlan_hdr *vhdr;
+
+		vhdr = data + nh_off;
+		nh_off += sizeof(struct vlan_hdr);
+		if (data + nh_off > data_end)
+			return rc;
+		h_proto = vhdr->h_vlan_encapsulated_proto;
+	}
+	if (h_proto == htons(ETH_P_ARP)) {
+		return XDP_PASS;
+	} else if (h_proto == htons(ETH_P_IP)) {
+		int src_ip = 0, dest_ip = 0;
+		struct direct_map *direct_entry;
+
+		ipproto = parse_ipv4(data, nh_off, data_end, &src_ip, &dest_ip);
+		direct_entry = (struct direct_map *)bpf_map_lookup_elem
+			(&exact_match, &dest_ip);
+		/*check for exact match, this would give a faster lookup*/
+		if (direct_entry && direct_entry->mac && direct_entry->arp.mac) {
+			src_mac = &direct_entry->mac;
+			dest_mac = &direct_entry->arp.mac;
+			forward_to = direct_entry->ifindex;
+		} else {
+			/*Look up in the trie for lpm*/
+			key4.b32[0] = 32;
+			key4.b8[4] = dest_ip % 0x100;
+			key4.b8[5] = (dest_ip >> 8) % 0x100;
+			key4.b8[6] = (dest_ip >> 16) % 0x100;
+			key4.b8[7] = (dest_ip >> 24) % 0x100;
+			prefix_value = ((struct trie_value *)bpf_map_lookup_elem
+					(&lpm_map, &key4));
+			if (!prefix_value) {
+				return XDP_DROP;
+			} else {
+				src_mac = &prefix_value->value;
+				if (src_mac) {
+					dest_mac = (long *)bpf_map_lookup_elem
+						(&arp_table, &dest_ip);
+					if (!dest_mac) {
+						if (prefix_value->gw) {
+							dest_ip = *(__be32 *)&prefix_value->gw;
+							dest_mac = (long *)bpf_map_lookup_elem(&arp_table, &dest_ip);
+						} else {
+							return XDP_DROP;
+						}
+					}
+					forward_to = prefix_value->ifindex;
+				} else {
+					return XDP_DROP;
+				}
+			}
+		}
+	} else {
+		ipproto = 0;
+	}
+	if (src_mac && dest_mac) {
+		set_src_dst_mac(data, src_mac, dest_mac);
+		value = bpf_map_lookup_elem(&rxcnt, &ipproto);
+		if (value)
+			*value += 1;
+		return  bpf_redirect(forward_to, 0);
+	}
+	return rc;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/xdp_router_ipv4_user.c b/samples/bpf/xdp_router_ipv4_user.c
new file mode 100644
index 0000000..32cc6b9
--- /dev/null
+++ b/samples/bpf/xdp_router_ipv4_user.c
@@ -0,0 +1,655 @@
+/*
+ * Copyright (C) 2017 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ */
+#include <linux/bpf.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <assert.h>
+#include <errno.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <unistd.h>
+#include "bpf_load.h"
+#include "libbpf.h"
+#include <arpa/inet.h>
+#include <fcntl.h>
+#include <poll.h>
+#include <net/if.h>
+#include <netdb.h>
+#include <sys/ioctl.h>
+#include <sys/syscall.h>
+#include "bpf_util.h"
+
+int sock, sock_arp, flags = 0;
+char buf[8192];
+static int total_ifindex;
+int *ifindex_list;
+
+static int get_route_table(int rtm_family);
+static void int_exit(int sig)
+{
+	int i = 0;
+
+	for (i = 0; i < total_ifindex; i++)
+		set_link_xdp_fd(ifindex_list[i], -1, flags);
+	exit(0);
+}
+
+static void close_and_exit(int sig)
+{
+	int i = 0;
+
+	close(sock);
+	close(sock_arp);
+
+	for (i = 0; i < total_ifindex; i++)
+		set_link_xdp_fd(ifindex_list[i], -1, flags);
+	exit(0);
+}
+
+/* Get the mac address of the interface given interface name */
+static long *getmac(char *iface)
+{
+	int fd;
+	struct ifreq ifr;
+	long *mac = NULL;
+
+	fd = socket(AF_INET, SOCK_DGRAM, 0);
+	ifr.ifr_addr.sa_family = AF_INET;
+	strncpy(ifr.ifr_name, iface, IFNAMSIZ - 1);
+	ioctl(fd, SIOCGIFHWADDR, &ifr);
+	mac = (long *)ifr.ifr_hwaddr.sa_data;
+	close(fd);
+	return mac;
+}
+
+static int recv_msg(struct sockaddr_nl sock_addr, int sock)
+{
+	char *buf_ptr;
+	struct nlmsghdr *nh;
+	int len, nll = 0;
+
+	buf_ptr = buf;
+	while (1) {
+		len = recv(sock, buf_ptr, sizeof(buf) - nll, 0);
+		if (len < 0)
+			return len;
+
+		nh = (struct nlmsghdr *)buf_ptr;
+
+		if (nh->nlmsg_type == NLMSG_DONE)
+			break;
+		buf_ptr += len;
+		nll += len;
+		if ((sock_addr.nl_groups & RTMGRP_NEIGH) == RTMGRP_NEIGH)
+			break;
+
+		if ((sock_addr.nl_groups & RTMGRP_IPV4_ROUTE) == RTMGRP_IPV4_ROUTE)
+			break;
+	}
+	return nll;
+}
+
+/* Function to parse the route entry returned by netlink
+ * Updates the route entry related map entries
+ */
+static void read_route(struct nlmsghdr *nh, int nll)
+{
+	struct route_table {
+		int dst, gw, dst_len, iface, metric;
+		long *mac;
+		char *iface_name;
+	} route;
+	struct arp_table {
+		int dst;
+		long mac;
+	};
+
+	struct direct_map {
+		long mac;
+		int ifindex;
+		struct arp_table arp;
+	} direct_entry;
+	int i;
+	int rtm_family;
+	struct bpf_lpm_trie_key *prefix_key;
+	char dsts[24], gws[24], ifs[16], dsts_len[24], metrics[24];
+	struct rtmsg *rt_msg;
+	int rtl;
+	struct rtattr *rt_attr;
+
+	if (nh->nlmsg_type == RTM_DELROUTE)
+		printf("DELETING Route entry\n");
+	else if (nh->nlmsg_type == RTM_GETROUTE)
+		printf("READING Route entry\n");
+	else if (nh->nlmsg_type == RTM_NEWROUTE)
+		printf("NEW Route entry\n");
+	else
+		printf("%d\n", nh->nlmsg_type);
+
+	bzero(&route, sizeof(route));
+	printf("Destination\t\tGateway\t\tGenmask\t\tMetric\t\tIface\n");
+	for (; NLMSG_OK(nh, nll); nh = NLMSG_NEXT(nh, nll)) {
+		rt_msg = (struct rtmsg *)NLMSG_DATA(nh);
+		rtm_family = rt_msg->rtm_family;
+		if (rtm_family == AF_INET)
+			if (rt_msg->rtm_table != RT_TABLE_MAIN)
+				continue;
+		rt_attr = (struct rtattr *)RTM_RTA(rt_msg);
+		rtl = RTM_PAYLOAD(nh);
+
+		for (; RTA_OK(rt_attr, rtl); rt_attr = RTA_NEXT(rt_attr, rtl)) {
+			switch (rt_attr->rta_type) {
+			case NDA_DST:
+				sprintf(dsts, "%d",
+					*((int *)RTA_DATA(rt_attr)));
+				break;
+			case RTA_GATEWAY:
+				sprintf(gws, "%d", *((int *)RTA_DATA(rt_attr)));
+				break;
+			case RTA_OIF:
+				sprintf(ifs, "%d", *((int *)RTA_DATA(rt_attr)));
+				break;
+			case RTA_METRICS:
+				sprintf(metrics, "%d",
+					*((int *)RTA_DATA(rt_attr)));
+			default:
+				break;
+			}
+		}
+		sprintf(dsts_len, "%d", rt_msg->rtm_dst_len);
+
+		route.dst = atoi(dsts);
+		route.dst_len = atoi(dsts_len);
+		route.gw = atoi(gws);
+		route.iface = atoi(ifs);
+		route.metric = atoi(metrics);
+		route.iface_name = alloca(sizeof(char *) * IFNAMSIZ);
+		route.iface_name = if_indextoname(route.iface, route.iface_name);
+		route.mac = getmac(route.iface_name);
+		if (rtm_family == AF_INET) {
+			struct trie_value {
+				__u8 prefix[4];
+				long value;
+				int gw;
+				int ifindex;
+				int metric;
+			} *prefix_value;
+
+			prefix_key = alloca(sizeof(*prefix_key) + 3);
+			prefix_value = alloca(sizeof(*prefix_value));
+
+			prefix_key->prefixlen = 32;
+			prefix_key->prefixlen = route.dst_len;
+			direct_entry.mac = *route.mac & 0xffffffffffff;
+			direct_entry.ifindex = route.iface;
+			direct_entry.arp.mac = 0;
+			direct_entry.arp.dst = 0;
+			if (route.dst_len == 32) {
+				if (nh->nlmsg_type == RTM_DELROUTE) {
+					assert(bpf_map_delete_elem(
+								   map_fd[3],
+								   &route.dst
+								   ) == 0);
+				} else {
+					if (bpf_map_lookup_elem(map_fd[2],
+								&route.dst,
+								&direct_entry.arp.mac
+								) == 0)
+						direct_entry.arp.dst = route.dst;
+
+					assert(bpf_map_update_elem(map_fd[3],
+								   &route.dst,
+								   &direct_entry,
+								   0) == 0);
+				}
+			}
+			for (i = 0; i < 4; i++)
+				prefix_key->data[i] =
+					(route.dst >> i * 8) % 0x100;
+			printf("%3d.%d.%d.%d\t\t%3x\t\t%d\t\t%d\t\t%s\n",
+			       (int)prefix_key->data[0], (int)prefix_key->data[1],
+			       (int)prefix_key->data[2], (int)prefix_key->data[3],
+			       route.gw, route.dst_len, route.metric,
+			       route.iface_name);
+			if (bpf_map_lookup_elem(map_fd[0], prefix_key,
+						prefix_value) < 0) {
+				for (i = 0; i < 4; i++)
+					prefix_value->prefix[i] = prefix_key->data[i];
+				prefix_value->value = *route.mac & 0xffffffffffff;
+				prefix_value->ifindex = route.iface;
+				prefix_value->gw = route.gw;
+				prefix_value->metric = route.metric;
+
+				assert(bpf_map_update_elem(map_fd[0],
+							   prefix_key,
+							   prefix_value, 0
+							   ) == 0);
+			} else {
+				if (nh->nlmsg_type == RTM_DELROUTE) {
+					printf("deleting entry\n");
+					printf("prefix key=%d.%d.%d.%d/%d",
+					       prefix_key->data[0],
+					       prefix_key->data[1],
+					       prefix_key->data[2],
+					       prefix_key->data[3],
+					       prefix_key->prefixlen);
+					assert(bpf_map_delete_elem(map_fd[0],
+								   prefix_key
+								   ) == 0);
+					/* Rereading the route table to check if
+					 * there is an entry with the same
+					 * prefix but a different metric as the
+					 * deleted enty.
+					 */
+					get_route_table(AF_INET);
+				} else if (prefix_key->data[0] ==
+					   prefix_value->prefix[0] &&
+					   prefix_key->data[1] ==
+					   prefix_value->prefix[1] &&
+					   prefix_key->data[2] ==
+					   prefix_value->prefix[2] &&
+					   prefix_key->data[3] ==
+					   prefix_value->prefix[3] &&
+					   route.metric >= prefix_value->metric) {
+					continue;
+				} else {
+					for (i = 0; i < 4; i++)
+						prefix_value->prefix[i] =
+							prefix_key->data[i];
+					prefix_value->value =
+						*route.mac & 0xffffffffffff;
+					prefix_value->ifindex = route.iface;
+					prefix_value->gw = route.gw;
+					prefix_value->metric = route.metric;
+					assert(bpf_map_update_elem(
+								   map_fd[0],
+								   prefix_key,
+								   prefix_value,
+								   0) == 0);
+				}
+			}
+		}
+		bzero(&route, sizeof(route));
+		bzero(dsts, sizeof(dsts));
+		bzero(dsts_len, sizeof(dsts_len));
+		bzero(gws, sizeof(gws));
+		bzero(ifs, sizeof(ifs));
+		bzero(&route, sizeof(route));
+	}
+}
+
+/* Function to read the existing route table  when the process is launched*/
+static int get_route_table(int rtm_family)
+{
+	struct {
+		struct nlmsghdr nl;
+		struct rtmsg rt;
+		char buf[8192];
+	} req;
+
+	int sock, seq = 0;
+	struct sockaddr_nl sa;
+	struct msghdr msg;
+	struct iovec iov;
+	int ret = 0;
+	struct nlmsghdr *nh;
+	int nll;
+
+	sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
+	if (sock < 0) {
+		printf("open netlink socket: %s\n", strerror(errno));
+		return -1;
+	}
+	bzero(&sa, sizeof(sa));
+	sa.nl_family = AF_NETLINK;
+	if (bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
+		printf("bind to netlink: %s\n", strerror(errno));
+		ret = -1;
+		goto cleanup;
+	}
+	bzero(&req, sizeof(req));
+	req.nl.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg));
+	req.nl.nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP;
+	req.nl.nlmsg_type = RTM_GETROUTE;
+
+	req.rt.rtm_family = rtm_family;
+	req.rt.rtm_table = RT_TABLE_MAIN;
+	req.nl.nlmsg_pid = 0;
+	req.nl.nlmsg_seq = ++seq;
+	bzero(&msg, sizeof(msg));
+	iov.iov_base = (void *)&req.nl;
+	iov.iov_len = req.nl.nlmsg_len;
+	msg.msg_iov = &iov;
+	msg.msg_iovlen = 1;
+	ret = sendmsg(sock, &msg, 0);
+	if (ret < 0) {
+		printf("send to netlink: %s\n", strerror(errno));
+		ret = -1;
+		goto cleanup;
+	}
+	bzero(buf, sizeof(buf));
+	nll = recv_msg(sa, sock);
+	if (nll < 0) {
+		printf("recv from netlink: %s\n", strerror(nll));
+		ret = -1;
+		goto cleanup;
+	}
+	nh = (struct nlmsghdr *)buf;
+	read_route(nh, nll);
+cleanup:
+	close(sock);
+	return ret;
+}
+
+/* Function to parse the arp entry returned by netlink
+ * Updates the arp entry related map entries
+ */
+static void read_arp(struct nlmsghdr *nh, int nll)
+{
+	struct arp_table {
+		int dst;
+		long mac;
+	} arp_entry;
+	struct direct_map {
+		long mac;
+		int ifindex;
+		struct arp_table arp;
+	} direct_entry;
+
+	char dsts[24], mac[24];
+	struct ndmsg *rt_msg;
+	int rtl, i = 0, ndm_family;
+	struct rtattr *rt_attr;
+
+	if (nh->nlmsg_type == RTM_GETNEIGH)
+		printf("READING arp entry\n");
+	printf("Address\tHwAddress\n");
+	for (; NLMSG_OK(nh, nll); nh = NLMSG_NEXT(nh, nll)) {
+		i++;
+		rt_msg = (struct ndmsg *)NLMSG_DATA(nh);
+		rt_attr = (struct rtattr *)RTM_RTA(rt_msg);
+		ndm_family = rt_msg->ndm_family;
+		rtl = RTM_PAYLOAD(nh);
+		for (; RTA_OK(rt_attr, rtl); rt_attr = RTA_NEXT(rt_attr, rtl)) {
+			switch (rt_attr->rta_type) {
+			case NDA_DST:
+				sprintf(dsts, "%d",
+					*((int *)RTA_DATA(rt_attr)));
+				break;
+			case NDA_LLADDR:
+				sprintf(mac, "%ld",
+					*((long *)RTA_DATA(rt_attr)));
+				break;
+			default:
+				break;
+			}
+		}
+		arp_entry.dst = atoi(dsts);
+		arp_entry.mac = atol(mac);
+		printf("%x\t\t%lx\n", arp_entry.dst, arp_entry.mac);
+		if (ndm_family == AF_INET) {
+			if (bpf_map_lookup_elem(map_fd[3], &arp_entry.dst,
+						&direct_entry) == 0) {
+				if (nh->nlmsg_type == RTM_DELNEIGH) {
+					direct_entry.arp.dst = 0;
+					direct_entry.arp.mac = 0;
+				} else if (nh->nlmsg_type == RTM_NEWNEIGH) {
+					direct_entry.arp.dst = arp_entry.dst;
+					direct_entry.arp.mac = arp_entry.mac;
+				}
+				assert(bpf_map_update_elem(map_fd[3],
+							   &arp_entry.dst,
+							   &direct_entry, 0
+							   ) == 0);
+				bzero(&direct_entry, sizeof(direct_entry));
+			}
+			if (nh->nlmsg_type == RTM_DELNEIGH) {
+				assert(bpf_map_delete_elem(map_fd[2],
+							   &arp_entry.dst) == 0);
+			} else if (nh->nlmsg_type == RTM_NEWNEIGH) {
+				assert(bpf_map_update_elem(map_fd[2],
+							   &arp_entry.dst,
+							   &arp_entry.mac, 0
+							   ) == 0);
+			}
+		}
+		bzero(&arp_entry, sizeof(arp_entry));
+		bzero(dsts, sizeof(dsts));
+	}
+}
+
+/* Function to read the existing arp table  when the process is launched*/
+static int get_arp_table(int rtm_family)
+{
+	struct {
+		struct nlmsghdr nl;
+		struct ndmsg rt;
+		char buf[8192];
+	} req;
+
+	int sock, seq = 0;
+	struct sockaddr_nl sa;
+	struct msghdr msg;
+	struct iovec iov;
+	int ret = 0;
+	struct nlmsghdr *nh;
+	int nll;
+
+	sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
+	if (sock < 0) {
+		printf("open netlink socket: %s\n", strerror(errno));
+		return -1;
+	}
+	bzero(&sa, sizeof(sa));
+	sa.nl_family = AF_NETLINK;
+	if (bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
+		printf("bind to netlink: %s\n", strerror(errno));
+		ret = -1;
+		goto cleanup;
+	}
+	bzero(&req, sizeof(req));
+	req.nl.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg));
+	req.nl.nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP;
+	req.nl.nlmsg_type = RTM_GETNEIGH;
+	req.rt.ndm_state = NUD_REACHABLE;
+	req.rt.ndm_family = rtm_family;
+	req.nl.nlmsg_pid = 0;
+	req.nl.nlmsg_seq = ++seq;
+	bzero(&msg, sizeof(msg));
+	iov.iov_base = (void *)&req.nl;
+	iov.iov_len = req.nl.nlmsg_len;
+	msg.msg_iov = &iov;
+	msg.msg_iovlen = 1;
+	ret = sendmsg(sock, &msg, 0);
+	if (ret < 0) {
+		printf("send to netlink: %s\n", strerror(errno));
+		ret = -1;
+		goto cleanup;
+	}
+	bzero(buf, sizeof(buf));
+	nll = recv_msg(sa, sock);
+	if (nll < 0) {
+		printf("recv from netlink: %s\n", strerror(nll));
+		ret = -1;
+		goto cleanup;
+	}
+	nh = (struct nlmsghdr *)buf;
+	read_arp(nh, nll);
+cleanup:
+	close(sock);
+	return ret;
+}
+
+/* Function to keep track and update changes in route and arp table
+ * Give regular statistics of packets forwarded
+ */
+static int monitor_route(void)
+{
+	struct sockaddr_nl la, lr;
+	struct nlmsghdr *nh;
+	int nll, ret = 0;
+	const unsigned int nr_keys = 256;
+	int interval = 5;
+	unsigned int nr_cpus = bpf_num_possible_cpus();
+	__u64 values[nr_cpus], prev[nr_keys][nr_cpus];
+	__u32 key;
+	int i;
+	struct pollfd fds_route, fds_arp;
+
+	sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
+	if (sock < 0) {
+		printf("open netlink socket: %s\n", strerror(errno));
+		return -1;
+	}
+
+	fcntl(sock, F_SETFL, O_NONBLOCK);
+	bzero(&lr, sizeof(lr));
+	lr.nl_family = AF_NETLINK;
+	lr.nl_groups = RTMGRP_IPV6_ROUTE | RTMGRP_IPV4_ROUTE | RTMGRP_NOTIFY;
+	if (bind(sock, (struct sockaddr *)&lr, sizeof(lr)) < 0) {
+		printf("bind to netlink: %s\n", strerror(errno));
+		ret = -1;
+		goto cleanup;
+	}
+	fds_route.fd = sock;
+	fds_route.events = POLL_IN;
+
+	sock_arp = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
+	if (sock_arp < 0) {
+		printf("open netlink socket: %s\n", strerror(errno));
+		return -1;
+	}
+
+	fcntl(sock_arp, F_SETFL, O_NONBLOCK);
+	bzero(&la, sizeof(la));
+	la.nl_family = AF_NETLINK;
+	la.nl_groups = RTMGRP_NEIGH | RTMGRP_NOTIFY;
+	if (bind(sock_arp, (struct sockaddr *)&la, sizeof(la)) < 0) {
+		printf("bind to netlink: %s\n", strerror(errno));
+		ret = -1;
+		goto cleanup;
+	}
+	fds_arp.fd = sock_arp;
+	fds_arp.events = POLL_IN;
+
+	memset(prev, 0, sizeof(prev));
+	do {
+		signal(SIGINT, close_and_exit);
+		signal(SIGTERM, close_and_exit);
+
+		sleep(interval);
+		for (key = 0; key < nr_keys; key++) {
+			__u64 sum = 0;
+
+			assert(bpf_map_lookup_elem(map_fd[1], &key, values) == 0);
+			for (i = 0; i < nr_cpus; i++)
+				sum += (values[i] - prev[key][i]);
+			if (sum)
+				printf("proto %u: %10llu pkt/s\n",
+				       key, sum / interval);
+			memcpy(prev[key], values, sizeof(values));
+		}
+
+		bzero(buf, sizeof(buf));
+		if (poll(&fds_route, 1, 3) == POLL_IN) {
+			nll = recv_msg(lr, sock);
+			if (nll < 0) {
+				printf("recv from netlink: %s\n", strerror(nll));
+				ret = -1;
+				goto cleanup;
+			}
+
+			nh = (struct nlmsghdr *)buf;
+			printf("Routing table updated.\n");
+			read_route(nh, nll);
+		}
+		bzero(buf, sizeof(buf));
+		if (poll(&fds_arp, 1, 3) == POLL_IN) {
+			nll = recv_msg(la, sock_arp);
+			if (nll < 0) {
+				printf("recv from netlink: %s\n", strerror(nll));
+				ret = -1;
+				goto cleanup;
+			}
+
+			nh = (struct nlmsghdr *)buf;
+			read_arp(nh, nll);
+		}
+
+	} while (1);
+cleanup:
+	close(sock);
+	return ret;
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	int i = 1;
+	char **ifname_list;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	if (ac < 2) {
+		printf("usage: %s [-S] Interface name list\n", argv[0]);
+		return 1;
+	}
+	if (!strcmp(argv[1], "-S")) {
+		flags = XDP_FLAGS_SKB_MODE;
+		total_ifindex = ac - 2;
+		ifname_list = (argv + 2);
+	} else {
+		flags = 0;
+		total_ifindex = ac - 1;
+		ifname_list = (argv + 1);
+	}
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+	printf("\n**************loading bpf file*********************\n\n\n");
+	if (!prog_fd[0]) {
+		printf("load_bpf_file: %s\n", strerror(errno));
+		return 1;
+	}
+	ifindex_list = (int *)malloc(total_ifindex * sizeof(int *));
+	for (i = 0; i < total_ifindex; i++) {
+		ifindex_list[i] = if_nametoindex(ifname_list[i]);
+		if (!ifindex_list[i]) {
+			printf("Couldn't translate interface name: %s", strerror(errno));
+			return 1;
+		}
+	}
+	for (i = 0; i < total_ifindex; i++) {
+		if (set_link_xdp_fd(ifindex_list[i], prog_fd[0], flags) < 0) {
+			printf("link set xdp fd failed\n");
+			int recovery_index = i;
+
+			for (i = 0; i < recovery_index; i++)
+				set_link_xdp_fd(ifindex_list[i], -1, flags);
+
+			return 1;
+		}
+		printf("Attached to %d\n", ifindex_list[i]);
+	}
+	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
+
+	printf("*******************ROUTE TABLE*************************\n\n\n");
+	get_route_table(AF_INET);
+	printf("*******************ARP TABLE***************************\n\n\n");
+	get_arp_table(AF_INET);
+	if (monitor_route() < 0) {
+		printf("Error in receiving route update");
+		return 1;
+	}
+
+	return 0;
+}
-- 
1.7.1
