From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Wed, 18 Oct 2017 16:22:18 +0200
Message-ID: <59E7639A.4060604@iogearbox.net>
References: <cover.1508251210.git.daniel@iogearbox.net> <20171018132526.GC1302522@devbig577.frc2.facebook.com> <59E75F4F.7070706@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@kernel.org, john.fastabend@gmail.com,
        mark.rutland@arm.com, richard@nod.at, sp3485@columbia.edu,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dennis Zhou <dennisszhou@gmail.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59E75F4F.7070706@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/18/2017 04:03 PM, Daniel Borkmann wrote:
> On 10/18/2017 03:25 PM, Tejun Heo wrote:
>> Hello, Daniel.
>>
>> (cc'ing Dennis)
>>
>> On Tue, Oct 17, 2017 at 04:55:51PM +0200, Daniel Borkmann wrote:
>>> The set fixes a splat in devmap percpu allocation when we alloc
>>> the flush bitmap. Patch 1 is a prerequisite for the fix in patch 2,
>>> patch 1 is rather small, so if this could be routed via -net, for
>>> example, with Tejun's Ack that would be good. Patch 3 gets rid of
>>> remaining PCPU_MIN_UNIT_SIZE checks, which are percpu allocator
>>> internals and should not be used.
>>>
>>> Thanks!
>>>
>>> Daniel Borkmann (3):
>>>    mm, percpu: add support for __GFP_NOWARN flag
>>
>> This looks fine.
>
> Great, thanks!
>
>>>    bpf: fix splat for illegal devmap percpu allocation
>>>    bpf: do not test for PCPU_MIN_UNIT_SIZE before percpu allocations
>>
>> These look okay too but if it helps percpu allocator can expose the
>> maximum size / alignment supported to take out the guessing game too.
>
> At least from BPF side there's right now no infra for exposing
> max possible alloc sizes for maps to e.g. user space as indication.
> There are few users left in the tree, where it would make sense for
> having some helpers though:
>
>    arch/tile/kernel/setup.c:729:   if (size < PCPU_MIN_UNIT_SIZE)
>    arch/tile/kernel/setup.c:730:           size = PCPU_MIN_UNIT_SIZE;
>    drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c:346: unsigned int max = (PCPU_MIN_UNIT_SIZE - sizeof(*pools)) << 3;
>    drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c:352: /* make sure per cpu pool fits into PCPU_MIN_UNIT_SIZE */
>    drivers/scsi/libfc/fc_exch.c:2488:       /* reduce range so per cpu pool fits into PCPU_MIN_UNIT_SIZE pool */
>    drivers/scsi/libfc/fc_exch.c:2489:      pool_exch_range = (PCPU_MIN_UNIT_SIZE - sizeof(*pool)) /
>
>> Also, the reason why PCPU_MIN_UNIT_SIZE is what it is is because
>> nobody needed anything bigger.  Increasing the size doesn't really
>> cost much at least on 64bit archs.  Is that something we want to be
>> considering?
>
> For devmap (and cpumap) itself it wouldn't make sense. For per-cpu
> hashtable we could indeed consider it in the future.

Higher prio imo would be to make the allocation itself faster
though, I remember we talked about this back in May wrt hashtable,
but I kind of lost track whether there was an update on this in
the mean time. ;-)

Cheers,
Daniel
