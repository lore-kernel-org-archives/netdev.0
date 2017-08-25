From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 7/8] samples/bpf: Add test case for nested socket options
Date: Fri, 25 Aug 2017 12:05:40 -0700
Message-ID: <1503687941-626-8-git-send-email-dsahern@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35872 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758136AbdHYTF6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 15:05:58 -0400
Received: by mail-pg0-f66.google.com with SMTP id 83so890664pgb.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 12:05:58 -0700 (PDT)
In-Reply-To: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 samples/bpf/test_cgrp2_sock3.sh | 162 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 162 insertions(+)
 create mode 100755 samples/bpf/test_cgrp2_sock3.sh

diff --git a/samples/bpf/test_cgrp2_sock3.sh b/samples/bpf/test_cgrp2_sock3.sh
new file mode 100755
index 000000000000..9bfed035963f
--- /dev/null
+++ b/samples/bpf/test_cgrp2_sock3.sh
@@ -0,0 +1,162 @@
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
+	printf "%-50s    [%4s]\n" "$1" "$2"
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
+		print_result "IPv4: $2" " OK "
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
+		print_result "IPv6: $2" " OK "
+	fi
+}
+
+################################################################################
+#
+setup()
+{
+	cleanup 2>/dev/null
+
+	mkdir -p ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev
+	[ $? -ne 0 ] && cleanup_and_exit 1 "Failed to create cgroup hierarchy"
+
+	test_cgrp2_sock -p 123 ${CGRP_MNT}/cgrp_sock_test/prio
+	[ $? -ne 0 ] && cleanup_and_exit 1 "Failed to install program to set priority"
+
+	test_cgrp2_sock -m 666 -r ${CGRP_MNT}/cgrp_sock_test/prio/mark
+	[ $? -ne 0 ] && cleanup_and_exit 1 "Failed to install program to set mark"
+
+	test_cgrp2_sock -b cgrp2_sock -r ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev
+	[ $? -ne 0 ] && cleanup_and_exit 1 "Failed to install program to set device"
+}
+
+cleanup()
+{
+	echo $$ >> ${CGRP_MNT}/cgroup.procs
+	rmdir ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev
+	rmdir ${CGRP_MNT}/cgrp_sock_test/prio/mark
+	rmdir ${CGRP_MNT}/cgrp_sock_test/prio
+	rmdir ${CGRP_MNT}/cgrp_sock_test
+}
+
+cleanup_and_exit()
+{
+	local rc=$1
+	local msg="$2"
+
+	[ -n "$msg" ] && echo "ERROR: $msg"
+
+	ip li del cgrp2_sock
+	umount ${CGRP_MNT}
+
+	exit $rc
+}
+
+################################################################################
+#
+
+run_tests()
+{
+	# set pid into first cgroup. socket should show it
+	# has a priority but not a mark or device bind
+	echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/cgroup.procs
+	check_sock "dev , mark 0, priority 123" "Priority only"
+
+	# set pid into second group. socket should show it
+	# has a priority and mark but not a device bind
+	echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/mark/cgroup.procs
+	check_sock "dev , mark 666, priority 123" "Priority + mark"
+
+	# set pid into inner group. socket should show it
+	# has a priority, mark and a device bind
+	echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev/cgroup.procs
+	check_sock "dev cgrp2_sock, mark 666, priority 123" "Priority + mark + dev"
+
+	echo
+
+	# set pid into first cgroup. socket should show it
+	# has a priority but not a mark or device bind
+	echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/cgroup.procs
+	check_sock6 "dev , mark 0, priority 123" "Priority only"
+
+	# set pid into second group. socket should show it
+	# has a priority and mark but not a device bind
+	echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/mark/cgroup.procs
+	check_sock6 "dev , mark 666, priority 123" "Priority + mark"
+
+	# set pid into inner group. socket should show it
+	# has a priority, mark and a device bind
+	echo $$ > ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev/cgroup.procs
+	check_sock6 "dev cgrp2_sock, mark 666, priority 123" "Priority + mark + dev"
+}
+
+################################################################################
+# verify expected invalid setups are invalid
+
+invalid_setup()
+{
+	echo
+
+	mkdir -p ${CGRP_MNT}/cgrp_sock_test/prio/mark/dev
+	[ $? -ne 0 ] && cleanup_and_exit 1 "Failed to create cgroup hierarchy"
+
+	test_cgrp2_sock -p 123 -r ${CGRP_MNT}/cgrp_sock_test/prio
+	[ $? -ne 0 ] && cleanup_and_exit 1 "Failed to install program to set priority"
+
+	# recursive - followed by non-recursive is not allowed
+	test_cgrp2_sock -m 666 ${CGRP_MNT}/cgrp_sock_test/prio/mark >/dev/null 2>&1
+	if [ $? -eq 0 ]; then
+		print_result "recursive setting followed by non-recursive" "FAIL"
+	else
+		print_result "recursive setting followed by non-recursive" " OK "
+	fi
+}
+
+################################################################################
+# main
+
+rc=0
+
+ip li add cgrp2_sock type dummy 2>/dev/null
+
+set -e
+mkdir -p ${CGRP_MNT}
+mount -t cgroup2 none ${CGRP_MNT}
+set +e
+
+setup
+run_tests
+cleanup
+
+invalid_setup
+
+cleanup_and_exit $rc
-- 
2.1.4
