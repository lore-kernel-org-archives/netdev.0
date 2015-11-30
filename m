From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix allocation warnings in bpf maps and integer
 overflow
Date: Mon, 30 Nov 2015 23:16:46 +0100
Message-ID: <565CCACE.8020406@iogearbox.net>
References: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com> <20151130005934.GA95228@ast-mbp.thefacebook.com> <565C549C.5080408@iogearbox.net> <565C5E7B.2080602@iogearbox.net> <20151130181310.GA30762@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151130181310.GA30762@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/2015 07:13 PM, Alexei Starovoitov wrote:
> On Mon, Nov 30, 2015 at 03:34:35PM +0100, Daniel Borkmann wrote:
>>>> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
>>>> index 3f4c99e06c6b..b1e53b79c586 100644
>>>> --- a/kernel/bpf/arraymap.c
>>>> +++ b/kernel/bpf/arraymap.c
>>>> @@ -28,11 +28,17 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
>>>>           attr->value_size == 0)
>>>>           return ERR_PTR(-EINVAL);
>>>>
>>>> +    if (attr->value_size >= 1 << (KMALLOC_SHIFT_MAX - 1))
>>>> +        /* if value_size is bigger, the user space won't be able to
>>>> +         * access the elements.
>>>> +         */
>>>> +        return ERR_PTR(-E2BIG);
>>>> +
>>>
>>> Bit confused, given that in array map, we try kzalloc() with __GFP_NOWARN already
>>> and if that fails, we fall back to vzalloc(), it shouldn't trigger memory allocation
>>> warnings here ...
>
> not quite, the above check is for kmalloc-s in syscall.c
>
>> Ok, I see. The check and comment is related to the fact that when we do bpf(2)
>> syscall to lookup an element:
>>
>> We call map_lookup_elem(), which does kmalloc() on the value_size.
>>
>> So an individual entry lookup could fail with kmalloc() there, unrelated to an
>> individual map implementation.
>
> kmalloc with order >= MAX_ORDER warning can be seen in syscall for update/lookup
> commands regardless of map implememtation.
> So the maps with "value_size >= 1 << (KMALLOC_SHIFT_MAX - 1)" were not accessible
> from user space anyway.
> This check in arraymap.c fixes the warning and prevents creation of such
> maps in the first place as the comment right below it says.

Yeah, right. Noticed that later on. It was a bit confusing at first as I didn't
parse that clearly from the commit message itself.

> Similar check in hashmap.c fixes warning, prevents abnormal map creation and fixes
> integer overflow which is the most dangerous of them all.
>
> The check in arraymap.c
> -        attr->max_entries > (U32_MAX - sizeof(*array)) / elem_size)
> +        attr->max_entries > (U32_MAX - PAGE_SIZE - sizeof(*array)) / elem_size)
>   fixes potential integer overflow in map.pages computation.
>
> and similar check in hashtab.c:
> (u64) htab->elem_size * htab->map.max_entries >= U32_MAX - PAGE_SIZE
> fixes integer overflow in map.pages as well.

Yep, got that part.

> the 'value_size >= (1 << (KMALLOC_SHIFT_MAX - 1)) - MAX_BPF_STACK - sizeof(struct htab_elem)'
> check in hashmap.c fixes integer overflow in elem_size and
> makes elem_size kmalloc-able later in htab_map_update_elem().
> Since it wasn't obvious that this one 'if' addresses these multiple issues,
> I've added a comment there.

... and the MAX_BPF_STACK stands for the maximum key part here, okay.

So, when creating a sufficiently large map where map->key_size + map->value_size
would be > MAX_BPF_STACK (but map->key_size still <= MAX_BPF_STACK), we can only
read the map from an eBPF program, but not update it. In such cases, updates could
only happen from user space application.

> Addition of __GFP_NOWARN only fixes OOM warning as commit log says.

That's obvious, too.

>> Hmm, seems this patch fixes many things at once, maybe makes sense to split it?
>
> hmm I don't see a point of changing the same single line over multipe patches.
> The split won't help backporting, but rather makes for more patches to deal with.
