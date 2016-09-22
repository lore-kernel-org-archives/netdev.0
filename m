From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v2] bpf: Set register type according to is_valid_access()
Date: Thu, 22 Sep 2016 21:56:47 +0200
Message-ID: <20160922195647.27914-1-mic@digikod.net>
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

This fix a pointer leak when an unprivileged eBPF program read a pointer
value from the context. Even if is_valid_access() returns a pointer
type, the eBPF verifier replace it with UNKNOWN_VALUE. The register
value containing an address is then allowed to leak. Moreover, this
prevented unprivileged eBPF programs to use functions with (legitimate)
pointer arguments.

This bug is not an issue for now because the only unprivileged eBPF
program allowed is of type BPF_PROG_TYPE_SOCKET_FILTER and all the types
from its context are UNKNOWN_VALUE. However, this fix is important for
future unprivileged eBPF program types which could use pointers in their
context.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Fixes: 969bf05eb3ce ("bpf: direct packet access")
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Kees Cook <keescook@chromium.org>
Acked-by: Sargun Dhillon <sargun@sargun.me>
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
