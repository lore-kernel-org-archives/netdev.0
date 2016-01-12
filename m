From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 5/9] bpf: syscall: add percpu version of lookup/update elem
Date: Tue, 12 Jan 2016 13:00:00 +0800
Message-ID: <CACVXFVM7B6diKgrGoXdMkYW94SeY9yRxbv8bJ+J0K=TBGxDBQQ@mail.gmail.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
	<1452527821-12276-6-git-send-email-tom.leiming@gmail.com>
	<20160111190248.GA26495@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111190248.GA26495@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

Thanks for your review.

On Tue, Jan 12, 2016 at 3:02 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Jan 11, 2016 at 11:56:57PM +0800, Ming Lei wrote:
>> Prepare for supporting percpu map in the following patch.
>>
>> Now userspace can lookup/update mapped value in one specific
>> CPU in case of percpu map.
>>
>> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
> ...
>> @@ -265,7 +272,10 @@ static int map_lookup_elem(union bpf_attr *attr)
>>               goto free_key;
>>
>>       rcu_read_lock();
>> -     ptr = map->ops->map_lookup_elem(map, key);
>> +     if (!percpu)
>> +             ptr = map->ops->map_lookup_elem(map, key);
>> +     else
>> +             ptr = map->ops->map_lookup_elem_percpu(map, key, attr->cpu);
>
> I think this approach is less potent than Martin's for several reasons:
> - bpf program shouldn't be supplying bpf_smp_processor_id(), since
>   it's error prone and a bit slower than doing it explicitly as in:
>   http://patchwork.ozlabs.org/patch/564482/
>   although Martin's patch also needs to use this_cpu_ptr() instead
>   of per_cpu_ptr(.., smp_processor_id());

For PERCPU map, smp_processor_id() is definitely required, and
Martin's patch need that too, please see htab_percpu_map_lookup_elem()
in his patch.

>
> - two new bpf helpers are not necessary in Martin's approach.
>   regular map_lookup_elem() will work for both per-cpu maps.

For percpu ARRAY, they are not necessary, but it is flexiable to
provide them since we should allow prog to retrieve the perpcu
value, also it is easier to implement the system call with the two
helpers.

For percpu HASH, they are required since eBPF prog need to support
deleting element, so we have provide these helpers for prog to retrieve
percpu value before deleting the elem.

>
> - such map_lookup_elem_percpu() from syscall is not accurate.
>   Martin's approach via smp_call_function_single() returns precise value,

I don't understand why Martin's approach is precise and my patch isn't,
could you explain it a bit?

>   whereas here memcpy() will race with other cpus.
>
> Overall I think both pre-cpu hash and per-cpu array maps are quite useful.

percpu hash isn't a must since we can get similar effect by making real_key
and cpu_id as key with less memory consumption, but we can introduce that.

> For this particular set I would suggest to rebase on top of Martin's
> to reuse BPF_MAP_LOOKUP_PERCPU_ELEM command that should be
applicable
> to both per-cpu array and per-cpu hash maps.

Martin's patch doesn't introduce the two helpers, which is required for percpu
hash, and it also makes the syscall easier to implement.

> and add BPF_MAP_UPDATE_PERCPU_ELEM via smp_call as another patch
> that should work for both as well.




Thanks,
Ming Lei
