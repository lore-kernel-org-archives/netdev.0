From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 13/53] perf tools: Prevent calling machine__delete() on non-allocated machine
Date: Mon, 11 Jan 2016 13:48:04 +0000
Message-ID: <1452520124-2073-14-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To prevent futher commits calling machine__delete() on non-allocated
'struct machine' (which would cause memory corruption), this patch
enforces machine__init(), record whether a machine structure is
dynamically allocated or not, and warn if machine__delete() is called
on incorrect object.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Reviewed-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/tests/vmlinux-kallsyms.c |  4 ++--
 tools/perf/util/machine.c           | 13 ++++++++-----
 tools/perf/util/machine.h           |  3 ++-
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/tools/perf/tests/vmlinux-kallsyms.c b/tools/perf/tests/vmlinux-kallsyms.c
index f0bfc9e..441e93d 100644
--- a/tools/perf/tests/vmlinux-kallsyms.c
+++ b/tools/perf/tests/vmlinux-kallsyms.c
@@ -35,8 +35,8 @@ int test__vmlinux_matches_kallsyms(int subtest __maybe_unused)
 	 * Init the machines that will hold kernel, modules obtained from
 	 * both vmlinux + .ko files and from /proc/kallsyms split by modules.
 	 */
-	machine__init(&kallsyms, "", HOST_KERNEL_ID);
-	machine__init(&vmlinux, "", HOST_KERNEL_ID);
+	machine__init(&kallsyms, "", HOST_KERNEL_ID, false);
+	machine__init(&vmlinux, "", HOST_KERNEL_ID, false);
 
 	/*
 	 * Step 2:
diff --git a/tools/perf/util/machine.c b/tools/perf/util/machine.c
index ad79297..59a3c01 100644
--- a/tools/perf/util/machine.c
+++ b/tools/perf/util/machine.c
@@ -1,3 +1,4 @@
+#include <asm/bug.h>
 #include "callchain.h"
 #include "debug.h"
 #include "event.h"
@@ -23,7 +24,7 @@ static void dsos__init(struct dsos *dsos)
 	pthread_rwlock_init(&dsos->lock, NULL);
 }
 
-int machine__init(struct machine *machine, const char *root_dir, pid_t pid)
+int machine__init(struct machine *machine, const char *root_dir, pid_t pid, bool allocated)
 {
 	memset(machine, 0, sizeof(*machine));
 	map_groups__init(&machine->kmaps, machine);
@@ -65,6 +66,7 @@ int machine__init(struct machine *machine, const char *root_dir, pid_t pid)
 	}
 
 	machine->current_tid = NULL;
+	machine->allocated = allocated;
 
 	return 0;
 }
@@ -74,7 +76,7 @@ struct machine *machine__new_host(void)
 	struct machine *machine = malloc(sizeof(*machine));
 
 	if (machine != NULL) {
-		machine__init(machine, "", HOST_KERNEL_ID);
+		machine__init(machine, "", HOST_KERNEL_ID, true);
 
 		if (machine__create_kernel_maps(machine) < 0)
 			goto out_delete;
@@ -137,12 +139,13 @@ void machine__exit(struct machine *machine)
 void machine__delete(struct machine *machine)
 {
 	machine__exit(machine);
-	free(machine);
+	WARN_ONCE((machine->allocated ? free(machine), 0 : -1),
+		  "WARNING: deleting a non-allocated machine. Skip.\n");
 }
 
 void machines__init(struct machines *machines)
 {
-	machine__init(&machines->host, "", HOST_KERNEL_ID);
+	machine__init(&machines->host, "", HOST_KERNEL_ID, false);
 	machines->guests = RB_ROOT;
 	machines->symbol_filter = NULL;
 }
@@ -163,7 +166,7 @@ struct machine *machines__add(struct machines *machines, pid_t pid,
 	if (machine == NULL)
 		return NULL;
 
-	if (machine__init(machine, root_dir, pid) != 0) {
+	if (machine__init(machine, root_dir, pid, true) != 0) {
 		free(machine);
 		return NULL;
 	}
diff --git a/tools/perf/util/machine.h b/tools/perf/util/machine.h
index 2c2b443..24dfd46 100644
--- a/tools/perf/util/machine.h
+++ b/tools/perf/util/machine.h
@@ -28,6 +28,7 @@ struct machine {
 	pid_t		  pid;
 	u16		  id_hdr_size;
 	bool		  comm_exec;
+	bool		  allocated;
 	char		  *root_dir;
 	struct rb_root	  threads;
 	pthread_rwlock_t  threads_lock;
@@ -131,7 +132,7 @@ void machines__set_symbol_filter(struct machines *machines,
 void machines__set_comm_exec(struct machines *machines, bool comm_exec);
 
 struct machine *machine__new_host(void);
-int machine__init(struct machine *machine, const char *root_dir, pid_t pid);
+int machine__init(struct machine *machine, const char *root_dir, pid_t pid, bool allocated);
 void machine__exit(struct machine *machine);
 void machine__delete_threads(struct machine *machine);
 void machine__delete(struct machine *machine);
-- 
1.8.3.4
