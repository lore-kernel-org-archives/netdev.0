From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 50/53] perf tools: Set tailsize attribut bit for overwrite events
Date: Mon, 11 Jan 2016 13:48:41 +0000
Message-ID: <1452520124-2073-51-git-send-email-wangnan0@huawei.com>
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

PERF_SAMPLE_TAILSIZE pad the size of an event at the end of it in the
ring buffer, makes reading from overwrite ring buffer possible. This
patch set that bit if evsel->overwrite is selected explicitly by user.
Overwrite and tailsize are still controled separatly for legacy
readonly mmap users (most of them are in perf/tests).

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/evlist.c |  2 ++
 tools/perf/util/evlist.h |  1 +
 tools/perf/util/evsel.c  | 28 ++++++++++++++++++++++++++++
 tools/perf/util/evsel.h  |  1 +
 4 files changed, 32 insertions(+)

diff --git a/tools/perf/util/evlist.c b/tools/perf/util/evlist.c
index 0511fd2..510e960 100644
--- a/tools/perf/util/evlist.c
+++ b/tools/perf/util/evlist.c
@@ -973,6 +973,8 @@ perf_evlist__channel_for_evsel(struct perf_evsel *evsel)
 
 	if (evsel->overwrite)
 		flag |= PERF_EVLIST__CHANNEL_RDONLY;
+	if (evsel->tailsize)
+		flag |= PERF_EVLIST__CHANNEL_TAILSIZE;
 	return flag;
 }
 
diff --git a/tools/perf/util/evlist.h b/tools/perf/util/evlist.h
index 21a8b85..4dfcd67 100644
--- a/tools/perf/util/evlist.h
+++ b/tools/perf/util/evlist.h
@@ -24,6 +24,7 @@ struct record_opts;
 enum perf_evlist_mmap_flag {
 	PERF_EVLIST__CHANNEL_ENABLED	= 1,
 	PERF_EVLIST__CHANNEL_RDONLY	= 2,
+	PERF_EVLIST__CHANNEL_TAILSIZE	= 4,
 };
 
 /**
diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index c59ea34..ae69a85 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -671,13 +671,33 @@ static void apply_config_terms(struct perf_evsel *evsel,
 			attr->inherit = term->val.inherit ? 1 : 0;
 			break;
 		case PERF_EVSEL__CONFIG_TERM_OVERWRITE:
+			/*
+			 * Let tailsize and overwrite controled by /overwrite/
+			 * semultaneously because /overwrite/ can only be
+			 * passed by user explicitly, in this case user should
+			 * be able to read from that event so tailsize must
+			 * set.
+			 *
+			 * (overwrite && !tailsize) can happen only when
+			 * perf_evlist__mmap() is called with overwrite == true.
+			 * In that case there's no chance to pass /overwrite/.
+			 */
 			evsel->overwrite = term->val.overwrite ? 1 : 0;
+			evsel->tailsize = term->val.overwrite ? 1 : 0;
 			break;
 		default:
 			break;
 		}
 	}
 
+	/*
+	 * Set tailsize sample bit after config term processing because
+	 * it is possible to set overwrite globally, without config
+	 * terms.
+	 */
+	if (evsel->tailsize)
+		perf_evsel__set_sample_bit(evsel, TAILSIZE);
+
 	/* User explicitly set per-event callgraph, clear the old setting and reset. */
 	if ((callgraph_buf != NULL) || (dump_size > 0)) {
 
@@ -748,7 +768,15 @@ void perf_evsel__config(struct perf_evsel *evsel, struct record_opts *opts)
 
 	attr->sample_id_all = perf_missing_features.sample_id_all ? 0 : 1;
 	attr->inherit	    = !opts->no_inherit;
+
+	/*
+	 * opts->overwrite can be set by user only.
+	 * Always keeps evsel->overwrite == evsel->tailsize.
+	 * (evsel->overwrite && !evsel->tailsize) can only happen
+	 * when calling perf_evlist__mmap() with overwrite == true.
+	 */
 	evsel->overwrite    = opts->overwrite;
+	evsel->tailsize	    = opts->overwrite;
 
 	perf_evsel__set_sample_bit(evsel, IP);
 	perf_evsel__set_sample_bit(evsel, TID);
diff --git a/tools/perf/util/evsel.h b/tools/perf/util/evsel.h
index c76e385..d93ee02 100644
--- a/tools/perf/util/evsel.h
+++ b/tools/perf/util/evsel.h
@@ -118,6 +118,7 @@ struct perf_evsel {
 	bool			per_pkg;
 	bool			precise_max;
 	bool			overwrite;
+	bool			tailsize;
 	/* parse modifier helper */
 	int			exclude_GH;
 	int			nr_members;
-- 
1.8.3.4
