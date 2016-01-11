From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 04/53] perf tools: Pass O option to Makefile.perf in build-test
Date: Mon, 11 Jan 2016 13:47:55 +0000
Message-ID: <1452520124-2073-5-git-send-email-wangnan0@huawei.com>
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

Doesn't like tools/perf/Makefile, tools/perf/Makefile.perf obey 'O'
option when it is passed through cmdline only, because of code in
tools/scripts/Makefile.include:

 ifneq ($(O),)
 ifeq ($(origin O), command line)
 	...
 	ABSOLUTE_O := $(shell cd $(O) ; pwd)
 	OUTPUT := $(ABSOLUTE_O)/$(if $(subdir),$(subdir)/)
 endif
 endif

This patch passes 'O' to Makefile.perf through cmdline explicitly
to make it follow O variable during build-test.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/tests/make | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/tools/perf/tests/make b/tools/perf/tests/make
index bd9c61a..a32615a3 100644
--- a/tools/perf/tests/make
+++ b/tools/perf/tests/make
@@ -3,7 +3,7 @@ ifeq ($(MAKECMDGOALS),)
 # no target specified, trigger the whole suite
 all:
 	@echo "Testing Makefile";      $(MAKE) -sf tests/make MK=Makefile
-	@echo "Testing Makefile.perf"; $(MAKE) -sf tests/make MK=Makefile.perf SET_PARALLEL=1
+	@echo "Testing Makefile.perf"; $(MAKE) -sf tests/make MK=Makefile.perf SET_PARALLEL=1 SET_O=1
 else
 # run only specific test over 'Makefile'
 %:
@@ -11,6 +11,14 @@ else
 endif
 else
 PERF := .
+O_OPT :=
+
+ifneq ($(O),)
+  FULL_O := $(shell readlink -f $(O) || echo $(O))
+  ifeq ($(SET_O),1)
+    O_OPT := 'O=$(FULL_O)'
+  endif
+endif
 
 PARALLEL_OPT=
 ifeq ($(SET_PARALLEL),1)
@@ -247,7 +255,7 @@ clean := @(cd $(PERF); make -s -f $(MK) clean >/dev/null)
 $(run):
 	$(call clean)
 	@TMP_DEST=$$(mktemp -d); \
-	cmd="cd $(PERF) && make -f $(MK) $(PARALLEL_OPT) DESTDIR=$$TMP_DEST $($@)"; \
+	cmd="cd $(PERF) && make -f $(MK) $(PARALLEL_OPT) $(O_OPT) DESTDIR=$$TMP_DEST $($@)"; \
 	echo "- $@: $$cmd" && echo $$cmd > $@ && \
 	( eval $$cmd ) >> $@ 2>&1; \
 	echo "  test: $(call test,$@)" >> $@ 2>&1; \
-- 
1.8.3.4
