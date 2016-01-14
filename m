From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] bpf: bpf_htab: Add syscall to iterate
 percpu value of a key
Date: Thu, 14 Jan 2016 11:23:25 +0800
Message-ID: <CACVXFVNuj_u+sFsSUMa2GKEyhDJr2r+TDDAxGXvbbMj5NuV2AA@mail.gmail.com>
References: <1452586852-1575604-1-git-send-email-kafai@fb.com>
	<1452586852-1575604-4-git-send-email-kafai@fb.com>
	<CACVXFVPAR52e01vVqtZ5LF5j7zscjAVgOccW1erj-a2VYScJrg@mail.gmail.com>
	<20160113052341.GB37858@ast-mbp.thefacebook.com>
	<CACVXFVMMPkekaNvo+ByNGcryB7Mum91xT7nR1YkK+kKu-J1-5w@mail.gmail.com>
	<20160114012433.GB43324@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160114012433.GB43324@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2016 at 9:24 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Wed, Jan 13, 2016 at 11:43:50PM +0800, Ming Lei wrote:
>> On Wed, Jan 13, 2016 at 1:23 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Wed, Jan 13, 2016 at 10:42:49AM +0800, Ming Lei wrote:
>> >>
>> >> So I don't think it is good to retrieve value from one CPU via one
>> >> single system call, and accumulate them finally in userspace.
>> >>
>> >> One approach I thought of is to define the function(or sort of)
>> >>
>> >>  handle_cpu_value(u32 cpu, void *val_cpu, void *val_total)
>> >>
>> >> in bpf kernel code for collecting value from each cpu and
>> >> accumulating them into 'val_total', and most of situations, the
>> >> function can be implemented without loop most of situations.
>> >> kernel can call this function directly, and the total value can be
>> >> return to userspace by one single syscall.
>> >>
>> >> Alexei and anyone, could you comment on this draft idea for
>> >> perpcu map?
>> >
>> > I'm not sure how you expect user space to specify such callback.
>> > Kernel cannot execute user code.
>>
>> I mean the above callback function can be built into bpf code and then
>> run from kernel after loading like in packet filter case by tcpdump, maybe
>> one new prog type is needed. It is doable in theroy. I need to investigate
>> a bit to understand how it can be called from kernel, and it might be OK
>> to call it via kprobe, but not elegent just for accumulating value from each
>> CPU.
>
> that would be a total overkill.

With current bpf framework, it isn't difficult to implement the prog type
for percpu, and it is still reasonable because accumulating values
from each CPU is one policy and should have been defined/provide
from bpf code in case of percpu map.

>
>> > Also syscall/malloc/etc is a noise comparing to ipi and it
>> > will still be there, so
>> > for(all cpus) { syscall+ipi;} will have the same speed.
>>
>> In the syscall path, lots of slow things, and finally the accumulated
>> value is often stale and may not reprensent accurate number at any
>> time, and can be thought as invalid.
>
> no. stale != invalid.
> Some analytics/monitor applications are good with ball park numbers
> and for them regular hash map with non-atomic increment is good enough,
> but others need accurate numbers. Even though they may be seconds stale.

Let me make it clearly, and the following is one case for reading packet length
on each CPU.

time: --------T0--------T1----------T2---------T3-------T4-----------------
CPU0:               E0(0)  E0(1)  .... E0(2M)
CPU1:                               E1(0)  E1(2) .... E1(1M)
CPU2:                                                  E2(0) ....
E2(10K)
CPU3:
E3(0)...E3(1K)

                    R0
                                    R1
                                                      R2
                                                                       R3

               A4

1) suppose the system has 4 cpu cores

2) There is one single event(suppose it is packets received) we are
interetested in, and if the event happens on CPU(i) we will add the
received packet's length into the value of CPU(i)

2) E0(i) reprents the ith event happened on CPU0 from T0, which will
be recored into the value of CPU(0), E1(i) represents the ith event on
CPU(1) from T1, ....

2) R0 represents reading value of CPU0 at the time T0, and R1 represents
reading value of CPU1 at the time T1, .....

3) A4 represents accumulating all percpu value into one totoal value at time T4,
suppose value(A4) = value(R0) + value(R1) + value(R2) + value(R3).

3) if we use syscall to implement Ri(i=1...3), the period between T(i)
and T(i+1)
can become quite big, for example dozens of seconds, so the accumulated value
in A4 can't represent the actual/correct value(counter) at any time between T0
and T4, and the value is wrong actually, and all events in above diagram
(E0(0)~E0(2M), E1(0)~E1(1M),  E2(0) .... E2(10K), ...) aren't counted at all,
and the missed number can be quite huge.

So does the value got by A4 make sense for user?


-- 
Ming Lei
