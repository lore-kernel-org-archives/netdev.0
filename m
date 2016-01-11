From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 20/53] perf record: Apply config to BPF objects before recording
Date: Mon, 11 Jan 2016 13:48:11 +0000
Message-ID: <1452520124-2073-21-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf__apply_obj_config() is introduced as the core API to apply object
config options to all BPF objects. This patch also does the real work
for setting values for BPF_MAP_TYPE_PERF_ARRAY maps by inserting value
stored in map's private field into the BPF map.

This patch is required because we are not always able to set all
BPF config during parsing. Further patch will set events created
by perf to BPF_MAP_TYPE_PERF_EVENT_ARRAY maps, which is not exist
until perf_evsel__open().

bpf_map_foreach_key() is introduced to iterate over each key
needs to be configured. This function would be extended to support
more map types and different key settings.

In perf record, before start recording, call bpf__apply_config() to
turn on all BPF config options.

Test result:

 # cat ./test_bpf_map_1.c
 /************************ BEGIN **************************/
 #include <uapi/linux/bpf.h>
 #define SEC(NAME) __attribute__((section(NAME), used))
 struct bpf_map_def {
     unsigned int type;
     unsigned int key_size;
     unsigned int value_size;
     unsigned int max_entries;
 };
 static void *(*map_lookup_elem)(struct bpf_map_def *, void *) =
     (void *)BPF_FUNC_map_lookup_elem;
 static int (*trace_printk)(const char *fmt, int fmt_size, ...) =
     (void *)BPF_FUNC_trace_printk;
 struct bpf_map_def SEC("maps") channel = {
     .type = BPF_MAP_TYPE_ARRAY,
     .key_size = sizeof(int),
     .value_size = sizeof(int),
     .max_entries = 1,
 };
 SEC("func=sys_nanosleep")
 int func(void *ctx)
 {
     int key = 0;
     char fmt[] = "%d\n";
     int *pval = map_lookup_elem(&channel, &key);
     if (!pval)
         return 0;
     trace_printk(fmt, sizeof(fmt), *pval);
     return 0;
 }
 char _license[] SEC("license") = "GPL";
 int _version SEC("version") = LINUX_VERSION_CODE;
 /************************* END ***************************/

 # echo "" > /sys/kernel/debug/tracing/trace
 # ./perf record -e './test_bpf_map_1.c/maps:channel.value=11/' usleep 10
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.012 MB perf.data ]
 # cat /sys/kernel/debug/tracing/trace
 # tracer: nop
 #
 # entries-in-buffer/entries-written: 1/1   #P:8
 [SNIP]
 #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
 #              | |       |   ||||       |         |
            usleep-18593 [007] d... 2394714.395539: : 11
 # ./perf record -e './test_bpf_map.c/maps:channel.value=101/' usleep 10
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.012 MB perf.data ]
 # cat /sys/kernel/debug/tracing/trace
 # tracer: nop
 #
 # entries-in-buffer/entries-written: 1/1   #P:8
 [SNIP]
 #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
 #              | |       |   ||||       |         |
            usleep-18593 [007] d... 2394714.395539: : 11
            usleep-19000 [006] d... 2394831.057840: : 101

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c  |  11 +++
 tools/perf/util/bpf-loader.c | 180 +++++++++++++++++++++++++++++++++++++++++++
 tools/perf/util/bpf-loader.h |  15 ++++
 3 files changed, 206 insertions(+)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index dc4e0ad..bd1692c 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -32,6 +32,7 @@
 #include "util/parse-branch-options.h"
 #include "util/parse-regs-options.h"
 #include "util/llvm-utils.h"
+#include "util/bpf-loader.h"
 
 #include <unistd.h>
 #include <sched.h>
@@ -526,6 +527,16 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 		goto out_child;
 	}
 
+	err = bpf__apply_obj_config();
+	if (err) {
+		char errbuf[BUFSIZ];
+
+		bpf__strerror_apply_obj_config(err, errbuf, sizeof(errbuf));
+		pr_err("ERROR: Apply config to BPF failed: %s\n",
+			 errbuf);
+		goto out_child;
+	}
+
 	/*
 	 * Normally perf_session__new would do this, but it doesn't have the
 	 * evlist.
diff --git a/tools/perf/util/bpf-loader.c b/tools/perf/util/bpf-loader.c
index 7d361aa..96fd18b 100644
--- a/tools/perf/util/bpf-loader.c
+++ b/tools/perf/util/bpf-loader.c
@@ -7,6 +7,7 @@
 
 #include <linux/bpf.h>
 #include <bpf/libbpf.h>
+#include <bpf/bpf.h>
 #include <linux/err.h>
 #include <linux/string.h>
 #include "perf.h"
@@ -984,6 +985,178 @@ out:
 
 }
 
+typedef int (*map_config_func_t)(const char *name, int map_fd,
+				 struct bpf_map_def *pdef,
+				 struct bpf_map_op *op,
+				 void *pkey, void *arg);
+
+static int
+foreach_key_array_all(map_config_func_t func,
+		      void *arg, const char *name,
+		      int map_fd, struct bpf_map_def *pdef,
+		      struct bpf_map_op *op)
+{
+	unsigned int i;
+	int err;
+
+	for (i = 0; i < pdef->max_entries; i++) {
+		err = func(name, map_fd, pdef, op, &i, arg);
+		if (err) {
+			pr_debug("ERROR: failed to insert value to %s[%u]\n",
+				 name, i);
+			return err;
+		}
+	}
+	return 0;
+}
+
+static int
+bpf_map_config_foreach_key(struct bpf_map *map,
+			   map_config_func_t func,
+			   void *arg)
+{
+	int err, map_fd;
+	const char *name;
+	struct bpf_map_op *op;
+	struct bpf_map_def def;
+	struct bpf_map_priv *priv;
+
+	name = bpf_map__get_name(map);
+
+	err = bpf_map__get_private(map, (void **)&priv);
+	if (err) {
+		pr_debug("ERROR: failed to get private from map %s\n", name);
+		return -BPF_LOADER_ERRNO__INTERNAL;
+	}
+	if (!priv || list_empty(&priv->ops_list)) {
+		pr_debug("INFO: nothing to config for map %s\n", name);
+		return 0;
+	}
+
+	err = bpf_map__get_def(map, &def);
+	if (err) {
+		pr_debug("ERROR: failed to get definition from map %s\n", name);
+		return -BPF_LOADER_ERRNO__INTERNAL;
+	}
+	map_fd = bpf_map__get_fd(map);
+	if (map_fd < 0) {
+		pr_debug("ERROR: failed to get fd from map %s\n", name);
+		return map_fd;
+	}
+
+	list_for_each_entry(op, &priv->ops_list, list) {
+		switch (def.type) {
+		case BPF_MAP_TYPE_ARRAY:
+			switch (op->key_type) {
+			case BPF_MAP_KEY_ALL:
+				return foreach_key_array_all(func, arg, name,
+							     map_fd, &def, op);
+			default:
+				pr_debug("ERROR: keytype for map '%s' invalid\n",
+					 name);
+				return -BPF_LOADER_ERRNO__INTERNAL;
+		}
+		default:
+			pr_debug("ERROR: type of '%s' incorrect\n", name);
+			return -BPF_LOADER_ERRNO__OBJCONF_MAP_TYPE;
+		}
+	}
+
+	return 0;
+}
+
+static int
+apply_config_value_for_key(int map_fd, void *pkey,
+			   size_t val_size, u64 val)
+{
+	int err = 0;
+
+	switch (val_size) {
+	case 1: {
+		u8 _val = (u8)(val);
+		err = bpf_map_update_elem(map_fd, pkey, &_val, BPF_ANY);
+		break;
+	}
+	case 2: {
+		u16 _val = (u16)(val);
+		err = bpf_map_update_elem(map_fd, pkey, &_val, BPF_ANY);
+		break;
+	}
+	case 4: {
+		u32 _val = (u32)(val);
+		err = bpf_map_update_elem(map_fd, pkey, &_val, BPF_ANY);
+		break;
+	}
+	case 8: {
+		err = bpf_map_update_elem(map_fd, pkey, &val, BPF_ANY);
+		break;
+	}
+	default:
+		pr_debug("ERROR: invalid value size\n");
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUESIZE;
+	}
+	if (err && errno)
+		err = -errno;
+	return err;
+}
+
+static int
+apply_obj_config_map_for_key(const char *name, int map_fd,
+			     struct bpf_map_def *pdef __maybe_unused,
+			     struct bpf_map_op *op,
+			     void *pkey, void *arg __maybe_unused)
+{
+	int err;
+
+	switch (op->op_type) {
+	case BPF_MAP_OP_SET_VALUE:
+		err = apply_config_value_for_key(map_fd, pkey,
+						 pdef->value_size,
+						 op->v.value);
+		break;
+	default:
+		pr_debug("ERROR: unknown value type for '%s'\n", name);
+		err = -BPF_LOADER_ERRNO__INTERNAL;
+	}
+	return err;
+}
+
+static int
+apply_obj_config_map(struct bpf_map *map)
+{
+	return bpf_map_config_foreach_key(map,
+					  apply_obj_config_map_for_key,
+					  NULL);
+}
+
+static int
+apply_obj_config_object(struct bpf_object *obj)
+{
+	struct bpf_map *map;
+	int err;
+
+	bpf_map__for_each(map, obj) {
+		err = apply_obj_config_map(map);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+int bpf__apply_obj_config(void)
+{
+	struct bpf_object *obj, *tmp;
+	int err;
+
+	bpf_object__for_each_safe(obj, tmp) {
+		err = apply_obj_config_object(obj);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 #define ERRNO_OFFSET(e)		((e) - __BPF_LOADER_ERRNO__START)
 #define ERRCODE_OFFSET(c)	ERRNO_OFFSET(BPF_LOADER_ERRNO__##c)
 #define NR_ERRNO	(__BPF_LOADER_ERRNO__END - __BPF_LOADER_ERRNO__START)
@@ -1138,3 +1311,10 @@ int bpf__strerror_config_obj(struct bpf_object *obj __maybe_unused,
 	bpf__strerror_end(buf, size);
 	return 0;
 }
+
+int bpf__strerror_apply_obj_config(int err, char *buf, size_t size)
+{
+	bpf__strerror_head(err, buf, size);
+	bpf__strerror_end(buf, size);
+	return 0;
+}
diff --git a/tools/perf/util/bpf-loader.h b/tools/perf/util/bpf-loader.h
index 2464db9..db3c34c 100644
--- a/tools/perf/util/bpf-loader.h
+++ b/tools/perf/util/bpf-loader.h
@@ -71,6 +71,8 @@ int bpf__strerror_config_obj(struct bpf_object *obj,
 			     struct perf_evlist *evlist,
 			     int *error_pos, int err, char *buf,
 			     size_t size);
+int bpf__apply_obj_config(void);
+int bpf__strerror_apply_obj_config(int err, char *buf, size_t size);
 #else
 static inline struct bpf_object *
 bpf__prepare_load(const char *filename __maybe_unused,
@@ -111,6 +113,12 @@ bpf__config_obj(struct bpf_object *obj __maybe_unused,
 }
 
 static inline int
+bpf__apply_obj_config(void)
+{
+	return 0;
+}
+
+static inline int
 __bpf_strerror(char *buf, size_t size)
 {
 	if (!size)
@@ -156,5 +164,12 @@ bpf__strerror_config_obj(struct bpf_object *obj __maybe_unused,
 {
 	return __bpf_strerror(buf, size);
 }
+
+static inline int
+bpf__strerror_apply_obj_config(int err __maybe_unused,
+			       char *buf, size_t size)
+{
+	return __bpf_strerror(buf, size);
+}
 #endif
 #endif
-- 
1.8.3.4
