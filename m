From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 23/53] perf tools: Support setting different slots in a BPF map separately
Date: Mon, 11 Jan 2016 13:48:14 +0000
Message-ID: <1452520124-2073-24-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	"Masami Hiramatsu" <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces basic facilities to support config different
slots in a BPF map one by one.

array.nr_ranges and array.ranges are introduced into 'struct
parse_events_term', where ranges is an array of indices range (start,
length) which will be configured by this config term. nr_ranges
is the size of the array. The array is passed to 'struct bpf_map_priv'.
To indicate the new type of configuration, BPF_MAP_KEY_RANGES is
added as a new key type. bpf_map_config_foreach_key() is extended to
iterate over those indices instead of all possible keys.

Code in this commit will be enabled by following commit which enables
the indices syntax for array configuration.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/bpf-loader.c   | 132 ++++++++++++++++++++++++++++++++++++++---
 tools/perf/util/bpf-loader.h   |   1 +
 tools/perf/util/parse-events.c |  33 ++++++++++-
 tools/perf/util/parse-events.h |  12 ++++
 4 files changed, 170 insertions(+), 8 deletions(-)

diff --git a/tools/perf/util/bpf-loader.c b/tools/perf/util/bpf-loader.c
index 2893b4e..6c25de8 100644
--- a/tools/perf/util/bpf-loader.c
+++ b/tools/perf/util/bpf-loader.c
@@ -17,6 +17,7 @@
 #include "llvm-utils.h"
 #include "probe-event.h"
 #include "probe-finder.h" // for MAX_PROBES
+#include "parse-events.h"
 #include "llvm-utils.h"
 
 #define DEFINE_PRINT_FN(name, level) \
@@ -747,6 +748,7 @@ enum bpf_map_op_type {
 
 enum bpf_map_key_type {
 	BPF_MAP_KEY_ALL,
+	BPF_MAP_KEY_RANGES,
 };
 
 struct bpf_map_op {
@@ -754,6 +756,9 @@ struct bpf_map_op {
 	enum bpf_map_op_type op_type;
 	enum bpf_map_key_type key_type;
 	union {
+		struct parse_events_array array;
+	} k;
+	union {
 		u64 value;
 		struct perf_evsel *evsel;
 	} v;
@@ -779,6 +784,8 @@ bpf_map_op__free(struct bpf_map_op *op)
 	 */
 	if ((list->next != LIST_POISON1) && (list->prev != LIST_POISON2))
 		list_del(list);
+	if (op->key_type == BPF_MAP_KEY_RANGES)
+		parse_events__clear_array(&op->k.array);
 	free(op);
 }
 
@@ -794,8 +801,30 @@ bpf_map_priv__clear(struct bpf_map *map __maybe_unused,
 	free(priv);
 }
 
+static int
+bpf_map_op_setkey(struct bpf_map_op *op, struct parse_events_term *term,
+		  const char *map_name)
+{
+	op->key_type = BPF_MAP_KEY_ALL;
+
+	if (term->array.nr_ranges) {
+		size_t memsz = term->array.nr_ranges *
+				sizeof(op->k.array.ranges[0]);
+
+		op->k.array.ranges = memdup(term->array.ranges, memsz);
+		if (!op->k.array.ranges) {
+			pr_debug("No enough memory to alloc indices for %s\n",
+				 map_name);
+			return -ENOMEM;
+		}
+		op->key_type = BPF_MAP_KEY_RANGES;
+		op->k.array.nr_ranges = term->array.nr_ranges;
+	}
+	return 0;
+}
+
 static struct bpf_map_op *
-bpf_map_op__alloc(struct bpf_map *map)
+bpf_map_op__alloc(struct bpf_map *map, struct parse_events_term *term)
 {
 	struct bpf_map_op *op;
 	struct bpf_map_priv *priv;
@@ -829,7 +858,12 @@ bpf_map_op__alloc(struct bpf_map *map)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	op->key_type = BPF_MAP_KEY_ALL;
+	err = bpf_map_op_setkey(op, term, map_name);
+	if (err) {
+		free(op);
+		return ERR_PTR(err);
+	}
+
 	list_add_tail(&op->list, &priv->ops_list);
 	return op;
 }
@@ -872,7 +906,7 @@ bpf__obj_config_map_array_value(struct bpf_map *map,
 		return -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUESIZE;
 	}
 
-	op = bpf_map_op__alloc(map);
+	op = bpf_map_op__alloc(map, term);
 	if (IS_ERR(op))
 		return PTR_ERR(op);
 	op->op_type = BPF_MAP_OP_SET_VALUE;
@@ -933,7 +967,7 @@ bpf__obj_config_map_array_event(struct bpf_map *map,
 		return -BPF_LOADER_ERRNO__OBJCONF_MAP_TYPE;
 	}
 
-	op = bpf_map_op__alloc(map);
+	op = bpf_map_op__alloc(map, term);
 	if (IS_ERR(op))
 		return PTR_ERR(op);
 
@@ -972,6 +1006,44 @@ struct bpf_obj_config_map_func bpf_obj_config_map_funcs[] = {
 };
 
 static int
+config_map_indices_range_check(struct parse_events_term *term,
+			       struct bpf_map *map,
+			       const char *map_name)
+{
+	struct parse_events_array *array = &term->array;
+	struct bpf_map_def def;
+	unsigned int i;
+	int err;
+
+	if (!array->nr_ranges)
+		return 0;
+	if (!array->ranges) {
+		pr_debug("ERROR: map %s: array->nr_ranges is %d but range array is NULL\n",
+			 map_name, (int)array->nr_ranges);
+		return -BPF_LOADER_ERRNO__INTERNAL;
+	}
+
+	err = bpf_map__get_def(map, &def);
+	if (err) {
+		pr_debug("ERROR: Unable to get map definition from '%s'\n",
+			 map_name);
+		return -BPF_LOADER_ERRNO__INTERNAL;
+	}
+
+	for (i = 0; i < array->nr_ranges; i++) {
+		unsigned int start = array->ranges[i].start;
+		size_t length = array->ranges[i].length;
+		unsigned int idx = start + length - 1;
+
+		if (idx >= def.max_entries) {
+			pr_debug("ERROR: index %d too large\n", idx);
+			return -BPF_LOADER_ERRNO__OBJCONF_MAP_IDX2BIG;
+		}
+	}
+	return 0;
+}
+
+static int
 bpf__obj_config_map(struct bpf_object *obj,
 		    struct parse_events_term *term,
 		    struct perf_evlist *evlist,
@@ -1007,6 +1079,13 @@ bpf__obj_config_map(struct bpf_object *obj,
 	}
 
 	*key_scan_pos += map_opt - map_name;
+
+	*key_scan_pos += strlen(map_opt);
+	err = config_map_indices_range_check(term, map, map_name);
+	if (err)
+		goto out;
+	*key_scan_pos -= strlen(map_opt);
+
 	for (i = 0; i < ARRAY_SIZE(bpf_obj_config_map_funcs); i++) {
 		struct bpf_obj_config_map_func *func =
 				&bpf_obj_config_map_funcs[i];
@@ -1077,6 +1156,33 @@ foreach_key_array_all(map_config_func_t func,
 }
 
 static int
+foreach_key_array_ranges(map_config_func_t func, void *arg,
+			 const char *name, int map_fd,
+			 struct bpf_map_def *pdef,
+			 struct bpf_map_op *op)
+{
+	unsigned int i, j;
+	int err;
+
+	for (i = 0; i < op->k.array.nr_ranges; i++) {
+		unsigned int start = op->k.array.ranges[i].start;
+		size_t length = op->k.array.ranges[i].length;
+
+		for (j = 0; j < length; j++) {
+			unsigned int idx = start + j;
+
+			err = func(name, map_fd, pdef, op, &idx, arg);
+			if (err) {
+				pr_debug("ERROR: failed to insert value to %s[%u]\n",
+					 name, idx);
+				return err;
+			}
+		}
+	}
+	return 0;
+}
+
+static int
 bpf_map_config_foreach_key(struct bpf_map *map,
 			   map_config_func_t func,
 			   void *arg)
@@ -1116,13 +1222,24 @@ bpf_map_config_foreach_key(struct bpf_map *map,
 		case BPF_MAP_TYPE_PERF_EVENT_ARRAY:
 			switch (op->key_type) {
 			case BPF_MAP_KEY_ALL:
-				return foreach_key_array_all(func, arg, name,
-							     map_fd, &def, op);
+				err = foreach_key_array_all(func, arg, name,
+							    map_fd, &def, op);
+				if (err)
+					return err;
+				break;
+			case BPF_MAP_KEY_RANGES:
+				err = foreach_key_array_ranges(func, arg, name,
+							       map_fd, &def,
+							       op);
+				if (err)
+					return err;
+				break;
 			default:
 				pr_debug("ERROR: keytype for map '%s' invalid\n",
 					 name);
 				return -BPF_LOADER_ERRNO__INTERNAL;
-		}
+			}
+			break;
 		default:
 			pr_debug("ERROR: type of '%s' incorrect\n", name);
 			return -BPF_LOADER_ERRNO__OBJCONF_MAP_TYPE;
@@ -1309,6 +1426,7 @@ static const char *bpf_loader_strerror_table[NR_ERRNO] = {
 	[ERRCODE_OFFSET(OBJCONF_MAP_EVTDIM)]	= "Event dimension too large",
 	[ERRCODE_OFFSET(OBJCONF_MAP_EVTINH)]	= "Doesn't support inherit event",
 	[ERRCODE_OFFSET(OBJCONF_MAP_EVTTYPE)]	= "Wrong event type for map",
+	[ERRCODE_OFFSET(OBJCONF_MAP_IDX2BIG)]	= "Index too large",
 };
 
 static int
diff --git a/tools/perf/util/bpf-loader.h b/tools/perf/util/bpf-loader.h
index c9ce792..30ee519 100644
--- a/tools/perf/util/bpf-loader.h
+++ b/tools/perf/util/bpf-loader.h
@@ -38,6 +38,7 @@ enum bpf_loader_errno {
 	BPF_LOADER_ERRNO__OBJCONF_MAP_EVTDIM,	/* Event dimension too large */
 	BPF_LOADER_ERRNO__OBJCONF_MAP_EVTINH,	/* Doesn't support inherit event */
 	BPF_LOADER_ERRNO__OBJCONF_MAP_EVTTYPE,	/* Wrong event type for map */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_IDX2BIG,	/* Index too large */
 	__BPF_LOADER_ERRNO__END,
 };
 
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 1e0ac77..f229663 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -2148,8 +2148,39 @@ void parse_events__free_terms(struct list_head *terms)
 {
 	struct parse_events_term *term, *h;
 
-	list_for_each_entry_safe(term, h, terms, list)
+	list_for_each_entry_safe(term, h, terms, list) {
+		if (term->array.nr_ranges)
+			free(term->array.ranges);
 		free(term);
+	}
+}
+
+int parse_events__merge_arrays(struct parse_events_array *dest,
+			       struct parse_events_array *another)
+{
+	struct parse_events_array new;
+
+	if (!dest || !another)
+		return -EINVAL;
+
+	new.nr_ranges = dest->nr_ranges + another->nr_ranges;
+	new.ranges = malloc(sizeof(new.ranges[0]) * new.nr_ranges);
+	if (!new.ranges)
+		return -ENOMEM;
+
+	memcpy(&new.ranges[0], dest->ranges,
+	       sizeof(new.ranges[0]) * dest->nr_ranges);
+	memcpy(&new.ranges[dest->nr_ranges], another->ranges,
+	       sizeof(new.ranges[0]) * another->nr_ranges);
+	free(dest->ranges);
+	free(another->ranges);
+	*dest = new;
+	return 0;
+}
+
+void parse_events__clear_array(struct parse_events_array *a)
+{
+	free(a->ranges);
 }
 
 void parse_events_evlist_error(struct parse_events_evlist *data,
diff --git a/tools/perf/util/parse-events.h b/tools/perf/util/parse-events.h
index 20ad3c2..c34615f 100644
--- a/tools/perf/util/parse-events.h
+++ b/tools/perf/util/parse-events.h
@@ -71,8 +71,17 @@ enum {
 	PARSE_EVENTS__TERM_TYPE_INHERIT
 };
 
+struct parse_events_array {
+	size_t nr_ranges;
+	struct {
+		unsigned int start;
+		size_t length;
+	} *ranges;
+};
+
 struct parse_events_term {
 	char *config;
+	struct parse_events_array array;
 	union {
 		char *str;
 		u64  num;
@@ -117,6 +126,9 @@ int parse_events_term__sym_hw(struct parse_events_term **term,
 int parse_events_term__clone(struct parse_events_term **new,
 			     struct parse_events_term *term);
 void parse_events__free_terms(struct list_head *terms);
+int parse_events__merge_arrays(struct parse_events_array *dest,
+			       struct parse_events_array *another);
+void parse_events__clear_array(struct parse_events_array *a);
 int parse_events__modifier_event(struct list_head *list, char *str, bool add);
 int parse_events__modifier_group(struct list_head *list, char *event_mod);
 int parse_events_name(struct list_head *list, char *name);
-- 
1.8.3.4
