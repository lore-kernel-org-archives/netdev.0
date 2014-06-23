From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH 14/17] MIPS: bpf: Prevent kernel fall over for >=32bit
 shifts
Date: Mon, 23 Jun 2014 12:39:38 +0100
Message-ID: <53A811FA.5060502@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com> <1403516340-22997-15-git-send-email-markos.chandras@imgtec.com> <063D6719AE5E284EB5DD2968C1650D6D1726096C@AcuExch.aculab.com> <53A80A27.5090503@imgtec.com> <063D6719AE5E284EB5DD2968C1650D6D1726139F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:19843 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbaFWLjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 07:39:46 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1726139F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2014 12:08 PM, David Laight wrote:
> From: Markos Chandras
>> On 06/23/2014 10:44 AM, David Laight wrote:
>>> From: Markos Chandras
>>>> Remove BUG_ON() if the shift immediate is >=32 to avoid
>>>> kernel crashes due to malicious user input. Since the micro-assembler
>>>> will not allow an immediate greater or equal to 32, we will use the
>>>> maximum value which is 31. This will do the correct thing on either 32-
>>>> or 64-bit cores since no 64-bit instructions are being used in JIT.
>>>
>>> I'm not sure that bounding the shift to 31 bits 'is the correct thing'.
>>> I'd have thought that emulating the large shift or masking the shift
>>> to 5 bits are equally 'correct'.
>>>
>>> ...
>> Hi David,
>>
>> Since we use 32-bit registers (or rather, we ignore the top 32bits on
>> MIPS64), shifting >= 32 will always result to 0.
>> Alexei suggested [1] to allow large shifts and emulate them, so this
>> patch aims to do that by treating >=32 shift values as 31. Please tell
>> me if I got this wrong.
> 
> Shifting by 31 converts 0xffffffff to 1, not 0.
> 
> 	David
> 
> 
> 
oops indeed. Maybe it can be fixed by something like this?


diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 545c8487542c..32233ec747e0 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -151,6 +151,8 @@ static inline int optimize_div(u32 *k)
         return 0;
 }

+static inline void emit_jit_reg_move(ptr dst, ptr src, struct jit_ctx
*ctx);
+
 /* Simply emit the instruction if the JIT memory space has been
allocated */
 #define emit_instr(ctx, func, ...)                      \
 do {                                                    \
@@ -310,8 +312,10 @@ static inline void emit_sll(unsigned int dst,
unsigned int src,
 {
         /* sa is 5-bits long */
         if (sa >= BIT(5))
-                sa = BIT(5) - 1;
-        emit_instr(ctx, sll, dst, src, sa);
+                /* Shifting >= 32 results in zero */
+                emit_jit_reg_move(dst, r_zero, ctx);
+        else
+                emit_instr(ctx, sll, dst, src, sa);
 }

 static inline void emit_srlv(unsigned int dst, unsigned int src,
@@ -325,8 +329,10 @@ static inline void emit_srl(unsigned int dst,
unsigned int src,
 {
         /* sa is 5-bits long */
         if (sa >= BIT(5))
-                sa =  BIT(5) - 1;
-        emit_instr(ctx, srl, dst, src, sa);
+                /* Shifting >= 32 results in zero */
+                emit_jit_reg_move(dst, r_zero, ctx);
+        else
+                emit_instr(ctx, srl, dst, src, sa);
 }


-- 
markos
