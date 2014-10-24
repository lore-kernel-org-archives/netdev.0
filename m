From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] bpf: split eBPF out of NET
Date: Thu, 23 Oct 2014 22:32:50 -0700
Message-ID: <CAMEtUuxsk=iLDsD4XXZ8EcurFXgFxD-9iePv=NbBZn+b3YOXJA@mail.gmail.com>
References: <1414114868-28228-1-git-send-email-ast@plumgrid.com>
	<20141024032355.GB7879@thin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:52319 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbaJXFcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 01:32:51 -0400
Received: by mail-wi0-f169.google.com with SMTP id q5so331568wiv.0
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 22:32:50 -0700 (PDT)
In-Reply-To: <20141024032355.GB7879@thin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 8:23 PM, Josh Triplett <josh@joshtriplett.org> wrote:
> On Thu, Oct 23, 2014 at 06:41:08PM -0700, Alexei Starovoitov wrote:
>> introduce two configs:
>> - hidden CONFIG_BPF to select eBPF interpreter that classic socket filters
>>   depend on
>> - visible CONFIG_BPF_SYSCALL (default off) that tracing and sockets can use
>>
>> that solves several problems:
>> - tracing and others that wish to use eBPF don't need to depend on NET.
>>   They can use BPF_SYSCALL to allow loading from userspace or select BPF
>>   to use it directly from kernel in NET-less configs.
>> - in 3.18 programs cannot be attached to events yet, so don't force it on
>> - when the rest of eBPF infra is there in 3.19+, it's still useful to
>>   switch it off to minimize kernel size
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Thanks for working on this!  A few nits below, but otherwise this looks
> good to me.  Once this gets appropriate reviews from net and bpf folks,
> please let me know if you want this to go through the net tree, the tiny
> tree, or some other tree.

Thanks :)
I've sent it to Dave and marked it as 'net', so it's for
his net tree. I don't mind if he decides to steer it into net-next
when it opens, since changing Kconfig is always tricky.
I just felt that this patch deserves to be in 'net' and in 3.18-rc

>> bloat-o-meter on x64 shows:
>> add/remove: 0/60 grow/shrink: 0/2 up/down: 0/-15601 (-15601)
>
> Very nice!  Please do include the bloat-o-meter stats in the commit
> message.

I don't think that's necessary. eBPF is in early stages of adoption.
More things to come, so bloat-o-meter stats will be obsolete
very quickly.

>> +# interpreter that classic socket filters depend on
>> +config BPF
>> +     boolean
>
> s/boolean/bool/

Is there a difference? I thought it's an alias.

>> +config BPF_SYSCALL
>> +     bool "Enable bpf() system call" if EXPERT
>> +     select ANON_INODES
>> +     select BPF
>> +     default n
>> +     help
>> +       Enable the bpf() system call that allows to manipulate eBPF
>> +       programs and maps via file descriptors.
>
> Not sure this one goes under EXPERT, especially since it currently has
> "default n".

I followed the same style as EPOLL, EVENTFD and others
in the same category.

>> +/* To execute LD_ABS/LD_IND instructions __bpf_prog_run() may call
>> + * skb_copy_bits(), so provide a weak definition of it for NET-less config.
>> + */
>> +int __weak skb_copy_bits(const struct sk_buff *skb, int offset, void *to,
>> +                      int len)
>> +{
>> +     return -EFAULT;
>> +}
>
> Please discuss this in the commit message.  What are the implications of
> ending up with this implementation that always returns -EFAULT?

because that's what real skb_copy_bits() would return.
In this case it's actually irrelevant, since non-socket programs
are not allowed to have LD_ABS/LD_IND instructions and
I'm only resolving linker error here.
But returning negative error helps prevent bugs in cases
where verifier or some in-kernel generated program uses
LD_ABS by mistake.
I don't think these type of explanations are necessary in
commit logs.

>> @@ -6,7 +6,7 @@ menuconfig NET
>>       bool "Networking support"
>>       select NLATTR
>>       select GENERIC_NET_UTILS
>> -     select ANON_INODES
>> +     select BPF
>
> Why does this not need to select ANON_INODES anymore?  Did *only* BPF
> use that, so it only needs to occur via BPF_SYSCALL?  If so, can you
> document that in the commit message?

I hope that folks who were following this work on netdev
remember commit 38b3629adb8c04 that added it.
So here I'm actually removing this ANON_INODES dependency
from NET and moving it into BPF_SYSCALL where it belongs.

btw, the goal of this patch is not tinification, but rather being
good citizen and not forcing new syscall on everyone.
It was tested with upcoming tracing patches that select
BPF instead of NET.
It will also help parallelize the development, since my old
predicate-tree into eBPF optimization for vanilla tracing filters:
http://lwn.net/Articles/598545/
can potentially go into tip tree a release earlier.
Back then full NET dependency was a show stopper.
This patch finally addresses it.
