From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: x86: warning: kernel stack regs has bad 'bp' value
Date: Wed, 3 May 2017 08:30:06 -0500
Message-ID: <20170503133006.7jv4qhnnbsv7ueam@treble>
References: <CAAeHK+zapAtjKaTMG7RSxn2P1K=+BK32sfroPToppXHMLD-wpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39534 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752122AbdECNaO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 09:30:14 -0400
Content-Disposition: inline
In-Reply-To: <CAAeHK+zapAtjKaTMG7RSxn2P1K=+BK32sfroPToppXHMLD-wpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 02:48:28PM +0200, Andrey Konovalov wrote:
> Hi,
> 
> I've got the following error report while fuzzing the kernel with syzkaller.
> 
> On commit 89c9fea3c8034cdb2fd745f551cde0b507fd6893 (4.11.0+).
> 
> A reproducer and .config are attached.
> 
> The reproducer open SCTP sockets and sends data to it in a loop.
> I'm not sure whether this is an issue with SCTP or with something else.
> 
> WARNING: kernel stack regs at ffff8800686869f8 in a.out:4933 has bad
> 'bp' value c3fc855a10167ec0

Hi Andrey,

Can you test this patch?


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
 
