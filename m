From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 7/8] samples/bpf: Add test case for nested socket options
Date: Tue, 22 Aug 2017 17:20:20 -0700
Message-ID: <1503447621-27997-8-git-send-email-dsahern@gmail.com>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37530 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752619AbdHWAUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 20:20:35 -0400
Received: by mail-pg0-f65.google.com with SMTP id 83so214863pgb.4
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 17:20:35 -0700 (PDT)
In-Reply-To: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 samples/bpf/test_cgrp2_sock3.sh | 118 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 118 insertions(+)
 create mode 100755 samples/bpf/test_cgrp2_sock3.sh

diff --git a/samples/bpf/test_cgrp2_sock3.sh b/samples/bpf/test_cgrp2_sock3.sh
new file mode 100755
index 000000000000..d371a8740aeb
--- /dev/null
+++ b/samples/bpf/test_cgrp2_sock3.sh
@@ -0,0 +1,118 @@
+#!/bin/sh
+
+# Verify socket options inherited by bpf programs attached
+# to a cgroup.
+
+CGRP_MNT="/tmp/cgroupv2-test_cgrp2_sock"
+
+################################################################################
+#
+print_result()
+{
+	printf "%50s    [%4s]\n" "$1" "$2"
+}
+
+check_sock()
+{
+	out=$(test_cgrp2_sock)
+	echo $out | grep -q "$1"
+	if [ $? -ne 0 ]; then
+		print_result "IPv4: $2" "FAIL"
+		echo "    expected: $1"
+		echo "        have: $out"
+		rc=1
+	else
+		print_result "IPv4: $2" "OK"
+	fi
+}
+
+check_sock6()
+{
+	out=$(test_cgrp2_sock -6)
+	echo $out | grep -q "$1"
+	if [ $? -ne 0 ]; then
+		print_result "IPv6: $2" "FAIL"
+		echo "    expected: $1"
+		echo "        have: $out"
+		rc=1
+	else
+		print_result "IPv6: $2" "OK"
+	fi
+}
+
+################################################################################
+#
+setup()
+{
+	ip li add cgrp2_sock type dummy
+
+	set -e
+
+	mkdir -p ${CGRP_MNT}
+	mount -t cgroup2 none ${CGRP_MNT}
+
+	mkdir -p ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev
+
+	test_cgrp2_sock -p 123 ${CGRP_MNT}/cgrp_sock_test/prio
+	test_cgrp2_sock -m 666 ${CGRP_MNT}/cgrp_sock_test/prio/mark
+	test_cgrp2_sock -b cgrp2_sock ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev
+
+	set +e
+}
+
+cleanup()
+{
+	ip li del cgrp2_sock
+
+	echo $$ >> ${CGRP_MNT}/cgroup.procs
+	rmdir ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev
+	rmdir ${CGRP_MNT}/cgrp_sock_test/prio/mark
+	rmdir ${CGRP_MNT}/cgrp_sock_test/prio
+	rmdir ${CGRP_MNT}/cgrp_sock_test
+
+	umount ${CGRP_MNT}
+}
+
+################################################################################
+# main
+
+rc=0
+
+setup
+
+# set pid into first cgroup. socket should show it
+# has a priority but not a mark or device bind
+echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/cgroup.procs
+check_sock "dev , mark 0, priority 123" "Priority only"
+
+
+# set pid into second group. socket should show it
+# has a priority and mark but not a device bind
+echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/mark/cgroup.procs
+check_sock "dev , mark 666, priority 123" "Priority + mark"
+
+# set pid into inner group. socket should show it
+# has a priority, mark and a device bind
+echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev/cgroup.procs
+check_sock "dev cgrp2_sock, mark 666, priority 123" "Priority + mark + dev"
+
+echo
+
+# set pid into first cgroup. socket should show it
+# has a priority but not a mark or device bind
+echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/cgroup.procs
+check_sock6 "dev , mark 0, priority 123" "Priority only"
+
+# set pid into second group. socket should show it
+# has a priority and mark but not a device bind
+echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/mark/cgroup.procs
+check_sock6 "dev , mark 666, priority 123" "Priority + mark"
+
+# set pid into inner group. socket should show it
+# has a priority, mark and a device bind
+echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev/cgroup.procs
+check_sock6 "dev cgrp2_sock, mark 666, priority 123" "Priority + mark + dev"
+
+cleanup
+
+exit $rc
-- 
2.1.4
