From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: pppd service crash in linux-3.13.6
Date: Thu, 13 Mar 2014 18:06:22 +0100
Message-ID: <20140313170622.GA31206@redhat.com>
References: <531A37FF.4000509@totakura.in> <531DEEA6.4090808@totakura.in> <531E111A.8040207@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sree Harsha Totakura <sreeharsha@totakura.in>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <531E111A.8040207@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10, Peter Hurley wrote:
>
> [ +cc Oleg Nesterov ]

Thanks.

> The NULL ptr dereference is from following the current->nsproxy ptr
> in ppp_register_channel().
>
> This was broken by
>
> commit 8aac62706adaaf0fab02c4327761561c8bda9448
> Author: Oleg Nesterov <oleg@redhat.com>
> Date:   Fri Jun 14 21:09:49 2013 +0200
>
>     move exit_task_namespaces() outside of exit_notify()
>
> which moved the exit_task_namespaces(tsk) before disassociate_ctty().

Heh. OK, we can move it down after disassociate_ctty(), the original
motivation for that commit was the problem which was also (hopefully)
fixed by e7b2c406925273 "fput: task_work_add() can fail if the caller
has passed exit_task_work()".

In fact I think that it makes sense to move it down after
exit_task_work() anyway. But this is almost off-topic and I'd like to
avoid this right now.

OTOH, why we should delay disassociate_ctty? IOW, do you see any
potential problem with the trivial patch below?

And it seems that it makes sense to move (at least) check_stack_usage()
down, but this is offtopic too.

Oleg.

--- x/kernel/exit.c
+++ kernel/exit.c/
@@ -784,6 +784,8 @@ void do_exit(long code)
 	exit_shm(tsk);
 	exit_files(tsk);
 	exit_fs(tsk);
+	if (group_dead)
+		disassociate_ctty(1);
 	exit_task_namespaces(tsk);
 	exit_task_work(tsk);
 	check_stack_usage();
@@ -799,13 +801,9 @@ void do_exit(long code)
 
 	cgroup_exit(tsk, 1);
 
-	if (group_dead)
-		disassociate_ctty(1);
-
 	module_put(task_thread_info(tsk)->exec_domain->module);
 
 	proc_exit_connector(tsk);
-
 	/*
 	 * FIXME: do that only when needed, using sched_exit tracepoint
 	 */
