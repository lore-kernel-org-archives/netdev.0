From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 2/6] selftests: Add install target
Date: Fri,  9 Jan 2015 20:06:11 +1100
Message-ID: <1420794375-31881-2-git-send-email-mpe@ellerman.id.au>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
Cc: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	cov@codeaurora.org, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com,
	linux-kbuild@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, shuahkh@osg.samsung.com
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds make install support to selftests. The basic usage is:

$ cd tools/testing/selftests
$ make install

That installs into tools/testing/selftests/install, which can then be
copied where ever necessary.

The install destination is also configurable using eg:

$ INSTALL_PATH=/mnt/selftests make install

The implementation uses two targets in the child makefiles. The first
"install" is expected to install all files into $(INSTALL_PATH).

The second, "emit_tests", is expected to emit the test instructions (ie.
bash script) on stdout. Separating this from install means the child
makefiles need no knowledge of the location of the test script.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 tools/testing/selftests/Makefile                | 32 +++++++++++++++++++++++++
 tools/testing/selftests/exec/Makefile           |  3 +++
 tools/testing/selftests/lib.mk                  | 23 +++++++++++++++++-
 tools/testing/selftests/memory-hotplug/Makefile |  2 ++
 tools/testing/selftests/mount/Makefile          |  2 ++
 tools/testing/selftests/mqueue/Makefile         |  7 ++++++
 tools/testing/selftests/net/Makefile            |  1 +
 tools/testing/selftests/sysctl/Makefile         |  1 +
 8 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 4e511221a0c1..4f2849b5ff77 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -47,7 +47,39 @@ clean_hotplug:
 		make -C $$TARGET clean; \
 	done;
 
+INSTALL_PATH ?= install
+INSTALL_PATH := $(abspath $(INSTALL_PATH))
+ALL_SCRIPT := $(INSTALL_PATH)/all.sh
+
+install:
+ifdef INSTALL_PATH
+	@# Ask all targets to install their files
+	mkdir -p $(INSTALL_PATH)
+	for TARGET in $(TARGETS); do \
+		mkdir -p $(INSTALL_PATH)/$$TARGET ; \
+		make -C $$TARGET INSTALL_PATH=$(INSTALL_PATH)/$$TARGET install; \
+	done;
+
+	@# Ask all targets to emit their test scripts
+	echo "#!/bin/bash\n\n" > $(ALL_SCRIPT)
+	echo "ROOT=\$$PWD\n" >> $(ALL_SCRIPT)
+
+	for TARGET in $(TARGETS); do \
+		echo "echo ; echo Running tests in $$TARGET" >> $(ALL_SCRIPT); \
+		echo "echo ========================================" >> $(ALL_SCRIPT); \
+		echo "cd $$TARGET" >> $(ALL_SCRIPT); \
+		make -s -C $$TARGET emit_tests >> $(ALL_SCRIPT); \
+		echo "cd \$$ROOT\n" >> $(ALL_SCRIPT); \
+	done;
+
+	chmod u+x $(ALL_SCRIPT)
+else
+	$(error Error: set INSTALL_PATH to use install)
+endif
+
 clean:
 	for TARGET in $(TARGETS); do \
 		make -C $$TARGET clean; \
 	done;
+
+.PHONY: install
diff --git a/tools/testing/selftests/exec/Makefile b/tools/testing/selftests/exec/Makefile
index a0098daeb73d..886cabe307b1 100644
--- a/tools/testing/selftests/exec/Makefile
+++ b/tools/testing/selftests/exec/Makefile
@@ -19,8 +19,11 @@ execveat.denatured: execveat
 	$(CC) $(CFLAGS) -o $@ $^
 
 TEST_PROGS := execveat
+TEST_FILES := $(DEPS)
 
 include ../lib.mk
 
+override EMIT_TESTS := echo "mkdir -p subdir; (./execveat && echo \"selftests: execveat [PASS]\") || echo \"selftests: execveat [FAIL]\""
+
 clean:
 	rm -rf $(BINARIES) $(DEPS) subdir.moved execveat.moved xxxxx*
diff --git a/tools/testing/selftests/lib.mk b/tools/testing/selftests/lib.mk
index b30c5a49cb61..7bd3dabe2846 100644
--- a/tools/testing/selftests/lib.mk
+++ b/tools/testing/selftests/lib.mk
@@ -7,4 +7,25 @@ endef
 run_tests: all
 	$(RUN_TESTS)
 
-.PHONY: run_tests all clean
+define INSTALL_RULE
+	mkdir -p $(INSTALL_PATH)
+	install -t $(INSTALL_PATH) $(TEST_PROGS) $(TEST_FILES)
+endef
+
+install: all
+ifdef INSTALL_PATH
+	$(INSTALL_RULE)
+else
+	$(error Error: set INSTALL_PATH to use install)
+endif
+
+define EMIT_TESTS
+	@for TEST in $(TEST_PROGS); do \
+		echo "(./$$TEST && echo \"selftests: $$TEST [PASS]\") || echo \"selftests: $$TEST [FAIL]\""; \
+	done;
+endef
+
+emit_tests:
+	$(EMIT_TESTS)
+
+.PHONY: run_tests all clean install emit_tests
diff --git a/tools/testing/selftests/memory-hotplug/Makefile b/tools/testing/selftests/memory-hotplug/Makefile
index 8f7dea66ecac..598a1f68f534 100644
--- a/tools/testing/selftests/memory-hotplug/Makefile
+++ b/tools/testing/selftests/memory-hotplug/Makefile
@@ -2,7 +2,9 @@ all:
 
 include ../lib.mk
 
+TEST_PROGS := on-off-test.sh
 override RUN_TESTS := ./on-off-test.sh -r 2 || echo "selftests: memory-hotplug [FAIL]"
+override EMIT_TESTS := echo "$(RUN_TESTS)"
 
 run_full_test:
 	@/bin/bash ./on-off-test.sh || echo "memory-hotplug selftests: [FAIL]"
diff --git a/tools/testing/selftests/mount/Makefile b/tools/testing/selftests/mount/Makefile
index 06931dfd3ef0..a5b367f032ba 100644
--- a/tools/testing/selftests/mount/Makefile
+++ b/tools/testing/selftests/mount/Makefile
@@ -7,7 +7,9 @@ unprivileged-remount-test: unprivileged-remount-test.c
 
 include ../lib.mk
 
+TEST_PROGS := unprivileged-remount-test
 override RUN_TESTS := if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
+override EMIT_TESTS := echo "$(RUN_TESTS)"
 
 clean:
 	rm -f unprivileged-remount-test
diff --git a/tools/testing/selftests/mqueue/Makefile b/tools/testing/selftests/mqueue/Makefile
index cbc300ef11bf..6ca7261b55dc 100644
--- a/tools/testing/selftests/mqueue/Makefile
+++ b/tools/testing/selftests/mqueue/Makefile
@@ -9,5 +9,12 @@ override define RUN_TESTS
 	@./mq_perf_tests || echo "selftests: mq_perf_tests [FAIL]"
 endef
 
+TEST_PROGS := mq_open_tests mq_perf_tests
+
+override define EMIT_TESTS
+	echo "./mq_open_tests /test1 || echo \"selftests: mq_open_tests [FAIL]\""
+	echo "./mq_perf_tests || echo \"selftests: mq_perf_tests [FAIL]\""
+endef
+
 clean:
 	rm -f mq_open_tests mq_perf_tests
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index fa8187ff15e6..6ba2ac7bbb0d 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -12,6 +12,7 @@ all: $(NET_PROGS)
 	$(CC) $(CFLAGS) -o $@ $^
 
 TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh
+TEST_FILES := $(NET_PROGS)
 
 include ../lib.mk
 
diff --git a/tools/testing/selftests/sysctl/Makefile b/tools/testing/selftests/sysctl/Makefile
index c9660f5ef9f9..b3c33e071f10 100644
--- a/tools/testing/selftests/sysctl/Makefile
+++ b/tools/testing/selftests/sysctl/Makefile
@@ -5,6 +5,7 @@
 all:
 
 TEST_PROGS := run_numerictests run_stringtests
+TEST_FILES := common_tests
 
 include ../lib.mk
 
-- 
2.1.0

