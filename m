From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 18/53] perf tools: Add API to config maps in bpf object
Date: Mon, 11 Jan 2016 13:48:09 +0000
Message-ID: <1452520124-2073-19-git-send-email-wangnan0@huawei.com>
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

bpf__config_obj() is introduced as a core API to config BPF object
after loading. One configuration option of maps is introduced. After
this patch BPF object can accept configuration like:

 maps:my_map.value=1234

(maps.my_map.value looks pretty. However, there's a small but hard
to fixed problem related to flex's greedy matching. Please see [1].
Choose ':' to avoid it in a simpler way.)

This patch is more complex than the work it really does because the
consideration of extension. In designing of BPF map configuration,
following things should be considered:

 1. Array indices selection: perf should allow user setting different
    value to different slots in an array, with syntax like:
    maps:my_map.value[0,3...6]=1234;

 2. A map can be config by different config terms, each for a part
    of it. For example, set each slot to pid of a thread;

 3. Type of value: integer is not the only valid value type. Perf
    event can also be put into a map after commit 35578d7984003097af2b1e3
    (bpf: Implement function bpf_perf_event_read() that get the selected
    hardware PMU conuter);

 4. For hash table, it is possible to use string or other as key;

 5. It is possible that map configuration is unable to be setup
    during parsing. Perf event is an example.

Therefore, this patch does following:

 1. Instead of updating map element during parsing, this patch stores
    map config options in 'struct bpf_map_priv'. Following patches
    would apply those configs at proper time;

 2. Link map operations to a list so a map can have multiple config
    terms attached, so different parts can be configured separately;

 3. Make 'struct bpf_map_priv' extensible so following patches can
    add new types of keys and operations;

 4. Use bpf_config_map_funcs array to support more maps config options.

Since the patch changing event parser to parse BPF object config is
relative large, I put in another commit. Code in this patch
could be tested after applying next patch.

[1] http://lkml.kernel.org/g/564ED621.4050500@huawei.com

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
 tools/perf/util/bpf-loader.c | 266 +++++++++++++++++++++++++++++++++++++++++++
 tools/perf/util/bpf-loader.h |  38 +++++++
 2 files changed, 304 insertions(+)

diff --git a/tools/perf/util/bpf-loader.c b/tools/perf/util/bpf-loader.c
index 540a7ef..7d361aa 100644
--- a/tools/perf/util/bpf-loader.c
+++ b/tools/perf/util/bpf-loader.c
@@ -739,6 +739,251 @@ int bpf__foreach_tev(struct bpf_object *obj,
 	return 0;
 }
 
+enum bpf_map_op_type {
+	BPF_MAP_OP_SET_VALUE,
+};
+
+enum bpf_map_key_type {
+	BPF_MAP_KEY_ALL,
+};
+
+struct bpf_map_op {
+	struct list_head list;
+	enum bpf_map_op_type op_type;
+	enum bpf_map_key_type key_type;
+	union {
+		u64 value;
+	} v;
+};
+
+struct bpf_map_priv {
+	struct list_head ops_list;
+};
+
+static void
+bpf_map_op__free(struct bpf_map_op *op)
+{
+	struct list_head *list = &op->list;
+	/*
+	 * bpf_map_op__free() needs to consider following cases:
+	 *   1. When the op is created but not linked to any list:
+	 *      impossible. This only happen in bpf_map_op__alloc()
+	 *      and it would be freed directly;
+	 *   2. Normal case, when the op is linked to a list;
+	 *   3. After the op has already be removed.
+	 * Thanks to list.h, if it has removed by list_del() then
+	 * list->{next,prev} should have been set to LIST_POISON{1,2}.
+	 */
+	if ((list->next != LIST_POISON1) && (list->prev != LIST_POISON2))
+		list_del(list);
+	free(op);
+}
+
+static void
+bpf_map_priv__clear(struct bpf_map *map __maybe_unused,
+		    void *_priv)
+{
+	struct bpf_map_priv *priv = _priv;
+	struct bpf_map_op *pos, *n;
+
+	list_for_each_entry_safe(pos, n, &priv->ops_list, list)
+		bpf_map_op__free(pos);
+	free(priv);
+}
+
+static struct bpf_map_op *
+bpf_map_op__alloc(struct bpf_map *map)
+{
+	struct bpf_map_op *op;
+	struct bpf_map_priv *priv;
+	const char *map_name;
+	int err;
+
+	map_name = bpf_map__get_name(map);
+	err = bpf_map__get_private(map, (void **)&priv);
+	if (err) {
+		pr_debug("Failed to get private from map %s\n", map_name);
+		return ERR_PTR(err);
+	}
+
+	if (!priv) {
+		priv = zalloc(sizeof(*priv));
+		if (!priv) {
+			pr_debug("No enough memory to alloc map private\n");
+			return ERR_PTR(-ENOMEM);
+		}
+		INIT_LIST_HEAD(&priv->ops_list);
+
+		if (bpf_map__set_private(map, priv, bpf_map_priv__clear)) {
+			free(priv);
+			return ERR_PTR(-BPF_LOADER_ERRNO__INTERNAL);
+		}
+	}
+
+	op = zalloc(sizeof(*op));
+	if (!op) {
+		pr_debug("Failed to alloc bpf_map_op\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	op->key_type = BPF_MAP_KEY_ALL;
+	list_add_tail(&op->list, &priv->ops_list);
+	return op;
+}
+
+static int
+bpf__obj_config_map_array_value(struct bpf_map *map,
+				struct parse_events_term *term)
+{
+	struct bpf_map_def def;
+	struct bpf_map_op *op;
+	const char *map_name;
+	int err;
+
+	map_name = bpf_map__get_name(map);
+
+	err = bpf_map__get_def(map, &def);
+	if (err) {
+		pr_debug("Unable to get map definition from '%s'\n",
+			 map_name);
+		return -BPF_LOADER_ERRNO__INTERNAL;
+	}
+
+	if (def.type != BPF_MAP_TYPE_ARRAY) {
+		pr_debug("Map %s type is not BPF_MAP_TYPE_ARRAY\n",
+			 map_name);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_TYPE;
+	}
+	if (def.key_size < sizeof(unsigned int)) {
+		pr_debug("Map %s has incorrect key size\n", map_name);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_KEYSIZE;
+	}
+	switch (def.value_size) {
+	case 1:
+	case 2:
+	case 4:
+	case 8:
+		break;
+	default:
+		pr_debug("Map %s has incorrect value size\n", map_name);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUESIZE;
+	}
+
+	op = bpf_map_op__alloc(map);
+	if (IS_ERR(op))
+		return PTR_ERR(op);
+	op->op_type = BPF_MAP_OP_SET_VALUE;
+	op->v.value = term->val.num;
+	return 0;
+}
+
+static int
+bpf__obj_config_map_value(struct bpf_map *map,
+			  struct parse_events_term *term,
+			  struct perf_evlist *evlist __maybe_unused)
+{
+	if (!term->err_val) {
+		pr_debug("Config value not set\n");
+		return -BPF_LOADER_ERRNO__OBJCONF_CONF;
+	}
+
+	if (term->type_val == PARSE_EVENTS__TERM_TYPE_NUM)
+		return bpf__obj_config_map_array_value(map, term);
+
+	pr_debug("ERROR: wrong value type\n");
+	return -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUE;
+}
+
+struct bpf_obj_config_map_func {
+	const char *config_opt;
+	int (*config_func)(struct bpf_map *, struct parse_events_term *,
+			   struct perf_evlist *);
+};
+
+struct bpf_obj_config_map_func bpf_obj_config_map_funcs[] = {
+	{"value", bpf__obj_config_map_value},
+};
+
+static int
+bpf__obj_config_map(struct bpf_object *obj,
+		    struct parse_events_term *term,
+		    struct perf_evlist *evlist,
+		    int *key_scan_pos)
+{
+	/* key is "maps:<mapname>.<config opt>" */
+	char *map_name = strdup(term->config + sizeof("maps:") - 1);
+	struct bpf_map *map;
+	int err = -BPF_LOADER_ERRNO__OBJCONF_OPT;
+	char *map_opt;
+	size_t i;
+
+	if (!map_name)
+		return -ENOMEM;
+
+	map_opt = strchr(map_name, '.');
+	if (!map_opt) {
+		pr_debug("ERROR: Invalid map config: %s\n", map_name);
+		goto out;
+	}
+
+	*map_opt++ = '\0';
+	if (*map_opt == '\0') {
+		pr_debug("ERROR: Invalid map option: %s\n", term->config);
+		goto out;
+	}
+
+	map = bpf_object__get_map_by_name(obj, map_name);
+	if (!map) {
+		pr_debug("ERROR: Map %s is not exist\n", map_name);
+		err = -BPF_LOADER_ERRNO__OBJCONF_MAP_NOTEXIST;
+		goto out;
+	}
+
+	*key_scan_pos += map_opt - map_name;
+	for (i = 0; i < ARRAY_SIZE(bpf_obj_config_map_funcs); i++) {
+		struct bpf_obj_config_map_func *func =
+				&bpf_obj_config_map_funcs[i];
+
+		if (strcmp(map_opt, func->config_opt) == 0) {
+			err = func->config_func(map, term, evlist);
+			goto out;
+		}
+	}
+
+	pr_debug("ERROR: invalid config option '%s' for maps\n",
+		 map_opt);
+	err = -BPF_LOADER_ERRNO__OBJCONF_MAP_OPT;
+out:
+	free(map_name);
+	if (!err)
+		key_scan_pos += strlen(map_opt);
+	return err;
+}
+
+int bpf__config_obj(struct bpf_object *obj,
+		    struct parse_events_term *term,
+		    struct perf_evlist *evlist,
+		    int *error_pos)
+{
+	int key_scan_pos = 0;
+	int err;
+
+	if (!obj || !term || !term->config)
+		return -EINVAL;
+
+	if (!prefixcmp(term->config, "maps:")) {
+		key_scan_pos = sizeof("maps:") - 1;
+		err = bpf__obj_config_map(obj, term, evlist, &key_scan_pos);
+		goto out;
+	}
+	err = -BPF_LOADER_ERRNO__OBJCONF_OPT;
+out:
+	if (error_pos)
+		*error_pos = key_scan_pos;
+	return err;
+
+}
+
 #define ERRNO_OFFSET(e)		((e) - __BPF_LOADER_ERRNO__START)
 #define ERRCODE_OFFSET(c)	ERRNO_OFFSET(BPF_LOADER_ERRNO__##c)
 #define NR_ERRNO	(__BPF_LOADER_ERRNO__END - __BPF_LOADER_ERRNO__START)
@@ -753,6 +998,14 @@ static const char *bpf_loader_strerror_table[NR_ERRNO] = {
 	[ERRCODE_OFFSET(PROLOGUE)]	= "Failed to generate prologue",
 	[ERRCODE_OFFSET(PROLOGUE2BIG)]	= "Prologue too big for program",
 	[ERRCODE_OFFSET(PROLOGUEOOB)]	= "Offset out of bound for prologue",
+	[ERRCODE_OFFSET(OBJCONF_OPT)]	= "Invalid object config option",
+	[ERRCODE_OFFSET(OBJCONF_CONF)]	= "Config value not set (lost '=')",
+	[ERRCODE_OFFSET(OBJCONF_MAP_OPT)]	= "Invalid object maps config option",
+	[ERRCODE_OFFSET(OBJCONF_MAP_NOTEXIST)]	= "Target map not exist",
+	[ERRCODE_OFFSET(OBJCONF_MAP_VALUE)]	= "Incorrect value type for map",
+	[ERRCODE_OFFSET(OBJCONF_MAP_TYPE)]	= "Incorrect map type",
+	[ERRCODE_OFFSET(OBJCONF_MAP_KEYSIZE)]	= "Incorrect map key size",
+	[ERRCODE_OFFSET(OBJCONF_MAP_VALUESIZE)]	= "Incorrect map value size",
 };
 
 static int
@@ -872,3 +1125,16 @@ int bpf__strerror_load(struct bpf_object *obj,
 	bpf__strerror_end(buf, size);
 	return 0;
 }
+
+int bpf__strerror_config_obj(struct bpf_object *obj __maybe_unused,
+			     struct parse_events_term *term __maybe_unused,
+			     struct perf_evlist *evlist __maybe_unused,
+			     int *error_pos __maybe_unused, int err,
+			     char *buf, size_t size)
+{
+	bpf__strerror_head(err, buf, size);
+	bpf__strerror_entry(BPF_LOADER_ERRNO__OBJCONF_MAP_TYPE,
+			    "Can't use this config term to this type of map");
+	bpf__strerror_end(buf, size);
+	return 0;
+}
diff --git a/tools/perf/util/bpf-loader.h b/tools/perf/util/bpf-loader.h
index 6fdc045..2464db9 100644
--- a/tools/perf/util/bpf-loader.h
+++ b/tools/perf/util/bpf-loader.h
@@ -10,6 +10,7 @@
 #include <string.h>
 #include <bpf/libbpf.h>
 #include "probe-event.h"
+#include "evlist.h"
 #include "debug.h"
 
 enum bpf_loader_errno {
@@ -24,10 +25,19 @@ enum bpf_loader_errno {
 	BPF_LOADER_ERRNO__PROLOGUE,	/* Failed to generate prologue */
 	BPF_LOADER_ERRNO__PROLOGUE2BIG,	/* Prologue too big for program */
 	BPF_LOADER_ERRNO__PROLOGUEOOB,	/* Offset out of bound for prologue */
+	BPF_LOADER_ERRNO__OBJCONF_OPT,	/* Invalid object config option */
+	BPF_LOADER_ERRNO__OBJCONF_CONF,	/* Config value not set (lost '=')) */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_OPT,	/* Invalid object maps config option */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_NOTEXIST,	/* Target map not exist */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_VALUE,	/* Incorrect value type for map */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_TYPE,	/* Incorrect map type */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_KEYSIZE,	/* Incorrect map key size */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_VALUESIZE,/* Incorrect map value size */
 	__BPF_LOADER_ERRNO__END,
 };
 
 struct bpf_object;
+struct parse_events_term;
 #define PERF_BPF_PROBE_GROUP "perf_bpf_probe"
 
 typedef int (*bpf_prog_iter_callback_t)(struct probe_trace_event *tev,
@@ -53,6 +63,14 @@ int bpf__strerror_load(struct bpf_object *obj, int err,
 		       char *buf, size_t size);
 int bpf__foreach_tev(struct bpf_object *obj,
 		     bpf_prog_iter_callback_t func, void *arg);
+
+int bpf__config_obj(struct bpf_object *obj, struct parse_events_term *term,
+		    struct perf_evlist *evlist, int *error_pos);
+int bpf__strerror_config_obj(struct bpf_object *obj,
+			     struct parse_events_term *term,
+			     struct perf_evlist *evlist,
+			     int *error_pos, int err, char *buf,
+			     size_t size);
 #else
 static inline struct bpf_object *
 bpf__prepare_load(const char *filename __maybe_unused,
@@ -84,6 +102,15 @@ bpf__foreach_tev(struct bpf_object *obj __maybe_unused,
 }
 
 static inline int
+bpf__config_obj(struct bpf_object *obj __maybe_unused,
+		struct parse_events_term *term __maybe_unused,
+		struct perf_evlist *evlist __maybe_unused,
+		int *error_pos __maybe_unused)
+{
+	return 0;
+}
+
+static inline int
 __bpf_strerror(char *buf, size_t size)
 {
 	if (!size)
@@ -118,5 +145,16 @@ static inline int bpf__strerror_load(struct bpf_object *obj __maybe_unused,
 {
 	return __bpf_strerror(buf, size);
 }
+
+static inline int
+bpf__strerror_config_obj(struct bpf_object *obj __maybe_unused,
+			 struct parse_events_term *term __maybe_unused,
+			 struct perf_evlist *evlist __maybe_unused,
+			 int *error_pos __maybe_unused,
+			 int err __maybe_unused,
+			 char *buf, size_t size)
+{
+	return __bpf_strerror(buf, size);
+}
 #endif
 #endif
-- 
1.8.3.4
