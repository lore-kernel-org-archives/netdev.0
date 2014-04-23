From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 09:02:54 +0200
Message-ID: <5357659E.1070807@redhat.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com> <20140422.235745.1219194947074686642.davem@davemloft.net> <CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858AbaDWHDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 03:03:00 -0400
In-Reply-To: <CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2014 06:59 AM, Alexei Starovoitov wrote:
> On Tue, Apr 22, 2014 at 8:57 PM, David Miller <davem@davemloft.net> wrote:
>> From: Alexei Starovoitov <ast@plumgrid.com>
>> Date: Tue, 22 Apr 2014 20:18:57 -0700
>>
>>> exisiting BPF verifier allows uninitialized access to registers,
>>> 'ret A' is considered to be a valid filter.
>>> So initialize A and X to zero to prevent leaking kernel memory
>>> In the future BPF verifier will be rejecting such filters
>>>
>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>
>> Has the code always been like this?

I think it would be much cleaner to just prevent such filters that
only contain a 'ret A', or 'ret X' w/o a load into X from attaching.
By that, we would need to do slightly more work on the verifier
side (which seemed to allow such cases since ever), but therefore
can spare us the extra work in fast path.

Only 'ret A' doesn't make sense, and similarly a program that never
loads anything into X, but wants to return it. We already did a
similar thing for the scratch memory store where we checked stores
into M[] and loads from M[] into A. I can take a look if you want ...
I have some pending BPF cleanups anyway from before the merge window.

> the previous interpreter had:
> unsigned int sk_run_filter(const struct sk_buff *skb,
>                             const struct sock_filter *fentry)
> {
>          void *ptr;
>          u32 A = 0;                      /* Accumulator */
>          u32 X = 0;                      /* Index Register */
> ...
> so it wasn't affected.
>
>> Did the eBPF changes introduce this problem either directly or
>> indirectly?
>
> this bug is an oversight on my side.
> I believe in the net-next it should be fixed by making verifier smarter
> instead of wasting run time cycles to initialize regs.
> For now the same fix is needed for both net and net-next.
> We can remove extra assignments when verifier becomes smarter.
> ebpf verifier that I posted earlier had checks for uninitialized regs and stack.
> I missed lack of uninit regs part in classic verifier when ebpf verifier and jit
> were dropped from the patch set.
> Sorry about this slip.
