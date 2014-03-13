From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: pppd service crash in linux-3.13.6
Date: Thu, 13 Mar 2014 13:55:31 -0400
Message-ID: <5321F113.7090000@hurleysoftware.com>
References: <531A37FF.4000509@totakura.in> <531DEEA6.4090808@totakura.in> <531E111A.8040207@hurleysoftware.com> <20140313170622.GA31206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sree Harsha Totakura <sreeharsha@totakura.in>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140313170622.GA31206@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oleg,

On 03/13/2014 01:06 PM, Oleg Nesterov wrote:
> On 03/10, Peter Hurley wrote:
>>
>> [ +cc Oleg Nesterov ]
>
> Thanks.
>
>> The NULL ptr dereference is from following the current->nsproxy ptr
>> in ppp_register_channel().
>>
>> This was broken by
>>
>> commit 8aac62706adaaf0fab02c4327761561c8bda9448
>> Author: Oleg Nesterov <oleg@redhat.com>
>> Date:   Fri Jun 14 21:09:49 2013 +0200
>>
>>      move exit_task_namespaces() outside of exit_notify()
>>
>> which moved the exit_task_namespaces(tsk) before disassociate_ctty().
>
> Heh. OK, we can move it down after disassociate_ctty(), the original
> motivation for that commit was the problem which was also (hopefully)
> fixed by e7b2c406925273 "fput: task_work_add() can fail if the caller
> has passed exit_task_work()".

I didn't look into what motivated the change; I will now though.

> In fact I think that it makes sense to move it down after
> exit_task_work() anyway. But this is almost off-topic and I'd like to
> avoid this right now.
>
> OTOH, why we should delay disassociate_ctty? IOW, do you see any
> potential problem with the trivial patch below?

I have no idea what kind of dependencies might exist between
task works, cgroup_exit() and all the teardown that disassociate_ctty()
does. I'll look into though.

> And it seems that it makes sense to move (at least) check_stack_usage()
> down, but this is offtopic too.

I agree that it makes sense to check the stack _after_ teardown code
runs, but all the arch-dependent exit_thread() code would need to be
audited first.

> Oleg.
>
> --- x/kernel/exit.c
> +++ kernel/exit.c/
> @@ -784,6 +784,8 @@ void do_exit(long code)
>   	exit_shm(tsk);
>   	exit_files(tsk);
>   	exit_fs(tsk);
> +	if (group_dead)
> +		disassociate_ctty(1);
>   	exit_task_namespaces(tsk);
>   	exit_task_work(tsk);
>   	check_stack_usage();
> @@ -799,13 +801,9 @@ void do_exit(long code)
>
>   	cgroup_exit(tsk, 1);
>
> -	if (group_dead)
> -		disassociate_ctty(1);
> -
>   	module_put(task_thread_info(tsk)->exec_domain->module);
>
>   	proc_exit_connector(tsk);
> -
>   	/*
>   	 * FIXME: do that only when needed, using sched_exit tracepoint
>   	 */

Regards,
Peter Hurley
