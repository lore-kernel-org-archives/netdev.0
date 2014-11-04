From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 04/20] selftests: add install target to enable installing selftests
Date: Tue,  4 Nov 2014 10:11:00 -0700
Message-ID: <dcfb5619debb4f3fe9b1eaad2bd49288f29cac42.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing selftests. This
new target will call install targets for the tests that are
specified in INSTALL_TARGETS. During install, a script is
generated to run tests that are installed. This script will
be installed in the selftest install directory. Individual
test Makefiles are changed to add to the script. This will
allow new tests to add install and run test commands to the
generated kselftest script.

Approach:

make kselftest_target:
-- exports kselftest INSTALL_KSFT_PATH
   default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
-- exports path for ksefltest.sh
-- runs selftests make install target:

selftests make install target
-- creates kselftest.sh script in install install dir
-- runs install targets for all INSTALL_TARGETS

Individual test make install targets:
-- install test programs and/or scripts in install dir
-- append to the ksefltest.sh file to add commands to run test

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/Makefile | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 45f145c..07b0244 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -16,6 +16,10 @@ TARGETS += sysctl
 TARGETS += firmware
 TARGETS += ftrace
 
+INSTALL_TARGETS = breakpoints cpu-hotplug efivarfs firmware ipc
+INSTALL_TARGETS += kcmp memfd memory-hotplug mqueue mount net
+INSTALL_TARGETS += ptrace sysctl timers user vm
+
 TARGETS_HOTPLUG = cpu-hotplug
 TARGETS_HOTPLUG += memory-hotplug
 
@@ -24,6 +28,16 @@ all:
 		make -C $$TARGET; \
 	done;
 
+install: all
+	echo "#!/bin/sh\n# Kselftest Run Tests ...." > $(KSELFTEST)
+	echo "# This file is generated during kselftest_install" >> $(KSELFTEST)
+	echo "# Please don't change it !!\n"  >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+	for TARGET in $(INSTALL_TARGETS); do \
+		echo "\nInstalling $$TARGET"; \
+		make -C $$TARGET install; \
+	done;
+
 run_tests: all
 	for TARGET in $(TARGETS); do \
 		make -C $$TARGET run_tests; \
-- 
1.9.1
