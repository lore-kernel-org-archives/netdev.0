From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 20:22:03 -0700
Message-ID: <CAMEtUuy-GoRouDJMHRLEpiAxG2mXnPiwiZY6j9eGTnuRvzmh-A@mail.gmail.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	<20140422.235745.1219194947074686642.davem@davemloft.net>
	<CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
	<20140423.125043.100674358164503915.davem@davemloft.net>
	<CAMEtUuwaEb5OgZHCYL-pJRrvLRWBqA1sXhg3diO3=K7ephyBpA@mail.gmail.com>
	<1398289142.29914.23.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuy-n4=YxejsCF0gg2VX1csfW5p8SfwggH2Tzi6XvE_htw@mail.gmail.com>
	<1398308109.29914.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:36842 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbaDXDWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 23:22:05 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so1648182wgh.3
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 20:22:03 -0700 (PDT)
In-Reply-To: <1398308109.29914.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 7:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-04-23 at 15:19 -0700, Alexei Starovoitov wrote:
>
>> yes, x86 jit is smart to deal around this problem in an efficient way.
>> sparc/arm jits copy pasted the idea correctly.
>
> Well... not really smart, but sufficient enough (even if I am sure we
> probably have some bugs)
>
>> but s390 jit seems to have a bug, since it's not clearing A
>> when 1st insn is BPF_S_LDX_B_MSH
>
> Sure, JIT is hard and quite risky (You forgot to CC Heiko & Martin, they
> probably can send the needed patch)
>
> Its not yet enabled by default for this reason.
>
> I am worried that all recent bpf changes raised the bar so high that
> nobody but you can really understand what is going on, unless spending
> a _lot_ of time on it.

I'm trying to explain it as much as I can. If you're willing to listen,
I'm happy to answer any questions.

> net/core/filter.c was about 880 lines in previous release, its now 1800+
> lines.

but the whole sk_encode/decode functions are obsolete.
Now we can remove some code too.

> netdev became a list discussing compiler technology,
> assembly code and ABI level stuff lately.
>
> Say I want to check why we have this code, potentially modifying
> arbitrary kernel memory :
>
>         BPF_STX_BPF_XADD_BPF_W: /* lock xadd *(u32 *)(A + insn->off) += X */
>                 atomic_add((u32) X, (atomic_t *)(unsigned long)
>                            (A + insn->off));
>                 CONT;
>         BPF_STX_BPF_XADD_BPF_DW: /* lock xadd *(u64 *)(A + insn->off) += X */
>                 atomic64_add((u64) X, (atomic64_t *)(unsigned long)
>                              (A + insn->off));
>                 CONT;
>
>
>
> No comments on this scary code, and I couldn't find why it is there.

I'm sorry but this very list forced me to drop all the comments and docs
around ebpf verifier that go into details how this is verified and why
it is safe.
I can repost the whole thing as one big series of patches
or send the links to previous patches where approach to safety is explained.
I thought the preference was to phase it in gradually.
Smallest patch at a time. Don't break anything. That's what I'm trying to do.

> $ git grep -n2 BPF_XADD
> include/linux/filter.h-19-/* ld/ldx fields */
> include/linux/filter.h-20-#define BPF_DW                0x18    /* double word */
> include/linux/filter.h:21:#define BPF_XADD      0xc0    /* exclusive add */
> include/linux/filter.h-22-
> include/linux/filter.h-23-/* alu/jmp fields */
> --
> net/core/filter.c-222-          DL(BPF_STX, BPF_MEM, BPF_W),
> net/core/filter.c-223-          DL(BPF_STX, BPF_MEM, BPF_DW),
> net/core/filter.c:224:          DL(BPF_STX, BPF_XADD, BPF_W),
> net/core/filter.c:225:          DL(BPF_STX, BPF_XADD, BPF_DW),
> net/core/filter.c-226-          DL(BPF_ST, BPF_MEM, BPF_B),
> net/core/filter.c-227-          DL(BPF_ST, BPF_MEM, BPF_H),
> --
> net/core/filter.c-479-  LDST(BPF_DW, u64)
> net/core/filter.c-480-#undef LDST
> net/core/filter.c:481:  BPF_STX_BPF_XADD_BPF_W: /* lock xadd *(u32 *)(A + insn->off) += X */
> net/core/filter.c-482-          atomic_add((u32) X, (atomic_t *)(unsigned long)
> net/core/filter.c-483-                     (A + insn->off));
> net/core/filter.c-484-          CONT;
> net/core/filter.c:485:  BPF_STX_BPF_XADD_BPF_DW: /* lock xadd *(u64 *)(A + insn->off) += X */
> net/core/filter.c-486-          atomic64_add((u64) X, (atomic64_t *)(unsigned long)
> net/core/filter.c-487-                       (A + insn->off));
>
> This looks like premature inclusion, at very minimum.
>
> Sure, I probably can find answer reading past months netdev/lkml traffic ?

yes. it's more than one month. It was posted first back in September.
ebpf architecture didn't change since then.
Just new use cases were found.
I thought to apply ebpf to ovs initially, but now it looks like tracing filters
will benefit it more, so they took a priority. seccomp, nids, etc

> Sorry if this looks like ranting, but I would rather complain before thousand
> of other lines of code are merged.

It's a valid concern. I need to share and explain more. Point taken.
