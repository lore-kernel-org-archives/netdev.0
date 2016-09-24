From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v3] bpf: Set register type according to is_valid_access()
Date: Sat, 24 Sep 2016 20:01:50 +0200
Message-ID: <20160924180150.23620-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kees Cook <keescook@chromium.org>,
        Sargun Dhillon <sargun@sargun.me>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This prevent future potential pointer leaks when an unprivileged eBPF
program will read a pointer value from its context. Even if
is_valid_access() returns a pointer type, the eBPF verifier replace it
with UNKNOWN_VALUE. The register value that contains a kernel address is
then allowed to leak. Moreover, this fix allows unprivileged eBPF
programs to use functions with (legitimate) pointer arguments.

Not an issue currently since reg_type is only set for PTR_TO_PACKET or
PTR_TO_PACKET_END in XDP and TC programs that can only be loaded as
privileged. For now, the only unprivileged eBPF program allowed is for
socket filtering and all the types from its context are UNKNOWN_VALUE.
However, this fix is important for future unprivileged eBPF programs
which could use pointers in their context.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index daea765d72e6..adbc7c161ba5 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -795,9 +795,8 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 		err = check_ctx_access(env, off, size, t, &reg_type);
 		if (!err && t == BPF_READ && value_regno >= 0) {
 			mark_reg_unknown_value(state->regs, value_regno);
-			if (env->allow_ptr_leaks)
-				/* note that reg.[id|off|range] == 0 */
-				state->regs[value_regno].type = reg_type;
+			/* note that reg.[id|off|range] == 0 */
+			state->regs[value_regno].type = reg_type;
 		}
 
 	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
-- 
2.9.3
