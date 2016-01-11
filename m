From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 22/53] perf tools: Support perf event alias name
Date: Mon, 11 Jan 2016 13:48:13 +0000
Message-ID: <1452520124-2073-23-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, He Kuang <hekuang@huawei.com>,
	Wang Nan <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"Masami Hiramatsu" <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:41179 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759748AbcAKNtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 08:49:33 -0500
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: He Kuang <hekuang@huawei.com>

This patch is useful when trying to pass a perf event to BPF map.
Before this patch we are unable to pass an event with config term to
BPF maps. For example:

 # perf record -a -e cycles/no-inherit,period=0x7fffffffffffffff/ \
                  -e './test_bpf_map_2.c/maps:pmu_map.event=cycles/no-inherit,period=0x7fffffffffffffff//' ls /
 event syntax error: '..ps:pmu_map.event=cycles/'
                                   \___ Event not found for map setting

Because those '/' and ',' embarrass parser.

This patch adds new bison rules for specifying an alias name to a perf
event, which allows cmdline refer to previous defined perf event through
its name. With this patch user can give alias name to a perf event using
following cmdline. The above goal can be achieved using:

 # perf record -a -e cyc=cycles/no-inherit,period=0x7fffffffffffffff/ \
                  -e './test_bpf_map_2.c/maps:pmu_map.event=cyc/' ls /

If alias is not provided (normal case):

 # perf record -e cycles ...

It will be set to event's name automatically ('cycles' in the above
example).

To allow parser refer to existing event selector, pass event list to
'struct parse_events_evlist'. perf_evlist__find_evsel_by_alias() is
introduced to get evsel through its alias.

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
 # echo "" > /sys/kernel/debug/tracing/trace
 # ./perf record -a -e cyc=cycles/no-inherit,period=0x7fffffffffffffff/ \
                    -e './test_bpf_map_2.c/maps:pmu_map.event=cyc/' ls /
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.755 MB perf.data ]
 # cat /sys/kernel/debug/tracing/trace | grep ls
               ls-25328 [002] d... 940138.313178: : sys_write:        pmu=4503165
               ls-25328 [002] dN.. 940138.313207: : sys_write_return: pmu=4582975
               ls-25328 [002] d... 940138.313211: : sys_write:        pmu=4599840
               ls-25328 [002] dN.. 940138.313220: : sys_write_return: pmu=4633352
 # ./perf report --stdio
 Error:
 The perf.data file has no samples!
 ...
 (This is expected because we set period of cycles to a very large
 value to period of cycles event because we want to use this event
 as a counter only, don't need sampling)

 # ./perf record -e cycles -e './test_bpf_map_2.c/maps:pmu_map.event=cycles/' ls /
 ERROR: Apply config to BPF failed: Doesn't support inherit event (Hint: use -i or use /no-inherit/ to turn off inherit)

Signed-off-by: He Kuang <hekuang@huawei.com>
Signed-off-by: Wang Nan <wangnan0@huawei.com>
Acked-by: Jiri Olsa <jolsa@kernel.org>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/bpf-loader.c   |  2 +-
 tools/perf/util/evlist.c       |  4 ++--
 tools/perf/util/evsel.c        |  1 +
 tools/perf/util/evsel.h        |  1 +
 tools/perf/util/parse-events.c | 26 ++++++++++++++++++++++++++
 tools/perf/util/parse-events.h |  4 ++++
 tools/perf/util/parse-events.y | 15 ++++++++++++++-
 7 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/tools/perf/util/bpf-loader.c b/tools/perf/util/bpf-loader.c
index 84b4581..2893b4e 100644
--- a/tools/perf/util/bpf-loader.c
+++ b/tools/perf/util/bpf-loader.c
@@ -1448,7 +1448,7 @@ int bpf__strerror_apply_obj_config(int err, char *buf, size_t size)
 	bpf__strerror_entry(BPF_LOADER_ERRNO__OBJCONF_MAP_EVTDIM,
 			    "Cannot set event to BPF maps in multi-thread tracing");
 	bpf__strerror_entry(BPF_LOADER_ERRNO__OBJCONF_MAP_EVTINH,
-			    "%s (Hint: use -i to turn off inherit)", emsg);
+			    "%s (Hint: use -i or use /no-inherit/ to turn off inherit)", emsg);
 	bpf__strerror_entry(BPF_LOADER_ERRNO__OBJCONF_MAP_EVTTYPE,
 			    "Can only put raw, hardware and BPF output event into a BPF map");
 	bpf__strerror_end(buf, size);
diff --git a/tools/perf/util/evlist.c b/tools/perf/util/evlist.c
index 9b56390..890b08b 100644
--- a/tools/perf/util/evlist.c
+++ b/tools/perf/util/evlist.c
@@ -1731,9 +1731,9 @@ perf_evlist__find_evsel_by_str(struct perf_evlist *evlist,
 	struct perf_evsel *evsel;
 
 	evlist__for_each(evlist, evsel) {
-		if (!evsel->name)
+		if (!evsel->alias)
 			continue;
-		if (strcmp(str, evsel->name) == 0)
+		if (strcmp(str, evsel->alias) == 0)
 			return evsel;
 	}
 
diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index cdbaf9b..a6b3b07 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -1076,6 +1076,7 @@ void perf_evsel__exit(struct perf_evsel *evsel)
 	thread_map__put(evsel->threads);
 	zfree(&evsel->group_name);
 	zfree(&evsel->name);
+	zfree(&evsel->alias);
 	perf_evsel__object.fini(evsel);
 }
 
diff --git a/tools/perf/util/evsel.h b/tools/perf/util/evsel.h
index 8e75434..19885fb 100644
--- a/tools/perf/util/evsel.h
+++ b/tools/perf/util/evsel.h
@@ -89,6 +89,7 @@ struct perf_evsel {
 	int			idx;
 	u32			ids;
 	char			*name;
+	char			*alias;
 	double			scale;
 	const char		*unit;
 	struct event_format	*tp_format;
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 6e2543c..1e0ac77 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -1091,6 +1091,30 @@ int parse_events__modifier_group(struct list_head *list,
 	return parse_events__modifier_event(list, event_mod, true);
 }
 
+int parse_events__set_event_alias(struct parse_events_evlist *data,
+				  struct list_head *list,
+				  const char *str,
+				  void *loc_alias_)
+{
+	struct perf_evsel *evsel;
+	YYLTYPE *loc_alias = loc_alias_;
+
+	if (!str)
+		return 0;
+
+	if (!list_is_singular(list)) {
+		struct parse_events_error *err = data->error;
+
+		err->idx = loc_alias->first_column;
+		err->str = strdup("One alias can be applied to one event only");
+		return -EINVAL;
+	}
+
+	evsel = list_first_entry(list, struct perf_evsel, node);
+	evsel->alias = strdup(str);
+	return evsel->alias ? 0 : -ENOMEM;
+}
+
 void parse_events__set_leader(char *name, struct list_head *list)
 {
 	struct perf_evsel *leader;
@@ -1283,6 +1307,8 @@ int parse_events_name(struct list_head *list, char *name)
 	__evlist__for_each(list, evsel) {
 		if (!evsel->name)
 			evsel->name = strdup(name);
+		if (!evsel->alias)
+			evsel->alias = strdup(name);
 	}
 
 	return 0;
diff --git a/tools/perf/util/parse-events.h b/tools/perf/util/parse-events.h
index 2a2b172..20ad3c2 100644
--- a/tools/perf/util/parse-events.h
+++ b/tools/perf/util/parse-events.h
@@ -172,4 +172,8 @@ extern int is_valid_tracepoint(const char *event_string);
 int valid_event_mount(const char *eventfs);
 char *parse_events_formats_error_string(char *additional_terms);
 
+int parse_events__set_event_alias(struct parse_events_evlist *data,
+				  struct list_head *list,
+				  const char *str,
+				  void *loc_alias_);
 #endif /* __PERF_PARSE_EVENTS_H */
diff --git a/tools/perf/util/parse-events.y b/tools/perf/util/parse-events.y
index 8992d16..c3cbd7a 100644
--- a/tools/perf/util/parse-events.y
+++ b/tools/perf/util/parse-events.y
@@ -77,6 +77,7 @@ static inc_group_count(struct list_head *list,
 %type <head> event_bpf_file
 %type <head> event_def
 %type <head> event_mod
+%type <head> event_alias
 %type <head> event_name
 %type <head> event
 %type <head> events
@@ -193,13 +194,25 @@ event_name PE_MODIFIER_EVENT
 event_name
 
 event_name:
-PE_EVENT_NAME event_def
+PE_EVENT_NAME event_alias
 {
 	ABORT_ON(parse_events_name($2, $1));
 	free($1);
 	$$ = $2;
 }
 |
+event_alias
+
+event_alias:
+PE_NAME '=' event_def
+{
+	struct list_head *list = $3;
+	struct parse_events_evlist *data = _data;
+
+	ABORT_ON(parse_events__set_event_alias(data, list, $1, &@1));
+	$$ = list;
+}
+|
 event_def
 
 event_def: event_pmu |
-- 
1.8.3.4
