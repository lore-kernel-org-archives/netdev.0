From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 3/3] bpf: Make sure that ->comm does not change under
 us.
Date: Tue, 17 Oct 2017 00:19:26 +0200
Message-ID: <59E5306E.8050000@iogearbox.net>
References: <CAADnVQ+0kTYr2azBW6mDSU6JwWtjWRZVaJQ=ZFmSs3JxCFrrRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQ+0kTYr2azBW6mDSU6JwWtjWRZVaJQ=ZFmSs3JxCFrrRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2017 12:10 AM, Alexei Starovoitov wrote:
> On Mon, Oct 16, 2017 at 2:10 PM, Richard Weinberger <richard@nod.at> wrote:
>> Am Montag, 16. Oktober 2017, 23:02:06 CEST schrieb Daniel Borkmann:
>>> On 10/16/2017 10:55 PM, Richard Weinberger wrote:
>>>> Am Montag, 16. Oktober 2017, 22:50:43 CEST schrieb Daniel Borkmann:
>>>>>>            struct task_struct *task = current;
>>>>>>
>>>>>> + task_lock(task);
>>>>>>
>>>>>>            strncpy(buf, task->comm, size);
>>>>>>
>>>>>> + task_unlock(task);
>>>>>
>>>>> Wouldn't this potentially lead to a deadlock? E.g. you attach yourself
>>>>> to task_lock() / spin_lock() / etc, and then the BPF prog triggers the
>>>>> bpf_get_current_comm() taking the lock again ...
>>>>
>>>> Yes, but doesn't the same apply to the use case when I attach to strncpy()
>>>> and run bpf_get_current_comm()?
>>>
>>> You mean due to recursion? In that case trace_call_bpf() would bail out
>>> due to the bpf_prog_active counter.
>>
>> Ah, that's true.
>> So, when someone wants to use bpf_get_current_comm() while tracing task_lock,
>> we have a problem. I agree.
>> On the other hand, without locking the function may return wrong results.
>
> it will surely race with somebody else setting task comm and it's fine.
> all of bpf tracing is read-only, so locks are only allowed inside bpf core
> bits like maps. Taking core locks like task_lock() is quite scary.
> bpf scripts rely on bpf_probe_read() of all sorts of kernel fields
> so reading comm here w/o lock is fine.

Yeah, and perf_event_comm() -> perf_event_comm_event() out of __set_task_comm()
is having same approach wrt comm read-out.
