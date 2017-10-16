From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 3/3] bpf: Make sure that ->comm does not change under us.
Date: Mon, 16 Oct 2017 15:10:06 -0700
Message-ID: <CAADnVQ+0kTYr2azBW6mDSU6JwWtjWRZVaJQ=ZFmSs3JxCFrrRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 2:10 PM, Richard Weinberger <richard@nod.at> wrote:
> Am Montag, 16. Oktober 2017, 23:02:06 CEST schrieb Daniel Borkmann:
>> On 10/16/2017 10:55 PM, Richard Weinberger wrote:
>> > Am Montag, 16. Oktober 2017, 22:50:43 CEST schrieb Daniel Borkmann:
>> >>>           struct task_struct *task = current;
>> >>>
>> >>> + task_lock(task);
>> >>>
>> >>>           strncpy(buf, task->comm, size);
>> >>>
>> >>> + task_unlock(task);
>> >>
>> >> Wouldn't this potentially lead to a deadlock? E.g. you attach yourself
>> >> to task_lock() / spin_lock() / etc, and then the BPF prog triggers the
>> >> bpf_get_current_comm() taking the lock again ...
>> >
>> > Yes, but doesn't the same apply to the use case when I attach to strncpy()
>> > and run bpf_get_current_comm()?
>>
>> You mean due to recursion? In that case trace_call_bpf() would bail out
>> due to the bpf_prog_active counter.
>
> Ah, that's true.
> So, when someone wants to use bpf_get_current_comm() while tracing task_lock,
> we have a problem. I agree.
> On the other hand, without locking the function may return wrong results.

it will surely race with somebody else setting task comm and it's fine.
all of bpf tracing is read-only, so locks are only allowed inside bpf core
bits like maps. Taking core locks like task_lock() is quite scary.
bpf scripts rely on bpf_probe_read() of all sorts of kernel fields
so reading comm here w/o lock is fine.
