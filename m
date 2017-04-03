From: Alban Crequy <alban.crequy@gmail.com>
Subject: [PATCH v3] tracing/kprobes: expose maxactive for kretprobe in kprobe_events
Date: Mon,  3 Apr 2017 12:36:22 +0200
Message-ID: <1491215782-15490-1-git-send-email-alban@kinvolk.io>
Cc: Masami Hiramatsu <mhiramat@kernel.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>,
        Anton Blanchard <anton@samba.org>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kselftest@vger.kernel.org, iago@kinvolk.io,
        michael@kinvolk.io, lukasz.dorau@intel.com,
        vitalii.chernookyi@intel.com, marcin.slusarz@intel.com,
        sarah.jelinek@intel.com, gabor.buella@intel.com
To: Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>, Shuah Khan <shuah@kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban@kinvolk.io>

When a kretprobe is installed on a kernel function, there is a maximum
limit of how many calls in parallel it can catch (aka "maxactive"). A
kernel module could call register_kretprobe() and initialize maxactive
(see example in samples/kprobes/kretprobe_example.c).

But that is not exposed to userspace and it is currently not possible to
choose maxactive when writing to /sys/kernel/debug/tracing/kprobe_events

The default maxactive can be as low as 1 on single-core with a
non-preemptive kernel. This is too low and we need to increase it not
only for recursive functions, but for functions that sleep or resched.

This patch updates the format of the command that can be written to
kprobe_events so that maxactive can be optionally specified.

I need this for a bpf program attached to the kretprobe of
inet_csk_accept, which can sleep for a long time.

This patch includes a basic selftest:

> # ./ftracetest -v  test.d/kprobe/
> === Ftrace unit tests ===
> [1] Kprobe dynamic event - adding and removing	[PASS]
> [2] Kprobe dynamic event - busy event check	[PASS]
> [3] Kprobe dynamic event with arguments	[PASS]
> [4] Kprobes event arguments with types	[PASS]
> [5] Kprobe dynamic event with function tracer	[PASS]
> [6] Kretprobe dynamic event with arguments	[PASS]
> [7] Kretprobe dynamic event with maxactive	[PASS]
>
> # of passed:  7
> # of failed:  0
> # of unresolved:  0
> # of untested:  0
> # of unsupported:  0
> # of xfailed:  0
> # of undefined(test bug):  0

BugLink: https://github.com/iovisor/bcc/issues/1072
Signed-off-by: Alban Crequy <alban@kinvolk.io>

---

Changes since v2:
- Explain the default maxactive value in the documentation.
  (Review from Steven Rostedt)

Changes since v1:
- Remove "(*)" from documentation. (Review from Masami Hiramatsu)
- Fix support for "r100" without the event name (Review from Masami Hiramatsu)
- Get rid of magic numbers within the code.  (Review from Steven Rostedt)
  Note that I didn't use KRETPROBE_MAXACTIVE_ALLOC since that patch is not
  merged.
- Return -E2BIG when maxactive is too big.
- Add basic selftest
---
 Documentation/trace/kprobetrace.txt                |  5 ++-
 kernel/trace/trace_kprobe.c                        | 39 ++++++++++++++++++----
 .../ftrace/test.d/kprobe/kretprobe_maxactive.tc    | 39 ++++++++++++++++++++++
 3 files changed, 76 insertions(+), 7 deletions(-)
 create mode 100644 tools/testing/selftests/ftrace/test.d/kprobe/kretprobe_maxactive.tc

diff --git a/Documentation/trace/kprobetrace.txt b/Documentation/trace/kprobetrace.txt
index 41ef9d8..25f3960 100644
--- a/Documentation/trace/kprobetrace.txt
+++ b/Documentation/trace/kprobetrace.txt
@@ -23,7 +23,7 @@ current_tracer. Instead of that, add probe points via
 Synopsis of kprobe_events
 -------------------------
   p[:[GRP/]EVENT] [MOD:]SYM[+offs]|MEMADDR [FETCHARGS]	: Set a probe
-  r[:[GRP/]EVENT] [MOD:]SYM[+0] [FETCHARGS]		: Set a return probe
+  r[MAXACTIVE][:[GRP/]EVENT] [MOD:]SYM[+0] [FETCHARGS]	: Set a return probe
   -:[GRP/]EVENT						: Clear a probe
 
  GRP		: Group name. If omitted, use "kprobes" for it.
@@ -32,6 +32,9 @@ Synopsis of kprobe_events
  MOD		: Module name which has given SYM.
  SYM[+offs]	: Symbol+offset where the probe is inserted.
  MEMADDR	: Address where the probe is inserted.
+ MAXACTIVE	: Maximum number of instances of the specified function that
+		  can be probed simultaneously, or 0 for the default value
+		  as defined in Documentation/kprobes.txt section 1.3.1.
 
  FETCHARGS	: Arguments. Each probe can have up to 128 args.
   %REG		: Fetch register REG
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index c5089c7..ae81f3c 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -25,6 +25,7 @@
 #include "trace_probe.h"
 
 #define KPROBE_EVENT_SYSTEM "kprobes"
+#define KRETPROBE_MAXACTIVE_MAX 4096
 
 /**
  * Kprobe event core functions
@@ -282,6 +283,7 @@ static struct trace_kprobe *alloc_trace_kprobe(const char *group,
 					     void *addr,
 					     const char *symbol,
 					     unsigned long offs,
+					     int maxactive,
 					     int nargs, bool is_return)
 {
 	struct trace_kprobe *tk;
@@ -309,6 +311,8 @@ static struct trace_kprobe *alloc_trace_kprobe(const char *group,
 	else
 		tk->rp.kp.pre_handler = kprobe_dispatcher;
 
+	tk->rp.maxactive = maxactive;
+
 	if (!event || !is_good_name(event)) {
 		ret = -EINVAL;
 		goto error;
@@ -598,8 +602,10 @@ static int create_trace_kprobe(int argc, char **argv)
 {
 	/*
 	 * Argument syntax:
-	 *  - Add kprobe: p[:[GRP/]EVENT] [MOD:]KSYM[+OFFS]|KADDR [FETCHARGS]
-	 *  - Add kretprobe: r[:[GRP/]EVENT] [MOD:]KSYM[+0] [FETCHARGS]
+	 *  - Add kprobe:
+	 *      p[:[GRP/]EVENT] [MOD:]KSYM[+OFFS]|KADDR [FETCHARGS]
+	 *  - Add kretprobe:
+	 *      r[MAXACTIVE][:[GRP/]EVENT] [MOD:]KSYM[+0] [FETCHARGS]
 	 * Fetch args:
 	 *  $retval	: fetch return value
 	 *  $stack	: fetch stack address
@@ -619,6 +625,7 @@ static int create_trace_kprobe(int argc, char **argv)
 	int i, ret = 0;
 	bool is_return = false, is_delete = false;
 	char *symbol = NULL, *event = NULL, *group = NULL;
+	int maxactive = 0;
 	char *arg;
 	unsigned long offset = 0;
 	void *addr = NULL;
@@ -637,8 +644,28 @@ static int create_trace_kprobe(int argc, char **argv)
 		return -EINVAL;
 	}
 
-	if (argv[0][1] == ':') {
-		event = &argv[0][2];
+	event = strchr(&argv[0][1], ':');
+	if (event) {
+		event[0] = '\0';
+		event++;
+	}
+	if (is_return && isdigit(argv[0][1])) {
+		ret = kstrtouint(&argv[0][1], 0, &maxactive);
+		if (ret) {
+			pr_info("Failed to parse maxactive.\n");
+			return ret;
+		}
+		/* kretprobes instances are iterated over via a list. The
+		 * maximum should stay reasonable.
+		 */
+		if (maxactive > KRETPROBE_MAXACTIVE_MAX) {
+			pr_info("Maxactive is too big (%d > %d).\n",
+				maxactive, KRETPROBE_MAXACTIVE_MAX);
+			return -E2BIG;
+		}
+	}
+
+	if (event) {
 		if (strchr(event, '/')) {
 			group = event;
 			event = strchr(group, '/') + 1;
@@ -718,8 +745,8 @@ static int create_trace_kprobe(int argc, char **argv)
 				 is_return ? 'r' : 'p', addr);
 		event = buf;
 	}
-	tk = alloc_trace_kprobe(group, event, addr, symbol, offset, argc,
-			       is_return);
+	tk = alloc_trace_kprobe(group, event, addr, symbol, offset, maxactive,
+			       argc, is_return);
 	if (IS_ERR(tk)) {
 		pr_info("Failed to allocate trace_probe.(%d)\n",
 			(int)PTR_ERR(tk));
diff --git a/tools/testing/selftests/ftrace/test.d/kprobe/kretprobe_maxactive.tc b/tools/testing/selftests/ftrace/test.d/kprobe/kretprobe_maxactive.tc
new file mode 100644
index 0000000..57abdf1
--- /dev/null
+++ b/tools/testing/selftests/ftrace/test.d/kprobe/kretprobe_maxactive.tc
@@ -0,0 +1,39 @@
+#!/bin/sh
+# description: Kretprobe dynamic event with maxactive
+
+[ -f kprobe_events ] || exit_unsupported # this is configurable
+
+echo > kprobe_events
+
+# Test if we successfully reject unknown messages
+if echo 'a:myprobeaccept inet_csk_accept' > kprobe_events; then false; else true; fi
+
+# Test if we successfully reject too big maxactive
+if echo 'r1000000:myprobeaccept inet_csk_accept' > kprobe_events; then false; else true; fi
+
+# Test if we successfully reject unparsable numbers for maxactive
+if echo 'r10fuzz:myprobeaccept inet_csk_accept' > kprobe_events; then false; else true; fi
+
+# Test for kretprobe with event name without maxactive
+echo 'r:myprobeaccept inet_csk_accept' > kprobe_events
+grep myprobeaccept kprobe_events
+test -d events/kprobes/myprobeaccept
+echo '-:myprobeaccept' >> kprobe_events
+
+# Test for kretprobe with event name with a small maxactive
+echo 'r10:myprobeaccept inet_csk_accept' > kprobe_events
+grep myprobeaccept kprobe_events
+test -d events/kprobes/myprobeaccept
+echo '-:myprobeaccept' >> kprobe_events
+
+# Test for kretprobe without event name without maxactive
+echo 'r inet_csk_accept' > kprobe_events
+grep inet_csk_accept kprobe_events
+echo > kprobe_events
+
+# Test for kretprobe without event name with a small maxactive
+echo 'r10 inet_csk_accept' > kprobe_events
+grep inet_csk_accept kprobe_events
+echo > kprobe_events
+
+clear_trace
-- 
2.7.4

