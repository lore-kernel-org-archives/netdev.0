From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix allocation warnings in bpf maps and integer
 overflow
Date: Mon, 30 Nov 2015 15:34:35 +0100
Message-ID: <565C5E7B.2080602@iogearbox.net>
References: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com> <20151130005934.GA95228@ast-mbp.thefacebook.com> <565C549C.5080408@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50984 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824AbbK3Oel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 09:34:41 -0500
In-Reply-To: <565C549C.5080408@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2015 02:52 PM, Daniel Borkmann wrote:
> On 11/30/2015 01:59 AM, Alexei Starovoitov wrote:
> [...]
>> For large map->value_size the user space can trigger memory allocation warnings like:
> [...]
>
>> To avoid never succeeding kmalloc with order >= MAX_ORDER check that
>> elem->value_size and computed elem_size are within limits for both hash and
>> array type maps.
> [...]
>
>> Large value_size can cause integer overflows in elem_size and map.pages
>> formulas, so check for that as well.
> [...]
>
>> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
>> index 3f4c99e06c6b..b1e53b79c586 100644
>> --- a/kernel/bpf/arraymap.c
>> +++ b/kernel/bpf/arraymap.c
>> @@ -28,11 +28,17 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
>>           attr->value_size == 0)
>>           return ERR_PTR(-EINVAL);
>>
>> +    if (attr->value_size >= 1 << (KMALLOC_SHIFT_MAX - 1))
>> +        /* if value_size is bigger, the user space won't be able to
>> +         * access the elements.
>> +         */
>> +        return ERR_PTR(-E2BIG);
>> +
>
> Bit confused, given that in array map, we try kzalloc() with __GFP_NOWARN already
> and if that fails, we fall back to vzalloc(), it shouldn't trigger memory allocation
> warnings here ...
>
> Then, integer overflow in elem_size with round_up(attr->value_size, 8) could only
> result in 0, which is already tested below.
>
>>       elem_size = round_up(attr->value_size, 8);
>>
>>       /* check round_up into zero and u32 overflow */
>>       if (elem_size == 0 ||
>> -        attr->max_entries > (U32_MAX - sizeof(*array)) / elem_size)
>> +        attr->max_entries > (U32_MAX - PAGE_SIZE - sizeof(*array)) / elem_size)
>>           return ERR_PTR(-ENOMEM);
>
> ... and this change seems to be needed for the integer overflow in map.pages?
>
> So if the first check above intends to check for some size overflow (?), how is it
> then related to KMALLOC_SHIFT_MAX?

Ok, I see. The check and comment is related to the fact that when we do bpf(2)
syscall to lookup an element:

We call map_lookup_elem(), which does kmalloc() on the value_size.

So an individual entry lookup could fail with kmalloc() there, unrelated to an
individual map implementation.

Hmm, seems this patch fixes many things at once, maybe makes sense to split it?
