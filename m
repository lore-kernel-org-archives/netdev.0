From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v7 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Sun, 9 Mar 2014 11:02:40 -0700
Message-ID: <CAMEtUuwyCD+-aWiOSRWf2+K0iaSxuDuW-Z8Em=LdskDgbtQkWA@mail.gmail.com>
References: <1394320530-3508-1-git-send-email-ast@plumgrid.com>
	<1394320530-3508-2-git-send-email-ast@plumgrid.com>
	<1394376574.20149.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.k
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:51061 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbaCISCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 14:02:42 -0400
Received: by mail-wg0-f46.google.com with SMTP id b13so1343255wgh.5
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 11:02:40 -0700 (PDT)
In-Reply-To: <1394376574.20149.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 9, 2014 at 7:49 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2014-03-08 at 15:15 -0800, Alexei Starovoitov wrote:
>
>> +                     if (BPF_SRC(fp->code) == BPF_K &&
>> +                         (int)fp->k < 0) {
>> +                             /* extended BPF immediates are signed,
>> +                              * zero extend immediate into tmp register
>> +                              * and use it in compare insn
>> +                              */
>> +                             insn->code = BPF_ALU | BPF_MOV | BPF_K;
>> +                             insn->a_reg = 2;
>> +                             insn->imm = fp->k;
>> +                             insn++;
>> +
>> +                             insn->a_reg = 6;
>> +                             insn->x_reg = 2;
>> +                             bpf_src = BPF_X;
>> +                     } else {
>> +                             insn->a_reg = 6;
>> +                             insn->x_reg = 7;
>> +                             insn->imm = fp->k;
>> +                             bpf_src = BPF_SRC(fp->code);
>> +                     }
>> +                     /* common case where 'jump_false' is next insn */
>> +                     if (fp->jf == 0) {
>> +                             insn->code = BPF_JMP | BPF_OP(fp->code) |
>> +                                     bpf_src;
>> +                             tgt = i + fp->jt + 1;
>> +                             EMIT_JMP;
>> +                             break;
>> +                     }
>> +                     /* convert JEQ into JNE when 'jump_true' is next insn */
>> +                     if (fp->jt == 0 && BPF_OP(fp->code) == BPF_JEQ) {
>> +                             insn->code = BPF_JMP | BPF_JNE | bpf_src;
>> +                             tgt = i + fp->jf + 1;
>> +                             EMIT_JMP;
>> +                             break;
>> +                     }
>> +                     /* other jumps are mapped into two insns: Jxx and JA */
>> +                     tgt = i + fp->jt + 1;
>> +                     insn->code = BPF_JMP | BPF_OP(fp->code) | bpf_src;
>> +                     EMIT_JMP;
>> +
>> +                     insn++;
>> +                     insn->code = BPF_JMP | BPF_JA;
>> +                     tgt = i + fp->jf + 1;
>> +                     EMIT_JMP;
>> +                     break;
>> +
>> +             /* ldxb 4*([14]&0xf) is remaped into 3 insns */
>> +             case BPF_LDX | BPF_MSH | BPF_B:
>> +                     insn->code = BPF_LD | BPF_ABS | BPF_B;
>> +                     insn->a_reg = 7;
>> +                     insn->imm = fp->k;
>> +
>> +                     insn++;
>> +                     insn->code = BPF_ALU | BPF_AND | BPF_K;
>> +                     insn->a_reg = 7;
>> +                     insn->imm = 0xf;
>> +
>> +                     insn++;
>> +                     insn->code = BPF_ALU | BPF_LSH | BPF_K;
>> +                     insn->a_reg = 7;
>> +                     insn->imm = 2;
>> +                     break;
>> +
>> +             /* RET_K, RET_A are remaped into 2 insns */
>> +             case BPF_RET | BPF_A:
>> +             case BPF_RET | BPF_K:
>> +                     insn->code = BPF_ALU | BPF_MOV |
>> +                             (BPF_RVAL(fp->code) == BPF_K ? BPF_K : BPF_X);
>> +                     insn->a_reg = 0;
>> +                     insn->x_reg = 6;
>> +                     insn->imm = fp->k;
>> +
>> +                     insn++;
>> +                     insn->code = BPF_RET | BPF_K;
>> +                     break;
>
>
> What the hell is this ?
>
> All this magical values, like 2, 6, 7, 10.

they are register numbers, since they are assigned into 'a_reg' and 'x_reg'
which are described in uapi/filter.h:
        __u8    a_reg:4; /* dest register */
        __u8    x_reg:4; /* source register */
and in Doc...filter.txt

In the V1 series I had a bunch of #define like:
#define R1 1
#define R2 2
which seemed as silly as doing '#define one 1'

I thought that the sk_convert_filter() code is pretty clear in terms
of what it's doing, but I'm happy to add an extensive comment to
describe the mechanics.
Also it felt that most of the time you and other folks want me to remove
comments, so I figured I'll add comments on demand.
Here looks like it's the case.

> I am afraid nobody will be able to read this but you.

that's certainly not the intent. I've presented it at the last plumbers conf
and would like to share more, since I think ebpf is a fundamental
breakthrough that can be used by many kernel subsystems.
This patch only covers old filters and seccomp.
We can do a lot more interesting things with tracing+ebpf and so on.

Regards,
Alexei
