From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 11/19] selftests/memory-hotplug: add install target to enable installing test
Date: Tue, 11 Nov 2014 13:27:51 -0700
Message-ID: <8cdb2abb6eaa794801548e04ee6b9f403778e126.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.easymail.ca ([64.68.201.169]:48097 "EHLO
	mailout.easymail.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbaKKU2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:28:25 -0500
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level source dir.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/memory-hotplug/Makefile    |  17 +-
 .../selftests/memory-hotplug/mem-on-off-test.sh    | 238 +++++++++++++++++++++
 .../selftests/memory-hotplug/on-off-test.sh        | 238 ---------------------
 3 files changed, 253 insertions(+), 240 deletions(-)
 create mode 100644 tools/testing/selftests/memory-hotplug/mem-on-off-test.sh
 delete mode 100644 tools/testing/selftests/memory-hotplug/on-off-test.sh

diff --git a/tools/testing/selftests/memory-hotplug/Makefile b/tools/testing/selftests/memory-hotplug/Makefile
index d46b8d4..8921631 100644
--- a/tools/testing/selftests/memory-hotplug/Makefile
+++ b/tools/testing/selftests/memory-hotplug/Makefile
@@ -1,9 +1,22 @@
+TEST_STR=/bin/bash ./mem-on-off-test.sh -r 2 || echo memory-hotplug selftests: [FAIL]
+
 all:
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./mem-on-off-test.sh $(INSTALL_KSFT_PATH)/mem-on-off-test.sh
+	@echo echo Start memory hotplug test .... >> $(KSELFTEST)
+	@echo "$(TEST_STR)" >> $(KSELFTEST) >> $(KSELFTEST)
+	@echo echo End memory hotplug test .... >> $(KSELFTEST)
+	@echo echo ============================== >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
+
 run_tests:
-	@/bin/bash ./on-off-test.sh -r 2 || echo "memory-hotplug selftests: [FAIL]"
+	@$(TEST_STR)
 
 run_full_test:
-	@/bin/bash ./on-off-test.sh || echo "memory-hotplug selftests: [FAIL]"
+	@/bin/bash ./mem-on-off-test.sh || echo "memory-hotplug selftests: [FAIL]"
 
 clean:
diff --git a/tools/testing/selftests/memory-hotplug/mem-on-off-test.sh b/tools/testing/selftests/memory-hotplug/mem-on-off-test.sh
new file mode 100644
index 0000000..6cddde0
--- /dev/null
+++ b/tools/testing/selftests/memory-hotplug/mem-on-off-test.sh
@@ -0,0 +1,238 @@
+#!/bin/bash
+
+SYSFS=
+
+prerequisite()
+{
+	msg="skip all tests:"
+
+	if [ $UID != 0 ]; then
+		echo $msg must be run as root >&2
+		exit 0
+	fi
+
+	SYSFS=`mount -t sysfs | head -1 | awk '{ print $3 }'`
+
+	if [ ! -d "$SYSFS" ]; then
+		echo $msg sysfs is not mounted >&2
+		exit 0
+	fi
+
+	if ! ls $SYSFS/devices/system/memory/memory* > /dev/null 2>&1; then
+		echo $msg memory hotplug is not supported >&2
+		exit 0
+	fi
+}
+
+#
+# list all hot-pluggable memory
+#
+hotpluggable_memory()
+{
+	local state=${1:-.\*}
+
+	for memory in $SYSFS/devices/system/memory/memory*; do
+		if grep -q 1 $memory/removable &&
+		   grep -q $state $memory/state; then
+			echo ${memory##/*/memory}
+		fi
+	done
+}
+
+hotplaggable_offline_memory()
+{
+	hotpluggable_memory offline
+}
+
+hotpluggable_online_memory()
+{
+	hotpluggable_memory online
+}
+
+memory_is_online()
+{
+	grep -q online $SYSFS/devices/system/memory/memory$1/state
+}
+
+memory_is_offline()
+{
+	grep -q offline $SYSFS/devices/system/memory/memory$1/state
+}
+
+online_memory()
+{
+	echo online > $SYSFS/devices/system/memory/memory$1/state
+}
+
+offline_memory()
+{
+	echo offline > $SYSFS/devices/system/memory/memory$1/state
+}
+
+online_memory_expect_success()
+{
+	local memory=$1
+
+	if ! online_memory $memory; then
+		echo $FUNCNAME $memory: unexpected fail >&2
+	elif ! memory_is_online $memory; then
+		echo $FUNCNAME $memory: unexpected offline >&2
+	fi
+}
+
+online_memory_expect_fail()
+{
+	local memory=$1
+
+	if online_memory $memory 2> /dev/null; then
+		echo $FUNCNAME $memory: unexpected success >&2
+	elif ! memory_is_offline $memory; then
+		echo $FUNCNAME $memory: unexpected online >&2
+	fi
+}
+
+offline_memory_expect_success()
+{
+	local memory=$1
+
+	if ! offline_memory $memory; then
+		echo $FUNCNAME $memory: unexpected fail >&2
+	elif ! memory_is_offline $memory; then
+		echo $FUNCNAME $memory: unexpected offline >&2
+	fi
+}
+
+offline_memory_expect_fail()
+{
+	local memory=$1
+
+	if offline_memory $memory 2> /dev/null; then
+		echo $FUNCNAME $memory: unexpected success >&2
+	elif ! memory_is_online $memory; then
+		echo $FUNCNAME $memory: unexpected offline >&2
+	fi
+}
+
+error=-12
+priority=0
+ratio=10
+
+while getopts e:hp:r: opt; do
+	case $opt in
+	e)
+		error=$OPTARG
+		;;
+	h)
+		echo "Usage $0 [ -e errno ] [ -p notifier-priority ] [ -r percent-of-memory-to-offline ]"
+		exit
+		;;
+	p)
+		priority=$OPTARG
+		;;
+	r)
+		ratio=$OPTARG
+		;;
+	esac
+done
+
+if ! [ "$error" -ge -4095 -a "$error" -lt 0 ]; then
+	echo "error code must be -4095 <= errno < 0" >&2
+	exit 1
+fi
+
+prerequisite
+
+echo "Test scope: $ratio% hotplug memory"
+echo -e "\t online all hotplug memory in offline state"
+echo -e "\t offline $ratio% hotplug memory in online state"
+echo -e "\t online all hotplug memory in offline state"
+
+#
+# Online all hot-pluggable memory
+#
+for memory in `hotplaggable_offline_memory`; do
+	echo offline-online $memory
+	online_memory_expect_success $memory
+done
+
+#
+# Offline $ratio percent of hot-pluggable memory
+#
+for memory in `hotpluggable_online_memory`; do
+	if [ $((RANDOM % 100)) -lt $ratio ]; then
+		echo online-offline $memory
+		offline_memory_expect_success $memory
+	fi
+done
+
+#
+# Online all hot-pluggable memory again
+#
+for memory in `hotplaggable_offline_memory`; do
+	echo offline-online $memory
+	online_memory_expect_success $memory
+done
+
+#
+# Test with memory notifier error injection
+#
+
+DEBUGFS=`mount -t debugfs | head -1 | awk '{ print $3 }'`
+NOTIFIER_ERR_INJECT_DIR=$DEBUGFS/notifier-error-inject/memory
+
+prerequisite_extra()
+{
+	msg="skip extra tests:"
+
+	/sbin/modprobe -q -r memory-notifier-error-inject
+	/sbin/modprobe -q memory-notifier-error-inject priority=$priority
+
+	if [ ! -d "$DEBUGFS" ]; then
+		echo $msg debugfs is not mounted >&2
+		exit 0
+	fi
+
+	if [ ! -d $NOTIFIER_ERR_INJECT_DIR ]; then
+		echo $msg memory-notifier-error-inject module is not available >&2
+		exit 0
+	fi
+}
+
+prerequisite_extra
+
+#
+# Offline $ratio percent of hot-pluggable memory
+#
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
+for memory in `hotpluggable_online_memory`; do
+	if [ $((RANDOM % 100)) -lt $ratio ]; then
+		offline_memory_expect_success $memory
+	fi
+done
+
+#
+# Test memory hot-add error handling (offline => online)
+#
+echo $error > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_ONLINE/error
+for memory in `hotplaggable_offline_memory`; do
+	online_memory_expect_fail $memory
+done
+
+#
+# Online all hot-pluggable memory
+#
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_ONLINE/error
+for memory in `hotplaggable_offline_memory`; do
+	online_memory_expect_success $memory
+done
+
+#
+# Test memory hot-remove error handling (online => offline)
+#
+echo $error > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
+for memory in `hotpluggable_online_memory`; do
+	offline_memory_expect_fail $memory
+done
+
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
+/sbin/modprobe -q -r memory-notifier-error-inject
diff --git a/tools/testing/selftests/memory-hotplug/on-off-test.sh b/tools/testing/selftests/memory-hotplug/on-off-test.sh
deleted file mode 100644
index 6cddde0..0000000
--- a/tools/testing/selftests/memory-hotplug/on-off-test.sh
+++ /dev/null
@@ -1,238 +0,0 @@
-#!/bin/bash
-
-SYSFS=
-
-prerequisite()
-{
-	msg="skip all tests:"
-
-	if [ $UID != 0 ]; then
-		echo $msg must be run as root >&2
-		exit 0
-	fi
-
-	SYSFS=`mount -t sysfs | head -1 | awk '{ print $3 }'`
-
-	if [ ! -d "$SYSFS" ]; then
-		echo $msg sysfs is not mounted >&2
-		exit 0
-	fi
-
-	if ! ls $SYSFS/devices/system/memory/memory* > /dev/null 2>&1; then
-		echo $msg memory hotplug is not supported >&2
-		exit 0
-	fi
-}
-
-#
-# list all hot-pluggable memory
-#
-hotpluggable_memory()
-{
-	local state=${1:-.\*}
-
-	for memory in $SYSFS/devices/system/memory/memory*; do
-		if grep -q 1 $memory/removable &&
-		   grep -q $state $memory/state; then
-			echo ${memory##/*/memory}
-		fi
-	done
-}
-
-hotplaggable_offline_memory()
-{
-	hotpluggable_memory offline
-}
-
-hotpluggable_online_memory()
-{
-	hotpluggable_memory online
-}
-
-memory_is_online()
-{
-	grep -q online $SYSFS/devices/system/memory/memory$1/state
-}
-
-memory_is_offline()
-{
-	grep -q offline $SYSFS/devices/system/memory/memory$1/state
-}
-
-online_memory()
-{
-	echo online > $SYSFS/devices/system/memory/memory$1/state
-}
-
-offline_memory()
-{
-	echo offline > $SYSFS/devices/system/memory/memory$1/state
-}
-
-online_memory_expect_success()
-{
-	local memory=$1
-
-	if ! online_memory $memory; then
-		echo $FUNCNAME $memory: unexpected fail >&2
-	elif ! memory_is_online $memory; then
-		echo $FUNCNAME $memory: unexpected offline >&2
-	fi
-}
-
-online_memory_expect_fail()
-{
-	local memory=$1
-
-	if online_memory $memory 2> /dev/null; then
-		echo $FUNCNAME $memory: unexpected success >&2
-	elif ! memory_is_offline $memory; then
-		echo $FUNCNAME $memory: unexpected online >&2
-	fi
-}
-
-offline_memory_expect_success()
-{
-	local memory=$1
-
-	if ! offline_memory $memory; then
-		echo $FUNCNAME $memory: unexpected fail >&2
-	elif ! memory_is_offline $memory; then
-		echo $FUNCNAME $memory: unexpected offline >&2
-	fi
-}
-
-offline_memory_expect_fail()
-{
-	local memory=$1
-
-	if offline_memory $memory 2> /dev/null; then
-		echo $FUNCNAME $memory: unexpected success >&2
-	elif ! memory_is_online $memory; then
-		echo $FUNCNAME $memory: unexpected offline >&2
-	fi
-}
-
-error=-12
-priority=0
-ratio=10
-
-while getopts e:hp:r: opt; do
-	case $opt in
-	e)
-		error=$OPTARG
-		;;
-	h)
-		echo "Usage $0 [ -e errno ] [ -p notifier-priority ] [ -r percent-of-memory-to-offline ]"
-		exit
-		;;
-	p)
-		priority=$OPTARG
-		;;
-	r)
-		ratio=$OPTARG
-		;;
-	esac
-done
-
-if ! [ "$error" -ge -4095 -a "$error" -lt 0 ]; then
-	echo "error code must be -4095 <= errno < 0" >&2
-	exit 1
-fi
-
-prerequisite
-
-echo "Test scope: $ratio% hotplug memory"
-echo -e "\t online all hotplug memory in offline state"
-echo -e "\t offline $ratio% hotplug memory in online state"
-echo -e "\t online all hotplug memory in offline state"
-
-#
-# Online all hot-pluggable memory
-#
-for memory in `hotplaggable_offline_memory`; do
-	echo offline-online $memory
-	online_memory_expect_success $memory
-done
-
-#
-# Offline $ratio percent of hot-pluggable memory
-#
-for memory in `hotpluggable_online_memory`; do
-	if [ $((RANDOM % 100)) -lt $ratio ]; then
-		echo online-offline $memory
-		offline_memory_expect_success $memory
-	fi
-done
-
-#
-# Online all hot-pluggable memory again
-#
-for memory in `hotplaggable_offline_memory`; do
-	echo offline-online $memory
-	online_memory_expect_success $memory
-done
-
-#
-# Test with memory notifier error injection
-#
-
-DEBUGFS=`mount -t debugfs | head -1 | awk '{ print $3 }'`
-NOTIFIER_ERR_INJECT_DIR=$DEBUGFS/notifier-error-inject/memory
-
-prerequisite_extra()
-{
-	msg="skip extra tests:"
-
-	/sbin/modprobe -q -r memory-notifier-error-inject
-	/sbin/modprobe -q memory-notifier-error-inject priority=$priority
-
-	if [ ! -d "$DEBUGFS" ]; then
-		echo $msg debugfs is not mounted >&2
-		exit 0
-	fi
-
-	if [ ! -d $NOTIFIER_ERR_INJECT_DIR ]; then
-		echo $msg memory-notifier-error-inject module is not available >&2
-		exit 0
-	fi
-}
-
-prerequisite_extra
-
-#
-# Offline $ratio percent of hot-pluggable memory
-#
-echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
-for memory in `hotpluggable_online_memory`; do
-	if [ $((RANDOM % 100)) -lt $ratio ]; then
-		offline_memory_expect_success $memory
-	fi
-done
-
-#
-# Test memory hot-add error handling (offline => online)
-#
-echo $error > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_ONLINE/error
-for memory in `hotplaggable_offline_memory`; do
-	online_memory_expect_fail $memory
-done
-
-#
-# Online all hot-pluggable memory
-#
-echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_ONLINE/error
-for memory in `hotplaggable_offline_memory`; do
-	online_memory_expect_success $memory
-done
-
-#
-# Test memory hot-remove error handling (online => offline)
-#
-echo $error > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
-for memory in `hotpluggable_online_memory`; do
-	offline_memory_expect_fail $memory
-done
-
-echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
-/sbin/modprobe -q -r memory-notifier-error-inject
-- 
1.9.1
