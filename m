From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 24/53] perf tools: Enable indices setting syntax for BPF maps
Date: Mon, 11 Jan 2016 13:48:15 +0000
Message-ID: <1452520124-2073-25-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduce a new syntax to perf event parser:

 # perf record -e './test_bpf_map_3.c/maps:channel.value[0,1,2,3...5]=101/' usleep 2

By utilizing the basic facilities in bpf-loader.c which allow setting
different slots in a BPF map separately, the newly introduced syntax
allows perf to control specific elements in a BPF map.

Test result:

 # cat ./test_bpf_map_3.c
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
 	.value_size = sizeof(unsigned char),
 	.max_entries = 100,
 };
 SEC("func=hrtimer_nanosleep rqtp->tv_nsec")
 int func(void *ctx, int err, long nsec)
 {
 	char fmt[] = "%ld\n";
 	long usec = nsec * 0x10624dd3 >> 38; // nsec / 1000
 	int key = (int)usec;
 	unsigned char *pval = map_lookup_elem(&channel, &key);

 	if (!pval)
 		return 0;
 	trace_printk(fmt, sizeof(fmt), (unsigned char)*pval);
 	return 0;
 }
 char _license[] SEC("license") = "GPL";
 int _version SEC("version") = LINUX_VERSION_CODE;
 /************************* END ***************************/

Normal case:
 # echo "" > /sys/kernel/debug/tracing/trace
 # ./perf record -e './test_bpf_map_3.c/maps:channel.value[0,1,2,3...5]=101/' usleep 2
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.012 MB perf.data ]
 # cat /sys/kernel/debug/tracing/trace | grep usleep
           usleep-405   [004] d... 2745423.547822: : 101
 # ./perf record -e './test_bpf_map_3.c/maps:channel.value[0...9,20...29]=102,maps:channel.value[10...19]=103/' usleep 3
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.012 MB perf.data ]
 # ./perf record -e './test_bpf_map_3.c/maps:channel.value[0...9,20...29]=102,maps:channel.value[10...19]=103/' usleep 15
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.012 MB perf.data ]
 # cat /sys/kernel/debug/tracing/trace | grep usleep
           usleep-405   [004] d... 2745423.547822: : 101
           usleep-655   [006] d... 2745434.122814: : 102
           usleep-904   [006] d... 2745439.916264: : 103
 # ./perf record -e './test_bpf_map_3.c/maps:channel.value[all]=104/' usleep 99
 # cat /sys/kernel/debug/tracing/trace | grep usleep
           usleep-405   [004] d... 2745423.547822: : 101
           usleep-655   [006] d... 2745434.122814: : 102
           usleep-904   [006] d... 2745439.916264: : 103
           usleep-1537  [003] d... 2745538.053737: : 104

Error case:
 # ./perf record -e './test_bpf_map_3.c/maps:channel.value[10...1000]=104/' usleep 99
 event syntax error: '..annel.value[10...1000]=104/'
                                   \___ Index too large
 Hint:	Valid config terms:
      	maps:[<arraymap>].value<indices>=[value]
      	maps:[<eventmap>].event<indices>=[event]

      	where <indices> is something like [0,3...5] or [all]
      	(add -v to see detail)
 Run 'perf list' for a list of valid events

  Usage: perf record [<options>] [<command>]
     or: perf record [<options>] -- <command> [<options>]

     -e, --event <event>   event selector. use 'perf list' to list available events

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Acked-by: Jiri Olsa <jolsa@kernel.org>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/parse-events.c |  5 ++-
 tools/perf/util/parse-events.l | 13 ++++++-
 tools/perf/util/parse-events.y | 85 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+), 3 deletions(-)

diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index f229663..03d18f4 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -660,9 +660,10 @@ parse_events_config_bpf(struct parse_events_evlist *data,
 						 sizeof(errbuf));
 			data->error->help = strdup(
 "Hint:\tValid config terms:\n"
-"     \tmaps:[<arraymap>].value=[value]\n"
-"     \tmaps:[<eventmap>].event=[event]\n"
+"     \tmaps:[<arraymap>].value<indices>=[value]\n"
+"     \tmaps:[<eventmap>].event<indices>=[event]\n"
 "\n"
+"     \twhere <indices> is something like [0,3...5] or [all]\n"
 "     \t(add -v to see detail)");
 			data->error->str = strdup(errbuf);
 			if (err == -BPF_LOADER_ERRNO__OBJCONF_MAP_VALUE)
diff --git a/tools/perf/util/parse-events.l b/tools/perf/util/parse-events.l
index 4387728..8bb3437 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -9,8 +9,8 @@
 %{
 #include <errno.h>
 #include "../perf.h"
-#include "parse-events-bison.h"
 #include "parse-events.h"
+#include "parse-events-bison.h"
 
 char *parse_events_get_text(yyscan_t yyscanner);
 YYSTYPE *parse_events_get_lval(yyscan_t yyscanner);
@@ -111,6 +111,7 @@ do {							\
 %x mem
 %s config
 %x event
+%x array
 
 group		[^,{}/]*[{][^}]*[}][^,{}/]*
 event_pmu	[^,{}/]+[/][^/]*[/][^,{}/]*
@@ -176,6 +177,14 @@ modifier_bp	[rwx]{1,3}
 
 }
 
+<array>{
+"]"			{ BEGIN(config); return ']'; }
+{num_dec}		{ return value(yyscanner, 10); }
+{num_hex}		{ return value(yyscanner, 16); }
+,			{ return ','; }
+"\.\.\."		{ return PE_ARRAY_RANGE; }
+}
+
 <config>{
 	/*
 	 * Please update parse_events_formats_error_string any time
@@ -196,6 +205,8 @@ no-inherit		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_NOINHERIT); }
 ,			{ return ','; }
 "/"			{ BEGIN(INITIAL); return '/'; }
 {name_minus}		{ return str(yyscanner, PE_NAME); }
+\[all\]			{ return PE_ARRAY_ALL; }
+"["			{ BEGIN(array); return '['; }
 }
 
 <mem>{
diff --git a/tools/perf/util/parse-events.y b/tools/perf/util/parse-events.y
index c3cbd7a..7e93b9f 100644
--- a/tools/perf/util/parse-events.y
+++ b/tools/perf/util/parse-events.y
@@ -48,6 +48,7 @@ static inc_group_count(struct list_head *list,
 %token PE_PREFIX_MEM PE_PREFIX_RAW PE_PREFIX_GROUP
 %token PE_ERROR
 %token PE_PMU_EVENT_PRE PE_PMU_EVENT_SUF PE_KERNEL_PMU_EVENT
+%token PE_ARRAY_ALL PE_ARRAY_RANGE
 %type <num> PE_VALUE
 %type <num> PE_VALUE_SYM_HW
 %type <num> PE_VALUE_SYM_SW
@@ -84,6 +85,9 @@ static inc_group_count(struct list_head *list,
 %type <head> group_def
 %type <head> group
 %type <head> groups
+%type <array> array
+%type <array> array_term
+%type <array> array_terms
 
 %union
 {
@@ -95,6 +99,7 @@ static inc_group_count(struct list_head *list,
 		char *sys;
 		char *event;
 	} tracepoint_name;
+	struct parse_events_array array;
 }
 %%
 
@@ -601,6 +606,86 @@ PE_TERM
 	ABORT_ON(parse_events_term__num(&term, (int)$1, NULL, 1, &@1, NULL));
 	$$ = term;
 }
+|
+PE_NAME array '=' PE_NAME
+{
+	struct parse_events_term *term;
+	int i;
+
+	ABORT_ON(parse_events_term__str(&term, PARSE_EVENTS__TERM_TYPE_USER,
+					$1, $4, &@1, &@4));
+
+	term->array = $2;
+	$$ = term;
+}
+|
+PE_NAME array '=' PE_VALUE
+{
+	struct parse_events_term *term;
+
+	ABORT_ON(parse_events_term__num(&term, PARSE_EVENTS__TERM_TYPE_USER,
+					$1, $4, &@1, &@4));
+	term->array = $2;
+	$$ = term;
+}
+
+array:
+'[' array_terms ']'
+{
+	$$ = $2;
+}
+|
+PE_ARRAY_ALL
+{
+	$$.nr_ranges = 0;
+	$$.ranges = NULL;
+}
+
+array_terms:
+array_terms ',' array_term
+{
+	struct parse_events_array new_array;
+
+	new_array.nr_ranges = $1.nr_ranges + $3.nr_ranges;
+	new_array.ranges = malloc(sizeof(new_array.ranges[0]) *
+				  new_array.nr_ranges);
+	ABORT_ON(!new_array.ranges);
+	memcpy(&new_array.ranges[0], $1.ranges,
+	       $1.nr_ranges * sizeof(new_array.ranges[0]));
+	memcpy(&new_array.ranges[$1.nr_ranges], $3.ranges,
+	       $3.nr_ranges * sizeof(new_array.ranges[0]));
+	free($1.ranges);
+	free($3.ranges);
+	$$ = new_array;
+}
+|
+array_term
+
+array_term:
+PE_VALUE
+{
+	struct parse_events_array array;
+
+	array.nr_ranges = 1;
+	array.ranges = malloc(sizeof(array.ranges[0]));
+	ABORT_ON(!array.ranges);
+	array.ranges[0].start = $1;
+	array.ranges[0].length = 1;
+	$$ = array;
+}
+|
+PE_VALUE PE_ARRAY_RANGE PE_VALUE
+{
+	struct parse_events_array array;
+
+	ABORT_ON($3 < $1);
+	array.nr_ranges = 1;
+	array.ranges = malloc(sizeof(array.ranges[0]));
+	ABORT_ON(!array.ranges);
+	array.ranges[0].start = $1;
+	array.ranges[0].length = $3 - $1 + 1;
+	$$ = array;
+}
 
 sep_dc: ':' |
 
-- 
1.8.3.4
