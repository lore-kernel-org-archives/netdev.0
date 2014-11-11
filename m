From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 00/19] kselftest install target feature
Date: Tue, 11 Nov 2014 13:27:40 -0700
Message-ID: <cover.1415735831.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kbuild-owner@vger.kernel.org>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds a new kselftest_install make target
to enable selftest install. When make kselftest_install is
run, selftests are installed on the system. A new install
target is added to selftests Makefile which will install
targets for the tests that are specified in INSTALL_TARGETS.
During install, a script is generated to run tests that are
installed. This script will be installed in the selftest install
directory. Individual test Makefiles are changed to add to the
script. This will allow new tests to add install and run test
commands to the generated kselftest script. kselftest target
now depends on kselftest_install and runs the generated kselftest
script to reduce duplicate work and for common look and feel when
running tests.

This v2 series addresses the duplicate code in install and
run_tests targets in individual test Makefiles.
Reference: https://lkml.org/lkml/2014/11/4/707

Dropped the following patch from the series since it has been
Acked and I queued it up for 3.19-rc1.

selftests/net: move test out of Makefile into a shell script
Reference: https://lkml.org/lkml/2014/11/4/794

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

Shuah Khan (19):
  selftests/user: move test out of Makefile into a shell script
  kbuild: kselftest_install - add a new make target to install selftests
  selftests: add install target to enable installing selftests
  selftests/breakpoints: add install target to enable installing test
  selftests/cpu-hotplug: add install target to enable installing test
  selftests/efivarfs: add install target to enable installing test
  selftests/firmware: add install target to enable installing test
  selftests/ipc: add install target to enable installing test
  selftests/kcmp: add install target to enable installing test
  selftests/memfd: add install target to enable installing test
  selftests/memory-hotplug: add install target to enable installing test
  selftests/mount: add install target to enable installing test
  selftests/mqueue: add install target to enable installing test
  selftests/net: add install target to enable installing test
  selftests/ptrace: add install target to enable installing test
  selftests/sysctl: add install target to enable installing test
  selftests/timers: add install target to enable installing test
  selftests/vm: add install target to enable installing test
  selftests/user: add install target to enable installing test

 Makefile                                           |  21 +-
 tools/testing/selftests/Makefile                   |  31 ++-
 tools/testing/selftests/breakpoints/Makefile       |  22 +-
 tools/testing/selftests/cpu-hotplug/Makefile       |  17 +-
 .../selftests/cpu-hotplug/cpu-on-off-test.sh       | 269 +++++++++++++++++++++
 tools/testing/selftests/cpu-hotplug/on-off-test.sh | 269 ---------------------
 tools/testing/selftests/efivarfs/Makefile          |  19 +-
 tools/testing/selftests/firmware/Makefile          |  49 ++--
 tools/testing/selftests/ipc/Makefile               |  22 +-
 tools/testing/selftests/kcmp/Makefile              |  22 +-
 tools/testing/selftests/memfd/Makefile             |  20 +-
 tools/testing/selftests/memory-hotplug/Makefile    |  17 +-
 .../selftests/memory-hotplug/mem-on-off-test.sh    | 238 ++++++++++++++++++
 .../selftests/memory-hotplug/on-off-test.sh        | 238 ------------------
 tools/testing/selftests/mount/Makefile             |  15 +-
 tools/testing/selftests/mqueue/Makefile            |  20 +-
 tools/testing/selftests/net/Makefile               |  23 +-
 tools/testing/selftests/ptrace/Makefile            |  19 +-
 tools/testing/selftests/sysctl/Makefile            |  23 +-
 tools/testing/selftests/timers/Makefile            |  15 +-
 tools/testing/selftests/user/Makefile              |  21 +-
 tools/testing/selftests/user/test_user_copy.sh     |  10 +
 tools/testing/selftests/vm/Makefile                |  14 +-
 23 files changed, 853 insertions(+), 561 deletions(-)
 create mode 100644 tools/testing/selftests/cpu-hotplug/cpu-on-off-test.sh
 delete mode 100644 tools/testing/selftests/cpu-hotplug/on-off-test.sh
 create mode 100644 tools/testing/selftests/memory-hotplug/mem-on-off-test.sh
 delete mode 100644 tools/testing/selftests/memory-hotplug/on-off-test.sh
 create mode 100755 tools/testing/selftests/user/test_user_copy.sh

-- 
1.9.1

