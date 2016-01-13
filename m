From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 5/9] bpf: syscall: add percpu version of lookup/update elem
Date: Wed, 13 Jan 2016 08:38:18 +0800
Message-ID: <CACVXFVOKRpPfVzAkeFq6vLkRG+JsK+GnmT5_YUBb4hZg3KjM1w@mail.gmail.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
	<1452527821-12276-6-git-send-email-tom.leiming@gmail.com>
	<20160111190248.GA26495@ast-mbp.thefacebook.com>
	<CACVXFVM7B6diKgrGoXdMkYW94SeY9yRxbv8bJ+J0K=TBGxDBQQ@mail.gmail.com>
	<20160112054928.GA31180@ast-mbp.thefacebook.com>
	<CACVXFVOyAm-X7WdC-OCau_tZCAmSJoHFh2p6do16SzFDD8EkUg@mail.gmail.com>
	<20160112191051.GA67436@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160112191051.GA67436@kafai-mba.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 3:10 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Tue, Jan 12, 2016 at 07:05:47PM +0800, Ming Lei wrote:
>> On Tue, Jan 12, 2016 at 1:49 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Tue, Jan 12, 2016 at 01:00:00PM +0800, Ming Lei wrote:
>> >> Hi Alexei,
>> >>
>> >> Thanks for your review.
>> >>
>> >> On Tue, Jan 12, 2016 at 3:02 AM, Alexei Starovoitov
>> >> <alexei.starovoitov@gmail.com> wrote:
>> >> > On Mon, Jan 11, 2016 at 11:56:57PM +0800, Ming Lei wrote:
>> >> >> Prepare for supporting percpu map in the following patch.
>> >> >>
>> >> >> Now userspace can lookup/update mapped value in one specific
>> >> >> CPU in case of percpu map.
>> >> >>
>> >> >> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
>> >> > ...
>> >> >> @@ -265,7 +272,10 @@ static int map_lookup_elem(union bpf_attr *attr)
>> >> >>               goto free_key;
>> >> >>
>> >> >>       rcu_read_lock();
>> >> >> -     ptr = map->ops->map_lookup_elem(map, key);
>> >> >> +     if (!percpu)
>> >> >> +             ptr = map->ops->map_lookup_elem(map, key);
>> >> >> +     else
>> >> >> +             ptr = map->ops->map_lookup_elem_percpu(map, key, attr->cpu);
>> >> >
>> >> > I think this approach is less potent than Martin's for several reasons:
>> >> > - bpf program shouldn't be supplying bpf_smp_processor_id(), since
>> >> >   it's error prone and a bit slower than doing it explicitly as in:
>> >> >   https://urldefense.proofpoint.com/v2/url?u=http-3A__patchwork.ozlabs.org_patch_564482_&d=CwIBaQ&c=5VD0RTtNlTh3ycd41b3MUw&r=VQnoQ7LvghIj0gVEaiQSUw&m=kb6DfquDoMLBv0hgOO76O9SMvdCnhwnEwhgON8868I8&s=QtJkMfQDB55jn_aA_umJ8jiJRQlQhW5UxYO5YdxuGNI&e=
>> >> >   although Martin's patch also needs to use this_cpu_ptr() instead
>> >> >   of per_cpu_ptr(.., smp_processor_id());
>> >>
>> >> For PERCPU map, smp_processor_id() is definitely required, and
>> >> Martin's patch need that too, please see htab_percpu_map_lookup_elem()
>> >> in his patch.
>> >
>> > hmm. it's definitely _not_ required. right?
>> > bpf programs shouldn't be accessing other per-cpu regions
>> > only their own. That's what this_cpu_ptr is for.
>> > I don't see a case where accessing other cpu per-cpu element
>> > wouldn't be a bug in the program.
>> >
>> >> > - two new bpf helpers are not necessary in Martin's approach.
>> >> >   regular map_lookup_elem() will work for both per-cpu maps.
>> >>
>> >> For percpu ARRAY, they are not necessary, but it is flexiable to
>> >> provide them since we should allow prog to retrieve the perpcu
>> >> value, also it is easier to implement the system call with the two
>> >> helpers.
>> >>
>> >> For percpu HASH, they are required since eBPF prog need to support
>> >> deleting element, so we have provide these helpers for prog to retrieve
>> >> percpu value before deleting the elem.
>> >
>> > bpf programs cannot have loops, so there is no valid case to access
>> > other cpu element, since program cannot aggregate all-cpu values.
>> > Therefore the programs can only update/lookup this_cpu element and
>> > delete such element across all cpus.
>>
>> Looks I missed the point of looping constraint, then basically delete element
>> helper doesn't make sense in percpu hash.
>>
>> >
>> >> > - such map_lookup_elem_percpu() from syscall is not accurate.
>> >> >   Martin's approach via smp_call_function_single() returns precise value,
>> >>
>> >> I don't understand why Martin's approach is precise and my patch isn't,
>> >> could you explain it a bit?
>> >
>> > because simple mempcy() called from syscall will race with lookup/increment
>> > done to this_cpu element on another cpu. To avoid this race the smp_call
>> > is needed, so that memcpy() happens on the cpu that updated the element,
>> > so smp_call's memcpy and bpf program won't be touch that cpu value
>> > at the same time and user space will read the correct element values.
>> > If program updates them a lot, the value that user space reads will become
>> > stale very quickly, but it will be valid. That's especially important
>> > when program have multiple counters inside single element value.
>>
>> But smp_call is often very slow because of IPI, so the value acculated
>> finally becomes stale easily even though the value from the requested cpu
>> is 'precise' at the exact time, especially when there are lots of CPUs, so I
>> think using smp_call is really a bad idea. And smp_call is worse than
>> iterating from CPUs simply.
> The userspace usually only aggregates value across all cpu every X seconds.

That is just in your case, and Alexei worried the issue of data stale.

> I hardly consider some number of micro-seconds old data is stale.

Firstly CPU can do hugh things in micro-seconds, such as the if's irq
may just come duirng the period.

Secondly, the time can become longer(maybe dozens of us, or in milli-seconds)
if CPU number is very bigger.

So why not do it in the quick way?


-- 
Ming Lei
