From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 13:38:33 -0700
Message-ID: <CAMEtUuwaEb5OgZHCYL-pJRrvLRWBqA1sXhg3diO3=K7ephyBpA@mail.gmail.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	<20140422.235745.1219194947074686642.davem@davemloft.net>
	<CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
	<20140423.125043.100674358164503915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:35294 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbaDWUie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 16:38:34 -0400
Received: by mail-we0-f177.google.com with SMTP id u57so1388858wes.36
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 13:38:33 -0700 (PDT)
In-Reply-To: <20140423.125043.100674358164503915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 9:50 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue, 22 Apr 2014 21:59:32 -0700
>
>> On Tue, Apr 22, 2014 at 8:57 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Alexei Starovoitov <ast@plumgrid.com>
>>> Date: Tue, 22 Apr 2014 20:18:57 -0700
>>>
>>>> exisiting BPF verifier allows uninitialized access to registers,
>>>> 'ret A' is considered to be a valid filter.
>>>> So initialize A and X to zero to prevent leaking kernel memory
>>>> In the future BPF verifier will be rejecting such filters
>>>>
>>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>>
>>> Has the code always been like this?
>>
>> the previous interpreter had:
>> unsigned int sk_run_filter(const struct sk_buff *skb,
>>                            const struct sock_filter *fentry)
>> {
>>         void *ptr;
>>         u32 A = 0;                      /* Accumulator */
>>         u32 X = 0;                      /* Index Register */
>> ...
>> so it wasn't affected.
>>
>>> Did the eBPF changes introduce this problem either directly or
>>> indirectly?
>>
>> this bug is an oversight on my side.
>> I believe in the net-next it should be fixed by making verifier smarter
>> instead of wasting run time cycles to initialize regs.
>> For now the same fix is needed for both net and net-next.
>> We can remove extra assignments when verifier becomes smarter.
>> ebpf verifier that I posted earlier had checks for uninitialized regs and stack.
>> I missed lack of uninit regs part in classic verifier when ebpf verifier and jit
>> were dropped from the patch set.
>
> I think you will need to add the initializations during validation
> rather than fail because existing BPF filters would be accepted and
> run.  You can't just make them fail unexpectedly after all of these
> years.

In this particular case we can indeed make verifier smarter to the point
that once it detects uninitialized A/X in a filter, it will add explicit init
after conversion, so we don't have to pay the penalty at run time.
It's a very good suggestion.

At the same time I think 'ret A' falls into category of the 20 year old bug.
The filters that using undocumented behavior are destined to be
broken sooner or later. tcpdump doesn't generate such filters.
Valid filters will not be affected by strict checking, but I think users
will be actually happy to see kernel rejecting their buggy filters.
I think we can have a global flag for bpf verifier whether to reject
such filters or accept them by adding explicit inits under
'bpf_permissive_loading' flag.
Thoughts?
