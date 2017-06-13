From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 5/5] MIPS: Give __secure_computing() access to syscall arguments.
Date: Tue, 13 Jun 2017 15:28:47 -0700
Message-ID: <20170613222847.7122-6-david.daney@cavium.com>
References: <20170613222847.7122-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        Matt Redfearn <matt.redfearn@imgtec.com>,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613222847.7122-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KProbes of __seccomp_filter() are not very useful without access to
the syscall arguments.

Do what x86 does, and populate a struct seccomp_data to be passed to
__secure_computing().  This allows samples/bpf/tracex5 to extract a
sensible trace.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/kernel/ptrace.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/arch/mips/kernel/ptrace.c b/arch/mips/kernel/ptrace.c
index 6931fe7..ba3b1f7 100644
--- a/arch/mips/kernel/ptrace.c
+++ b/arch/mips/kernel/ptrace.c
@@ -868,8 +868,26 @@ asmlinkage long syscall_trace_enter(struct pt_regs *regs, long syscall)
 	    tracehook_report_syscall_entry(regs))
 		return -1;
 
-	if (secure_computing(NULL) == -1)
-		return -1;
+#ifdef CONFIG_SECCOMP
+	if (unlikely(test_thread_flag(TIF_SECCOMP))) {
+		int ret, i;
+		struct seccomp_data sd;
+
+		sd.nr = syscall;
+		sd.arch = syscall_get_arch();
+		for (i = 0; i < 6; i++) {
+			unsigned long v, r;
+
+			r = mips_get_syscall_arg(&v, current, regs, i);
+			sd.args[i] = r ? 0 : v;
+		}
+		sd.instruction_pointer = KSTK_EIP(current);
+
+		ret = __secure_computing(&sd);
+		if (ret == -1)
+			return ret;
+	}
+#endif
 
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_enter(regs, regs->regs[2]);
-- 
2.9.4
