From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [RFC PATCH v2 5/5] Add sample for adding simple drop program to link
Date: Thu,  7 Apr 2016 21:48:50 -0700
Message-ID: <1460090930-11219-5-git-send-email-bblanco@plumgrid.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	ogerlitz@mellanox.com, daniel@iogearbox.net, brouer@redhat.com,
	eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35058 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818AbcDHEtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 00:49:11 -0400
Received: by mail-pf0-f174.google.com with SMTP id n1so69038398pfn.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 21:49:10 -0700 (PDT)
In-Reply-To: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sample program that only drops packets at the
BPF_PROG_TYPE_PHYS_DEV hook of a link. With the drop-only program,
observed single core rate is ~19.5Mpps.

Other tests were run, for instance without the dropcnt increment or
without reading from the packet header, the packet rate was mostly
unchanged.

$ perf record -a samples/bpf/netdrvx1 $(</sys/class/net/eth0/ifindex)
proto 17:   19596362 drops/s

./pktgen_sample03_burst_single_flow.sh -i $DEV -d $IP -m $MAC -t 4
Running... ctrl^C to stop
Device: eth4@0
Result: OK: 7873817(c7872245+d1572) usec, 38801823 (60byte,0frags)
  4927955pps 2365Mb/sec (2365418400bps) errors: 0
Device: eth4@1
Result: OK: 7873817(c7872123+d1693) usec, 38587342 (60byte,0frags)
  4900715pps 2352Mb/sec (2352343200bps) errors: 0
Device: eth4@2
Result: OK: 7873817(c7870929+d2888) usec, 38718848 (60byte,0frags)
  4917417pps 2360Mb/sec (2360360160bps) errors: 0
Device: eth4@3
Result: OK: 7873818(c7872193+d1625) usec, 38796346 (60byte,0frags)
  4927259pps 2365Mb/sec (2365084320bps) errors: 0

perf report --no-children:
 29.48%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_process_rx_cq
 18.17%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_alloc_frags
  8.19%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_free_frag
  5.35%  ksoftirqd/6  [kernel.vmlinux]  [k] get_page_from_freelist
  2.92%  ksoftirqd/6  [kernel.vmlinux]  [k] free_pages_prepare
  2.90%  ksoftirqd/6  [mlx4_en]         [k] mlx4_call_bpf
  2.72%  ksoftirqd/6  [fjes]            [k] 0x000000000000af66
  2.37%  ksoftirqd/6  [kernel.vmlinux]  [k] swiotlb_sync_single_for_cpu
  1.92%  ksoftirqd/6  [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
  1.83%  ksoftirqd/6  [kernel.vmlinux]  [k] free_one_page
  1.70%  ksoftirqd/6  [kernel.vmlinux]  [k] swiotlb_sync_single
  1.69%  ksoftirqd/6  [kernel.vmlinux]  [k] bpf_map_lookup_elem
  1.33%  swapper      [kernel.vmlinux]  [k] intel_idle
  1.32%  ksoftirqd/6  [fjes]            [k] 0x000000000000af90
  1.21%  ksoftirqd/6  [kernel.vmlinux]  [k] sk_load_byte_positive_offset
  1.07%  ksoftirqd/6  [kernel.vmlinux]  [k] __alloc_pages_nodemask
  0.89%  ksoftirqd/6  [kernel.vmlinux]  [k] __rmqueue
  0.84%  ksoftirqd/6  [mlx4_en]         [k] mlx4_alloc_pages.isra.23
  0.79%  ksoftirqd/6  [kernel.vmlinux]  [k] net_rx_action

machine specs:
 receiver - Intel E5-1630 v3 @ 3.70GHz
 sender - Intel E5645 @ 2.40GHz
 Mellanox ConnectX-3 @40G

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 samples/bpf/Makefile        |   4 ++
 samples/bpf/bpf_load.c      |   8 +++
 samples/bpf/netdrvx1_kern.c |  26 ++++++++
 samples/bpf/netdrvx1_user.c | 155 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 193 insertions(+)
 create mode 100644 samples/bpf/netdrvx1_kern.c
 create mode 100644 samples/bpf/netdrvx1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 9959771..19bb926 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -20,6 +20,7 @@ hostprogs-y += offwaketime
 hostprogs-y += spintest
 hostprogs-y += map_perf_test
 hostprogs-y += test_overhead
+hostprogs-y += netdrvx1
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -40,6 +41,7 @@ offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
 spintest-objs := bpf_load.o libbpf.o spintest_user.o
 map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
+netdrvx1-objs := bpf_load.o libbpf.o netdrvx1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -60,6 +62,7 @@ always += spintest_kern.o
 always += map_perf_test_kern.o
 always += test_overhead_tp_kern.o
 always += test_overhead_kprobe_kern.o
+always += netdrvx1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -80,6 +83,7 @@ HOSTLOADLIBES_offwaketime += -lelf
 HOSTLOADLIBES_spintest += -lelf
 HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
+HOSTLOADLIBES_netdrvx1 += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 022af71..c7b2245 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -50,6 +50,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_kprobe = strncmp(event, "kprobe/", 7) == 0;
 	bool is_kretprobe = strncmp(event, "kretprobe/", 10) == 0;
 	bool is_tracepoint = strncmp(event, "tracepoint/", 11) == 0;
+	bool is_phys_dev = strncmp(event, "phys_dev", 8) == 0;
 	enum bpf_prog_type prog_type;
 	char buf[256];
 	int fd, efd, err, id;
@@ -66,6 +67,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_KPROBE;
 	} else if (is_tracepoint) {
 		prog_type = BPF_PROG_TYPE_TRACEPOINT;
+	} else if (is_phys_dev) {
+		prog_type = BPF_PROG_TYPE_PHYS_DEV;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -79,6 +82,9 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
+	if (is_phys_dev)
+		return 0;
+
 	if (is_socket) {
 		event += 6;
 		if (*event != '/')
@@ -319,6 +325,7 @@ int load_bpf_file(char *path)
 			if (memcmp(shname_prog, "kprobe/", 7) == 0 ||
 			    memcmp(shname_prog, "kretprobe/", 10) == 0 ||
 			    memcmp(shname_prog, "tracepoint/", 11) == 0 ||
+			    memcmp(shname_prog, "phys_dev", 8) == 0 ||
 			    memcmp(shname_prog, "socket", 6) == 0)
 				load_and_attach(shname_prog, insns, data_prog->d_size);
 		}
@@ -336,6 +343,7 @@ int load_bpf_file(char *path)
 		if (memcmp(shname, "kprobe/", 7) == 0 ||
 		    memcmp(shname, "kretprobe/", 10) == 0 ||
 		    memcmp(shname, "tracepoint/", 11) == 0 ||
+		    memcmp(shname, "phys_dev", 8) == 0 ||
 		    memcmp(shname, "socket", 6) == 0)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
diff --git a/samples/bpf/netdrvx1_kern.c b/samples/bpf/netdrvx1_kern.c
new file mode 100644
index 0000000..849802d
--- /dev/null
+++ b/samples/bpf/netdrvx1_kern.c
@@ -0,0 +1,26 @@
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/if_packet.h>
+#include <uapi/linux/ip.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") dropcnt = {
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 256,
+};
+
+SEC("phys_dev1")
+int bpf_prog1(struct bpf_phys_dev_md *ctx)
+{
+	int index = load_byte(ctx, ETH_HLEN + offsetof(struct iphdr, protocol));
+	long *value;
+
+	value = bpf_map_lookup_elem(&dropcnt, &index);
+	if (value)
+		*value += 1;
+
+	return BPF_PHYS_DEV_DROP;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/netdrvx1_user.c b/samples/bpf/netdrvx1_user.c
new file mode 100644
index 0000000..9e6ec9a
--- /dev/null
+++ b/samples/bpf/netdrvx1_user.c
@@ -0,0 +1,155 @@
+#include <linux/bpf.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <assert.h>
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <unistd.h>
+#include "bpf_load.h"
+#include "libbpf.h"
+
+static int set_link_bpf_fd(int ifindex, int fd)
+{
+	struct sockaddr_nl sa;
+	int sock, seq = 0, len, ret = -1;
+	char buf[4096];
+	struct rtattr *rta;
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
+	rta = (struct rtattr *)(((char *) &req)
+				+ NLMSG_ALIGN(req.nh.nlmsg_len));
+	rta->rta_type = 42/*IFLA_BPF_FD*/;
+	rta->rta_len = RTA_LENGTH(sizeof(unsigned int));
+	req.nh.nlmsg_len = NLMSG_ALIGN(req.nh.nlmsg_len)
+		+ RTA_LENGTH(sizeof(fd));
+	memcpy(RTA_DATA(rta), &fd, sizeof(fd));
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
+
+/* simple per-protocol drop counter
+ */
+static void poll_stats(int secs)
+{
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	__u64 values[nr_cpus];
+	__u32 key;
+	int i;
+
+	sleep(secs);
+
+	for (key = 0; key < 256; key++) {
+		__u64 sum = 0;
+
+		assert(bpf_lookup_elem(map_fd[0], &key, values) == 0);
+		for (i = 0; i < nr_cpus; i++)
+			sum += values[i];
+		if (sum)
+			printf("proto %u: %10llu drops/s\n", key, sum/secs);
+	}
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	int ifindex;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (ac != 2) {
+		printf("usage: %s IFINDEX\n", argv[0]);
+		return 1;
+	}
+
+	ifindex = strtoul(argv[1], NULL, 0);
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
+	if (set_link_bpf_fd(ifindex, prog_fd[0]) < 0) {
+		printf("link set bpf fd failed\n");
+		return 1;
+	}
+
+	poll_stats(5);
+
+	set_link_bpf_fd(ifindex, -1);
+
+	return 0;
+}
-- 
2.8.0
