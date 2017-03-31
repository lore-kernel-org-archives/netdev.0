From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 4/6] selftests/bpf: add a test for overlapping packet range checks
Date: Thu, 30 Mar 2017 21:45:41 -0700
Message-ID: <20170331044543.4075183-5-ast@fb.com>
References: <20170331044543.4075183-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47463 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752204AbdCaEpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 00:45:50 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2V4hEEG002197
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 21:45:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29hg5581jh-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 21:45:49 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 e74602be15cc11e79be724be05904660-ec7fd9a0 for <netdev@vger.kernel.org>;        Thu,
 30 Mar 2017 21:45:45 -0700
In-Reply-To: <20170331044543.4075183-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add simple C test case for llvm and verifier range check fix from
commit b1977682a385 ("bpf: improve verifier packet range checks")

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/testing/selftests/bpf/Makefile          |  17 +++-
 tools/testing/selftests/bpf/test_pkt_access.c |  64 ++++++++++++
 tools/testing/selftests/bpf/test_progs.c      | 138 ++++++++++++++++++++++++++
 3 files changed, 215 insertions(+), 4 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_pkt_access.c
 create mode 100644 tools/testing/selftests/bpf/test_progs.c

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 6a1ad58cb66f..ff68c9419a67 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,16 +1,18 @@
 LIBDIR := ../../../lib
 BPFDIR := $(LIBDIR)/bpf
 
-CFLAGS += -Wall -O2 -I../../../include/uapi -I$(LIBDIR)
-LDLIBS += -lcap
+CFLAGS += -Wall -O2 -I../../../include/uapi -I$(LIBDIR) -I../../../include
+LDLIBS += -lcap -lelf
 
-TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map
+TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs
+
+TEST_GEN_FILES = test_pkt_access.o
 
 TEST_PROGS := test_kmod.sh
 
 include ../lib.mk
 
-BPFOBJ := $(OUTPUT)/bpf.o
+BPFOBJ := $(OUTPUT)/libbpf.a
 
 $(TEST_GEN_PROGS): $(BPFOBJ)
 
@@ -21,3 +23,10 @@ $(TEST_GEN_PROGS): $(BPFOBJ)
 
 $(BPFOBJ): force
 	$(MAKE) -C $(BPFDIR) OUTPUT=$(OUTPUT)/
+
+CLANG ?= clang
+
+%.o: %.c
+	$(CLANG) -I../../../include/uapi -I../../../../samples/bpf/ \
+		-D__x86_64__ -Wno-compare-distinct-pointer-types \
+		-O2 -target bpf -c $< -o $@
diff --git a/tools/testing/selftests/bpf/test_pkt_access.c b/tools/testing/selftests/bpf/test_pkt_access.c
new file mode 100644
index 000000000000..fd1e0832d409
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_pkt_access.c
@@ -0,0 +1,64 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stddef.h>
+#include <linux/bpf.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/in.h>
+#include <linux/tcp.h>
+#include <linux/pkt_cls.h>
+#include "bpf_helpers.h"
+
+#define _htons __builtin_bswap16
+#define barrier() __asm__ __volatile__("": : :"memory")
+int _version SEC("version") = 1;
+
+SEC("test1")
+int process(struct __sk_buff *skb)
+{
+	void *data_end = (void *)(long)skb->data_end;
+	void *data = (void *)(long)skb->data;
+	struct ethhdr *eth = (struct ethhdr *)(data);
+	struct tcphdr *tcp = NULL;
+	__u8 proto = 255;
+	__u64 ihl_len;
+
+	if (eth + 1 > data_end)
+		return TC_ACT_SHOT;
+
+	if (eth->h_proto == _htons(ETH_P_IP)) {
+		struct iphdr *iph = (struct iphdr *)(eth + 1);
+
+		if (iph + 1 > data_end)
+			return TC_ACT_SHOT;
+		ihl_len = iph->ihl * 4;
+		proto = iph->protocol;
+		tcp = (struct tcphdr *)((void *)(iph) + ihl_len);
+	} else if (eth->h_proto == _htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ip6h = (struct ipv6hdr *)(eth + 1);
+
+		if (ip6h + 1 > data_end)
+			return TC_ACT_SHOT;
+		ihl_len = sizeof(*ip6h);
+		proto = ip6h->nexthdr;
+		tcp = (struct tcphdr *)((void *)(ip6h) + ihl_len);
+	}
+
+	if (tcp) {
+		if (((void *)(tcp) + 20) > data_end || proto != 6)
+			return TC_ACT_SHOT;
+		barrier(); /* to force ordering of checks */
+		if (((void *)(tcp) + 18) > data_end)
+			return TC_ACT_SHOT;
+		if (tcp->urg_ptr == 123)
+			return TC_ACT_OK;
+	}
+
+	return TC_ACT_UNSPEC;
+}
diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
new file mode 100644
index 000000000000..1d9a310e71e5
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_progs.c
@@ -0,0 +1,138 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <errno.h>
+#include <string.h>
+#include <assert.h>
+#include <stdlib.h>
+
+#include <linux/types.h>
+typedef __u16 __sum16;
+#include <arpa/inet.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+
+#include <sys/wait.h>
+#include <sys/resource.h>
+
+#include <linux/bpf.h>
+#include <linux/err.h>
+#include <bpf/bpf.h>
+#include <bpf/libbpf.h>
+
+#define _htons __builtin_bswap16
+
+static int error_cnt, pass_cnt;
+
+/* ipv4 test vector */
+static struct {
+	struct ethhdr eth;
+	struct iphdr iph;
+	struct tcphdr tcp;
+} __packed pkt_v4 = {
+	.eth.h_proto = _htons(ETH_P_IP),
+	.iph.ihl = 5,
+	.iph.protocol = 6,
+	.tcp.urg_ptr = 123,
+};
+
+/* ipv6 test vector */
+static struct {
+	struct ethhdr eth;
+	struct ipv6hdr iph;
+	struct tcphdr tcp;
+} __packed pkt_v6 = {
+	.eth.h_proto = _htons(ETH_P_IPV6),
+	.iph.nexthdr = 6,
+	.tcp.urg_ptr = 123,
+};
+
+#define CHECK(condition, tag, format...) ({				\
+	int __ret = !!(condition);					\
+	if (__ret) {							\
+		error_cnt++;						\
+		printf("%s:FAIL:%s ", __func__, tag);			\
+		printf(format);						\
+	} else {							\
+		pass_cnt++;						\
+		printf("%s:PASS:%s %d nsec\n", __func__, tag, duration);\
+	}								\
+})
+
+static int bpf_prog_load(const char *file, enum bpf_prog_type type,
+			 struct bpf_object **pobj, int *prog_fd)
+{
+	struct bpf_program *prog;
+	struct bpf_object *obj;
+	int err;
+
+	obj = bpf_object__open(file);
+	if (IS_ERR(obj)) {
+		error_cnt++;
+		return -ENOENT;
+	}
+
+	prog = bpf_program__next(NULL, obj);
+	if (!prog) {
+		bpf_object__close(obj);
+		error_cnt++;
+		return -ENOENT;
+	}
+
+	bpf_program__set_type(prog, type);
+	err = bpf_object__load(obj);
+	if (err) {
+		bpf_object__close(obj);
+		error_cnt++;
+		return -EINVAL;
+	}
+
+	*pobj = obj;
+	*prog_fd = bpf_program__fd(prog);
+	return 0;
+}
+
+static void test_pkt_access(void)
+{
+	const char *file = "./test_pkt_access.o";
+	struct bpf_object *obj;
+	__u32 duration, retval;
+	int err, prog_fd;
+
+	err = bpf_prog_load(file, BPF_PROG_TYPE_SCHED_CLS, &obj, &prog_fd);
+	if (err)
+		return;
+
+	err = bpf_prog_test_run(prog_fd, 100000, &pkt_v4, sizeof(pkt_v4),
+				NULL, NULL, &retval, &duration);
+	CHECK(err || errno || retval, "ipv4",
+	      "err %d errno %d retval %d duration %d\n",
+	      err, errno, retval, duration);
+
+	err = bpf_prog_test_run(prog_fd, 100000, &pkt_v6, sizeof(pkt_v6),
+				NULL, NULL, &retval, &duration);
+	CHECK(err || errno || retval, "ipv6",
+	      "err %d errno %d retval %d duration %d\n",
+	      err, errno, retval, duration);
+	bpf_object__close(obj);
+}
+
+int main(void)
+{
+	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
+
+	setrlimit(RLIMIT_MEMLOCK, &rinf);
+
+	test_pkt_access();
+
+	printf("Summary: %d PASSED, %d FAILED\n", pass_cnt, error_cnt);
+	return 0;
+}
-- 
2.9.3
