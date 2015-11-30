From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH net] bpf: fix allocation warnings in bpf maps and integer overflow
Date: Mon, 30 Nov 2015 14:57:40 +0100
Message-ID: <CACT4Y+aGR2p6VCLgqg5otFU+0unPGp4rYe9jyCGLL1hg8D5_vA@mail.gmail.com>
References: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com>
 <20151130005934.GA95228@ast-mbp.thefacebook.com> <565C549C.5080408@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <565C549C.5080408@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 2:52 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 11/30/2015 01:59 AM, Alexei Starovoitov wrote:
> [...]
>>
>> For large map->value_size the user space can trigger memory allocation
>> warnings like:
>
> [...]
>
>> To avoid never succeeding kmalloc with order >= MAX_ORDER check that
>> elem->value_size and computed elem_size are within limits for both hash
>> and
>> array type maps.
>
> [...]
>
>> Large value_size can cause integer overflows in elem_size and map.pages
>> formulas, so check for that as well.
>
> [...]
>
>> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
>> index 3f4c99e06c6b..b1e53b79c586 100644
>> --- a/kernel/bpf/arraymap.c
>> +++ b/kernel/bpf/arraymap.c
>> @@ -28,11 +28,17 @@ static struct bpf_map *array_map_alloc(union bpf_attr
>> *attr)
>>             attr->value_size == 0)
>>                 return ERR_PTR(-EINVAL);
>>
>> +       if (attr->value_size >= 1 << (KMALLOC_SHIFT_MAX - 1))
>> +               /* if value_size is bigger, the user space won't be able
>> to
>> +                * access the elements.
>> +                */
>> +               return ERR_PTR(-E2BIG);
>> +
>
>
> Bit confused, given that in array map, we try kzalloc() with __GFP_NOWARN
> already
> and if that fails, we fall back to vzalloc(), it shouldn't trigger memory
> allocation
> warnings here ...
>
> Then, integer overflow in elem_size with round_up(attr->value_size, 8) could
> only
> result in 0, which is already tested below.
>
>>         elem_size = round_up(attr->value_size, 8);
>>
>>         /* check round_up into zero and u32 overflow */
>>         if (elem_size == 0 ||
>> -           attr->max_entries > (U32_MAX - sizeof(*array)) / elem_size)
>> +           attr->max_entries > (U32_MAX - PAGE_SIZE - sizeof(*array)) /
>> elem_size)
>>                 return ERR_PTR(-ENOMEM);
>
>
> ... and this change seems to be needed for the integer overflow in
> map.pages?
>
> So if the first check above intends to check for some size overflow (?), how
> is it
> then related to KMALLOC_SHIFT_MAX?


kamlloc produces a WARNING if you try to allocate more than it ever
possibly can (KMALLOC_SHIFT_MAX).
