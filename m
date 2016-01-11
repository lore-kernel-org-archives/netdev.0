From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 05/53] perf tools: Test correct path of perf in build-test
Date: Mon, 11 Jan 2016 13:47:56 +0000
Message-ID: <1452520124-2073-6-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If an 'O' is passed to 'make build-test', many 'test -x' and 'test -f'
will fail because perf resides in a different directory. Fix this by
computing PERF_OUT according to 'O' and test correct output files.
For make_kernelsrc and make_kernelsrc_tools, set KBUILD_OUTPUT_DIR
instead because the path is different from others ($(O)/perf vs
 $(O)/tools/perf).

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/tests/make | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/tools/perf/tests/make b/tools/perf/tests/make
index a32615a3..0f5afcb 100644
--- a/tools/perf/tests/make
+++ b/tools/perf/tests/make
@@ -11,10 +11,12 @@ else
 endif
 else
 PERF := .
+PERF_OUT := $(PERF)
 O_OPT :=
 
 ifneq ($(O),)
   FULL_O := $(shell readlink -f $(O) || echo $(O))
+  PERF_OUT := $(FULL_O)
   ifeq ($(SET_O),1)
     O_OPT := 'O=$(FULL_O)'
   endif
@@ -159,11 +161,11 @@ test_make_doc    := $(test_ok)
 test_make_help_O := $(test_ok)
 test_make_doc_O  := $(test_ok)
 
-test_make_python_perf_so := test -f $(PERF)/python/perf.so
+test_make_python_perf_so := test -f $(PERF_OUT)/python/perf.so
 
-test_make_perf_o           := test -f $(PERF)/perf.o
-test_make_util_map_o       := test -f $(PERF)/util/map.o
-test_make_util_pmu_bison_o := test -f $(PERF)/util/pmu-bison.o
+test_make_perf_o           := test -f $(PERF_OUT)/perf.o
+test_make_util_map_o       := test -f $(PERF_OUT)/util/map.o
+test_make_util_pmu_bison_o := test -f $(PERF_OUT)/util/pmu-bison.o
 
 define test_dest_files
   for file in $(1); do				\
@@ -230,7 +232,7 @@ test_make_perf_o_O            := test -f $$TMP_O/perf.o
 test_make_util_map_o_O        := test -f $$TMP_O/util/map.o
 test_make_util_pmu_bison_o_O := test -f $$TMP_O/util/pmu-bison.o
 
-test_default = test -x $(PERF)/perf
+test_default = test -x $(PERF_OUT)/perf
 test = $(if $(test_$1),$(test_$1),$(test_default))
 
 test_default_O = test -x $$TMP_O/perf
@@ -250,7 +252,7 @@ endif
 
 MAKEFLAGS := --no-print-directory
 
-clean := @(cd $(PERF); make -s -f $(MK) clean >/dev/null)
+clean := @(cd $(PERF); make -s -f $(MK) O=$(PERF_OUT) clean >/dev/null; make -s -f $(MK) clean >/dev/null)
 
 $(run):
 	$(call clean)
@@ -279,17 +281,22 @@ tarpkg:
 	( eval $$cmd ) >> $@ 2>&1 && \
 	rm -f $@
 
+KBUILD_OUTPUT_DIR := ../..
+ifneq ($(O),)
+  KBUILD_OUTPUT_DIR := $(O)
+endif
+
 make_kernelsrc:
 	@echo "- make -C <kernelsrc> $(PARALLEL_OPT) tools/perf"
 	$(call clean); \
 	(make -C ../.. $(PARALLEL_OPT) tools/perf) > $@ 2>&1 && \
-	test -x perf && rm -f $@ || (cat $@ ; false)
+	test -x $(KBUILD_OUTPUT_DIR)/tools/perf && rm -f $@ || (cat $@ ; false)
 
 make_kernelsrc_tools:
 	@echo "- make -C <kernelsrc>/tools $(PARALLEL_OPT) perf"
 	$(call clean); \
 	(make -C ../../tools $(PARALLEL_OPT) perf) > $@ 2>&1 && \
-	test -x perf && rm -f $@ || (cat $@ ; false)
+	test -x $(KBUILD_OUTPUT_DIR)/tools/perf && rm -f $@ || (cat $@ ; false)
 
 all: $(run) $(run_O) tarpkg make_kernelsrc make_kernelsrc_tools
 	@echo OK
-- 
1.8.3.4
