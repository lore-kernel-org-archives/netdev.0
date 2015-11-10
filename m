From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH] bpf_trace: Make dependent on PERF_EVENTS
Date: Tue, 10 Nov 2015 15:28:17 -0500
Message-ID: <20151110152817.144195a0@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Peter Zijlstra <peterz@infradead.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Arnd Bergmann reported:

  In my ARM randconfig tests, I'm getting a build error for
  newly added code in bpf_perf_event_read and bpf_perf_event_output
  whenever CONFIG_PERF_EVENTS is disabled:

  kernel/trace/bpf_trace.c: In function 'bpf_perf_event_read':
  kernel/trace/bpf_trace.c:203:11: error: 'struct perf_event' has no member named 'oncpu'
  if (event->oncpu != smp_processor_id() ||
           ^
  kernel/trace/bpf_trace.c:204:11: error: 'struct perf_event' has no member named 'pmu'
        event->pmu->count)

  This can happen when UPROBE_EVENT is enabled but KPROBE_EVENT
  is disabled. I'm not sure if that is a configuration we care
  about, otherwise we could prevent this case from occuring by
  adding Kconfig dependencies.

Looking at this further, it's really that UPROBE_EVENT enables PERF_EVENTS.
By just having BPF_EVENTS depend on PERF_EVENTS, then all is fine.

Link: http://lkml.kernel.org/r/4525348.Aq9YoXkChv@wuerfel
Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 kernel/trace/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 8d6363f42169..e45db6b0d878 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -434,7 +434,7 @@ config UPROBE_EVENT
 
 config BPF_EVENTS
 	depends on BPF_SYSCALL
-	depends on KPROBE_EVENT || UPROBE_EVENT
+	depends on (KPROBE_EVENT || UPROBE_EVENT) && PERF_EVENTS
 	bool
 	default y
 	help
-- 
1.8.3.1
