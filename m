From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 09:13:55 -0700
Message-ID: <CAMEtUux2Y1B4By1pUQNWjtKZ3XTCgPQiuXsYfGMMbHYDAhUgXA@mail.gmail.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	<53577181.1000406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:57053 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbaDWQN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 12:13:57 -0400
Received: by mail-wg0-f46.google.com with SMTP id b13so1084613wgh.29
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 09:13:55 -0700 (PDT)
In-Reply-To: <53577181.1000406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 12:53 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 04/23/2014 05:18 AM, Alexei Starovoitov wrote:
>>
>> exisiting BPF verifier allows uninitialized access to registers,
>> 'ret A' is considered to be a valid filter.
>> So initialize A and X to zero to prevent leaking kernel memory
>> In the future BPF verifier will be rejecting such filters
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> Cc: Daniel Borkmann <dborkman@redhat.com>
>
>
> I gave it some more thought, it's actually more than just 'ret A'
> from your description, user programs could be used to generate code
> like 'add X' or 'add #42' instead of a txa or load instruction [where
> A is previously uninitialized], as it was always initialized to 0
> before. We prevent to do a 'ret X', but X could be uninitialized and
> then transferred over to taint A etc. So yeah, this patch is the most
> simple way to prevent that w/o huge complexity. Therefore, it's
> better this way:
>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>

Thanks.

the uninitialized checking is indeed not as simple as rejecting 'ret A'.
verifier needs to consider data flow between registers based
on control graph. Just linear scan won't be correct.
Also for ebpf there are 10+1 registers to consider, so ebpf verifier
will take care of both (classic and extended) at once.
classic verifier can stay as-is and eventually removed.
For example after 'bpf_call' insn the registers r1-r5 are scratched,
so they cannot be read, r10 is frame pointer and is read only, etc.
will prepare ebpf verifier patch asap.
the steps will be:
- classic verifier (as-is today)
- bpf->ebpf converter (as-is today)
- ebpf verifier
after insane amount of testing we will be able to remove classic verifier,
since ebpf verifier will be doing it more thorough.
