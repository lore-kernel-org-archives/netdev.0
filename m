From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 15/53] perf tools: Fix symbols searching for offline module in buildid-cache
Date: Mon, 11 Jan 2016 13:48:06 +0000
Message-ID: <1452520124-2073-16-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"Masami Hiramatsu" <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before this patch, if a sample is triggered inside an offline module
(module not in /lib/modules/`uname -r`/), even if the module is in
buildid-cache, 'perf report' is still unable to get correct symbol.
For example:

 # rm -rf ~/.debug/
 # perf buildid-cache -a ./mymodule.ko
 # perf probe -m ./mymodule.ko -a get_mymodule_val
 Added new event:
   probe:get_mymodule_val (on get_mymodule_val in mymodule)

 You can now use it in all perf tools, such as:

 	perf record -e probe:get_mymodule_val -aR sleep 1

 # perf record -e probe:get_mymodule_val cat /proc/mymodule
 mymodule:3
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.011 MB perf.data (1 samples) ]

 # perf report --stdio
 [SNIP]
 #
 # Overhead  Command  Shared Object     Symbol
 # ........  .......  ................  ......................
 #
    100.00%  cat      [mymodule]        [k] 0x0000000000000001

 # perf report -vvvv --stdio
 dso__load_sym: adjusting symbol: st_value: 0 sh_addr: 0 sh_offset: 0x70
 symbol__new: get_mymodule_val 0x70-0x8a
 [SNIP]

This is caused by dso__load() -> dso__load_sym(). In dso__load(), kmod
is true only when dso is regular kernel module. All files loaded from
buildid-cache is treated as user programs. Following dso__load_sym()
set map->pgoff incorrectly.

This patch gives kernel modules in buildid-cache a chance to adjust
value of kmod. After dso__load() get the type of symbols, if it is
buildid, check the last 3 chars of original filename against '.ko',
and adjust the value of kmod if the file is a kernel module.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>
---
 tools/perf/util/build-id.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 tools/perf/util/build-id.h |  1 +
 tools/perf/util/symbol.c   |  4 ++++
 3 files changed, 49 insertions(+)

diff --git a/tools/perf/util/build-id.c b/tools/perf/util/build-id.c
index 6a7e273..6b18082 100644
--- a/tools/perf/util/build-id.c
+++ b/tools/perf/util/build-id.c
@@ -166,6 +166,50 @@ char *dso__build_id_filename(const struct dso *dso, char *bf, size_t size)
 	return build_id__filename(build_id_hex, bf, size);
 }
 
+bool dso__build_id_is_kmod(const struct dso *dso, char *bf, size_t size)
+{
+	char *id_name, *ch;
+	struct stat sb;
+
+	id_name = dso__build_id_filename(dso, bf, size);
+	if (!id_name)
+		goto err;
+	if (access(id_name, F_OK))
+		goto err;
+	if (lstat(id_name, &sb) == -1)
+		goto err;
+	if ((size_t)sb.st_size > size - 1)
+		goto err;
+	if (readlink(id_name, bf, size - 1) < 0)
+		goto err;
+
+	bf[sb.st_size] = '\0';
+
+	/*
+	 * link should be:
+	 * ../../lib/modules/4.4.0-rc4/kernel/net/ipv4/netfilter/nf_nat_ipv4.ko/a09fe3eb3147dafa4e3b31dbd6257e4d696bdc92
+	 */
+	ch = strrchr(bf, '/');
+	if (!ch)
+		goto err;
+	if (ch - 3 < bf)
+		goto err;
+
+	return strncmp(".ko", ch - 3, 3) == 0;
+err:
+	/*
+	 * If dso__build_id_filename work, get id_name again,
+	 * because id_name points to bf and is broken.
+	 */
+	if (id_name)
+		id_name = dso__build_id_filename(dso, bf, size);
+	pr_err("Invalid build id: %s\n", id_name ? :
+					 dso->long_name ? :
+					 dso->short_name ? :
+					 "[unknown]");
+	return false;
+}
+
 #define dsos__for_each_with_build_id(pos, head)	\
 	list_for_each_entry(pos, head, node)	\
 		if (!pos->has_build_id)		\
diff --git a/tools/perf/util/build-id.h b/tools/perf/util/build-id.h
index 27a14a8..64af3e2 100644
--- a/tools/perf/util/build-id.h
+++ b/tools/perf/util/build-id.h
@@ -16,6 +16,7 @@ int sysfs__sprintf_build_id(const char *root_dir, char *sbuild_id);
 int filename__sprintf_build_id(const char *pathname, char *sbuild_id);
 
 char *dso__build_id_filename(const struct dso *dso, char *bf, size_t size);
+bool dso__build_id_is_kmod(const struct dso *dso, char *bf, size_t size);
 
 int build_id__mark_dso_hit(struct perf_tool *tool, union perf_event *event,
 			   struct perf_sample *sample, struct perf_evsel *evsel,
diff --git a/tools/perf/util/symbol.c b/tools/perf/util/symbol.c
index 3b2de6e..d78d105 100644
--- a/tools/perf/util/symbol.c
+++ b/tools/perf/util/symbol.c
@@ -1525,6 +1525,10 @@ int dso__load(struct dso *dso, struct map *map, symbol_filter_t filter)
 	if (!runtime_ss && syms_ss)
 		runtime_ss = syms_ss;
 
+	if (syms_ss && syms_ss->type == DSO_BINARY_TYPE__BUILD_ID_CACHE)
+		if (dso__build_id_is_kmod(dso, name, PATH_MAX))
+			kmod = true;
+
 	if (syms_ss)
 		ret = dso__load_sym(dso, map, syms_ss, runtime_ss, filter, kmod);
 	else
-- 
1.8.3.4
