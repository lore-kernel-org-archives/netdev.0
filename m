From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 15:19:41 -0700
Message-ID: <CAMEtUuy-n4=YxejsCF0gg2VX1csfW5p8SfwggH2Tzi6XvE_htw@mail.gmail.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	<20140422.235745.1219194947074686642.davem@davemloft.net>
	<CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
	<20140423.125043.100674358164503915.davem@davemloft.net>
	<CAMEtUuwaEb5OgZHCYL-pJRrvLRWBqA1sXhg3diO3=K7ephyBpA@mail.gmail.com>
	<1398289142.29914.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:54103 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaDWWTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 18:19:42 -0400
Received: by mail-wg0-f51.google.com with SMTP id z12so267127wgg.34
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 15:19:41 -0700 (PDT)
In-Reply-To: <1398289142.29914.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 2:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-04-23 at 13:38 -0700, Alexei Starovoitov wrote:
>
>> In this particular case we can indeed make verifier smarter to the point
>> that once it detects uninitialized A/X in a filter, it will add explicit init
>> after conversion, so we don't have to pay the penalty at run time.
>> It's a very good suggestion.
>>
>> At the same time I think 'ret A' falls into category of the 20 year old bug.
>> The filters that using undocumented behavior are destined to be
>> broken sooner or later. tcpdump doesn't generate such filters.
>> Valid filters will not be affected by strict checking, but I think users
>> will be actually happy to see kernel rejecting their buggy filters.
>> I think we can have a global flag for bpf verifier whether to reject
>> such filters or accept them by adding explicit inits under
>> 'bpf_permissive_loading' flag.
>> Thoughts?
>
>
> I do not really understand the concerns and this discussion over this
> bug.
>
> BPF JIT does basic checks and forces A=0 if first instruction doesn't
> set A.
>
> ( arch/x86/net/bpf_jit_comp.c line 263 )
>
> X is forced to 0 anyway if X is ever used in the JITed filter.
> ( line 227, and we have a typo in comment : s/leek/leak/ )

yes, x86 jit is smart to deal around this problem in an efficient way.
sparc/arm jits copy pasted the idea correctly.
but s390 jit seems to have a bug, since it's not clearing A
when 1st insn is BPF_S_LDX_B_MSH
That shouldn't be a jit job, especially since it can be done by verifier.
classic bpf has 2 regs, ebpf has 10. Checking 1st insn won't work
for ebpf.

> This is not a big deal. If you want to 'optimize', fine, but don't break
> programs.

Fine. I'm not saying to break them by default. I'm suggesting
to give users a flag to detect invalid programs.

> There is no way you add a 'flag' to break a user program, even
> if _you_ believe its broken.
>
> Maybe it assumed initial X / A contents were 0.
>
> Even if not documented, we cannot break this 20 years after the facts.

I'm not suggesting to have this flag by default, but don't you want
kernel to say that bpf program is using uninitialized register?
imo the more checking can be done the better user experience will be.
Just like compiler warnings. Better to have an option to know
what's wrong with the filter than not having it at all.
