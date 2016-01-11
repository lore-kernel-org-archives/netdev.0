From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 48/53] perf tools: Enable overwrite settings
Date: Mon, 11 Jan 2016 13:48:39 +0000
Message-ID: <1452520124-2073-49-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows following config terms and option:

 # perf record --overwrite ...

   Globally set following events to overwrite;

 # perf record --event cycles/overwrite/ ...
 # perf record --event cycles/no-overwrite/ ...

Set specific events to be overwrite or no-overwrite.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c    |  1 +
 tools/perf/perf.h              |  1 +
 tools/perf/util/evsel.c        |  4 ++++
 tools/perf/util/evsel.h        |  2 ++
 tools/perf/util/parse-events.c | 14 ++++++++++++++
 tools/perf/util/parse-events.h |  4 +++-
 tools/perf/util/parse-events.l |  2 ++
 7 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index e55a23f..8e56f92 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -1267,6 +1267,7 @@ struct option __record_options[] = {
 	OPT_BOOLEAN_SET('i', "no-inherit", &record.opts.no_inherit,
 			&record.opts.no_inherit_set,
 			"child tasks do not inherit counters"),
+	OPT_BOOLEAN(0, "overwrite", &record.opts.overwrite, "use overwrite mode"),
 	OPT_UINTEGER('F', "freq", &record.opts.user_freq, "profile at this frequency"),
 	OPT_CALLBACK('m', "mmap-pages", &record.opts, "pages[,pages]",
 		     "number of mmap data pages and AUX area tracing mmap pages",
diff --git a/tools/perf/perf.h b/tools/perf/perf.h
index 90129ac..71f305b 100644
--- a/tools/perf/perf.h
+++ b/tools/perf/perf.h
@@ -58,6 +58,7 @@ struct record_opts {
 	bool	     full_auxtrace;
 	bool	     auxtrace_snapshot_mode;
 	bool	     record_switch_events;
+	bool	     overwrite;
 	unsigned int freq;
 	unsigned int mmap_pages;
 	unsigned int auxtrace_mmap_pages;
diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index f1b633e..6932b8b 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -670,6 +670,9 @@ static void apply_config_terms(struct perf_evsel *evsel,
 			 */
 			attr->inherit = term->val.inherit ? 1 : 0;
 			break;
+		case PERF_EVSEL__CONFIG_TERM_OVERWRITE:
+			evsel->overwrite = term->val.overwrite ? 1 : 0;
+			break;
 		default:
 			break;
 		}
@@ -745,6 +748,7 @@ void perf_evsel__config(struct perf_evsel *evsel, struct record_opts *opts)
 
 	attr->sample_id_all = perf_missing_features.sample_id_all ? 0 : 1;
 	attr->inherit	    = !opts->no_inherit;
+	evsel->overwrite    = opts->overwrite;
 
 	perf_evsel__set_sample_bit(evsel, IP);
 	perf_evsel__set_sample_bit(evsel, TID);
diff --git a/tools/perf/util/evsel.h b/tools/perf/util/evsel.h
index 8932a5c..c76e385 100644
--- a/tools/perf/util/evsel.h
+++ b/tools/perf/util/evsel.h
@@ -44,6 +44,7 @@ enum {
 	PERF_EVSEL__CONFIG_TERM_CALLGRAPH,
 	PERF_EVSEL__CONFIG_TERM_STACK_USER,
 	PERF_EVSEL__CONFIG_TERM_INHERIT,
+	PERF_EVSEL__CONFIG_TERM_OVERWRITE,
 	PERF_EVSEL__CONFIG_TERM_MAX,
 };
 
@@ -57,6 +58,7 @@ struct perf_evsel_config_term {
 		char	*callgraph;
 		u64	stack_user;
 		bool	inherit;
+		bool	overwrite;
 	} val;
 };
 
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 03d18f4..c1d4f39 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -855,6 +855,12 @@ do {									   \
 	case PARSE_EVENTS__TERM_TYPE_NOINHERIT:
 		CHECK_TYPE_VAL(NUM);
 		break;
+	case PARSE_EVENTS__TERM_TYPE_OVERWRITE:
+		CHECK_TYPE_VAL(NUM);
+		break;
+	case PARSE_EVENTS__TERM_TYPE_NOOVERWRITE:
+		CHECK_TYPE_VAL(NUM);
+		break;
 	case PARSE_EVENTS__TERM_TYPE_NAME:
 		CHECK_TYPE_VAL(STR);
 		break;
@@ -892,6 +898,8 @@ static int config_term_tracepoint(struct perf_event_attr *attr,
 	case PARSE_EVENTS__TERM_TYPE_STACKSIZE:
 	case PARSE_EVENTS__TERM_TYPE_INHERIT:
 	case PARSE_EVENTS__TERM_TYPE_NOINHERIT:
+	case PARSE_EVENTS__TERM_TYPE_OVERWRITE:
+	case PARSE_EVENTS__TERM_TYPE_NOOVERWRITE:
 		return config_term_common(attr, term, err);
 	default:
 		if (err) {
@@ -961,6 +969,12 @@ do {								\
 		case PARSE_EVENTS__TERM_TYPE_NOINHERIT:
 			ADD_CONFIG_TERM(INHERIT, inherit, term->val.num ? 0 : 1);
 			break;
+		case PARSE_EVENTS__TERM_TYPE_OVERWRITE:
+			ADD_CONFIG_TERM(OVERWRITE, overwrite, term->val.num ? 1 : 0);
+			break;
+		case PARSE_EVENTS__TERM_TYPE_NOOVERWRITE:
+			ADD_CONFIG_TERM(OVERWRITE, overwrite, term->val.num ? 0 : 1);
+			break;
 		default:
 			break;
 		}
diff --git a/tools/perf/util/parse-events.h b/tools/perf/util/parse-events.h
index c34615f..29cc804 100644
--- a/tools/perf/util/parse-events.h
+++ b/tools/perf/util/parse-events.h
@@ -68,7 +68,9 @@ enum {
 	PARSE_EVENTS__TERM_TYPE_CALLGRAPH,
 	PARSE_EVENTS__TERM_TYPE_STACKSIZE,
 	PARSE_EVENTS__TERM_TYPE_NOINHERIT,
-	PARSE_EVENTS__TERM_TYPE_INHERIT
+	PARSE_EVENTS__TERM_TYPE_INHERIT,
+	PARSE_EVENTS__TERM_TYPE_NOOVERWRITE,
+	PARSE_EVENTS__TERM_TYPE_OVERWRITE,
 };
 
 struct parse_events_array {
diff --git a/tools/perf/util/parse-events.l b/tools/perf/util/parse-events.l
index 27d567f..2ef6f96 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -202,6 +202,8 @@ call-graph		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_CALLGRAPH); }
 stack-size		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_STACKSIZE); }
 inherit			{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_INHERIT); }
 no-inherit		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_NOINHERIT); }
+overwrite		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_OVERWRITE); }
+no-overwrite		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_NOOVERWRITE); }
 ,			{ return ','; }
 "/"			{ BEGIN(INITIAL); return '/'; }
 {name_minus}		{ return str(yyscanner, PE_NAME); }
-- 
1.8.3.4
