From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next] selftests: bpf: add a test for XDP redirect
Date: Mon,  7 Aug 2017 13:14:42 -0700
Message-ID: <1502136882-40204-1-git-send-email-u9012063@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33915 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdHGUPI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 16:15:08 -0400
Received: by mail-pf0-f193.google.com with SMTP id t86so1339239pfe.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 13:15:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add test for xdp_redirect by creating two namespaces with two
veth peers, then forward packets in-between.

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 tools/include/uapi/linux/bpf.h                   |  3 +-
 tools/testing/selftests/bpf/Makefile             |  4 +-
 tools/testing/selftests/bpf/test_xdp_redirect.c  | 28 ++++++++++++
 tools/testing/selftests/bpf/test_xdp_redirect.sh | 54 ++++++++++++++++++++++++
 4 files changed, 86 insertions(+), 3 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_xdp_redirect.c
 create mode 100755 tools/testing/selftests/bpf/test_xdp_redirect.sh

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 1579cab49717..8d9bfcca3fe4 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -592,7 +592,8 @@ union bpf_attr {
 	FN(get_socket_uid),		\
 	FN(set_hash),			\
 	FN(setsockopt),			\
-	FN(skb_adjust_room),
+	FN(skb_adjust_room),		\
+	FN(redirect_map),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 153c3a181a4c..3c2e67da4b41 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -15,9 +15,9 @@ TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test
 	test_align
 
 TEST_GEN_FILES = test_pkt_access.o test_xdp.o test_l4lb.o test_tcp_estats.o test_obj_id.o \
-	test_pkt_md_access.o
+	test_pkt_md_access.o test_xdp_redirect.o
 
-TEST_PROGS := test_kmod.sh
+TEST_PROGS := test_kmod.sh test_xdp_redirect.sh
 
 include ../lib.mk
 
diff --git a/tools/testing/selftests/bpf/test_xdp_redirect.c b/tools/testing/selftests/bpf/test_xdp_redirect.c
new file mode 100644
index 000000000000..ef9e704be140
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_xdp_redirect.c
@@ -0,0 +1,28 @@
+/* Copyright (c) 2017 VMware
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+#include <linux/bpf.h>
+#include "bpf_helpers.h"
+
+int _version SEC("version") = 1;
+
+SEC("redirect_to_111")
+int xdp_redirect_to_111(struct xdp_md *xdp)
+{
+	return bpf_redirect(111, 0);
+}
+SEC("redirect_to_222")
+int xdp_redirect_to_222(struct xdp_md *xdp)
+{
+	return bpf_redirect(222, 0);
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/tools/testing/selftests/bpf/test_xdp_redirect.sh b/tools/testing/selftests/bpf/test_xdp_redirect.sh
new file mode 100755
index 000000000000..d8c73ed6e040
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_xdp_redirect.sh
@@ -0,0 +1,54 @@
+#!/bin/sh
+# Create 2 namespaces with two veth peers, and
+# forward packets in-between using generic XDP
+#
+# NS1(veth11)     NS2(veth22)
+#     |               |
+#     |               |
+#   (veth1, ------ (veth2,
+#   id:111)         id:222)
+#     | xdp forwarding |
+#     ------------------
+
+cleanup()
+{
+	if [ "$?" = "0" ]; then
+		echo "selftests: test_xdp_redirect [PASS]";
+	else
+		echo "selftests: test_xdp_redirect [FAILED]";
+	fi
+
+	set +e
+	ip netns del ns1 2> /dev/null
+	ip netns del ns2 2> /dev/null
+}
+
+set -e
+
+ip netns add ns1
+ip netns add ns2
+
+trap cleanup 0 2 3 6 9
+
+ip link add veth1 index 111 type veth peer name veth11
+ip link add veth2 index 222 type veth peer name veth22
+
+ip link set veth11 netns ns1
+ip link set veth22 netns ns2
+
+ip link set veth1 up
+ip link set veth2 up
+
+ip netns exec ns1 ip addr add 10.1.1.11/24 dev veth11
+ip netns exec ns2 ip addr add 10.1.1.22/24 dev veth22
+
+ip netns exec ns1 ip link set dev veth11 up
+ip netns exec ns2 ip link set dev veth22 up
+
+ip link set dev veth1 xdpgeneric obj test_xdp_redirect.o sec redirect_to_222
+ip link set dev veth2 xdpgeneric obj test_xdp_redirect.o sec redirect_to_111
+
+ip netns exec ns1 ping -c 1 10.1.1.22
+ip netns exec ns2 ping -c 1 10.1.1.11
+
+exit 0
-- 
2.7.4
