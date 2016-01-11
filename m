From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 03/53] perf tools: Set parallel making options build-test
Date: Mon, 11 Jan 2016 13:47:54 +0000
Message-ID: <1452520124-2073-4-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"Namhyung Kim" <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'make build-test' is painful because of time consuming. In a full test,
all test cases are built twice with tools/perf/Makefile and
tools/perf/Makefile.perf. 'Makefile' automatically computes parallel
options for make, but 'Makefile.perf' not, so all test cases is built
with one job. It is very slow.

This patch adds '-j' options to Makefile.perf testing. It computes
parallel building options like what tools/perf/Makefile does, and pass
'-j' option to Makefile.perf test.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Acked-by: Jiri Olsa <jolsa@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/tests/make | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/tools/perf/tests/make b/tools/perf/tests/make
index 130be7c..bd9c61a 100644
--- a/tools/perf/tests/make
+++ b/tools/perf/tests/make
@@ -3,7 +3,7 @@ ifeq ($(MAKECMDGOALS),)
 # no target specified, trigger the whole suite
 all:
 	@echo "Testing Makefile";      $(MAKE) -sf tests/make MK=Makefile
-	@echo "Testing Makefile.perf"; $(MAKE) -sf tests/make MK=Makefile.perf
+	@echo "Testing Makefile.perf"; $(MAKE) -sf tests/make MK=Makefile.perf SET_PARALLEL=1
 else
 # run only specific test over 'Makefile'
 %:
@@ -12,6 +12,15 @@ endif
 else
 PERF := .
 
+PARALLEL_OPT=
+ifeq ($(SET_PARALLEL),1)
+  cores := $(shell (getconf _NPROCESSORS_ONLN || egrep -c '^processor|^CPU[0-9]' /proc/cpuinfo) 2>/dev/null)
+  ifeq ($(cores),0)
+    cores := 1
+  endif
+  PARALLEL_OPT="-j$(cores)"
+endif
+
 include config/Makefile.arch
 
 # FIXME looks like x86 is the only arch running tests ;-)
@@ -238,7 +247,7 @@ clean := @(cd $(PERF); make -s -f $(MK) clean >/dev/null)
 $(run):
 	$(call clean)
 	@TMP_DEST=$$(mktemp -d); \
-	cmd="cd $(PERF) && make -f $(MK) DESTDIR=$$TMP_DEST $($@)"; \
+	cmd="cd $(PERF) && make -f $(MK) $(PARALLEL_OPT) DESTDIR=$$TMP_DEST $($@)"; \
 	echo "- $@: $$cmd" && echo $$cmd > $@ && \
 	( eval $$cmd ) >> $@ 2>&1; \
 	echo "  test: $(call test,$@)" >> $@ 2>&1; \
@@ -249,7 +258,7 @@ $(run_O):
 	$(call clean)
 	@TMP_O=$$(mktemp -d); \
 	TMP_DEST=$$(mktemp -d); \
-	cmd="cd $(PERF) && make -f $(MK) O=$$TMP_O DESTDIR=$$TMP_DEST $($(patsubst %_O,%,$@))"; \
+	cmd="cd $(PERF) && make -f $(MK) $(PARALLEL_OPT) O=$$TMP_O DESTDIR=$$TMP_DEST $($(patsubst %_O,%,$@))"; \
 	echo "- $@: $$cmd" && echo $$cmd > $@ && \
 	( eval $$cmd ) >> $@ 2>&1 && \
 	echo "  test: $(call test_O,$@)" >> $@ 2>&1; \
@@ -263,15 +272,15 @@ tarpkg:
 	rm -f $@
 
 make_kernelsrc:
-	@echo "- make -C <kernelsrc> tools/perf"
+	@echo "- make -C <kernelsrc> $(PARALLEL_OPT) tools/perf"
 	$(call clean); \
-	(make -C ../.. tools/perf) > $@ 2>&1 && \
+	(make -C ../.. $(PARALLEL_OPT) tools/perf) > $@ 2>&1 && \
 	test -x perf && rm -f $@ || (cat $@ ; false)
 
 make_kernelsrc_tools:
-	@echo "- make -C <kernelsrc>/tools perf"
+	@echo "- make -C <kernelsrc>/tools $(PARALLEL_OPT) perf"
 	$(call clean); \
-	(make -C ../../tools perf) > $@ 2>&1 && \
+	(make -C ../../tools $(PARALLEL_OPT) perf) > $@ 2>&1 && \
 	test -x perf && rm -f $@ || (cat $@ ; false)
 
 all: $(run) $(run_O) tarpkg make_kernelsrc make_kernelsrc_tools
-- 
1.8.3.4
