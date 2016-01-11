From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 21/53] perf tools: Enable passing event to BPF object
Date: Mon, 11 Jan 2016 13:48:12 +0000
Message-ID: <1452520124-2073-22-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"Masami Hiramatsu" <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A new syntax is appended into parser so user can pass predefined perf
events into BPF objects.

After this patch, BPF programs for perf are finally able to utilize
bpf_perf_event_read() introduced in commit 35578d7984003097af2b1e3
(bpf: Implement function bpf_perf_event_read() that get the selected
hardware PMU conuter).

Test result:

 # cat ./test_bpf_map_2.c
 /************************ BEGIN **************************/
 #include <uapi/linux/bpf.h>
 #define SEC(NAME) __attribute__((section(NAME), used))
 struct bpf_map_def {
     unsigned int type;
     unsigned int key_size;
     unsigned int value_size;
     unsigned int max_entries;
 };
 static int (*trace_printk)(const char *fmt, int fmt_size, ...) =
     (void *)BPF_FUNC_trace_printk;
 static int (*get_smp_processor_id)(void) =
     (void *)BPF_FUNC_get_smp_processor_id;
 static int (*perf_event_read)(struct bpf_map_def *, int) =
     (void *)BPF_FUNC_perf_event_read;

 struct bpf_map_def SEC("maps") pmu_map = {
     .type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
     .key_size = sizeof(int),
     .value_size = sizeof(int),
     .max_entries = __NR_CPUS__,
 };
 SEC("func_write=sys_write")
 int func_write(void *ctx)
 {
     unsigned long long val;
     char fmt[] = "sys_write:        pmu=%llu\n";
     val = perf_event_read(&pmu_map, get_smp_processor_id());
     trace_printk(fmt, sizeof(fmt), val);
     return 0;
 }

 SEC("func_write_return=sys_write%return")
 int func_write_return(void *ctx)
 {
     unsigned long long val = 0;
     char fmt[] = "sys_write_return: pmu=%llu\n";
     val = perf_event_read(&pmu_map, get_smp_processor_id());
     trace_printk(fmt, sizeof(fmt), val);
     return 0;
 }
 char _license[] SEC("license") = "GPL";
 int _version SEC("version") = LINUX_VERSION_CODE;
 /************************* END ***************************/

Normal case:
 # echo "" > /sys/kernel/debug/tracing/trace
 # ./perf record -i -e cycles -e './test_bpf_map_2.c/maps:pmu_map.event=cycles/' ls /
 [SNIP]
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.013 MB perf.data (7 samples) ]
 # cat /sys/kernel/debug/tracing/trace | grep ls
               ls-17066 [000] d... 938449.863301: : sys_write:        pmu=1157327
               ls-17066 [000] dN.. 938449.863342: : sys_write_return: pmu=1225218
               ls-17066 [000] d... 938449.863349: : sys_write:        pmu=1241922
               ls-17066 [000] dN.. 938449.863369: : sys_write_return: pmu=1267445

Normal case (system wide):
 # echo "" > /sys/kernel/debug/tracing/trace
 # ./perf record -i -e cycles -e './test_bpf_map_2.c/maps:pmu_map.event=cycles/' -a
 ^C[ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.811 MB perf.data (120 samples) ]

 # cat /sys/kernel/debug/tracing/trace | grep -v '18446744073709551594' | grep -v perf | head -n 20
 [SNIP]
 #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
 #              | |       |   ||||       |         |
            gmain-30828 [002] d... 2740551.068992: : sys_write:        pmu=84373
            gmain-30828 [002] d... 2740551.068992: : sys_write_return: pmu=87696
            gmain-30828 [002] d... 2740551.068996: : sys_write:        pmu=100658
            gmain-30828 [002] d... 2740551.068997: : sys_write_return: pmu=102572

Error case 1:

 # ./perf record -e './test_bpf_map_2.c' ls /
 [SNIP]
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.014 MB perf.data ]
 # cat /sys/kernel/debug/tracing/trace | grep ls
               ls-17115 [007] d... 2724279.665625: : sys_write:        pmu=18446744073709551614
               ls-17115 [007] dN.. 2724279.665651: : sys_write_return: pmu=18446744073709551614
               ls-17115 [007] d... 2724279.665658: : sys_write:        pmu=18446744073709551614
               ls-17115 [007] dN.. 2724279.665677: : sys_write_return: pmu=18446744073709551614

 (18446744073709551614 is 0xfffffffffffffffe (-2))

Error case 2:
 # ./perf record -e cycles -e './test_bpf_map_2.c/maps:pmu_map.event=evt/' -a
 event syntax error: '..ps:pmu_map.event=evt/'
                                   \___ Event not found for map setting

 Hint:	Valid config terms:
      	maps:[<arraymap>].value=[value]
      	maps:[<eventmap>].event=[event]
 [SNIP]

Error case 3:
 # ls /proc/2348/task/
 2348  2505  2506  2507  2508
 # ./perf record -i -e cycles -e './test_bpf_map_2.c/maps:pmu_map.event=cycles/' -p 2348
 ERROR: Apply config to BPF failed: Cannot set event to BPF maps in multi-thread tracing

Error case 4:
 # ./perf record -e cycles -e './test_bpf_map_2.c/maps:pmu_map.event=cycles/' ls /
 ERROR: Apply config to BPF failed: Doesn't support inherit event (Hint: use -i to turn off inherit)

Error case 5:
 # ./perf record -i -e raw_syscalls:sys_enter -e './test_bpf_map_2.c/maps:pmu_map.event=raw_syscalls:sys_enter/' ls
 ERROR: Apply config to BPF failed: Can only put raw, hardware and BPF output event into a BPF map

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Acked-by: Jiri Olsa <jolsa@kernel.org>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/bpf-loader.c   | 138 ++++++++++++++++++++++++++++++++++++++++-
 tools/perf/util/bpf-loader.h   |   5 ++
 tools/perf/util/evlist.c       |  16 +++++
 tools/perf/util/evlist.h       |   3 +
 tools/perf/util/parse-events.c |  15 +++--
 tools/perf/util/parse-events.h |   1 +
 6 files changed, 171 insertions(+), 7 deletions(-)

diff --git a/tools/perf/util/bpf-loader.c b/tools/perf/util/bpf-loader.c
index 96fd18b..84b4581 100644
--- a/tools/perf/util/bpf-loader.c
+++ b/tools/perf/util/bpf-loader.c
@@ -742,6 +742,7 @@ int bpf__foreach_tev(struct bpf_object *obj,
 
 enum bpf_map_op_type {
 	BPF_MAP_OP_SET_VALUE,
+	BPF_MAP_OP_SET_EVSEL,
 };
 
 enum bpf_map_key_type {
@@ -754,6 +755,7 @@ struct bpf_map_op {
 	enum bpf_map_key_type key_type;
 	union {
 		u64 value;
+		struct perf_evsel *evsel;
 	} v;
 };
 
@@ -891,10 +893,73 @@ bpf__obj_config_map_value(struct bpf_map *map,
 	if (term->type_val == PARSE_EVENTS__TERM_TYPE_NUM)
 		return bpf__obj_config_map_array_value(map, term);
 
-	pr_debug("ERROR: wrong value type\n");
+	pr_debug("ERROR: wrong value type for 'value'\n");
 	return -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUE;
 }
 
+static int
+bpf__obj_config_map_array_event(struct bpf_map *map,
+				struct parse_events_term *term,
+				struct perf_evlist *evlist)
+{
+	struct perf_evsel *evsel;
+	struct bpf_map_def def;
+	struct bpf_map_op *op;
+	const char *map_name;
+	int err;
+
+	map_name = bpf_map__get_name(map);
+	evsel = perf_evlist__find_evsel_by_str(evlist, term->val.str);
+	if (!evsel) {
+		pr_debug("Event (for '%s') '%s' doesn't exist\n",
+			 map_name, term->val.str);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_NOEVT;
+	}
+
+	err = bpf_map__get_def(map, &def);
+	if (err) {
+		pr_debug("Unable to get map definition from '%s'\n",
+			 map_name);
+		return err;
+	}
+
+	/*
+	 * No need to check key_size and value_size:
+	 * kernel has already checked them.
+	 */
+	if (def.type != BPF_MAP_TYPE_PERF_EVENT_ARRAY) {
+		pr_debug("Map %s type is not BPF_MAP_TYPE_PERF_EVENT_ARRAY\n",
+			 map_name);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_TYPE;
+	}
+
+	op = bpf_map_op__alloc(map);
+	if (IS_ERR(op))
+		return PTR_ERR(op);
+
+	op->v.evsel = evsel;
+	op->op_type = BPF_MAP_OP_SET_EVSEL;
+	return 0;
+}
+
+static int
+bpf__obj_config_map_event(struct bpf_map *map,
+			  struct parse_events_term *term,
+			  struct perf_evlist *evlist)
+{
+	if (!term->err_val) {
+		pr_debug("Config value not set\n");
+		return -BPF_LOADER_ERRNO__OBJCONF_CONF;
+	}
+
+	if (term->type_val == PARSE_EVENTS__TERM_TYPE_STR)
+		return bpf__obj_config_map_array_event(map, term, evlist);
+
+	pr_debug("ERROR: wrong value type for 'event'\n");
+	return -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUE;
+}
+
+
 struct bpf_obj_config_map_func {
 	const char *config_opt;
 	int (*config_func)(struct bpf_map *, struct parse_events_term *,
@@ -903,6 +968,7 @@ struct bpf_obj_config_map_func {
 
 struct bpf_obj_config_map_func bpf_obj_config_map_funcs[] = {
 	{"value", bpf__obj_config_map_value},
+	{"event", bpf__obj_config_map_event},
 };
 
 static int
@@ -1047,6 +1113,7 @@ bpf_map_config_foreach_key(struct bpf_map *map,
 	list_for_each_entry(op, &priv->ops_list, list) {
 		switch (def.type) {
 		case BPF_MAP_TYPE_ARRAY:
+		case BPF_MAP_TYPE_PERF_EVENT_ARRAY:
 			switch (op->key_type) {
 			case BPF_MAP_KEY_ALL:
 				return foreach_key_array_all(func, arg, name,
@@ -1101,6 +1168,60 @@ apply_config_value_for_key(int map_fd, void *pkey,
 }
 
 static int
+apply_config_evsel_for_key(const char *name, int map_fd, void *pkey,
+			   struct perf_evsel *evsel)
+{
+	struct xyarray *xy = evsel->fd;
+	struct perf_event_attr *attr;
+	unsigned int key, events;
+	bool check_pass = false;
+	int *evt_fd;
+	int err;
+
+	if (!xy) {
+		pr_debug("ERROR: evsel not ready for map %s\n", name);
+		return -BPF_LOADER_ERRNO__INTERNAL;
+	}
+
+	if (xy->row_size / xy->entry_size != 1) {
+		pr_debug("ERROR: Dimension of target event is incorrect for map %s\n",
+			 name);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_EVTDIM;
+	}
+
+	attr = &evsel->attr;
+	if (attr->inherit) {
+		pr_debug("ERROR: Can't put inherit event into map %s\n", name);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_EVTINH;
+	}
+
+	if (attr->type == PERF_TYPE_RAW)
+		check_pass = true;
+	if (attr->type == PERF_TYPE_HARDWARE)
+		check_pass = true;
+	if (attr->type == PERF_TYPE_SOFTWARE &&
+			attr->config == PERF_COUNT_SW_BPF_OUTPUT)
+		check_pass = true;
+	if (!check_pass) {
+		pr_debug("ERROR: Event type is wrong for map %s\n", name);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_EVTTYPE;
+	}
+
+	events = xy->entries / (xy->row_size / xy->entry_size);
+	key = *((unsigned int *)pkey);
+	if (key >= events) {
+		pr_debug("ERROR: there is no event %d for map %s\n",
+			 key, name);
+		return -BPF_LOADER_ERRNO__OBJCONF_MAP_MAPSIZE;
+	}
+	evt_fd = xyarray__entry(xy, key, 0);
+	err = bpf_map_update_elem(map_fd, pkey, evt_fd, BPF_ANY);
+	if (err && errno)
+		err = -errno;
+	return err;
+}
+
+static int
 apply_obj_config_map_for_key(const char *name, int map_fd,
 			     struct bpf_map_def *pdef __maybe_unused,
 			     struct bpf_map_op *op,
@@ -1114,6 +1235,10 @@ apply_obj_config_map_for_key(const char *name, int map_fd,
 						 pdef->value_size,
 						 op->v.value);
 		break;
+	case BPF_MAP_OP_SET_EVSEL:
+		err = apply_config_evsel_for_key(name, map_fd, pkey,
+						 op->v.evsel);
+		break;
 	default:
 		pr_debug("ERROR: unknown value type for '%s'\n", name);
 		err = -BPF_LOADER_ERRNO__INTERNAL;
@@ -1179,6 +1304,11 @@ static const char *bpf_loader_strerror_table[NR_ERRNO] = {
 	[ERRCODE_OFFSET(OBJCONF_MAP_TYPE)]	= "Incorrect map type",
 	[ERRCODE_OFFSET(OBJCONF_MAP_KEYSIZE)]	= "Incorrect map key size",
 	[ERRCODE_OFFSET(OBJCONF_MAP_VALUESIZE)]	= "Incorrect map value size",
+	[ERRCODE_OFFSET(OBJCONF_MAP_NOEVT)]	= "Event not found for map setting",
+	[ERRCODE_OFFSET(OBJCONF_MAP_MAPSIZE)]	= "Invalid map size for event setting",
+	[ERRCODE_OFFSET(OBJCONF_MAP_EVTDIM)]	= "Event dimension too large",
+	[ERRCODE_OFFSET(OBJCONF_MAP_EVTINH)]	= "Doesn't support inherit event",
+	[ERRCODE_OFFSET(OBJCONF_MAP_EVTTYPE)]	= "Wrong event type for map",
 };
 
 static int
@@ -1315,6 +1445,12 @@ int bpf__strerror_config_obj(struct bpf_object *obj __maybe_unused,
 int bpf__strerror_apply_obj_config(int err, char *buf, size_t size)
 {
 	bpf__strerror_head(err, buf, size);
+	bpf__strerror_entry(BPF_LOADER_ERRNO__OBJCONF_MAP_EVTDIM,
+			    "Cannot set event to BPF maps in multi-thread tracing");
+	bpf__strerror_entry(BPF_LOADER_ERRNO__OBJCONF_MAP_EVTINH,
+			    "%s (Hint: use -i to turn off inherit)", emsg);
+	bpf__strerror_entry(BPF_LOADER_ERRNO__OBJCONF_MAP_EVTTYPE,
+			    "Can only put raw, hardware and BPF output event into a BPF map");
 	bpf__strerror_end(buf, size);
 	return 0;
 }
diff --git a/tools/perf/util/bpf-loader.h b/tools/perf/util/bpf-loader.h
index db3c34c..c9ce792 100644
--- a/tools/perf/util/bpf-loader.h
+++ b/tools/perf/util/bpf-loader.h
@@ -33,6 +33,11 @@ enum bpf_loader_errno {
 	BPF_LOADER_ERRNO__OBJCONF_MAP_TYPE,	/* Incorrect map type */
 	BPF_LOADER_ERRNO__OBJCONF_MAP_KEYSIZE,	/* Incorrect map key size */
 	BPF_LOADER_ERRNO__OBJCONF_MAP_VALUESIZE,/* Incorrect map value size */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_NOEVT,	/* Event not found for map setting */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_MAPSIZE,	/* Invalid map size for event setting */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_EVTDIM,	/* Event dimension too large */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_EVTINH,	/* Doesn't support inherit event */
+	BPF_LOADER_ERRNO__OBJCONF_MAP_EVTTYPE,	/* Wrong event type for map */
 	__BPF_LOADER_ERRNO__END,
 };
 
diff --git a/tools/perf/util/evlist.c b/tools/perf/util/evlist.c
index d81f13d..9b56390 100644
--- a/tools/perf/util/evlist.c
+++ b/tools/perf/util/evlist.c
@@ -1723,3 +1723,19 @@ void perf_evlist__set_tracking_event(struct perf_evlist *evlist,
 
 	tracking_evsel->tracking = true;
 }
+
+struct perf_evsel *
+perf_evlist__find_evsel_by_str(struct perf_evlist *evlist,
+			       const char *str)
+{
+	struct perf_evsel *evsel;
+
+	evlist__for_each(evlist, evsel) {
+		if (!evsel->name)
+			continue;
+		if (strcmp(str, evsel->name) == 0)
+			return evsel;
+	}
+
+	return NULL;
+}
diff --git a/tools/perf/util/evlist.h b/tools/perf/util/evlist.h
index 7c4d9a2..a0d1522 100644
--- a/tools/perf/util/evlist.h
+++ b/tools/perf/util/evlist.h
@@ -294,4 +294,7 @@ void perf_evlist__set_tracking_event(struct perf_evlist *evlist,
 				     struct perf_evsel *tracking_evsel);
 
 void perf_event_attr__set_max_precise_ip(struct perf_event_attr *attr);
+
+struct perf_evsel *
+perf_evlist__find_evsel_by_str(struct perf_evlist *evlist, const char *str);
 #endif /* __PERF_EVLIST_H */
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 1c2dc5d..6e2543c 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -653,14 +653,16 @@ parse_events_config_bpf(struct parse_events_evlist *data,
 			return -EINVAL;
 		}
 
-		err = bpf__config_obj(obj, term, NULL, &error_pos);
+		err = bpf__config_obj(obj, term, data->evlist, &error_pos);
 		if (err) {
-			bpf__strerror_config_obj(obj, term, NULL,
+			bpf__strerror_config_obj(obj, term, data->evlist,
 						 &error_pos, err, errbuf,
 						 sizeof(errbuf));
 			data->error->help = strdup(
-"Hint:\tValid config term:\n"
+"Hint:\tValid config terms:\n"
 "     \tmaps:[<arraymap>].value=[value]\n"
+"     \tmaps:[<eventmap>].event=[event]\n"
+"\n"
 "     \t(add -v to see detail)");
 			data->error->str = strdup(errbuf);
 			if (err == -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUE)
@@ -1442,9 +1444,10 @@ int parse_events(struct perf_evlist *evlist, const char *str,
 		 struct parse_events_error *err)
 {
 	struct parse_events_evlist data = {
-		.list  = LIST_HEAD_INIT(data.list),
-		.idx   = evlist->nr_entries,
-		.error = err,
+		.list   = LIST_HEAD_INIT(data.list),
+		.idx    = evlist->nr_entries,
+		.error  = err,
+		.evlist = evlist,
 	};
 	int ret;
 
diff --git a/tools/perf/util/parse-events.h b/tools/perf/util/parse-events.h
index 84694f3..2a2b172 100644
--- a/tools/perf/util/parse-events.h
+++ b/tools/perf/util/parse-events.h
@@ -98,6 +98,7 @@ struct parse_events_evlist {
 	int			   idx;
 	int			   nr_groups;
 	struct parse_events_error *error;
+	struct perf_evlist	  *evlist;
 };
 
 struct parse_events_terms {
-- 
1.8.3.4
