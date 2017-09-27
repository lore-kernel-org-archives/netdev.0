From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: WARNING: kernel stack frame pointer at ffff880156a5fea0 in
 bash:2103 has bad value 00007ffec7d87e50
Date: Wed, 27 Sep 2017 09:14:30 -0500
Message-ID: <20170927141430.i6awpjkyoqffof4b@treble>
References: <2656822.vqnppgTvlm@blindfold>
 <1598510.AHGpDp18sh@blindfold>
 <20170926224246.mj6cxkkelc4sanda@treble>
 <41856500.WAzQIuoSLi@blindfold>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, ast@kernel.org,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@kernel.org
To: Richard Weinberger <richard@sigma-star.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <41856500.WAzQIuoSLi@blindfold>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 08:51:22AM +0200, Richard Weinberger wrote:
> Am Mittwoch, 27. September 2017, 00:42:46 CEST schrieb Josh Poimboeuf:
> > > Here is another variant of the warning, it matches the attached .config:
> > I can take a look at it.  Unfortunately, for these types of issues I
> > often need the vmlinux file to be able to make sense of the unwinder
> > dump.  So if you happen to have somewhere to copy the vmlinux to, that
> > would be helpful.  Or if you give me your GCC version I can try to
> > rebuild it locally.
> 
> There you go:
> http://git.infradead.org/~rw/bpf_splat/vmlinux.xz

Thanks.  Can you test this fix?


diff --git a/arch/x86/kernel/kprobes/common.h b/arch/x86/kernel/kprobes/common.h
index db2182d63ed0..3fc0f9a794cb 100644
--- a/arch/x86/kernel/kprobes/common.h
+++ b/arch/x86/kernel/kprobes/common.h
@@ -3,6 +3,15 @@
 
 /* Kprobes and Optprobes common header */
 
+#include <asm/asm.h>
+
+#ifdef CONFIG_FRAME_POINTER
+# define SAVE_RBP_STRING "	push %" _ASM_BP "\n" \
+			 "	mov  %" _ASM_SP ", %" _ASM_BP "\n"
+#else
+# define SAVE_RBP_STRING "	push %" _ASM_BP "\n"
+#endif
+
 #ifdef CONFIG_X86_64
 #define SAVE_REGS_STRING			\
 	/* Skip cs, ip, orig_ax. */		\
@@ -17,7 +26,7 @@
 	"	pushq %r10\n"			\
 	"	pushq %r11\n"			\
 	"	pushq %rbx\n"			\
-	"	pushq %rbp\n"			\
+	SAVE_RBP_STRING				\
 	"	pushq %r12\n"			\
 	"	pushq %r13\n"			\
 	"	pushq %r14\n"			\
@@ -48,7 +57,7 @@
 	"	pushl %es\n"			\
 	"	pushl %ds\n"			\
 	"	pushl %eax\n"			\
-	"	pushl %ebp\n"			\
+	SAVE_RBP_STRING				\
 	"	pushl %edi\n"			\
 	"	pushl %esi\n"			\
 	"	pushl %edx\n"			\
