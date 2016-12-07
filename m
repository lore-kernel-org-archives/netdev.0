From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 4/4] bpf: xdp: Add XDP example for head adjustment
Date: Tue, 6 Dec 2016 21:31:54 -0800
Message-ID: <1481088714-54512-5-git-send-email-kafai@fb.com>
References: <1481088714-54512-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48471 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932115AbcLGFb7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 00:31:59 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uB75R7MT026705
        for <netdev@vger.kernel.org>; Tue, 6 Dec 2016 21:31:58 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2762bh0k15-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 21:31:58 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 77a680cebc3e11e69e730002c9521c9e-d9f9a50 for <netdev@vger.kernel.org>; Tue,
 06 Dec 2016 21:31:56 -0800
In-Reply-To: <1481088714-54512-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The XDP prog checks if the incoming packet matches any VIP:PORT
combination in the BPF hashmap.  If it is, it will encapsulate
the packet with a IPv4/v6 header as instructed by the value of
the BPF hashmap and then XDP_TX it out.

The VIP:PORT -> IP-Encap-Info can be specified by the cmd args
of the user prog.

Acked-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 samples/bpf/Makefile              |   4 +
 samples/bpf/bpf_helpers.h         |   2 +
 samples/bpf/bpf_load.c            |  94 ++++++++++++++
 samples/bpf/bpf_load.h            |   1 +
 samples/bpf/xdp1_user.c           |  93 --------------
 samples/bpf/xdp_tx_iptnl_common.h |  37 ++++++
 samples/bpf/xdp_tx_iptnl_kern.c   | 232 ++++++++++++++++++++++++++++++++++
 samples/bpf/xdp_tx_iptnl_user.c   | 253 ++++++++++++++++++++++++++++++++++++++
 8 files changed, 623 insertions(+), 93 deletions(-)
 create mode 100644 samples/bpf/xdp_tx_iptnl_common.h
 create mode 100644 samples/bpf/xdp_tx_iptnl_kern.c
 create mode 100644 samples/bpf/xdp_tx_iptnl_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 00cd3081c038..f78e0ef6ff10 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -33,6 +33,7 @@ hostprogs-y += trace_event
 hostprogs-y += sampleip
 hostprogs-y += tc_l2_redirect
 hostprogs-y += lwt_len_hist
+hostprogs-y += xdp_tx_iptnl
 
 test_lru_dist-objs := test_lru_dist.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
@@ -67,6 +68,7 @@ trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
 sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
 tc_l2_redirect-objs := bpf_load.o libbpf.o tc_l2_redirect_user.o
 lwt_len_hist-objs := bpf_load.o libbpf.o lwt_len_hist_user.o
+xdp_tx_iptnl-objs := bpf_load.o libbpf.o xdp_tx_iptnl_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -99,6 +101,7 @@ always += test_current_task_under_cgroup_kern.o
 always += trace_event_kern.o
 always += sampleip_kern.o
 always += lwt_len_hist_kern.o
+always += xdp_tx_iptnl_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
@@ -129,6 +132,7 @@ HOSTLOADLIBES_trace_event += -lelf
 HOSTLOADLIBES_sampleip += -lelf
 HOSTLOADLIBES_tc_l2_redirect += -l elf
 HOSTLOADLIBES_lwt_len_hist += -l elf
+HOSTLOADLIBES_xdp_tx_iptnl += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 8370a6e3839d..faaffe2e139a 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -57,6 +57,8 @@ static int (*bpf_skb_set_tunnel_opt)(void *ctx, void *md, int size) =
 	(void *) BPF_FUNC_skb_set_tunnel_opt;
 static unsigned long long (*bpf_get_prandom_u32)(void) =
 	(void *) BPF_FUNC_get_prandom_u32;
+static int (*bpf_xdp_adjust_head)(void *ctx, int offset) =
+	(void *) BPF_FUNC_xdp_adjust_head;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 49b45ccbe153..e30b6de94f2e 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -12,6 +12,10 @@
 #include <linux/bpf.h>
 #include <linux/filter.h>
 #include <linux/perf_event.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <sys/types.h>
+#include <sys/socket.h>
 #include <sys/syscall.h>
 #include <sys/ioctl.h>
 #include <sys/mman.h>
@@ -450,3 +454,93 @@ struct ksym *ksym_search(long key)
 	/* out of range. return _stext */
 	return &syms[0];
 }
+
+int set_link_xdp_fd(int ifindex, int fd)
+{
+	struct sockaddr_nl sa;
+	int sock, seq = 0, len, ret = -1;
+	char buf[4096];
+	struct nlattr *nla, *nla_xdp;
+	struct {
+		struct nlmsghdr  nh;
+		struct ifinfomsg ifinfo;
+		char             attrbuf[64];
+	} req;
+	struct nlmsghdr *nh;
+	struct nlmsgerr *err;
+
+	memset(&sa, 0, sizeof(sa));
+	sa.nl_family = AF_NETLINK;
+
+	sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
+	if (sock < 0) {
+		printf("open netlink socket: %s\n", strerror(errno));
+		return -1;
+	}
+
+	if (bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
+		printf("bind to netlink: %s\n", strerror(errno));
+		goto cleanup;
+	}
+
+	memset(&req, 0, sizeof(req));
+	req.nh.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.nh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
+	req.nh.nlmsg_type = RTM_SETLINK;
+	req.nh.nlmsg_pid = 0;
+	req.nh.nlmsg_seq = ++seq;
+	req.ifinfo.ifi_family = AF_UNSPEC;
+	req.ifinfo.ifi_index = ifindex;
+	nla = (struct nlattr *)(((char *)&req)
+				+ NLMSG_ALIGN(req.nh.nlmsg_len));
+	nla->nla_type = NLA_F_NESTED | 43/*IFLA_XDP*/;
+
+	nla_xdp = (struct nlattr *)((char *)nla + NLA_HDRLEN);
+	nla_xdp->nla_type = 1/*IFLA_XDP_FD*/;
+	nla_xdp->nla_len = NLA_HDRLEN + sizeof(int);
+	memcpy((char *)nla_xdp + NLA_HDRLEN, &fd, sizeof(fd));
+	nla->nla_len = NLA_HDRLEN + nla_xdp->nla_len;
+
+	req.nh.nlmsg_len += NLA_ALIGN(nla->nla_len);
+
+	if (send(sock, &req, req.nh.nlmsg_len, 0) < 0) {
+		printf("send to netlink: %s\n", strerror(errno));
+		goto cleanup;
+	}
+
+	len = recv(sock, buf, sizeof(buf), 0);
+	if (len < 0) {
+		printf("recv from netlink: %s\n", strerror(errno));
+		goto cleanup;
+	}
+
+	for (nh = (struct nlmsghdr *)buf; NLMSG_OK(nh, len);
+	     nh = NLMSG_NEXT(nh, len)) {
+		if (nh->nlmsg_pid != getpid()) {
+			printf("Wrong pid %d, expected %d\n",
+			       nh->nlmsg_pid, getpid());
+			goto cleanup;
+		}
+		if (nh->nlmsg_seq != seq) {
+			printf("Wrong seq %d, expected %d\n",
+			       nh->nlmsg_seq, seq);
+			goto cleanup;
+		}
+		switch (nh->nlmsg_type) {
+		case NLMSG_ERROR:
+			err = (struct nlmsgerr *)NLMSG_DATA(nh);
+			if (!err->error)
+				continue;
+			printf("nlmsg error %s\n", strerror(-err->error));
+			goto cleanup;
+		case NLMSG_DONE:
+			break;
+		}
+	}
+
+	ret = 0;
+
+cleanup:
+	close(sock);
+	return ret;
+}
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index 4adeeef53ad6..fb46a421ab41 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -31,4 +31,5 @@ struct ksym {
 
 int load_kallsyms(void);
 struct ksym *ksym_search(long key);
+int set_link_xdp_fd(int ifindex, int fd);
 #endif
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index 2b2150d6d6f7..5f040a0d7712 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -5,111 +5,18 @@
  * License as published by the Free Software Foundation.
  */
 #include <linux/bpf.h>
-#include <linux/netlink.h>
-#include <linux/rtnetlink.h>
 #include <assert.h>
 #include <errno.h>
 #include <signal.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
-#include <sys/socket.h>
 #include <unistd.h>
 
 #include "bpf_load.h"
 #include "bpf_util.h"
 #include "libbpf.h"
 
-static int set_link_xdp_fd(int ifindex, int fd)
-{
-	struct sockaddr_nl sa;
-	int sock, seq = 0, len, ret = -1;
-	char buf[4096];
-	struct nlattr *nla, *nla_xdp;
-	struct {
-		struct nlmsghdr  nh;
-		struct ifinfomsg ifinfo;
-		char             attrbuf[64];
-	} req;
-	struct nlmsghdr *nh;
-	struct nlmsgerr *err;
-
-	memset(&sa, 0, sizeof(sa));
-	sa.nl_family = AF_NETLINK;
-
-	sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
-	if (sock < 0) {
-		printf("open netlink socket: %s\n", strerror(errno));
-		return -1;
-	}
-
-	if (bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
-		printf("bind to netlink: %s\n", strerror(errno));
-		goto cleanup;
-	}
-
-	memset(&req, 0, sizeof(req));
-	req.nh.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-	req.nh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
-	req.nh.nlmsg_type = RTM_SETLINK;
-	req.nh.nlmsg_pid = 0;
-	req.nh.nlmsg_seq = ++seq;
-	req.ifinfo.ifi_family = AF_UNSPEC;
-	req.ifinfo.ifi_index = ifindex;
-	nla = (struct nlattr *)(((char *)&req)
-				+ NLMSG_ALIGN(req.nh.nlmsg_len));
-	nla->nla_type = NLA_F_NESTED | 43/*IFLA_XDP*/;
-
-	nla_xdp = (struct nlattr *)((char *)nla + NLA_HDRLEN);
-	nla_xdp->nla_type = 1/*IFLA_XDP_FD*/;
-	nla_xdp->nla_len = NLA_HDRLEN + sizeof(int);
-	memcpy((char *)nla_xdp + NLA_HDRLEN, &fd, sizeof(fd));
-	nla->nla_len = NLA_HDRLEN + nla_xdp->nla_len;
-
-	req.nh.nlmsg_len += NLA_ALIGN(nla->nla_len);
-
-	if (send(sock, &req, req.nh.nlmsg_len, 0) < 0) {
-		printf("send to netlink: %s\n", strerror(errno));
-		goto cleanup;
-	}
-
-	len = recv(sock, buf, sizeof(buf), 0);
-	if (len < 0) {
-		printf("recv from netlink: %s\n", strerror(errno));
-		goto cleanup;
-	}
-
-	for (nh = (struct nlmsghdr *)buf; NLMSG_OK(nh, len);
-	     nh = NLMSG_NEXT(nh, len)) {
-		if (nh->nlmsg_pid != getpid()) {
-			printf("Wrong pid %d, expected %d\n",
-			       nh->nlmsg_pid, getpid());
-			goto cleanup;
-		}
-		if (nh->nlmsg_seq != seq) {
-			printf("Wrong seq %d, expected %d\n",
-			       nh->nlmsg_seq, seq);
-			goto cleanup;
-		}
-		switch (nh->nlmsg_type) {
-		case NLMSG_ERROR:
-			err = (struct nlmsgerr *)NLMSG_DATA(nh);
-			if (!err->error)
-				continue;
-			printf("nlmsg error %s\n", strerror(-err->error));
-			goto cleanup;
-		case NLMSG_DONE:
-			break;
-		}
-	}
-
-	ret = 0;
-
-cleanup:
-	close(sock);
-	return ret;
-}
-
 static int ifindex;
 
 static void int_exit(int sig)
diff --git a/samples/bpf/xdp_tx_iptnl_common.h b/samples/bpf/xdp_tx_iptnl_common.h
new file mode 100644
index 000000000000..dd12cc35110f
--- /dev/null
+++ b/samples/bpf/xdp_tx_iptnl_common.h
@@ -0,0 +1,37 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _SAMPLES_BPF_XDP_TX_IPTNL_COMMON_H
+#define _SAMPLES_BPF_XDP_TX_IPTNL_COMMON_H
+
+#include <linux/types.h>
+
+#define MAX_IPTNL_ENTRIES 256U
+
+struct vip {
+	union {
+		__u32 v6[4];
+		__u32 v4;
+	} daddr;
+	__u16 dport;
+	__u16 family;
+	__u8 protocol;
+};
+
+struct iptnl_info {
+	union {
+		__u32 v6[4];
+		__u32 v4;
+	} saddr;
+	union {
+		__u32 v6[4];
+		__u32 v4;
+	} daddr;
+	__u16 family;
+	__u8 dmac[6];
+};
+
+#endif
diff --git a/samples/bpf/xdp_tx_iptnl_kern.c b/samples/bpf/xdp_tx_iptnl_kern.c
new file mode 100644
index 000000000000..d88c064175aa
--- /dev/null
+++ b/samples/bpf/xdp_tx_iptnl_kern.c
@@ -0,0 +1,232 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <uapi/linux/bpf.h>
+#include <linux/in.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <linux/if_vlan.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include "bpf_helpers.h"
+#include "xdp_tx_iptnl_common.h"
+
+struct bpf_map_def SEC("maps") rxcnt = {
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
+	.key_size = sizeof(__u32),
+	.value_size = sizeof(__u64),
+	.max_entries = 256,
+};
+
+struct bpf_map_def SEC("maps") vip2tnl = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct vip),
+	.value_size = sizeof(struct iptnl_info),
+	.max_entries = MAX_IPTNL_ENTRIES,
+};
+
+static __always_inline void count_tx(u32 protocol)
+{
+	u64 *rxcnt_count;
+
+	rxcnt_count = bpf_map_lookup_elem(&rxcnt, &protocol);
+	if (rxcnt_count)
+		*rxcnt_count += 1;
+}
+
+static __always_inline int get_dport(void *trans_data, void *data_end,
+				     u8 protocol)
+{
+	struct tcphdr *th;
+	struct udphdr *uh;
+
+	switch (protocol) {
+	case IPPROTO_TCP:
+		th = (struct tcphdr *)trans_data;
+		if (th + 1 > data_end)
+			return -1;
+		return th->dest;
+	case IPPROTO_UDP:
+		uh = (struct udphdr *)trans_data;
+		if (uh + 1 > data_end)
+			return -1;
+		return uh->dest;
+	default:
+		return 0;
+	}
+}
+
+static __always_inline void set_ethhdr(struct ethhdr *new_eth,
+				       const struct ethhdr *old_eth,
+				       const struct iptnl_info *tnl,
+				       __be16 h_proto)
+{
+	memcpy(new_eth->h_source, old_eth->h_dest, sizeof(new_eth->h_source));
+	memcpy(new_eth->h_dest, tnl->dmac, sizeof(new_eth->h_dest));
+	new_eth->h_proto = h_proto;
+}
+
+static __always_inline int handle_ipv4(struct xdp_md *xdp)
+{
+	void *data_end = (void *)(long)xdp->data_end;
+	void *data = (void *)(long)xdp->data;
+	struct iptnl_info *tnl;
+	struct ethhdr *new_eth;
+	struct ethhdr *old_eth;
+	struct iphdr *iph = data + sizeof(struct ethhdr);
+	u16 *next_iph_u16;
+	u16 payload_len;
+	struct vip vip = {};
+	int dport;
+	u32 csum = 0;
+	int i;
+
+	if (iph + 1 > data_end)
+		return XDP_DROP;
+
+	dport = get_dport(iph + 1, data_end, iph->protocol);
+	if (dport == -1)
+		return XDP_DROP;
+
+	vip.protocol = iph->protocol;
+	vip.family = AF_INET;
+	vip.daddr.v4 = iph->daddr;
+	vip.dport = dport;
+	payload_len = ntohs(iph->tot_len);
+
+	tnl = bpf_map_lookup_elem(&vip2tnl, &vip);
+	/* It only does v4-in-v4 */
+	if (!tnl || tnl->family != AF_INET)
+		return XDP_PASS;
+
+	/* The vip key is found.  Add an IP header and send it out */
+
+	if (bpf_xdp_adjust_head(xdp, 0 - (int)sizeof(struct iphdr)))
+		return XDP_DROP;
+
+	data = (void *)(long)xdp->data;
+	data_end = (void *)(long)xdp->data_end;
+
+	new_eth = data;
+	iph = data + sizeof(*new_eth);
+	old_eth = data + sizeof(*iph);
+
+	if (new_eth + 1 > data_end ||
+	    old_eth + 1 > data_end ||
+	    iph + 1 > data_end)
+		return XDP_DROP;
+
+	set_ethhdr(new_eth, old_eth, tnl, htons(ETH_P_IP));
+
+	iph->version = 4;
+	iph->ihl = sizeof(*iph) >> 2;
+	iph->frag_off =	0;
+	iph->protocol = IPPROTO_IPIP;
+	iph->check = 0;
+	iph->tos = 0;
+	iph->tot_len = htons(payload_len + sizeof(*iph));
+	iph->daddr = tnl->daddr.v4;
+	iph->saddr = tnl->saddr.v4;
+	iph->ttl = 8;
+
+	next_iph_u16 = (u16 *)iph;
+#pragma clang loop unroll(full)
+	for (i = 0; i < sizeof(*iph) >> 1; i++)
+		csum += *next_iph_u16++;
+
+	iph->check = ~((csum & 0xffff) + (csum >> 16));
+
+	count_tx(vip.protocol);
+
+	return XDP_TX;
+}
+
+static __always_inline int handle_ipv6(struct xdp_md *xdp)
+{
+	void *data_end = (void *)(long)xdp->data_end;
+	void *data = (void *)(long)xdp->data;
+	struct iptnl_info *tnl;
+	struct ethhdr *new_eth;
+	struct ethhdr *old_eth;
+	struct ipv6hdr *ip6h = data + sizeof(struct ethhdr);
+	__u16 payload_len;
+	struct vip vip = {};
+	int dport;
+
+	if (ip6h + 1 > data_end)
+		return XDP_DROP;
+
+	dport = get_dport(ip6h + 1, data_end, ip6h->nexthdr);
+	if (dport == -1)
+		return XDP_DROP;
+
+	vip.protocol = ip6h->nexthdr;
+	vip.family = AF_INET6;
+	memcpy(vip.daddr.v6, ip6h->daddr.s6_addr32, sizeof(vip.daddr));
+	vip.dport = dport;
+	payload_len = ip6h->payload_len;
+
+	tnl = bpf_map_lookup_elem(&vip2tnl, &vip);
+	/* It only does v6-in-v6 */
+	if (!tnl || tnl->family != AF_INET6)
+		return XDP_PASS;
+
+	/* The vip key is found.  Add an IP header and send it out */
+
+	if (bpf_xdp_adjust_head(xdp, 0 - (int)sizeof(struct ipv6hdr)))
+		return XDP_DROP;
+
+	data = (void *)(long)xdp->data;
+	data_end = (void *)(long)xdp->data_end;
+
+	new_eth = data;
+	ip6h = data + sizeof(*new_eth);
+	old_eth = data + sizeof(*ip6h);
+
+	if (new_eth + 1 > data_end ||
+	    old_eth + 1 > data_end ||
+	    ip6h + 1 > data_end)
+		return XDP_DROP;
+
+	set_ethhdr(new_eth, old_eth, tnl, htons(ETH_P_IPV6));
+
+	ip6h->version = 6;
+	ip6h->priority = 0;
+	memset(ip6h->flow_lbl, 0, sizeof(ip6h->flow_lbl));
+	ip6h->payload_len = htons(ntohs(payload_len) + sizeof(*ip6h));
+	ip6h->nexthdr = IPPROTO_IPV6;
+	ip6h->hop_limit = 8;
+	memcpy(ip6h->saddr.s6_addr32, tnl->saddr.v6, sizeof(tnl->saddr.v6));
+	memcpy(ip6h->daddr.s6_addr32, tnl->daddr.v6, sizeof(tnl->daddr.v6));
+
+	count_tx(vip.protocol);
+
+	return XDP_TX;
+}
+
+SEC("xdp_tx_iptnl")
+int _xdp_tx_iptnl(struct xdp_md *xdp)
+{
+	void *data_end = (void *)(long)xdp->data_end;
+	void *data = (void *)(long)xdp->data;
+	struct ethhdr *eth = data;
+	__u16 h_proto;
+
+	if (eth + 1 > data_end)
+		return XDP_DROP;
+
+	h_proto = eth->h_proto;
+
+	if (h_proto == htons(ETH_P_IP))
+		return handle_ipv4(xdp);
+	else if (h_proto == htons(ETH_P_IPV6))
+
+		return handle_ipv6(xdp);
+	else
+		return XDP_PASS;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/xdp_tx_iptnl_user.c b/samples/bpf/xdp_tx_iptnl_user.c
new file mode 100644
index 000000000000..9aeef7579af4
--- /dev/null
+++ b/samples/bpf/xdp_tx_iptnl_user.c
@@ -0,0 +1,253 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/bpf.h>
+#include <assert.h>
+#include <errno.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/resource.h>
+#include <arpa/inet.h>
+#include <netinet/ether.h>
+#include <unistd.h>
+#include <time.h>
+#include "bpf_load.h"
+#include "libbpf.h"
+#include "bpf_util.h"
+#include "xdp_tx_iptnl_common.h"
+
+#define STATS_INTERVAL_S 2U
+
+static int ifindex = -1;
+
+static void int_exit(int sig)
+{
+	if (ifindex > -1)
+		set_link_xdp_fd(ifindex, -1);
+	exit(0);
+}
+
+/* simple per-protocol drop counter
+ */
+static void poll_stats(unsigned int kill_after_s)
+{
+	const unsigned int nr_protos = 256;
+	unsigned int nr_cpus = bpf_num_possible_cpus();
+	time_t started_at = time(NULL);
+	__u64 values[nr_cpus], prev[nr_protos][nr_cpus];
+	__u32 proto;
+	int i;
+
+	memset(prev, 0, sizeof(prev));
+
+	while (!kill_after_s || time(NULL) - started_at <= kill_after_s) {
+		sleep(STATS_INTERVAL_S);
+
+		for (proto = 0; proto < nr_protos; proto++) {
+			__u64 sum = 0;
+
+			assert(bpf_lookup_elem(map_fd[0], &proto, values) == 0);
+			for (i = 0; i < nr_cpus; i++)
+				sum += (values[i] - prev[proto][i]);
+
+			if (sum)
+				printf("proto %u: sum:%10llu pkts, rate:%10llu pkts/s\n",
+				       proto, sum, sum / STATS_INTERVAL_S);
+			memcpy(prev[proto], values, sizeof(values));
+		}
+	}
+}
+
+static void usage(const char *cmd)
+{
+	printf("Usage: %s [...]\n", cmd);
+	printf("    -i <ifindex> Interface Index\n");
+	printf("    -a <vip-service-address> IPv4 or IPv6\n");
+	printf("    -p <vip-service-port> A port range (e.g. 433-444) is also allowed\n");
+	printf("    -s <source-ip> Used in the IPTunnel Header\n");
+	printf("    -d <dest-ip> Used in the IPTunnel header>\n");
+	printf("    -m <dest-MAC> Used in sending the IP Tunneled pkt>\n");
+	printf("    -T <stop-after-X-seconds> Default: 0 (forever)\n");
+	printf("    -P <IP-Protocol> Default is TCP\n");
+	printf("    -h Display this help\n");
+}
+
+static int parse_ipstr(const char *ipstr, unsigned int *addr)
+{
+	if (inet_pton(AF_INET6, ipstr, addr) == 1) {
+		return AF_INET6;
+	} else if (inet_pton(AF_INET, ipstr, addr) == 1) {
+		addr[1] = addr[2] = addr[3] = 0;
+		return AF_INET;
+	}
+
+	fprintf(stderr, "%s is an invalid IP\n", ipstr);
+	return AF_UNSPEC;
+}
+
+static int parse_ports(const char *port_str, int *min_port, int *max_port)
+{
+	char *end;
+	long tmp_min_port;
+	long tmp_max_port;
+
+	tmp_min_port = strtol(optarg, &end, 10);
+	if (tmp_min_port < 1 || tmp_min_port > 65535) {
+		fprintf(stderr, "Invalid port(s):%s\n", optarg);
+		return 1;
+	}
+
+	if (*end == '-') {
+		end++;
+		tmp_max_port = strtol(end, NULL, 10);
+		if (tmp_max_port < 1 || tmp_max_port > 65535) {
+			fprintf(stderr, "Invalid port(s):%s\n", optarg);
+			return 1;
+		}
+	} else {
+		tmp_max_port = tmp_min_port;
+	}
+
+	if (tmp_min_port > tmp_max_port) {
+		fprintf(stderr, "Invalid port(s):%s\n", optarg);
+		return 1;
+	}
+
+	if (tmp_max_port - tmp_min_port + 1 > MAX_IPTNL_ENTRIES) {
+		fprintf(stderr, "Port range (%s) is larger than %u\n",
+			port_str, MAX_IPTNL_ENTRIES);
+		return 1;
+	}
+	*min_port = tmp_min_port;
+	*max_port = tmp_max_port;
+
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	unsigned char opt_flags[256] = {};
+	unsigned int kill_after_s = 0;
+	const char *optstr = "i:a:p:s:d:m:T:P:";
+	int min_port = 0, max_port = 0;
+	struct iptnl_info tnl = {};
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	struct vip vip = {};
+	char filename[256];
+	int opt;
+	int i;
+
+	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
+		perror("setrlimit(RLIMIT_MEMLOCK, RLIM_INFINITY)");
+		return 1;
+	}
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	if (!prog_fd[0]) {
+		printf("load_bpf_file: %s\n", strerror(errno));
+		return 1;
+	}
+
+	tnl.family = AF_UNSPEC;
+	vip.protocol = IPPROTO_TCP;
+
+	for (i = 0; i < strlen(optstr); i++)
+		if ('a' <= optstr[i] && optstr[i] <= 'z')
+			opt_flags[(unsigned char)optstr[i]] = 1;
+
+	while ((opt = getopt(argc, argv, optstr)) != -1) {
+		unsigned short family;
+		unsigned int *v6;
+
+		switch (opt) {
+		case 'i':
+			ifindex = atoi(optarg);
+			break;
+		case 'a':
+			vip.family = parse_ipstr(optarg, vip.daddr.v6);
+			if (vip.family == AF_UNSPEC)
+				return 1;
+			break;
+		case 'p':
+			if (parse_ports(optarg, &min_port, &max_port))
+				return 1;
+			break;
+		case 'P':
+			vip.protocol = atoi(optarg);
+			break;
+		case 's':
+		case 'd':
+			if (opt == 's')
+				v6 = tnl.saddr.v6;
+			else
+				v6 = tnl.daddr.v6;
+
+			family = parse_ipstr(optarg, v6);
+			if (family == AF_UNSPEC)
+				return 1;
+			if (tnl.family == AF_UNSPEC) {
+				tnl.family = family;
+			} else if (tnl.family != family) {
+				fprintf(stderr,
+					"The IP version of the src and dst addresses used in the IP encapsulation does not match\n");
+				return 1;
+			}
+			break;
+		case 'm':
+			if (!ether_aton_r(optarg,
+					  (struct ether_addr *)tnl.dmac)) {
+				fprintf(stderr, "Invalid mac address:%s\n",
+					optarg);
+				return 1;
+			}
+			break;
+		case 'T':
+			kill_after_s = atoi(optarg);
+			break;
+		default:
+			usage(argv[0]);
+			return 1;
+		}
+		opt_flags[opt] = 0;
+	}
+
+	for (i = 0; i < strlen(optstr); i++) {
+		if (opt_flags[(unsigned int)optstr[i]]) {
+			fprintf(stderr, "Missing argument -%c\n", optstr[i]);
+			usage(argv[0]);
+			return 1;
+		}
+	}
+
+	signal(SIGINT, int_exit);
+
+	while (min_port <= max_port) {
+		vip.dport = htons(min_port++);
+		if (bpf_update_elem(map_fd[1], &vip, &tnl, BPF_NOEXIST)) {
+			perror("bpf_update_elem(&vip2tnl)");
+			return 1;
+		}
+	}
+
+	if (set_link_xdp_fd(ifindex, prog_fd[0]) < 0) {
+		printf("link set xdp fd failed\n");
+		return 1;
+	}
+
+	poll_stats(kill_after_s);
+
+	set_link_xdp_fd(ifindex, -1);
+
+	return 0;
+}
-- 
2.5.1
