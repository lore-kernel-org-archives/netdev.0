From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 19/53] perf tools: Enable BPF object configure syntax
Date: Mon, 11 Jan 2016 13:48:10 +0000
Message-ID: <1452520124-2073-20-git-send-email-wangnan0@huawei.com>
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

This patch adds the final step for BPF map configuration. A new syntax
is appended into parser so user can config BPF objects through '/' '/'
enclosed config terms.

After this patch, following syntax is available:

 # perf record -e ./test_bpf_map_1.c/maps:channel.value=10/ ...

It would takes effect after appling following commits.

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

 - Normal case:
 # ./perf record -e './test_bpf_map_1.c/maps:channel.value=10/' usleep 10
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.012 MB perf.data ]

 - Error case:

 # ./perf record -e './test_bpf_map_1.c/maps:channel.value/' usleep 10
 event syntax error: '..ps:channel:value/'
                                   \___ Config value not set (lost '=')
 Hint:	Valid config term:
      	maps:[<arraymap>]:value=[value]
	     	(add -v to see detail)
	Run 'perf list' for a list of valid events

 Usage: perf record [<options>] [<command>]
    or: perf record [<options>] -- <command> [<options>]

    -e, --event <event>   event selector. use 'perf list' to list available events

 # ./perf record -e './test_bpf_map_1.c/xmaps:channel.value=10/' usleep 10
 event syntax error: '..pf_map_1.c/xmaps:channel.value=10/'
                                   \___ Invalid object config option
 [SNIP]

 # ./perf record -e './test_bpf_map_1.c/maps:xchannel.value=10/' usleep 10
 event syntax error: '..p_1.c/maps:xchannel.value=10/'
                                   \___ Target map not exist
 [SNIP]

 # ./perf record -e './test_bpf_map_1.c/maps:channel.xvalue=10/' usleep 10
 event syntax error: '..ps:channel.xvalue=10/'
                                   \___ Invalid object maps config option
 [SNIP]

 # ./perf record -e './test_bpf_map_1.c/maps:channel.value=x10/' usleep 10
 event syntax error: '..nnel.value=x10/'
                                   \___ Incorrect value type for map
 [SNIP]

 Change BPF_MAP_TYPE_ARRAY to '1':

 # ./perf record -e './test_bpf_map_1.c/maps:channel.value=10/' usleep 10
 event syntax error: '..ps:channel.value=10/'
                                   \___ Can't use this config term to this type of map

 Hint:	Valid config term:
     	maps:[<arraymap>].value=[value]
     	(add -v to see detail)

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
 tools/perf/util/parse-events.c | 56 +++++++++++++++++++++++++++++++++++++++---
 tools/perf/util/parse-events.h |  3 ++-
 tools/perf/util/parse-events.l |  2 +-
 tools/perf/util/parse-events.y | 23 ++++++++++++++---
 4 files changed, 75 insertions(+), 9 deletions(-)

diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 4f7b0ef..1c2dc5d 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -628,17 +628,64 @@ errout:
 	return err;
 }
 
+static int
+parse_events_config_bpf(struct parse_events_evlist *data,
+		       struct bpf_object *obj,
+		       struct list_head *head_config)
+{
+	struct parse_events_term *term;
+	int error_pos;
+
+	if (!head_config || list_empty(head_config))
+		return 0;
+
+	list_for_each_entry(term, head_config, list) {
+		char errbuf[BUFSIZ];
+		int err;
+
+		if (term->type_term != PARSE_EVENTS__TERM_TYPE_USER) {
+			snprintf(errbuf, sizeof(errbuf),
+				 "Invalid config term for BPF object");
+			errbuf[BUFSIZ - 1] = '\0';
+
+			data->error->idx = term->err_term;
+			data->error->str = strdup(errbuf);
+			return -EINVAL;
+		}
+
+		err = bpf__config_obj(obj, term, NULL, &error_pos);
+		if (err) {
+			bpf__strerror_config_obj(obj, term, NULL,
+						 &error_pos, err, errbuf,
+						 sizeof(errbuf));
+			data->error->help = strdup(
+"Hint:\tValid config term:\n"
+"     \tmaps:[<arraymap>].value=[value]\n"
+"     \t(add -v to see detail)");
+			data->error->str = strdup(errbuf);
+			if (err == -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUE)
+				data->error->idx = term->err_val;
+			else
+				data->error->idx = term->err_term + error_pos;
+			return err;
+		}
+	}
+	return 0;
+
+}
+
 int parse_events_load_bpf(struct parse_events_evlist *data,
 			  struct list_head *list,
 			  char *bpf_file_name,
-			  bool source)
+			  bool source,
+			  struct list_head *head_config)
 {
 	struct bpf_object *obj;
+	int err;
 
 	obj = bpf__prepare_load(bpf_file_name, source);
 	if (IS_ERR(obj)) {
 		char errbuf[BUFSIZ];
-		int err;
 
 		err = PTR_ERR(obj);
 
@@ -656,7 +703,10 @@ int parse_events_load_bpf(struct parse_events_evlist *data,
 		return err;
 	}
 
-	return parse_events_load_bpf_obj(data, list, obj);
+	err = parse_events_load_bpf_obj(data, list, obj);
+	if (err)
+		return err;
+	return parse_events_config_bpf(data, obj, head_config);
 }
 
 static int
diff --git a/tools/perf/util/parse-events.h b/tools/perf/util/parse-events.h
index f1a6db1..84694f3 100644
--- a/tools/perf/util/parse-events.h
+++ b/tools/perf/util/parse-events.h
@@ -126,7 +126,8 @@ int parse_events_add_tracepoint(struct list_head *list, int *idx,
 int parse_events_load_bpf(struct parse_events_evlist *data,
 			  struct list_head *list,
 			  char *bpf_file_name,
-			  bool source);
+			  bool source,
+			  struct list_head *head_config);
 /* Provide this function for perf test */
 struct bpf_object;
 int parse_events_load_bpf_obj(struct parse_events_evlist *data,
diff --git a/tools/perf/util/parse-events.l b/tools/perf/util/parse-events.l
index 58c5831..4387728 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -122,7 +122,7 @@ num_dec		[0-9]+
 num_hex		0x[a-fA-F0-9]+
 num_raw_hex	[a-fA-F0-9]+
 name		[a-zA-Z_*?][a-zA-Z0-9_*?.]*
-name_minus	[a-zA-Z_*?][a-zA-Z0-9\-_*?.]*
+name_minus	[a-zA-Z_*?][a-zA-Z0-9\-_*?.:]*
 /* If you add a modifier you need to update check_modifier() */
 modifier_event	[ukhpPGHSDI]+
 modifier_bp	[rwx]{1,3}
diff --git a/tools/perf/util/parse-events.y b/tools/perf/util/parse-events.y
index ad37996..8992d16 100644
--- a/tools/perf/util/parse-events.y
+++ b/tools/perf/util/parse-events.y
@@ -64,6 +64,7 @@ static inc_group_count(struct list_head *list,
 %type <str> PE_PMU_EVENT_PRE PE_PMU_EVENT_SUF PE_KERNEL_PMU_EVENT
 %type <num> value_sym
 %type <head> event_config
+%type <head> event_bpf_config
 %type <term> event_term
 %type <head> event_pmu
 %type <head> event_legacy_symbol
@@ -455,27 +456,41 @@ PE_RAW
 }
 
 event_bpf_file:
-PE_BPF_OBJECT
+PE_BPF_OBJECT event_bpf_config
 {
 	struct parse_events_evlist *data = _data;
 	struct parse_events_error *error = data->error;
 	struct list_head *list;
 
 	ALLOC_LIST(list);
-	ABORT_ON(parse_events_load_bpf(data, list, $1, false));
+	ABORT_ON(parse_events_load_bpf(data, list, $1, false, $2));
+	if ($2)
+		parse_events__free_terms($2);
 	$$ = list;
 }
 |
-PE_BPF_SOURCE
+PE_BPF_SOURCE event_bpf_config
 {
 	struct parse_events_evlist *data = _data;
 	struct list_head *list;
 
 	ALLOC_LIST(list);
-	ABORT_ON(parse_events_load_bpf(data, list, $1, true));
+	ABORT_ON(parse_events_load_bpf(data, list, $1, true, $2));
+	if ($2)
+		parse_events__free_terms($2);
 	$$ = list;
 }
 
+event_bpf_config:
+'/' event_config '/'
+{
+	$$ = $2;
+}
+|
+{
+	$$ = NULL;
+}
+
 start_terms: event_config
 {
 	struct parse_events_terms *data = _data;
-- 
1.8.3.4
