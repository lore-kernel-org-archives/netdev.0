From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v3 4/4] cgroup: bpf: Add an example to do cgroup checking in BPF
Date: Thu, 30 Jun 2016 10:28:45 -0700
Message-ID: <1467307725-1948415-5-git-send-email-kafai@fb.com>
References: <1467307725-1948415-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tejun Heo <tj@kernel.org>, <kernel-team@fb.com>
To: <cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53711 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751597AbcF3R3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 13:29:07 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5UHLwLq027213
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 10:29:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23w6k6gebx-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 10:29:03 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 232722f23ee811e6a4170002c99293a0-5bf9af0 for <netdev@vger.kernel.org>;	Thu,
 30 Jun 2016 10:29:02 -0700
In-Reply-To: <1467307725-1948415-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

test_cgrp2_array_pin.c:
A userland program that creates a bpf_map (BPF_MAP_TYPE_GROUP_ARRAY),
pouplates/updates it with a cgroup2's backed fd and pins it to a
bpf-fs's file.  The pinned file can be loaded by tc and then used
by the bpf prog later.  This program can also update an existing pinned
array and it could be useful for debugging/testing purpose.

test_cgrp2_tc_kern.c:
A bpf prog which should be loaded by tc.  It is to demonstrate
the usage of bpf_skb_in_cgroup.

test_cgrp2_tc.sh:
A script that glues the test_cgrp2_array_pin.c and
test_cgrp2_tc_kern.c together.  The idea is like:
1. Load the test_cgrp2_tc_kern.o by tc
2. Use test_cgrp2_array_pin.c to populate a BPF_MAP_TYPE_CGROUP_ARRAY
   with a cgroup fd
3. Do a 'ping -6 ff02::1%ve' to ensure the packet has been
   dropped because of a match on the cgroup

Most of the lines in test_cgrp2_tc.sh is the boilerplate
to setup the cgroup/bpf-fs/net-devices/netns...etc.  It is
not bulletproof on errors but should work well enough and
give enough debug info if things did not go well.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Tejun Heo <tj@kernel.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile               |   3 +
 samples/bpf/bpf_helpers.h          |   2 +
 samples/bpf/test_cgrp2_array_pin.c | 109 ++++++++++++++++++++++
 samples/bpf/test_cgrp2_tc.sh       | 184 +++++++++++++++++++++++++++++++++++++
 samples/bpf/test_cgrp2_tc_kern.c   |  69 ++++++++++++++
 5 files changed, 367 insertions(+)
 create mode 100644 samples/bpf/test_cgrp2_array_pin.c
 create mode 100755 samples/bpf/test_cgrp2_tc.sh
 create mode 100644 samples/bpf/test_cgrp2_tc_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 0bf2478..a98b780 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -20,6 +20,7 @@ hostprogs-y += offwaketime
 hostprogs-y += spintest
 hostprogs-y += map_perf_test
 hostprogs-y += test_overhead
+hostprogs-y += test_cgrp2_array_pin
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -40,6 +41,7 @@ offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
 spintest-objs := bpf_load.o libbpf.o spintest_user.o
 map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
+test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -61,6 +63,7 @@ always += map_perf_test_kern.o
 always += test_overhead_tp_kern.o
 always += test_overhead_kprobe_kern.o
 always += parse_varlen.o parse_simple.o parse_ldabs.o
+always += test_cgrp2_tc_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 7904a2a..84e3fd9 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -70,6 +70,8 @@ static int (*bpf_l3_csum_replace)(void *ctx, int off, int from, int to, int flag
 	(void *) BPF_FUNC_l3_csum_replace;
 static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flags) =
 	(void *) BPF_FUNC_l4_csum_replace;
+static int (*bpf_skb_in_cgroup)(void *ctx, void *map, int index) =
+	(void *) BPF_FUNC_skb_in_cgroup;
 
 #if defined(__x86_64__)
 
diff --git a/samples/bpf/test_cgrp2_array_pin.c b/samples/bpf/test_cgrp2_array_pin.c
new file mode 100644
index 0000000..70e86f7
--- /dev/null
+++ b/samples/bpf/test_cgrp2_array_pin.c
@@ -0,0 +1,109 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/unistd.h>
+#include <linux/bpf.h>
+
+#include <stdio.h>
+#include <stdint.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+#include <fcntl.h>
+
+#include "libbpf.h"
+
+static void usage(void)
+{
+	printf("Usage: test_cgrp2_array_pin [...]\n");
+	printf("       -F <file>   File to pin an BPF cgroup array\n");
+	printf("       -U <file>   Update an already pinned BPF cgroup array\n");
+	printf("       -v <value>  Full path of the cgroup2\n");
+	printf("       -h          Display this help\n");
+}
+
+int main(int argc, char **argv)
+{
+	const char *pinned_file = NULL, *cg2 = NULL;
+	int create_array = 1;
+	int array_key = 0;
+	int array_fd = -1;
+	int cg2_fd = -1;
+	int ret = -1;
+	int opt;
+
+	while ((opt = getopt(argc, argv, "F:U:v:")) != -1) {
+		switch (opt) {
+		/* General args */
+		case 'F':
+			pinned_file = optarg;
+			break;
+		case 'U':
+			pinned_file = optarg;
+			create_array = 0;
+			break;
+		case 'v':
+			cg2 = optarg;
+			break;
+		default:
+			usage();
+			goto out;
+		}
+	}
+
+	if (!cg2 || !pinned_file) {
+		usage();
+		goto out;
+	}
+
+	cg2_fd = open(cg2, O_RDONLY);
+	if (cg2_fd < 0) {
+		fprintf(stderr, "open(%s,...): %s(%d)\n",
+			cg2, strerror(errno), errno);
+		goto out;
+	}
+
+	if (create_array) {
+		array_fd = bpf_create_map(BPF_MAP_TYPE_CGROUP_ARRAY,
+					  sizeof(uint32_t), sizeof(uint32_t),
+					  1, 0);
+		if (array_fd < 0) {
+			fprintf(stderr,
+				"bpf_create_map(BPF_MAP_TYPE_CGROUP_ARRAY,...): %s(%d)\n",
+				strerror(errno), errno);
+			goto out;
+		}
+	} else {
+		array_fd = bpf_obj_get(pinned_file);
+		if (array_fd < 0) {
+			fprintf(stderr, "bpf_obj_get(%s): %s(%d)\n",
+				pinned_file, strerror(errno), errno);
+			goto out;
+		}
+	}
+
+	ret = bpf_update_elem(array_fd, &array_key, &cg2_fd, 0);
+	if (ret) {
+		perror("bpf_update_elem");
+		goto out;
+	}
+
+	if (create_array) {
+		ret = bpf_obj_pin(array_fd, pinned_file);
+		if (ret) {
+			fprintf(stderr, "bpf_obj_pin(..., %s): %s(%d)\n",
+				pinned_file, strerror(errno), errno);
+			goto out;
+		}
+	}
+
+out:
+	if (array_fd != -1)
+		close(array_fd);
+	if (cg2_fd != -1)
+		close(cg2_fd);
+	return ret;
+}
diff --git a/samples/bpf/test_cgrp2_tc.sh b/samples/bpf/test_cgrp2_tc.sh
new file mode 100755
index 0000000..0b119ee
--- /dev/null
+++ b/samples/bpf/test_cgrp2_tc.sh
@@ -0,0 +1,184 @@
+#!/bin/bash
+
+MY_DIR=$(dirname $0)
+# Details on the bpf prog
+BPF_CGRP2_ARRAY_NAME='test_cgrp2_array_pin'
+BPF_PROG="$MY_DIR/test_cgrp2_tc_kern.o"
+BPF_SECTION='filter'
+
+[ -z "$TC" ] && TC='tc'
+[ -z "$IP" ] && IP='ip'
+
+# Names of the veth interface, net namespace...etc.
+HOST_IFC='ve'
+NS_IFC='vens'
+NS='ns'
+
+find_mnt() {
+    cat /proc/mounts | \
+	awk '{ if ($3 == "'$1'" && mnt == "") { mnt = $2 }} END { print mnt }'
+}
+
+# Init cgroup2 vars
+init_cgrp2_vars() {
+    CGRP2_ROOT=$(find_mnt cgroup2)
+    if [ -z "$CGRP2_ROOT" ]
+    then
+	CGRP2_ROOT='/mnt/cgroup2'
+	MOUNT_CGRP2="yes"
+    fi
+    CGRP2_TC="$CGRP2_ROOT/tc"
+    CGRP2_TC_LEAF="$CGRP2_TC/leaf"
+}
+
+# Init bpf fs vars
+init_bpf_fs_vars() {
+    local bpf_fs_root=$(find_mnt bpf)
+    [ -n "$bpf_fs_root" ] || return -1
+    BPF_FS_TC_SHARE="$bpf_fs_root/tc/globals"
+}
+
+setup_cgrp2() {
+    case $1 in
+	start)
+	    if [ "$MOUNT_CGRP2" == 'yes' ]
+	    then
+		[ -d $CGRP2_ROOT ] || mkdir -p $CGRP2_ROOT
+		mount -t cgroup2 none $CGRP2_ROOT || return $?
+	    fi
+	    mkdir -p $CGRP2_TC_LEAF
+	    ;;
+	*)
+	    rmdir $CGRP2_TC_LEAF && rmdir $CGRP2_TC
+	    [ "$MOUNT_CGRP2" == 'yes' ] && umount $CGRP2_ROOT
+	    ;;
+    esac
+}
+
+setup_bpf_cgrp2_array() {
+    local bpf_cgrp2_array="$BPF_FS_TC_SHARE/$BPF_CGRP2_ARRAY_NAME"
+    case $1 in
+	start)
+	    $MY_DIR/test_cgrp2_array_pin -U $bpf_cgrp2_array -v $CGRP2_TC
+	    ;;
+	*)
+	    [ -d "$BPF_FS_TC_SHARE" ] && rm -f $bpf_cgrp2_array
+	    ;;
+    esac
+}
+
+setup_net() {
+    case $1 in
+	start)
+	    $IP link add $HOST_IFC type veth peer name $NS_IFC || return $?
+	    $IP link set dev $HOST_IFC up || return $?
+	    sysctl -q net.ipv6.conf.$HOST_IFC.accept_dad=0
+
+	    $IP netns add ns || return $?
+	    $IP link set dev $NS_IFC netns ns || return $?
+	    $IP -n $NS link set dev $NS_IFC up || return $?
+	    $IP netns exec $NS sysctl -q net.ipv6.conf.$NS_IFC.accept_dad=0
+	    $TC qdisc add dev $HOST_IFC clsact || return $?
+	    $TC filter add dev $HOST_IFC egress bpf da obj $BPF_PROG sec $BPF_SECTION || return $?
+	    ;;
+	*)
+	    $IP netns del $NS
+	    $IP link del $HOST_IFC
+	    ;;
+    esac
+}
+
+run_in_cgrp() {
+    # Fork another bash and move it under the specified cgroup.
+    # It makes the cgroup cleanup easier at the end of the test.
+    cmd='echo $$ > '
+    cmd="$cmd $1/cgroup.procs; exec $2"
+    bash -c "$cmd"
+}
+
+do_test() {
+    run_in_cgrp $CGRP2_TC_LEAF "ping -6 -c3 ff02::1%$HOST_IFC >& /dev/null"
+    local dropped=$($TC -s qdisc show dev $HOST_IFC | tail -3 | \
+			   awk '/drop/{print substr($7, 0, index($7, ",")-1)}')
+    if [[ $dropped -eq 0 ]]
+    then
+	echo "FAIL"
+	return 1
+    else
+	echo "Successfully filtered $dropped packets"
+	return 0
+    fi
+}
+
+do_exit() {
+    if [ "$DEBUG" == "yes" ] && [ "$MODE" != 'cleanuponly' ]
+    then
+	echo "------ DEBUG ------"
+	echo "mount: "; mount | egrep '(cgroup2|bpf)'; echo
+	echo "$CGRP2_TC_LEAF: "; ls -l $CGRP2_TC_LEAF; echo
+	if [ -d "$BPF_FS_TC_SHARE" ]
+	then
+	    echo "$BPF_FS_TC_SHARE: "; ls -l $BPF_FS_TC_SHARE; echo
+	fi
+	echo "Host net:"
+	$IP netns
+	$IP link show dev $HOST_IFC
+	$IP -6 a show dev $HOST_IFC
+	$TC -s qdisc show dev $HOST_IFC
+	echo
+	echo "$NS net:"
+	$IP -n $NS link show dev $NS_IFC
+	$IP -n $NS -6 link show dev $NS_IFC
+	echo "------ DEBUG ------"
+	echo
+    fi
+
+    if [ "$MODE" != 'nocleanup' ]
+    then
+	setup_net stop
+	setup_bpf_cgrp2_array stop
+	setup_cgrp2 stop
+    fi
+}
+
+init_cgrp2_vars
+init_bpf_fs_vars
+
+while [[ $# -ge 1 ]]
+do
+    a="$1"
+    case $a in
+	debug)
+	    DEBUG='yes'
+	    shift 1
+	    ;;
+	cleanup-only)
+	    MODE='cleanuponly'
+	    shift 1
+	    ;;
+	no-cleanup)
+	    MODE='nocleanup'
+	    shift 1
+	    ;;
+	*)
+	    echo "test_cgrp2_tc [debug] [cleanup-only | no-cleanup]"
+	    echo "  debug: Print cgrp and network setup details at the end of the test"
+	    echo "  cleanup-only: Try to cleanup things from last test.  No test will be run"
+	    echo "  no-cleanup: Run the test but don't do cleanup at the end"
+	    echo "[Note: If no arg is given, it will run the test and do cleanup at the end]"
+	    echo
+	    exit -1
+	    ;;
+    esac
+done
+
+trap do_exit 0
+
+[ "$MODE" == 'cleanuponly' ] && exit
+
+setup_cgrp2 start || exit $?
+setup_net start || exit $?
+init_bpf_fs_vars || exit $?
+setup_bpf_cgrp2_array start || exit $?
+do_test
+echo
diff --git a/samples/bpf/test_cgrp2_tc_kern.c b/samples/bpf/test_cgrp2_tc_kern.c
new file mode 100644
index 0000000..2732c37
--- /dev/null
+++ b/samples/bpf/test_cgrp2_tc_kern.c
@@ -0,0 +1,69 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/in6.h>
+#include <uapi/linux/ipv6.h>
+#include <uapi/linux/pkt_cls.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+/* copy of 'struct ethhdr' without __packed */
+struct eth_hdr {
+	unsigned char   h_dest[ETH_ALEN];
+	unsigned char   h_source[ETH_ALEN];
+	unsigned short  h_proto;
+};
+
+#define PIN_GLOBAL_NS		2
+struct bpf_elf_map {
+	__u32 type;
+	__u32 size_key;
+	__u32 size_value;
+	__u32 max_elem;
+	__u32 flags;
+	__u32 id;
+	__u32 pinning;
+};
+
+struct bpf_elf_map SEC("maps") test_cgrp2_array_pin = {
+	.type		= BPF_MAP_TYPE_CGROUP_ARRAY,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.pinning	= PIN_GLOBAL_NS,
+	.max_elem	= 1,
+};
+
+SEC("filter")
+int handle_egress(struct __sk_buff *skb)
+{
+	void *data = (void *)(long)skb->data;
+	struct eth_hdr *eth = data;
+	struct ipv6hdr *ip6h = data + sizeof(*eth);
+	void *data_end = (void *)(long)skb->data_end;
+	char dont_care_msg[] = "dont care %04x %d\n";
+	char pass_msg[] = "pass\n";
+	char reject_msg[] = "reject\n";
+
+	/* single length check */
+	if (data + sizeof(*eth) + sizeof(*ip6h) > data_end)
+		return TC_ACT_OK;
+
+	if (eth->h_proto != htons(ETH_P_IPV6) ||
+	    ip6h->nexthdr != IPPROTO_ICMPV6) {
+		bpf_trace_printk(dont_care_msg, sizeof(dont_care_msg),
+				 eth->h_proto, ip6h->nexthdr);
+		return TC_ACT_OK;
+	} else if (bpf_skb_in_cgroup(skb, &test_cgrp2_array_pin, 0) != 1) {
+		bpf_trace_printk(pass_msg, sizeof(pass_msg));
+		return TC_ACT_OK;
+	} else {
+		bpf_trace_printk(reject_msg, sizeof(reject_msg));
+		return TC_ACT_SHOT;
+	}
+}
+
+char _license[] SEC("license") = "GPL";
-- 
2.5.1
