From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 3/6] selftests: Add install support for the powerpc tests
Date: Fri,  9 Jan 2015 20:06:12 +1100
Message-ID: <1420794375-31881-3-git-send-email-mpe@ellerman.id.au>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:33032 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755724AbbAIJGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2015 04:06:48 -0500
In-Reply-To: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bulk of the selftests are actually below the powerpc sub directory.

This adds support for installing them, when on a powerpc machine, or if
ARCH and CROSS_COMPILE are set appropriately.

This is a little more complicated because of the sub directory structure
under powerpc, but much of the common logic in lib.mk is still used. The
net effect of the patch is still a reduction in code.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 tools/testing/selftests/powerpc/Makefile           | 19 ++++++++-
 tools/testing/selftests/powerpc/copyloops/Makefile | 15 +++----
 tools/testing/selftests/powerpc/mm/Makefile        | 15 +++----
 tools/testing/selftests/powerpc/pmu/Makefile       | 48 ++++++++++++----------
 tools/testing/selftests/powerpc/pmu/ebb/Makefile   | 13 +++---
 .../testing/selftests/powerpc/primitives/Makefile  | 15 +++----
 tools/testing/selftests/powerpc/tm/Makefile        | 15 +++----
 7 files changed, 68 insertions(+), 72 deletions(-)

diff --git a/tools/testing/selftests/powerpc/Makefile b/tools/testing/selftests/powerpc/Makefile
index f6ff90a76bd7..d2d19db7eda7 100644
--- a/tools/testing/selftests/powerpc/Makefile
+++ b/tools/testing/selftests/powerpc/Makefile
@@ -22,10 +22,25 @@ all: $(TARGETS)
 $(TARGETS):
 	$(MAKE) -k -C $@ all
 
-run_tests: all
+include ../lib.mk
+
+override define RUN_TESTS
 	@for TARGET in $(TARGETS); do \
 		$(MAKE) -C $$TARGET run_tests; \
 	done;
+endef
+
+override define INSTALL_RULE
+	@for TARGET in $(TARGETS); do \
+		$(MAKE) -C $$TARGET install; \
+	done;
+endef
+
+override define EMIT_TESTS
+	@for TARGET in $(TARGETS); do \
+		$(MAKE) -s -C $$TARGET emit_tests; \
+	done;
+endef
 
 clean:
 	@for TARGET in $(TARGETS); do \
@@ -36,4 +51,4 @@ clean:
 tags:
 	find . -name '*.c' -o -name '*.h' | xargs ctags
 
-.PHONY: all run_tests clean tags $(TARGETS)
+.PHONY: tags $(TARGETS)
diff --git a/tools/testing/selftests/powerpc/copyloops/Makefile b/tools/testing/selftests/powerpc/copyloops/Makefile
index 6f2d3be227f9..c05023514ce8 100644
--- a/tools/testing/selftests/powerpc/copyloops/Makefile
+++ b/tools/testing/selftests/powerpc/copyloops/Makefile
@@ -6,24 +6,19 @@ CFLAGS += -D SELFTEST
 # Use our CFLAGS for the implicit .S rule
 ASFLAGS = $(CFLAGS)
 
-PROGS := copyuser_64 copyuser_power7 memcpy_64 memcpy_power7
+TEST_PROGS := copyuser_64 copyuser_power7 memcpy_64 memcpy_power7
 EXTRA_SOURCES := validate.c ../harness.c
 
-all: $(PROGS)
+all: $(TEST_PROGS)
 
 copyuser_64:     CPPFLAGS += -D COPY_LOOP=test___copy_tofrom_user_base
 copyuser_power7: CPPFLAGS += -D COPY_LOOP=test___copy_tofrom_user_power7
 memcpy_64:       CPPFLAGS += -D COPY_LOOP=test_memcpy
 memcpy_power7:   CPPFLAGS += -D COPY_LOOP=test_memcpy_power7
 
-$(PROGS): $(EXTRA_SOURCES)
+$(TEST_PROGS): $(EXTRA_SOURCES)
 
-run_tests: all
-	@-for PROG in $(PROGS); do \
-		./$$PROG; \
-	done;
+include ../../lib.mk
 
 clean:
-	rm -f $(PROGS) *.o
-
-.PHONY: all run_tests clean
+	rm -f $(TEST_PROGS) *.o
diff --git a/tools/testing/selftests/powerpc/mm/Makefile b/tools/testing/selftests/powerpc/mm/Makefile
index 357ccbd6bad9..e3b5fa360520 100644
--- a/tools/testing/selftests/powerpc/mm/Makefile
+++ b/tools/testing/selftests/powerpc/mm/Makefile
@@ -1,18 +1,13 @@
 noarg:
 	$(MAKE) -C ../
 
-PROGS := hugetlb_vs_thp_test
+TEST_PROGS := hugetlb_vs_thp_test
 
-all: $(PROGS)
+all: $(TEST_PROGS)
 
-$(PROGS): ../harness.c
+$(TEST_PROGS): ../harness.c
 
-run_tests: all
-	@-for PROG in $(PROGS); do \
-		./$$PROG; \
-	done;
+include ../../lib.mk
 
 clean:
-	rm -f $(PROGS)
-
-.PHONY: all run_tests clean
+	rm -f $(TEST_PROGS)
diff --git a/tools/testing/selftests/powerpc/pmu/Makefile b/tools/testing/selftests/powerpc/pmu/Makefile
index c9f4263906a5..5a161175bbd4 100644
--- a/tools/testing/selftests/powerpc/pmu/Makefile
+++ b/tools/testing/selftests/powerpc/pmu/Makefile
@@ -1,38 +1,42 @@
 noarg:
 	$(MAKE) -C ../
 
-PROGS := count_instructions l3_bank_test per_event_excludes
+TEST_PROGS := count_instructions l3_bank_test per_event_excludes
 EXTRA_SOURCES := ../harness.c event.c lib.c
 
-SUB_TARGETS = ebb
+all: $(TEST_PROGS) ebb
 
-all: $(PROGS) $(SUB_TARGETS)
-
-$(PROGS): $(EXTRA_SOURCES)
+$(TEST_PROGS): $(EXTRA_SOURCES)
 
 # loop.S can only be built 64-bit
 count_instructions: loop.S count_instructions.c $(EXTRA_SOURCES)
 	$(CC) $(CFLAGS) -m64 -o $@ $^
 
-run_tests: all sub_run_tests
-	@-for PROG in $(PROGS); do \
-		./$$PROG; \
-	done;
+include ../../lib.mk
 
-clean: sub_clean
-	rm -f $(PROGS) loop.o
+DEFAULT_RUN_TESTS := $(RUN_TESTS)
+override define RUN_TESTS
+	$(DEFAULT_RUN_TESTS)
+	$(MAKE) -C ebb run_tests
+endef
 
-$(SUB_TARGETS):
-	$(MAKE) -k -C $@ all
+DEFAULT_EMIT_TESTS := $(EMIT_TESTS)
+override define EMIT_TESTS
+	$(DEFAULT_EMIT_TESTS)
+	$(MAKE) -s -C ebb emit_tests
+endef
 
-sub_run_tests: all
-	@for TARGET in $(SUB_TARGETS); do \
-		$(MAKE) -C $$TARGET run_tests; \
-	done;
+DEFAULT_INSTALL := $(INSTALL_RULE)
+override define INSTALL_RULE
+	$(DEFAULT_INSTALL_RULE)
+	$(MAKE) -C ebb install
+endef
 
-sub_clean:
-	@for TARGET in $(SUB_TARGETS); do \
-		$(MAKE) -C $$TARGET clean; \
-	done;
+clean:
+	rm -f $(TEST_PROGS) loop.o
+	$(MAKE) -C ebb clean
+
+ebb:
+	$(MAKE) -k -C $@ all
 
-.PHONY: all run_tests clean sub_run_tests sub_clean $(SUB_TARGETS)
+.PHONY: all run_tests clean ebb
diff --git a/tools/testing/selftests/powerpc/pmu/ebb/Makefile b/tools/testing/selftests/powerpc/pmu/ebb/Makefile
index 3dc4332698cb..5cdc9dbf2b27 100644
--- a/tools/testing/selftests/powerpc/pmu/ebb/Makefile
+++ b/tools/testing/selftests/powerpc/pmu/ebb/Makefile
@@ -4,7 +4,7 @@ noarg:
 # The EBB handler is 64-bit code and everything links against it
 CFLAGS += -m64
 
-PROGS := reg_access_test event_attributes_test cycles_test	\
+TEST_PROGS := reg_access_test event_attributes_test cycles_test	\
 	 cycles_with_freeze_test pmc56_overflow_test		\
 	 ebb_vs_cpu_event_test cpu_event_vs_ebb_test		\
 	 cpu_event_pinned_vs_ebb_test task_event_vs_ebb_test	\
@@ -16,18 +16,15 @@ PROGS := reg_access_test event_attributes_test cycles_test	\
 	 lost_exception_test no_handler_test			\
 	 cycles_with_mmcr2_test
 
-all: $(PROGS)
+all: $(TEST_PROGS)
 
-$(PROGS): ../../harness.c ../event.c ../lib.c ebb.c ebb_handler.S trace.c busy_loop.S
+$(TEST_PROGS): ../../harness.c ../event.c ../lib.c ebb.c ebb_handler.S trace.c busy_loop.S
 
 instruction_count_test: ../loop.S
 
 lost_exception_test: ../lib.c
 
-run_tests: all
-	@-for PROG in $(PROGS); do \
-		./$$PROG; \
-	done;
+include ../../../lib.mk
 
 clean:
-	rm -f $(PROGS)
+	rm -f $(TEST_PROGS)
diff --git a/tools/testing/selftests/powerpc/primitives/Makefile b/tools/testing/selftests/powerpc/primitives/Makefile
index ea737ca01732..b68c6221d3d1 100644
--- a/tools/testing/selftests/powerpc/primitives/Makefile
+++ b/tools/testing/selftests/powerpc/primitives/Makefile
@@ -1,17 +1,12 @@
 CFLAGS += -I$(CURDIR)
 
-PROGS := load_unaligned_zeropad
+TEST_PROGS := load_unaligned_zeropad
 
-all: $(PROGS)
+all: $(TEST_PROGS)
 
-$(PROGS): ../harness.c
+$(TEST_PROGS): ../harness.c
 
-run_tests: all
-	@-for PROG in $(PROGS); do \
-		./$$PROG; \
-	done;
+include ../../lib.mk
 
 clean:
-	rm -f $(PROGS) *.o
-
-.PHONY: all run_tests clean
+	rm -f $(TEST_PROGS) *.o
diff --git a/tools/testing/selftests/powerpc/tm/Makefile b/tools/testing/selftests/powerpc/tm/Makefile
index 2cede239a074..34f2ec634b40 100644
--- a/tools/testing/selftests/powerpc/tm/Makefile
+++ b/tools/testing/selftests/powerpc/tm/Makefile
@@ -1,15 +1,10 @@
-PROGS := tm-resched-dscr
+TEST_PROGS := tm-resched-dscr
 
-all: $(PROGS)
+all: $(TEST_PROGS)
 
-$(PROGS): ../harness.c
+$(TEST_PROGS): ../harness.c
 
-run_tests: all
-	@-for PROG in $(PROGS); do \
-		./$$PROG; \
-	done;
+include ../../lib.mk
 
 clean:
-	rm -f $(PROGS) *.o
-
-.PHONY: all run_tests clean
+	rm -f $(TEST_PROGS) *.o
-- 
2.1.0
