From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 16/53] perf tools: Fix mmap2 event allocation in synthesize code
Date: Mon, 11 Jan 2016 13:48:07 +0000
Message-ID: <1452520124-2073-17-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	He Kuang <hekuang@huawei.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

perf_event__synthesize_mmap_events() issues mmap2 events, but the
memory of that event is allocated using:

 mmap_event = malloc(sizeof(mmap_event->mmap) + machine->id_hdr_size);

If path of mmap source file is long (near PATH_MAX), random crash
would happen. Should use sizeof(mmap_event->mmap2).

Fix two memory allocations and rename all mmap_event to mmap2_event
to make it clear.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Acked-by: Jiri Olsa <jolsa@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: He Kuang <hekuang@huawei.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/event.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/tools/perf/util/event.c b/tools/perf/util/event.c
index cd61bb1..cde8228 100644
--- a/tools/perf/util/event.c
+++ b/tools/perf/util/event.c
@@ -413,7 +413,7 @@ int perf_event__synthesize_modules(struct perf_tool *tool,
 }
 
 static int __event__synthesize_thread(union perf_event *comm_event,
-				      union perf_event *mmap_event,
+				      union perf_event *mmap2_event,
 				      union perf_event *fork_event,
 				      pid_t pid, int full,
 					  perf_event__handler_t process,
@@ -436,7 +436,7 @@ static int __event__synthesize_thread(union perf_event *comm_event,
 		if (tgid == -1)
 			return -1;
 
-		return perf_event__synthesize_mmap_events(tool, mmap_event, pid, tgid,
+		return perf_event__synthesize_mmap_events(tool, mmap2_event, pid, tgid,
 							  process, machine, mmap_data,
 							  proc_map_timeout);
 	}
@@ -478,7 +478,7 @@ static int __event__synthesize_thread(union perf_event *comm_event,
 		rc = 0;
 		if (_pid == pid) {
 			/* process the parent's maps too */
-			rc = perf_event__synthesize_mmap_events(tool, mmap_event, pid, tgid,
+			rc = perf_event__synthesize_mmap_events(tool, mmap2_event, pid, tgid,
 						process, machine, mmap_data, proc_map_timeout);
 			if (rc)
 				break;
@@ -496,15 +496,15 @@ int perf_event__synthesize_thread_map(struct perf_tool *tool,
 				      bool mmap_data,
 				      unsigned int proc_map_timeout)
 {
-	union perf_event *comm_event, *mmap_event, *fork_event;
+	union perf_event *comm_event, *mmap2_event, *fork_event;
 	int err = -1, thread, j;
 
 	comm_event = malloc(sizeof(comm_event->comm) + machine->id_hdr_size);
 	if (comm_event == NULL)
 		goto out;
 
-	mmap_event = malloc(sizeof(mmap_event->mmap) + machine->id_hdr_size);
-	if (mmap_event == NULL)
+	mmap2_event = malloc(sizeof(mmap2_event->mmap2) + machine->id_hdr_size);
+	if (mmap2_event == NULL)
 		goto out_free_comm;
 
 	fork_event = malloc(sizeof(fork_event->fork) + machine->id_hdr_size);
@@ -513,7 +513,7 @@ int perf_event__synthesize_thread_map(struct perf_tool *tool,
 
 	err = 0;
 	for (thread = 0; thread < threads->nr; ++thread) {
-		if (__event__synthesize_thread(comm_event, mmap_event,
+		if (__event__synthesize_thread(comm_event, mmap2_event,
 					       fork_event,
 					       thread_map__pid(threads, thread), 0,
 					       process, tool, machine,
@@ -539,7 +539,7 @@ int perf_event__synthesize_thread_map(struct perf_tool *tool,
 
 			/* if not, generate events for it */
 			if (need_leader &&
-			    __event__synthesize_thread(comm_event, mmap_event,
+			    __event__synthesize_thread(comm_event, mmap2_event,
 						       fork_event,
 						       comm_event->comm.pid, 0,
 						       process, tool, machine,
@@ -551,7 +551,7 @@ int perf_event__synthesize_thread_map(struct perf_tool *tool,
 	}
 	free(fork_event);
 out_free_mmap:
-	free(mmap_event);
+	free(mmap2_event);
 out_free_comm:
 	free(comm_event);
 out:
@@ -567,7 +567,7 @@ int perf_event__synthesize_threads(struct perf_tool *tool,
 	DIR *proc;
 	char proc_path[PATH_MAX];
 	struct dirent dirent, *next;
-	union perf_event *comm_event, *mmap_event, *fork_event;
+	union perf_event *comm_event, *mmap2_event, *fork_event;
 	int err = -1;
 
 	if (machine__is_default_guest(machine))
@@ -577,8 +577,8 @@ int perf_event__synthesize_threads(struct perf_tool *tool,
 	if (comm_event == NULL)
 		goto out;
 
-	mmap_event = malloc(sizeof(mmap_event->mmap) + machine->id_hdr_size);
-	if (mmap_event == NULL)
+	mmap2_event = malloc(sizeof(mmap2_event->mmap2) + machine->id_hdr_size);
+	if (mmap2_event == NULL)
 		goto out_free_comm;
 
 	fork_event = malloc(sizeof(fork_event->fork) + machine->id_hdr_size);
@@ -601,7 +601,7 @@ int perf_event__synthesize_threads(struct perf_tool *tool,
  		 * We may race with exiting thread, so don't stop just because
  		 * one thread couldn't be synthesized.
  		 */
-		__event__synthesize_thread(comm_event, mmap_event, fork_event, pid,
+		__event__synthesize_thread(comm_event, mmap2_event, fork_event, pid,
 					   1, process, tool, machine, mmap_data,
 					   proc_map_timeout);
 	}
@@ -611,7 +611,7 @@ int perf_event__synthesize_threads(struct perf_tool *tool,
 out_free_fork:
 	free(fork_event);
 out_free_mmap:
-	free(mmap_event);
+	free(mmap2_event);
 out_free_comm:
 	free(comm_event);
 out:
-- 
1.8.3.4
