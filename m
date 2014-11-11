From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 02/19] kbuild: kselftest_install - add a new make target to install selftests
Date: Tue, 11 Nov 2014 13:27:42 -0700
Message-ID: <a2344d4df903d673afe1631118f40917f773cc9a.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to install to install kernel selftests.
This new target will build and install selftests. kselftest
target now depends on kselftest_install and runs the generated
kselftest script to reduce duplicate work and for common look
and feel when running tests.

Approach:

make kselftest_target:
-- exports kselftest INSTALL_KSFT_PATH
   default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
-- exports path for ksefltest.sh
-- runs selftests make install target:

selftests make install target
-- creates kselftest.sh script in install install dir
-- runs install targets for all INSTALL_TARGETS
   (Note: ftrace and powerpc aren't included in INSTALL_TARGETS,
          to not add more content to patch v1 series. This work
          will happen soon. In this series these two targets are
          run after running the generated kselftest script, without
          any regression in the way these tests are run with
          "make kselftest" prior to this work.)
-- install target can be run only from top level source dir.

Individual test make install targets:
-- install test programs and/or scripts in install dir
-- append to the ksefltest.sh file to add commands to run test
-- install target can be run only from top level source dir.

Adds the following new ways to initiate selftests:
-- Installing and running kselftest from install directory
   by running  "make kselftest"
-- Running kselftest script from install directory

Maintains the following ways to run tests:
-- make -C tools/testing/selftests run_tests
-- make -C tools/testing/selftests TARGETS=target run_tests
   Ability specify targets: e.g TARGETS=net
-- make run_tests from tools/testing/selftests
-- make run_tests from individual test directories:
   e.g: make run_tests in tools/testing/selftests/breakpoints

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Makefile | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index 05d67af..ccbd2e1 100644
--- a/Makefile
+++ b/Makefile
@@ -1071,12 +1071,26 @@ headers_check: headers_install
 	$(Q)$(MAKE) $(hdr-inst)=arch/$(hdr-arch)/include/uapi/asm $(hdr-dst) HDRCHECK=1
 
 # ---------------------------------------------------------------------------
-# Kernel selftest
+# Kernel selftest targets
+
+PHONY += __kselftest_configure
+INSTALL_KSFT_PATH=$(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
+export INSTALL_KSFT_PATH
+KSELFTEST=$(INSTALL_KSFT_PATH)/kselftest.sh
+export KSELFTEST
 
 PHONY += kselftest
-kselftest:
+kselftest: kselftest_install
 	$(Q)$(MAKE) -C tools/testing/selftests run_tests
 
+# Kernel selftest install
+
+PHONY += kselftest_install
+kselftest_install: __kselftest_configure
+	@rm -rf $(INSTALL_KSFT_PATH)
+	@mkdir -p $(INSTALL_KSFT_PATH)
+	$(Q)$(MAKE) -C tools/testing/selftests install
+
 # ---------------------------------------------------------------------------
 # Modules
 
@@ -1285,6 +1299,9 @@ help:
 	@echo  '                    Build, install, and boot kernel before'
 	@echo  '                    running kselftest on it'
 	@echo  ''
+	@echo  '  kselftest_install - Install Kselftests to INSTALL_KSFT_PATH'
+	@echo  '                      default: $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)'
+	@echo  ''
 	@echo  'Kernel packaging:'
 	@$(MAKE) $(build)=$(package-dir) help
 	@echo  ''
-- 
1.9.1
