From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 2/2] bpf: add support for %s specifier to bpf_trace_printk()
Date: Fri, 28 Aug 2015 12:51:49 -0700
Message-ID: <1440791509-5450-3-git-send-email-ast@plumgrid.com>
References: <1440791509-5450-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440791509-5450-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

%s specifier makes bpf program and kernel debugging easier.
To make sure that trace_printk won't crash the unsafe string
is copied into stack and unsafe pointer is substituted.

The following C program:
 #include <linux/fs.h>
int foo(struct pt_regs *ctx, struct filename *filename)
{
  void *name = 0;

  bpf_probe_read(&name, sizeof(name), &filename->name);
  bpf_trace_printk("executed %s\n", name);
  return 0;
}

when attached to kprobe do_execve()
will produce output in /sys/kernel/debug/tracing/trace_pipe :
    make-13492 [002] d..1  3250.997277: : executed /bin/sh
      sh-13493 [004] d..1  3250.998716: : executed /usr/bin/gcc
     gcc-13494 [002] d..1  3250.999822: : executed /usr/lib/gcc/x86_64-linux-gnu/4.7/cc1
     gcc-13495 [002] d..1  3251.006731: : executed /usr/bin/as
     gcc-13496 [002] d..1  3251.011831: : executed /usr/lib/gcc/x86_64-linux-gnu/4.7/collect2
collect2-13497 [000] d..1  3251.012941: : executed /usr/bin/ld

Suggested-by: Brendan Gregg <brendan.d.gregg@gmail.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

v1->v2:
use generalized strncpy_from_unsafe() and
fix the case of multiple '%s' per format string.

 kernel/trace/bpf_trace.c |   32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ef9936df1b04..0fe96c7c8803 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,13 +81,16 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 
 /*
  * limited trace_printk()
- * only %d %u %x %ld %lu %lx %lld %llu %llx %p conversion specifiers allowed
+ * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
  */
 static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
 {
 	char *fmt = (char *) (long) r1;
+	bool str_seen = false;
 	int mod[3] = {};
 	int fmt_cnt = 0;
+	u64 unsafe_addr;
+	char buf[64];
 	int i;
 
 	/*
@@ -114,12 +117,37 @@ static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
 		if (fmt[i] == 'l') {
 			mod[fmt_cnt]++;
 			i++;
-		} else if (fmt[i] == 'p') {
+		} else if (fmt[i] == 'p' || fmt[i] == 's') {
 			mod[fmt_cnt]++;
 			i++;
 			if (!isspace(fmt[i]) && !ispunct(fmt[i]) && fmt[i] != 0)
 				return -EINVAL;
 			fmt_cnt++;
+			if (fmt[i - 1] == 's') {
+				if (str_seen)
+					/* allow only one '%s' per fmt string */
+					return -EINVAL;
+				str_seen = true;
+
+				switch (fmt_cnt) {
+				case 1:
+					unsafe_addr = r3;
+					r3 = (long) buf;
+					break;
+				case 2:
+					unsafe_addr = r4;
+					r4 = (long) buf;
+					break;
+				case 3:
+					unsafe_addr = r5;
+					r5 = (long) buf;
+					break;
+				}
+				buf[0] = 0;
+				strncpy_from_unsafe(buf,
+						    (void *) (long) unsafe_addr,
+						    sizeof(buf));
+			}
 			continue;
 		}
 
-- 
1.7.9.5
