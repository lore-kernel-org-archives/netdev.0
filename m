From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 51/53] perf record: Read from tailsize ring buffer
Date: Mon, 11 Jan 2016 13:48:42 +0000
Message-ID: <1452520124-2073-52-git-send-email-wangnan0@huawei.com>
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

tailsize_rb_find_start() introduced to find the first available event
from a tailsize ring buffer through tailsize. event with '/overwrite/'
setting is able to be read. record__mmap_should_read() is changed
accordingly.

Reading a active tailsize ring buffer is unsafe. A global tailsize ring
buffer director is introduced into 'struct record'
record__mmap_should_read() returns true if tailsize_evt_stopped is true.
Following patch whould turn off events attached to tailsize ring buffer
and toggle this director.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 69 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 68 insertions(+), 1 deletion(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 8e56f92..6c8905b 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -56,6 +56,7 @@ struct record {
 	bool			no_buildid_cache_set;
 	bool			timestamp_filename;
 	bool			switch_output;
+	bool			tailsize_evt_stopped;
 	unsigned long long	samples;
 };
 
@@ -79,6 +80,63 @@ static int process_synthesized_event(struct perf_tool *tool,
 	return record__write(rec, event, event->header.size);
 }
 
+static int
+tailsize_rb_find_start(void *buf, u64 head, int mask, u64 *p_evt_head)
+{
+	int buf_size = mask + 1;
+	u64 evt_head = head;
+	u64 *pevt_size;
+
+	pr_debug("start reading tailsize, head=%"PRId64"\n", head);
+	while (true) {
+		struct perf_event_header *pheader;
+
+		pevt_size = buf + ((evt_head - sizeof(*pevt_size)) & mask);
+		pr_debug4("read tailsize: size: %"PRId64"\n", *pevt_size);
+
+		if (*pevt_size % sizeof(u64) != 0) {
+			pr_warning("Tailsize ring buffer corrupted: unaligned\n");
+			return -1;
+		}
+
+		if (!*pevt_size) {
+			if (evt_head) {
+				pr_warning("Tailsize ring buffer corrupted: size is 0 but evt_head (0x%"PRIx64") is not 0\n",
+					   (unsigned long)evt_head);
+				return -1;
+			}
+			*p_evt_head = evt_head;
+			return 0;
+		}
+
+		if (evt_head < *pevt_size) {
+			pr_warning("Tailsize ring buffer corrupted: head (%"PRId64") < size (%"PRId64")\n",
+				   evt_head, *pevt_size);
+			return -1;
+		}
+
+		evt_head -= *pevt_size;
+
+		if (evt_head + buf_size < head) {
+			evt_head += *pevt_size;
+			pr_debug("Finish reading tailsize buffer, evt_head=%"PRIx64", head=%"PRIx64"\n",
+				 evt_head, head);
+			*p_evt_head = evt_head;
+			return 0;
+		}
+
+		pheader = (struct perf_event_header *)(buf + (evt_head & mask));
+		if (pheader->size != *pevt_size) {
+			pr_warning("Tailsize ring buffer corrupted: found size mismatch: %d vs %"PRId64"\n",
+				   pheader->size, *pevt_size);
+			return -1;
+		}
+	}
+
+	pr_warning("ERROR: shouldn't get there\n");
+	return -1;
+}
+
 static int record__mmap_read(struct record *rec, int idx)
 {
 	struct perf_mmap *md = &rec->evlist->mmap[idx];
@@ -88,10 +146,17 @@ static int record__mmap_read(struct record *rec, int idx)
 	unsigned long size;
 	void *buf;
 	int rc = 0;
+	int channel;
 
 	if (old == head)
 		return 0;
 
+	channel = perf_evlist__idx_channel(rec->evlist, idx);
+	if (perf_evlist__channel_check(rec->evlist, channel, TAILSIZE)) {
+		if (tailsize_rb_find_start(data, head, md->mask, &old))
+			return -1;
+	}
+
 	rec->samples++;
 
 	size = head - old;
@@ -462,7 +527,8 @@ static bool record__mmap_should_read(struct record *rec, int idx)
 	if (perf_evlist__channel_idx(rec->evlist, &channel, &idx))
 		return false;
 	if (perf_evlist__channel_check(rec->evlist, channel, RDONLY))
-		return false;
+		if (perf_evlist__channel_check(rec->evlist, channel, TAILSIZE))
+			return rec->tailsize_evt_stopped;
 	return true;
 }
 
@@ -1226,6 +1292,7 @@ static struct record record = {
 		.mmap2		= perf_event__process_mmap2,
 		.ordered_events	= true,
 	},
+	.tailsize_evt_stopped	= false,
 };
 
 const char record_callchain_help[] = CALLCHAIN_RECORD_HELP
-- 
1.8.3.4
