From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Tue, 3 Jun 2014 14:40:39 -0700
Message-ID: <CA+ZOOTOfq705CbUjx9ppw4gLxJ8JFCaFsphwhAS+NskHVjd86Q@mail.gmail.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
	<538C3C94.3080206@redhat.com>
	<CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com>
	<538CAEA6.4060307@redhat.com>
	<CAMEtUuwxJOgYgFjg9deQZOffeg6-JUGZXZ1Rj344eQmriQ0F0Q@mail.gmail.com>
	<538D8DAA.7090105@redhat.com>
	<CAMEtUuw8uyCGeLeUB0PXm5cCpqcsjPLZt6y9FcKjapbVPjWTuw@mail.gmail.com>
	<538E319B.3000606@redhat.com>
	<CAMEtUuzsHJioXZtuGje6UmwZmcmDZEn8PdkkYanA9j1sp242+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:46402 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965087AbaFCVkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 17:40:39 -0400
Received: by mail-ie0-f182.google.com with SMTP id x19so6557519ier.13
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 14:40:39 -0700 (PDT)
In-Reply-To: <CAMEtUuzsHJioXZtuGje6UmwZmcmDZEn8PdkkYanA9j1sp242+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all, and just to join the crowd, kernel/bpf/ FTW.

Now, I have some suggestions about eBPF. IMO classic BPF is an ISA
oriented to filter (meaning returning a single integer that states how
many bytes of the packet must be captured) packets (e.g. consider the
6 load modes, where 3 provide access the packet -- abs, ind, msh --,
one to an skb field -- len--, the 5th one to the memory itself -- mem
--, and the 6th is an immediate set mode --imm-- ) that has been used
in other environments (seccomp, tracing, etc.) by (a) extending the
idea of a "packet" into a "buffer", and (b) adding ancillary loads.

eBPF should be a generic ISA that can be used by many environments,
including those served today by classic BPF. IMO, we should get a
nicely-defined ISA (MIPS anyone?) and check what should go into eBPF
and what should not.

- 1. we should considering separating the eBPF ISA farther from classic BPF
  - eBPF still uses a_reg and x_reg as the names of the 2 op
registers. This is very confusing, especially when dealing with
translated filters that do move data between A and X. I've had a_reg
being X, and x_reg being A. We should rename them d_reg and s_reg.
  - BPF_LD vs. BPF_LDX: this made sense in classic BPF, as there was
only one register, and d_reg was implicit in the name of the insn
code. Now, why are we keeping both in eBPF, when the register we're
writing to is made explicit in d_reg (I already forgot if d_reg was
a_reg or x_reg ;) ? Removing one of them will save us 1/8th of the
insns.
  - BPF_ST vs. BPF_STX: same here. Note that the current
sk_convert_filter() just converts all stores to BPF_STX.

- 2. there are other insn that we should consider adding:
  - lui: AFAICT, there is no clean way to build a 64-bit number (you
can LD_IMM the upper part, lsh 32, and then add the lower part).
  - nop: I'd like to have a nop. Do I know why? Nope.


On Tue, Jun 3, 2014 at 1:58 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Tue, Jun 3, 2014 at 1:35 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 06/03/2014 05:44 PM, Alexei Starovoitov wrote:
>> ...
>>>
>>> All of your points are valid. They are right questions to ask. I just
>>>
>>> don't see why you're still arguing about first step of filter.c split,
>>> whereas your concerns are about steps 2, 3, 4.
>>
>>
>> Fair enough, lets keep them in mind though for future work. Btw,
>
> Ok :)
>
>> are other files planned for kernel/bpf/ or should it instead just
>> simply be kernel/bpf.c?
>
> The most obvious one is eBPF verifier in separate file (kernel/bpf/verifier.c)
> bpf maps is yet another thing, but that's different topic.
> Probably a set of bpf-callable functions in another file. Like right now
> for sockets these helpers are __skb_get_pay_offset(), __skb_get_nlattr()
> For tracing there will be a different set of helper functions and eventually
> some will be common. Like __get_raw_cpu_id() from filter.c could
> eventually move to kernel/bpf/helpers.c
LGTM.

I like the idea of every user (packet filter, seccomp, etc.) providing
a map of the bpf calls that are ok, as in the packet filter stating
that {1->__skb_get_pay_offset(), 2->__skb_get_nlattr(), ...}, but
seccomp providing a completely different (or even empty) map.

-Chema


> I'm not a fan of squeezing different logic into one file.
