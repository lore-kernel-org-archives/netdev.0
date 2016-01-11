From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 42/53] perf record: Prevent reading invalid data in record__mmap_read
Date: Mon, 11 Jan 2016 13:48:33 +0000
Message-ID: <1452520124-2073-43-git-send-email-wangnan0@huawei.com>
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

When record__mmap_read() require data more than the size of ring
buffer, drop those data to avoid access invalid memory.

This can happen when reading from overwritable ring buffer, which
should be avoided. However, check this for robustness.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index b65b41f..3f58426 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -37,6 +37,7 @@
 #include <unistd.h>
 #include <sched.h>
 #include <sys/mman.h>
+#include <asm/bug.h>
 
 
 struct record {
@@ -94,6 +95,13 @@ static int record__mmap_read(struct record *rec, int idx)
 	rec->samples++;
 
 	size = head - old;
+	if (size > (unsigned long)(md->mask) + 1) {
+		WARN_ONCE(1, "WARNING: failed to keep up with mmap data. (warn only once)\n");
+
+		md->prev = head;
+		perf_evlist__mmap_consume(rec->evlist, idx);
+		return 0;
+	}
 
 	if ((old & md->mask) + size != (head & md->mask)) {
 		buf = &data[old & md->mask];
-- 
1.8.3.4
