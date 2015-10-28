From: Wang Nan <wangnan0@huawei.com>
Subject: [RFC PATCH net-next 1/4] perf tools: Enable pre-event inherit setting by config terms
Date: Wed, 28 Oct 2015 10:55:02 +0000
Message-ID: <1446029705-199659-2-git-send-email-wangnan0@huawei.com>
References: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lizefan@huawei.com>, <pi3orama@163.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: <acme@kernel.org>, <ast@kernel.org>, <brendan.d.gregg@gmail.com>,
	<jolsa@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows perf record setting event's attr.inherit bit by
config terms like:

 # perf record -e cycles/no-inherit/ ...
 # perf record -e cycles/inherit/ ...

So user can control inherit bit for each event separately.

In following example, a.out fork()s in main then do some complex
CPU intensive computations in both of its children.

Basic result with and without inherit:

 # perf record -e cycles -e instructions ./a.out
 [ perf record: Woken up 9 times to write data ]
 [ perf record: Captured and wrote 2.205 MB perf.data (47920 samples) ]
 # perf report --stdio
 # ...
 # Samples: 23K of event 'cycles'
 # Event count (approx.): 23641752891
 ...
 # Samples: 24K of event 'instructions'
 # Event count (approx.): 30428312415


 # perf record -i -e cycles -e instructions ./a.out
 [ perf record: Woken up 5 times to write data ]
 [ perf record: Captured and wrote 1.111 MB perf.data (24019 samples) ]
 ...
 # Samples: 12K of event 'cycles'
 # Event count (approx.): 11699501775
 ...
 # Samples: 12K of event 'instructions'
 # Event count (approx.): 15058023559

Cancel inherit for one event when globally enable:

 # perf record -e cycles/no-inherit/ -e instructions ./a.out
 [ perf record: Woken up 7 times to write data ]
 [ perf record: Captured and wrote 1.660 MB perf.data (36004 samples) ]
 ...
 # Samples: 12K of event 'cycles/no-inherit/'
 # Event count (approx.): 11895759282
 ...
 # Samples: 24K of event 'instructions'
 # Event count (approx.): 30668000441

Enable inherit for one event when globally disable:

 # perf record -i -e cycles/inherit/ -e instructions ./a.out
 [ perf record: Woken up 7 times to write data ]
 [ perf record: Captured and wrote 1.654 MB perf.data (35868 samples) ]
 ...
 # Samples: 23K of event 'cycles/inherit/'
 # Event count (approx.): 23285400229
 ...
 # Samples: 11K of event 'instructions'
 # Event count (approx.): 14969050259

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Li Zefan <lizefan@huawei.com>
Cc: pi3orama@163.com
Link: http://lkml.kernel.org/n/ebpf-eel1zncmxd8rkw7hr5u04gn0@git.kernel.org
---
 tools/perf/util/evsel.c        |  9 +++++++++
 tools/perf/util/evsel.h        |  2 ++
 tools/perf/util/parse-events.c | 14 ++++++++++++++
 tools/perf/util/parse-events.h |  2 ++
 tools/perf/util/parse-events.l |  2 ++
 5 files changed, 29 insertions(+)

diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index f820906..397fb4e 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -653,6 +653,15 @@ static void apply_config_terms(struct perf_evsel *evsel,
 		case PERF_EVSEL__CONFIG_TERM_STACK_USER:
 			dump_size = term->val.stack_user;
 			break;
+		case PERF_EVSEL__CONFIG_TERM_INHERIT:
+			/*
+			 * attr->inherit should has already been set by
+			 * perf_evsel__config. If user explicitly set
+			 * inherit using config terms, override global
+			 * opt->no_inherit setting.
+			 */
+			attr->inherit = term->val.inherit ? 1 : 0;
+			break;
 		default:
 			break;
 		}
diff --git a/tools/perf/util/evsel.h b/tools/perf/util/evsel.h
index 9a95e73..e402f83 100644
--- a/tools/perf/util/evsel.h
+++ b/tools/perf/util/evsel.h
@@ -43,6 +43,7 @@ enum {
 	PERF_EVSEL__CONFIG_TERM_TIME,
 	PERF_EVSEL__CONFIG_TERM_CALLGRAPH,
 	PERF_EVSEL__CONFIG_TERM_STACK_USER,
+	PERF_EVSEL__CONFIG_TERM_INHERIT,
 	PERF_EVSEL__CONFIG_TERM_MAX,
 };
 
@@ -55,6 +56,7 @@ struct perf_evsel_config_term {
 		bool	time;
 		char	*callgraph;
 		u64	stack_user;
+		u64	inherit;
 	} val;
 };
 
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index ae973cd..b98a82c 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -841,6 +841,12 @@ do {									   \
 	case PARSE_EVENTS__TERM_TYPE_STACKSIZE:
 		CHECK_TYPE_VAL(NUM);
 		break;
+	case PARSE_EVENTS__TERM_TYPE_INHERIT:
+		CHECK_TYPE_VAL(NUM);
+		break;
+	case PARSE_EVENTS__TERM_TYPE_NOINHERIT:
+		CHECK_TYPE_VAL(NUM);
+		break;
 	case PARSE_EVENTS__TERM_TYPE_NAME:
 		CHECK_TYPE_VAL(STR);
 		break;
@@ -876,6 +882,8 @@ static int config_term_tracepoint(struct perf_event_attr *attr,
 	switch (term->type_term) {
 	case PARSE_EVENTS__TERM_TYPE_CALLGRAPH:
 	case PARSE_EVENTS__TERM_TYPE_STACKSIZE:
+	case PARSE_EVENTS__TERM_TYPE_INHERIT:
+	case PARSE_EVENTS__TERM_TYPE_NOINHERIT:
 		return config_term_common(attr, term, err);
 	default:
 		if (err) {
@@ -939,6 +947,12 @@ do {								\
 		case PARSE_EVENTS__TERM_TYPE_STACKSIZE:
 			ADD_CONFIG_TERM(STACK_USER, stack_user, term->val.num);
 			break;
+		case PARSE_EVENTS__TERM_TYPE_INHERIT:
+			ADD_CONFIG_TERM(INHERIT, inherit, term->val.num ? 1 : 0);
+			break;
+		case PARSE_EVENTS__TERM_TYPE_NOINHERIT:
+			ADD_CONFIG_TERM(INHERIT, inherit, term->val.num ? 0 : 1);
+			break;
 		default:
 			break;
 		}
diff --git a/tools/perf/util/parse-events.h b/tools/perf/util/parse-events.h
index 5ba1d3e..9d415a8 100644
--- a/tools/perf/util/parse-events.h
+++ b/tools/perf/util/parse-events.h
@@ -67,6 +67,8 @@ enum {
 	PARSE_EVENTS__TERM_TYPE_TIME,
 	PARSE_EVENTS__TERM_TYPE_CALLGRAPH,
 	PARSE_EVENTS__TERM_TYPE_STACKSIZE,
+	PARSE_EVENTS__TERM_TYPE_NOINHERIT,
+	PARSE_EVENTS__TERM_TYPE_INHERIT
 };
 
 struct parse_events_term {
diff --git a/tools/perf/util/parse-events.l b/tools/perf/util/parse-events.l
index 0d92a4d..1fa8e0b 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -200,6 +200,8 @@ branch_type		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_BRANCH_SAMPLE_TYPE
 time			{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_TIME); }
 call-graph		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_CALLGRAPH); }
 stack-size		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_STACKSIZE); }
+inherit			{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_INHERIT); }
+no-inherit		{ return term(yyscanner, PARSE_EVENTS__TERM_TYPE_NOINHERIT); }
 ,			{ return ','; }
 "/"			{ BEGIN(INITIAL); return '/'; }
 {name_minus}		{ return str(yyscanner, PE_NAME); }
-- 
1.8.3.4
