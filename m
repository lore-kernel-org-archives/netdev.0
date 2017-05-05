From: tip-bot for Josh Poimboeuf <tipbot@zytor.com>
Subject: [tip:x86/urgent] x86/asm: Don't use RBP as a temporary register in
 csum_partial_copy_generic()
Date: Fri, 5 May 2017 01:10:08 -0700
Message-ID: <tip-42fc6c6cb1662ba2fa727dd01c9473c63be4e3b6@git.kernel.org>
References: <4b03a961efda5ec9bfe46b7b9c9ad72d1efad343.1493909486.git.jpoimboe@redhat.com>
Reply-To: andreyknvl@google.com, netdev@vger.kernel.org,
          syzkaller@googlegroups.com, nhorman@tuxdriver.com,
          kcc@google.com, marcelo.leitner@gmail.com,
          torvalds@linux-foundation.org, edumazet@google.com,
          jpoimboe@redhat.com, linux-kernel@vger.kernel.org,
          dvyukov@google.com, hpa@zytor.com, tglx@linutronix.de,
          vyasevich@gmail.com, peterz@infradead.org, davem@davemloft.net,
          xiyou.wangcong@gmail.com, mingo@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, jpoimboe@redhat.com,
        nhorman@tuxdriver.com, syzkaller@googlegroups.com,
        netdev@vger.kernel.org, kcc@google.com, marcelo.leitner@gmail.com,
        edumazet@google.com, torvalds@linux-foundation.org,
        andreyknvl@google.com, mingo@kernel.org, xiyou.wangcong@gmail.com,
        peterz@infradead.org, davem@davemloft.net, dvyukov@google.com,
        tglx@linutronix.de, vyasevich@gmail.com, hpa@zytor.com
To: linux-tip-commits@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4b03a961efda5ec9bfe46b7b9c9ad72d1efad343.1493909486.git.jpoimboe@redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit-ID:  42fc6c6cb1662ba2fa727dd01c9473c63be4e3b6
Gitweb:     http://git.kernel.org/tip/42fc6c6cb1662ba2fa727dd01c9473c63be4e3b6
Author:     Josh Poimboeuf <jpoimboe@redhat.com>
AuthorDate: Thu, 4 May 2017 09:51:40 -0500
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Fri, 5 May 2017 07:59:24 +0200

x86/asm: Don't use RBP as a temporary register in csum_partial_copy_generic()

Andrey Konovalov reported the following warning while fuzzing the kernel
with syzkaller:

  WARNING: kernel stack regs at ffff8800686869f8 in a.out:4933 has bad 'bp' value c3fc855a10167ec0

The unwinder dump revealed that RBP had a bad value when an interrupt
occurred in csum_partial_copy_generic().

That function saves RBP on the stack and then overwrites it, using it as
a scratch register.  That's problematic because it breaks stack traces
if an interrupt occurs in the middle of the function.

Replace the usage of RBP with another callee-saved register (R15) so
stack traces are no longer affected.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: David S . Miller <davem@davemloft.net>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: linux-sctp@vger.kernel.org
Cc: netdev <netdev@vger.kernel.org>
Cc: syzkaller <syzkaller@googlegroups.com>
Link: http://lkml.kernel.org/r/4b03a961efda5ec9bfe46b7b9c9ad72d1efad343.1493909486.git.jpoimboe@redhat.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/lib/csum-copy_64.S | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/lib/csum-copy_64.S b/arch/x86/lib/csum-copy_64.S
index 7e48807..45a53df 100644
--- a/arch/x86/lib/csum-copy_64.S
+++ b/arch/x86/lib/csum-copy_64.S
@@ -55,7 +55,7 @@ ENTRY(csum_partial_copy_generic)
 	movq  %r12, 3*8(%rsp)
 	movq  %r14, 4*8(%rsp)
 	movq  %r13, 5*8(%rsp)
-	movq  %rbp, 6*8(%rsp)
+	movq  %r15, 6*8(%rsp)
 
 	movq  %r8, (%rsp)
 	movq  %r9, 1*8(%rsp)
@@ -74,7 +74,7 @@ ENTRY(csum_partial_copy_generic)
 	/* main loop. clear in 64 byte blocks */
 	/* r9: zero, r8: temp2, rbx: temp1, rax: sum, rcx: saved length */
 	/* r11:	temp3, rdx: temp4, r12 loopcnt */
-	/* r10:	temp5, rbp: temp6, r14 temp7, r13 temp8 */
+	/* r10:	temp5, r15: temp6, r14 temp7, r13 temp8 */
 	.p2align 4
 .Lloop:
 	source
@@ -89,7 +89,7 @@ ENTRY(csum_partial_copy_generic)
 	source
 	movq  32(%rdi), %r10
 	source
-	movq  40(%rdi), %rbp
+	movq  40(%rdi), %r15
 	source
 	movq  48(%rdi), %r14
 	source
@@ -103,7 +103,7 @@ ENTRY(csum_partial_copy_generic)
 	adcq  %r11, %rax
 	adcq  %rdx, %rax
 	adcq  %r10, %rax
-	adcq  %rbp, %rax
+	adcq  %r15, %rax
 	adcq  %r14, %rax
 	adcq  %r13, %rax
 
@@ -121,7 +121,7 @@ ENTRY(csum_partial_copy_generic)
 	dest
 	movq %r10, 32(%rsi)
 	dest
-	movq %rbp, 40(%rsi)
+	movq %r15, 40(%rsi)
 	dest
 	movq %r14, 48(%rsi)
 	dest
@@ -203,7 +203,7 @@ ENTRY(csum_partial_copy_generic)
 	movq 3*8(%rsp), %r12
 	movq 4*8(%rsp), %r14
 	movq 5*8(%rsp), %r13
-	movq 6*8(%rsp), %rbp
+	movq 6*8(%rsp), %r15
 	addq $7*8, %rsp
 	ret
 
