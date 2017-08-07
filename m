From: James Hogan <james.hogan@imgtec.com>
Subject: [RFC PATCH 1/2] bpf: Fix bpf_trace_printk on 32-bit architectures
Date: Mon, 7 Aug 2017 23:25:13 +0100
Message-ID: <20170807222514.24292-2-james.hogan@imgtec.com>
References: <20170807222514.24292-1-james.hogan@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        James Hogan <james.hogan@imgtec.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807222514.24292-1-james.hogan@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf_trace_printk() uses conditional operators to attempt to pass
different types to __trace_printk() depending on the format operators.
This doesn't work as intended on 32-bit architectures where u32 & long
are passed differently to u64, since the result of C conditional
operators follows the "usual arithmetic conversions" rules, such that
the values passed to __trace_printk() will always be u64.

For example the samples/bpf/tracex5 test printed lines like below on
MIPS, where the fd and buf have come from the u64 fd argument, and the
size from the buf argument:
  dd-1176  [000] ....  1180.941542: 0x00000001: write(fd=1, buf=  (null), size=6258688)

Instead of this:
  dd-1217  [000] ....  1625.616026: 0x00000001: write(fd=1, buf=009e4000, size=512)

Work around this with an ugly hack which expands each combination of
argument types for the 3 arguments. On 64-bit kernels it is assumed that
u32, long & u64 are all passed the same way so no casting takes place
(it has apparently worked implicitly until now). On 32-bit kernels it is
assumed that long and u32 pass the same way so there are 8 combinations.

On 32-bit kernels bpf_trace_printk() increases in size but should now
work correctly. On 64-bit kernels it actually reduces in size slightly,
I presume due to removal of some of the casts (which as far as I can
tell are unnecessary for printk anyway due to the controlled nature of
the interpretation):

arch   function                              old     new   delta
x86_64 bpf_trace_printk                      532     412    -120
x86    bpf_trace_printk                      676    1120    +444
MIPS64 bpf_trace_printk                      760     612    -148
MIPS32 bpf_trace_printk                      768     996    +228

Fixes: 9c959c863f82 ("tracing: Allow BPF programs to call bpf_trace_printk()")
Signed-off-by: James Hogan <james.hogan@imgtec.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: netdev@vger.kernel.org
---
I'm open to nicer ways of fixing this.

This is tested with samples/bpf/tracex5 on MIPS32 and MIPS64. Only build
tested on x86.
---
 kernel/trace/bpf_trace.c | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 37385193a608..32dcbe1b48f2 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -204,10 +204,28 @@ BPF_CALL_5(bpf_trace_printk, char *, fmt, u32, fmt_size, u64, arg1,
 		fmt_cnt++;
 	}
 
-	return __trace_printk(1/* fake ip will not be printed */, fmt,
-			      mod[0] == 2 ? arg1 : mod[0] == 1 ? (long) arg1 : (u32) arg1,
-			      mod[1] == 2 ? arg2 : mod[1] == 1 ? (long) arg2 : (u32) arg2,
-			      mod[2] == 2 ? arg3 : mod[2] == 1 ? (long) arg3 : (u32) arg3);
+	/*
+	 * This is a horribly ugly hack to allow different combinations of
+	 * argument types to be used, particularly on 32-bit architectures where
+	 * u32 & long pass the same as one another, but differently to u64.
+	 *
+	 * On 64-bit architectures it is assumed u32, long & u64 pass in the
+	 * same way.
+	 */
+
+#define __BPFTP_P(...)	__trace_printk(1/* fake ip will not be printed */, \
+				       fmt, ##__VA_ARGS__)
+#define __BPFTP_1(...)	((mod[0] == 2 || __BITS_PER_LONG == 64)		\
+			 ? __BPFTP_P(arg1, ##__VA_ARGS__)		\
+			 : __BPFTP_P((long)arg1, ##__VA_ARGS__))
+#define __BPFTP_2(...)	((mod[1] == 2 || __BITS_PER_LONG == 64)		\
+			 ? __BPFTP_1(arg2, ##__VA_ARGS__)		\
+			 : __BPFTP_1((long)arg2, ##__VA_ARGS__))
+#define __BPFTP_3(...)	((mod[2] == 2 || __BITS_PER_LONG == 64)		\
+			 ? __BPFTP_2(arg3, ##__VA_ARGS__)		\
+			 : __BPFTP_2((long)arg3, ##__VA_ARGS__))
+
+	return __BPFTP_3();
 }
 
 static const struct bpf_func_proto bpf_trace_printk_proto = {
-- 
2.13.2
