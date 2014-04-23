From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 12:50:43 -0400 (EDT)
Message-ID: <20140423.125043.100674358164503915.davem@davemloft.net>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	<20140422.235745.1219194947074686642.davem@davemloft.net>
	<CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756730AbaDWQut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 12:50:49 -0400
In-Reply-To: <CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 22 Apr 2014 21:59:32 -0700

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
> 
> the previous interpreter had:
> unsigned int sk_run_filter(const struct sk_buff *skb,
>                            const struct sock_filter *fentry)
> {
>         void *ptr;
>         u32 A = 0;                      /* Accumulator */
>         u32 X = 0;                      /* Index Register */
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

I think you will need to add the initializations during validation
rather than fail because existing BPF filters would be accepted and
run.  You can't just make them fail unexpectedly after all of these
years.
