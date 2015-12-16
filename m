From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 5/6] bpf: hash: avoid to call kmalloc() in eBPF prog
Date: Wed, 16 Dec 2015 15:13:22 +0800
Message-ID: <CACVXFVNhh3eX_vobCG6JehuV=sJ1xywK6C-s1BGeakVkprbaPA@mail.gmail.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
	<1450178464-27721-6-git-send-email-tom.leiming@gmail.com>
	<20151215231057.GB67370@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151215231057.GB67370@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 16, 2015 at 7:10 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Dec 15, 2015 at 07:21:03PM +0800, Ming Lei wrote:
>> kmalloc() is often a bit time-consuming, also
>> one atomic counter has to be used to track the total
>> allocated elements, which is also not good.
>>
>> This patch pre-allocates element pool in htab_map_alloc(),
>> then use percpu_ida to allocate one slot from the pool,
>> then the runtime allocation/freeing cost can be decreased.
>>
>> From my test, at least 10% fio throughput is improved in block
>> I/O test when tools/biolatency of bcc(iovisor) is running.
>>
>> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
>
> Looks very intersting as well.
> Approach looks good.
> If you can make a common allocation helper for this map and
> for blk-mq would be even better.

OK, I will see if it is doable.

>
>> -     htab->elem_size = sizeof(struct htab_elem) +
>> -                       round_up(htab->map.key_size, 8) +
>> -                       htab->map.value_size;
>> +     htab->elem_size = round_up(sizeof(struct htab_elem) +
>> +                                round_up(htab->map.key_size, 8) +
>> +                                htab->map.value_size,
>> +                                cache_line_size());
>
> this rounding to cache line is great for performance, but it's extra
> memory upfront which may not be needed. The per-allocation is a classic
> performance vs memory trade-off. In other cases it may hurt.

The current kmalloc allocation for 'struct htab_elem' is still cache line
aligned, that is one reason why I choose to do it, but we can change
it too.

> So could you change the patch to do pre-allocation only when
> requested by user space via extra flag for hash map or via
> new BPF_MAP_TYPE_HASH_PREALLOC type? Not sure yet whether flag or
> new type is better. I guess implementation will dictate.

Looks a better idea, then we can let user make the choice.

>
> PS
> Glad that you found iovisor/tools/biolatency useful.
> It's indeed pretty helpful to analyze real-time block io latency.

This tool is great and I have played it for a while, :-)



Thanks,
Ming Lei
