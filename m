From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [PATCH] bpf: convert hashtab lock to raw lock
Date: Mon, 02 Nov 2015 09:12:29 -0800
Message-ID: <5637997D.1020502@linaro.org>
References: <1446243386-26582-1-git-send-email-yang.shi@linaro.org>	<20151031000356.GA28070@Alexeis-MacBook-Pro.local> <20151031094736.494427d7@grimm.local.home> <56350A86.5090500@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <56350A86.5090500@iogearbox.net>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/31/2015 11:37 AM, Daniel Borkmann wrote:
> On 10/31/2015 02:47 PM, Steven Rostedt wrote:
>> On Fri, 30 Oct 2015 17:03:58 -0700
>> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>>> On Fri, Oct 30, 2015 at 03:16:26PM -0700, Yang Shi wrote:
>>>> When running bpf samples on rt kernel, it reports the below warning:
>>>>
>>>> BUG: sleeping function called from invalid context at
>>>> kernel/locking/rtmutex.c:917
>>>> in_atomic(): 1, irqs_disabled(): 128, pid: 477, name: ping
>>>> Preemption disabled at:[<ffff80000017db58>] kprobe_perf_func+0x30/0x228
>>> ...
>>>> diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
>>>> index 83c209d..972b76b 100644
>>>> --- a/kernel/bpf/hashtab.c
>>>> +++ b/kernel/bpf/hashtab.c
>>>> @@ -17,7 +17,7 @@
>>>>   struct bpf_htab {
>>>>       struct bpf_map map;
>>>>       struct hlist_head *buckets;
>>>> -    spinlock_t lock;
>>>> +    raw_spinlock_t lock;
>>>
>>> How do we address such things in general?
>>> I bet there are tons of places around the kernel that
>>> call spin_lock from atomic.
>>> I'd hate to lose the benefits of lockdep of non-raw spin_lock
>>> just to make rt happy.
>>
>> You wont lose any benefits of lockdep. Lockdep still checks
>> raw_spin_lock(). The only difference between raw_spin_lock and
>> spin_lock is that in -rt spin_lock turns into an rt_mutex() and
>> raw_spin_lock stays a spin lock.
>
> ( Btw, Yang, would have been nice if your commit description would have
>    already included such info, not only that you convert it, but also why
>    it's okay to do so. )

I think Thomas's document will include all the information about rt spin 
lock/raw spin lock, etc.

Alexei & Daniel,

If you think such info is necessary, I definitely could add it into the 
commit log in v2.

>
>> The error is that in -rt, you called a mutex and not a spin lock while
>> atomic.
>
> You are right, I think this happens due to the preempt_disable() in the
> trace_call_bpf() handler. So, I think the patch seems okay. The dep_map
> is btw union'ed in the struct spinlock case to the same offset of the
> dep_map from raw_spinlock.
>
> It's a bit inconvenient, though, when we add other library code as maps
> in future, f.e. things like rhashtable as they would first need to be
> converted to raw_spinlock_t as well, but judging from the git log, it
> looks like common practice.

Yes, it is common practice for converting sleepable spin lock to raw 
spin lock in -rt to avoid scheduling in atomic context bug.

Thanks,
Yang

>
> Thanks,
> Daniel

