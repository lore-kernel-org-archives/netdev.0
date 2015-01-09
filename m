From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 1/6] selftests: Introduce minimal shared logic for running tests
Date: Fri,  9 Jan 2015 20:06:10 +1100
Message-ID: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a Make include file which most selftests can then include to
get the run_tests logic.

On its own this has the advantage of some reduction in repetition, and
also means the pass/fail message is defined in fewer places.

However the key advantage is it will allow us to implement install very
simply in a subsequent patch.

The default implementation just executes each program in $(TEST_PROGS).

We use a variable to hold the default implementation of $(RUN_TESTS)
because that gives us a clean way to override it if necessary, ie. using
override. The mount, memory-hotplug and mqueue tests use that to provide
a different implementation.

Tests are not run via /bin/bash, so if they are scripts they must be
executable, we add u+x to several.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 tools/testing/selftests/breakpoints/Makefile       |  5 +++--
 tools/testing/selftests/cpu-hotplug/Makefile       |  5 +++--
 tools/testing/selftests/cpu-hotplug/on-off-test.sh |  0
 tools/testing/selftests/efivarfs/Makefile          |  5 +++--
 tools/testing/selftests/efivarfs/efivarfs.sh       |  0
 tools/testing/selftests/exec/Makefile              |  5 +++--
 tools/testing/selftests/firmware/Makefile          | 20 ++------------------
 tools/testing/selftests/firmware/fw_filesystem.sh  |  0
 tools/testing/selftests/firmware/fw_userhelper.sh  |  0
 tools/testing/selftests/ftrace/Makefile            |  5 +++--
 tools/testing/selftests/ipc/Makefile               |  5 +++--
 tools/testing/selftests/kcmp/Makefile              |  5 +++--
 tools/testing/selftests/lib.mk                     | 10 ++++++++++
 tools/testing/selftests/memfd/Makefile             |  6 +++---
 tools/testing/selftests/memory-hotplug/Makefile    |  5 +++--
 tools/testing/selftests/mount/Makefile             |  8 ++------
 tools/testing/selftests/mqueue/Makefile            |  9 ++++++---
 tools/testing/selftests/net/Makefile               |  8 ++++----
 tools/testing/selftests/ptrace/Makefile            |  5 +++--
 tools/testing/selftests/size/Makefile              |  5 +++--
 tools/testing/selftests/sysctl/Makefile            | 11 ++---------
 tools/testing/selftests/timers/Makefile            |  5 +++--
 tools/testing/selftests/user/Makefile              |  5 +++--
 tools/testing/selftests/vm/Makefile                |  5 +++--
 24 files changed, 68 insertions(+), 69 deletions(-)
 mode change 100644 => 100755 tools/testing/selftests/cpu-hotplug/on-off-test.sh
 mode change 100644 => 100755 tools/testing/selftests/efivarfs/efivarfs.sh
 mode change 100644 => 100755 tools/testing/selftests/firmware/fw_filesystem.sh
 mode change 100644 => 100755 tools/testing/selftests/firmware/fw_userhelper.sh
 create mode 100644 tools/testing/selftests/lib.mk

diff --git a/tools/testing/selftests/breakpoints/Makefile b/tools/testing/selftests/breakpoints/Makefile
index e18b42b254af..182235640209 100644
--- a/tools/testing/selftests/breakpoints/Makefile
+++ b/tools/testing/selftests/breakpoints/Makefile
@@ -16,8 +16,9 @@ else
 	echo "Not an x86 target, can't build breakpoints selftests"
 endif
 
-run_tests:
-	@./breakpoint_test || echo "breakpoints selftests: [FAIL]"
+TEST_PROGS := breakpoint_test
+
+include ../lib.mk
 
 clean:
 	rm -fr breakpoint_test
diff --git a/tools/testing/selftests/cpu-hotplug/Makefile b/tools/testing/selftests/cpu-hotplug/Makefile
index e9c28d8dc84b..15f02591d22c 100644
--- a/tools/testing/selftests/cpu-hotplug/Makefile
+++ b/tools/testing/selftests/cpu-hotplug/Makefile
@@ -1,7 +1,8 @@
 all:
 
-run_tests:
-	@/bin/bash ./on-off-test.sh || echo "cpu-hotplug selftests: [FAIL]"
+TEST_PROGS := on-off-test.sh
+
+include ../lib.mk
 
 run_full_test:
 	@/bin/bash ./on-off-test.sh -a || echo "cpu-hotplug selftests: [FAIL]"
diff --git a/tools/testing/selftests/cpu-hotplug/on-off-test.sh b/tools/testing/selftests/cpu-hotplug/on-off-test.sh
old mode 100644
new mode 100755
diff --git a/tools/testing/selftests/efivarfs/Makefile b/tools/testing/selftests/efivarfs/Makefile
index 29e8c6bc81b0..3052d0bda24b 100644
--- a/tools/testing/selftests/efivarfs/Makefile
+++ b/tools/testing/selftests/efivarfs/Makefile
@@ -5,8 +5,9 @@ test_objs = open-unlink create-read
 
 all: $(test_objs)
 
-run_tests: all
-	@/bin/bash ./efivarfs.sh || echo "efivarfs selftests: [FAIL]"
+TEST_PROGS := efivarfs.sh
+
+include ../lib.mk
 
 clean:
 	rm -f $(test_objs)
diff --git a/tools/testing/selftests/efivarfs/efivarfs.sh b/tools/testing/selftests/efivarfs/efivarfs.sh
old mode 100644
new mode 100755
diff --git a/tools/testing/selftests/exec/Makefile b/tools/testing/selftests/exec/Makefile
index 66dfc2ce1788..a0098daeb73d 100644
--- a/tools/testing/selftests/exec/Makefile
+++ b/tools/testing/selftests/exec/Makefile
@@ -18,8 +18,9 @@ execveat.denatured: execveat
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
-run_tests: all
-	./execveat
+TEST_PROGS := execveat
+
+include ../lib.mk
 
 clean:
 	rm -rf $(BINARIES) $(DEPS) subdir.moved execveat.moved xxxxx*
diff --git a/tools/testing/selftests/firmware/Makefile b/tools/testing/selftests/firmware/Makefile
index e23cce0bbc3a..9bf82234855b 100644
--- a/tools/testing/selftests/firmware/Makefile
+++ b/tools/testing/selftests/firmware/Makefile
@@ -3,25 +3,9 @@
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests"
 all:
 
-fw_filesystem:
-	@if /bin/sh ./fw_filesystem.sh ; then \
-                echo "fw_filesystem: ok"; \
-        else \
-                echo "fw_filesystem: [FAIL]"; \
-                exit 1; \
-        fi
+TEST_PROGS := fw_filesystem.sh fw_userhelper.sh
 
-fw_userhelper:
-	@if /bin/sh ./fw_userhelper.sh ; then \
-                echo "fw_userhelper: ok"; \
-        else \
-                echo "fw_userhelper: [FAIL]"; \
-                exit 1; \
-        fi
-
-run_tests: all fw_filesystem fw_userhelper
+include ../lib.mk
 
 # Nothing to clean up.
 clean:
-
-.PHONY: all clean run_tests fw_filesystem fw_userhelper
diff --git a/tools/testing/selftests/firmware/fw_filesystem.sh b/tools/testing/selftests/firmware/fw_filesystem.sh
old mode 100644
new mode 100755
diff --git a/tools/testing/selftests/firmware/fw_userhelper.sh b/tools/testing/selftests/firmware/fw_userhelper.sh
old mode 100644
new mode 100755
diff --git a/tools/testing/selftests/ftrace/Makefile b/tools/testing/selftests/ftrace/Makefile
index 76cc9f156267..346720639d1d 100644
--- a/tools/testing/selftests/ftrace/Makefile
+++ b/tools/testing/selftests/ftrace/Makefile
@@ -1,7 +1,8 @@
 all:
 
-run_tests:
-	@/bin/sh ./ftracetest || echo "ftrace selftests: [FAIL]"
+TEST_PROGS := ftracetest
+
+include ../lib.mk
 
 clean:
 	rm -rf logs/*
diff --git a/tools/testing/selftests/ipc/Makefile b/tools/testing/selftests/ipc/Makefile
index 74bbefdeaf4c..3b6013da4f59 100644
--- a/tools/testing/selftests/ipc/Makefile
+++ b/tools/testing/selftests/ipc/Makefile
@@ -18,8 +18,9 @@ else
 	echo "Not an x86 target, can't build msgque selftest"
 endif
 
-run_tests: all
-	./msgque_test
+TEST_PROGS := msgque_test
+
+include ../lib.mk
 
 clean:
 	rm -fr ./msgque_test
diff --git a/tools/testing/selftests/kcmp/Makefile b/tools/testing/selftests/kcmp/Makefile
index ff0eefdc6ceb..0eecd183058c 100644
--- a/tools/testing/selftests/kcmp/Makefile
+++ b/tools/testing/selftests/kcmp/Makefile
@@ -3,8 +3,9 @@ CFLAGS += -I../../../../usr/include/
 
 all: kcmp_test
 
-run_tests: all
-	@./kcmp_test || echo "kcmp_test: [FAIL]"
+TEST_PROGS := kcmp_test
+
+include ../lib.mk
 
 clean:
 	$(RM) kcmp_test kcmp-test-file
diff --git a/tools/testing/selftests/lib.mk b/tools/testing/selftests/lib.mk
new file mode 100644
index 000000000000..b30c5a49cb61
--- /dev/null
+++ b/tools/testing/selftests/lib.mk
@@ -0,0 +1,10 @@
+define RUN_TESTS
+	@for TEST in $(TEST_PROGS); do \
+		(./$$TEST && echo "selftests: $$TEST [PASS]") || echo "selftests: $$TEST [FAIL]"; \
+	done;
+endef
+
+run_tests: all
+	$(RUN_TESTS)
+
+.PHONY: run_tests all clean
diff --git a/tools/testing/selftests/memfd/Makefile b/tools/testing/selftests/memfd/Makefile
index b80cd10d53ba..191dee9d6fd3 100644
--- a/tools/testing/selftests/memfd/Makefile
+++ b/tools/testing/selftests/memfd/Makefile
@@ -5,9 +5,9 @@ CFLAGS += -I../../../../include/
 all:
 	gcc $(CFLAGS) memfd_test.c -o memfd_test
 
-run_tests: all
-	gcc $(CFLAGS) memfd_test.c -o memfd_test
-	@./memfd_test || echo "memfd_test: [FAIL]"
+TEST_PROGS := memfd_test
+
+include ../lib.mk
 
 build_fuse:
 	gcc $(CFLAGS) fuse_mnt.c `pkg-config fuse --cflags --libs` -o fuse_mnt
diff --git a/tools/testing/selftests/memory-hotplug/Makefile b/tools/testing/selftests/memory-hotplug/Makefile
index d46b8d489cd2..8f7dea66ecac 100644
--- a/tools/testing/selftests/memory-hotplug/Makefile
+++ b/tools/testing/selftests/memory-hotplug/Makefile
@@ -1,7 +1,8 @@
 all:
 
-run_tests:
-	@/bin/bash ./on-off-test.sh -r 2 || echo "memory-hotplug selftests: [FAIL]"
+include ../lib.mk
+
+override RUN_TESTS := ./on-off-test.sh -r 2 || echo "selftests: memory-hotplug [FAIL]"
 
 run_full_test:
 	@/bin/bash ./on-off-test.sh || echo "memory-hotplug selftests: [FAIL]"
diff --git a/tools/testing/selftests/mount/Makefile b/tools/testing/selftests/mount/Makefile
index 337d853c2b72..06931dfd3ef0 100644
--- a/tools/testing/selftests/mount/Makefile
+++ b/tools/testing/selftests/mount/Makefile
@@ -5,13 +5,9 @@ all: unprivileged-remount-test
 unprivileged-remount-test: unprivileged-remount-test.c
 	gcc -Wall -O2 unprivileged-remount-test.c -o unprivileged-remount-test
 
-# Allow specific tests to be selected.
-test_unprivileged_remount: unprivileged-remount-test
-	@if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
+include ../lib.mk
 
-run_tests: all test_unprivileged_remount
+override RUN_TESTS := if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
 
 clean:
 	rm -f unprivileged-remount-test
-
-.PHONY: all test_unprivileged_remount
diff --git a/tools/testing/selftests/mqueue/Makefile b/tools/testing/selftests/mqueue/Makefile
index 8056e2e68fa4..cbc300ef11bf 100644
--- a/tools/testing/selftests/mqueue/Makefile
+++ b/tools/testing/selftests/mqueue/Makefile
@@ -2,9 +2,12 @@ all:
 	gcc -O2 mq_open_tests.c -o mq_open_tests -lrt
 	gcc -O2 -o mq_perf_tests mq_perf_tests.c -lrt -lpthread -lpopt
 
-run_tests:
-	@./mq_open_tests /test1 || echo "mq_open_tests: [FAIL]"
-	@./mq_perf_tests || echo "mq_perf_tests: [FAIL]"
+include ../lib.mk
+
+override define RUN_TESTS
+	@./mq_open_tests /test1 || echo "selftests: mq_open_tests [FAIL]"
+	@./mq_perf_tests || echo "selftests: mq_perf_tests [FAIL]"
+endef
 
 clean:
 	rm -f mq_open_tests mq_perf_tests
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 62f22cc9941c..fa8187ff15e6 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -11,9 +11,9 @@ all: $(NET_PROGS)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
-run_tests: all
-	@/bin/sh ./run_netsocktests || echo "sockettests: [FAIL]"
-	@/bin/sh ./run_afpackettests || echo "afpackettests: [FAIL]"
-	./test_bpf.sh
+TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh
+
+include ../lib.mk
+
 clean:
 	$(RM) $(NET_PROGS)
diff --git a/tools/testing/selftests/ptrace/Makefile b/tools/testing/selftests/ptrace/Makefile
index 47ae2d385ce8..453927fea90c 100644
--- a/tools/testing/selftests/ptrace/Makefile
+++ b/tools/testing/selftests/ptrace/Makefile
@@ -6,5 +6,6 @@ all: peeksiginfo
 clean:
 	rm -f peeksiginfo
 
-run_tests: all
-	@./peeksiginfo || echo "peeksiginfo selftests: [FAIL]"
+TEST_PROGS := peeksiginfo
+
+include ../lib.mk
diff --git a/tools/testing/selftests/size/Makefile b/tools/testing/selftests/size/Makefile
index 04dc25e4fa92..e4353d74ea6e 100644
--- a/tools/testing/selftests/size/Makefile
+++ b/tools/testing/selftests/size/Makefile
@@ -5,8 +5,9 @@ all: get_size
 get_size: get_size.c
 	$(CC) -static -ffreestanding -nostartfiles -s $< -o $@
 
-run_tests: all
-	./get_size
+TEST_PROGS := get_size
+
+include ../lib.mk
 
 clean:
 	$(RM) get_size
diff --git a/tools/testing/selftests/sysctl/Makefile b/tools/testing/selftests/sysctl/Makefile
index 0a92adaf0865..c9660f5ef9f9 100644
--- a/tools/testing/selftests/sysctl/Makefile
+++ b/tools/testing/selftests/sysctl/Makefile
@@ -4,16 +4,9 @@
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests".
 all:
 
-# Allow specific tests to be selected.
-test_num:
-	@/bin/sh ./run_numerictests
+TEST_PROGS := run_numerictests run_stringtests
 
-test_string:
-	@/bin/sh ./run_stringtests
-
-run_tests: all test_num test_string
+include ../lib.mk
 
 # Nothing to clean up.
 clean:
-
-.PHONY: all run_tests clean test_num test_string
diff --git a/tools/testing/selftests/timers/Makefile b/tools/testing/selftests/timers/Makefile
index eb2859f4ad21..149cee3b7b8a 100644
--- a/tools/testing/selftests/timers/Makefile
+++ b/tools/testing/selftests/timers/Makefile
@@ -1,8 +1,9 @@
 all:
 	gcc posix_timers.c -o posix_timers -lrt
 
-run_tests: all
-	./posix_timers
+TEST_PROGS := posix_timers
+
+include ../lib.mk
 
 clean:
 	rm -f ./posix_timers
diff --git a/tools/testing/selftests/user/Makefile b/tools/testing/selftests/user/Makefile
index 12c9d15bab07..d401b63c5b1a 100644
--- a/tools/testing/selftests/user/Makefile
+++ b/tools/testing/selftests/user/Makefile
@@ -3,5 +3,6 @@
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests"
 all:
 
-run_tests: all
-	./test_user_copy.sh
+TEST_PROGS := test_user_copy.sh
+
+include ../lib.mk
diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 4c4b1f631ecf..c0462182ec37 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -9,8 +9,9 @@ all: $(BINARIES)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
-run_tests: all
-	@/bin/sh ./run_vmtests || (echo "vmtests: [FAIL]"; exit 1)
+TEST_PROGS := run_vmtests
+
+include ../lib.mk
 
 clean:
 	$(RM) $(BINARIES)
-- 
2.1.0
