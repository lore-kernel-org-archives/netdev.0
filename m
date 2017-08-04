From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net-next v3 1/2] bpf: add support for sys_enter_* and
 sys_exit_* tracepoints
Date: Fri, 4 Aug 2017 11:50:50 -0700
Message-ID: <19e84d8d-e778-711d-1fb1-92981e345435@fb.com>
References: <20170803162951.1564963-1-yhs@fb.com>
 <20170803162951.1564963-2-yhs@fb.com>
 <11ef74f9-b0ef-264f-f582-62a8c8f1f027@fb.com>
 <CAH3MdRWpDDxTrfF9rkL7e8ZJW2LATQjMntJqgwCpFCzoiycDHQ@mail.gmail.com>
 <a418c894-3f9f-bec6-7f0d-43319413b222@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <peterz@infradead.org>, <rostedt@goodmis.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>, Y Song <ys114321@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48187 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751216AbdHDSvn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 14:51:43 -0400
In-Reply-To: <a418c894-3f9f-bec6-7f0d-43319413b222@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/4/17 11:40 AM, Alexei Starovoitov wrote:
> On 8/3/17 5:09 PM, Y Song wrote:
>> On Thu, Aug 3, 2017 at 7:08 PM, Alexei Starovoitov <ast@fb.com> wrote:
>>> On 8/3/17 6:29 AM, Yonghong Song wrote:
>>>>
>>>> @@ -578,8 +596,9 @@ static void perf_syscall_enter(void *ignore, struct
>>>> pt_regs *regs, long id)
>>>>         if (!sys_data)
>>>>                 return;
>>>>
>>>> +       prog = READ_ONCE(sys_data->enter_event->prog);
>>>>         head = this_cpu_ptr(sys_data->enter_event->perf_events);
>>>> -       if (hlist_empty(head))
>>>> +       if (!prog && hlist_empty(head))
>>>>                 return;
>>>>
>>>>         /* get the size after alignment with the u32 buffer size 
>>>> field */
>>>> @@ -594,6 +613,13 @@ static void perf_syscall_enter(void *ignore, 
>>>> struct
>>>> pt_regs *regs, long id)
>>>>         rec->nr = syscall_nr;
>>>>         syscall_get_arguments(current, regs, 0, sys_data->nb_args,
>>>>                                (unsigned long *)&rec->args);
>>>> +
>>>> +       if ((prog && !perf_call_bpf_enter(prog, regs, sys_data, 
>>>> rec)) ||
>>>> +           hlist_empty(head)) {
>>>> +               perf_swevent_put_recursion_context(rctx);
>>>> +               return;
>>>> +       }
>>>
>>>
>>> hmm. if I read the patch correctly that makes it different from
>>> kprobe/uprobe/tracepoints+bpf behavior. Why make it different and
>>> force user space to perf_event_open() on every cpu?
>>> In other cases it's the job of the bpf program to filter by cpu
>>> if necessary and that is well understood by bcc scripts.
>>
>> The patch actually does allow the bpf program to track all cpus.
>> The test:
>>>> +       if (!prog && hlist_empty(head))
>>>>                 return;
>> ensures that if prog is not empty, it will not return even if the
>> event in the current cpu is empty. Later on, perf_call_bpf_enter will
>> be called if prog is not empty. This ensures that
>> the bpf program will execute regardless of the current cpu.
>>
>> Maybe I missed anything here?
> 
> you're right. sorry. misread && for ||.
> That part looks good indeed.
> 
> Another question...
> that part:
>          if (is_tracepoint) {
>                  int off = trace_event_get_offsets(event->tp_event);
> 
>                  if (prog->aux->max_ctx_offset > off) {
> seems to be not used in this new path...
> or new is_syscall_tp is also is_tracepoint ?

Good catch! I think I need "is_tracepoint || is_syscall_tp" here.
If trace_event_get_offsets can get the correct offset for the current
particular syscall_{enter|exit}_* event, we will be find.
I will double check this and have another patch.

> If so, then it's ok...
> and trace_event_get_offsets() returns the actual number
> of syscall args or always upper bound of 6?

Since the specific event is fed here, I think the actual number
will be returned.

> just curious how this new code checks that bpf prog cannot
> access args[6+].
> 
> Thanks!
> 
