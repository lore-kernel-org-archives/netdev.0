From: Y Song <ys114321@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] bpf: add support for sys_enter_* and
 sys_exit_* tracepoints
Date: Thu, 3 Aug 2017 20:09:22 -0700
Message-ID: <CAH3MdRWpDDxTrfF9rkL7e8ZJW2LATQjMntJqgwCpFCzoiycDHQ@mail.gmail.com>
References: <20170803162951.1564963-1-yhs@fb.com> <20170803162951.1564963-2-yhs@fb.com>
 <11ef74f9-b0ef-264f-f582-62a8c8f1f027@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Yonghong Song <yhs@fb.com>, peterz@infradead.org,
        rostedt@goodmis.org, Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34247 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751918AbdHDDKD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 23:10:03 -0400
Received: by mail-vk0-f65.google.com with SMTP id d124so224912vkf.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 20:10:03 -0700 (PDT)
In-Reply-To: <11ef74f9-b0ef-264f-f582-62a8c8f1f027@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 3, 2017 at 7:08 PM, Alexei Starovoitov <ast@fb.com> wrote:
> On 8/3/17 6:29 AM, Yonghong Song wrote:
>>
>> @@ -578,8 +596,9 @@ static void perf_syscall_enter(void *ignore, struct
>> pt_regs *regs, long id)
>>         if (!sys_data)
>>                 return;
>>
>> +       prog = READ_ONCE(sys_data->enter_event->prog);
>>         head = this_cpu_ptr(sys_data->enter_event->perf_events);
>> -       if (hlist_empty(head))
>> +       if (!prog && hlist_empty(head))
>>                 return;
>>
>>         /* get the size after alignment with the u32 buffer size field */
>> @@ -594,6 +613,13 @@ static void perf_syscall_enter(void *ignore, struct
>> pt_regs *regs, long id)
>>         rec->nr = syscall_nr;
>>         syscall_get_arguments(current, regs, 0, sys_data->nb_args,
>>                                (unsigned long *)&rec->args);
>> +
>> +       if ((prog && !perf_call_bpf_enter(prog, regs, sys_data, rec)) ||
>> +           hlist_empty(head)) {
>> +               perf_swevent_put_recursion_context(rctx);
>> +               return;
>> +       }
>
>
> hmm. if I read the patch correctly that makes it different from
> kprobe/uprobe/tracepoints+bpf behavior. Why make it different and
> force user space to perf_event_open() on every cpu?
> In other cases it's the job of the bpf program to filter by cpu
> if necessary and that is well understood by bcc scripts.

The patch actually does allow the bpf program to track all cpus.
The test:
>> +       if (!prog && hlist_empty(head))
>>                 return;
ensures that if prog is not empty, it will not return even if the
event in the current cpu is empty. Later on, perf_call_bpf_enter will
be called if prog is not empty. This ensures that
the bpf program will execute regardless of the current cpu.

Maybe I missed anything here?
