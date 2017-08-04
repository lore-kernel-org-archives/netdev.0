From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v3 1/2] bpf: add support for sys_enter_* and
 sys_exit_* tracepoints
Date: Thu, 3 Aug 2017 16:08:07 -1000
Message-ID: <11ef74f9-b0ef-264f-f582-62a8c8f1f027@fb.com>
References: <20170803162951.1564963-1-yhs@fb.com>
 <20170803162951.1564963-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>
To: Yonghong Song <yhs@fb.com>, <peterz@infradead.org>,
        <rostedt@goodmis.org>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33148 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751231AbdHDCJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 22:09:01 -0400
In-Reply-To: <20170803162951.1564963-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/17 6:29 AM, Yonghong Song wrote:
> @@ -578,8 +596,9 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
>  	if (!sys_data)
>  		return;
>
> +	prog = READ_ONCE(sys_data->enter_event->prog);
>  	head = this_cpu_ptr(sys_data->enter_event->perf_events);
> -	if (hlist_empty(head))
> +	if (!prog && hlist_empty(head))
>  		return;
>
>  	/* get the size after alignment with the u32 buffer size field */
> @@ -594,6 +613,13 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
>  	rec->nr = syscall_nr;
>  	syscall_get_arguments(current, regs, 0, sys_data->nb_args,
>  			       (unsigned long *)&rec->args);
> +
> +	if ((prog && !perf_call_bpf_enter(prog, regs, sys_data, rec)) ||
> +	    hlist_empty(head)) {
> +		perf_swevent_put_recursion_context(rctx);
> +		return;
> +	}

hmm. if I read the patch correctly that makes it different from
kprobe/uprobe/tracepoints+bpf behavior. Why make it different and
force user space to perf_event_open() on every cpu?
In other cases it's the job of the bpf program to filter by cpu
if necessary and that is well understood by bcc scripts.
