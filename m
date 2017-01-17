From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Kernel 4.6.7-rt14 kernel workqueue lockup - rtnl deadlock plus
 syscall endless loop
Date: Tue, 17 Jan 2017 09:53:51 -0800
Message-ID: <20170117095351.5444deb1@xeon-e3>
References: <AM5PR0701MB187338B2418A19E1B4B55C98A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Elad Nachman <EladN@gilat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35891 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdAQSAH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 13:00:07 -0500
Received: by mail-pg0-f42.google.com with SMTP id t6so21156879pgt.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:00:06 -0800 (PST)
In-Reply-To: <AM5PR0701MB187338B2418A19E1B4B55C98A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jan 2017 17:39:03 +0000
Elad Nachman <EladN@gilat.com> wrote:

> Hi,
> 
> I am experiencing sporadic work queue lockups on kernel 4.6.7-rt14 (mach-socfpga).
> 
> Using a HW debugger I got the following information:
> 
> A process containing a network namespace is terminating itself (SIGKILL), which causes cleanup_net() to be scheduled to kworker/u4:2 to clean up the network namespace running on the process.
> 
> Kworker/u4:2 got preempted (plus there are a lot of other work queue items, like vmstat_shepherd, wakeup_dirtytime_writeback, phy_state_machine, neigh_periodic_work, check_lifetime plus another one by a LKM) while holding the rtnl lock.
> 
> A processing running waitpid() on the terminated process starts a new process, which forks busybox to run sysctl -w net.ipv6.conf.all.forwarding = 1 .
> This in turn starts making a write syscall, calling in turn vfs_write, proc_sys_call_handler, addrconf_sysctl_forward, and finally addrconf_fixup_forwarding().
> 
> addrconf_fixup_forwarding() runs the following code:
> 
> if (!rtnl_trylock())
>                  return restart_syscall();
> 
> This fails and restart_syscall() does the following:
> 
> set_tsk_thread_flag(current, TIF_SIGPENDING);
>          return -ERESTARTNOINTR;
> 
> Now the system call goes back to ret_fast_syscall (arch/arm/kernel/entry-common.S)
> Testing the flags in the task_struct (which contain TIF_SIGPENDING) the code branches to fast_work_pending, then falls through to slow_work_pending, which
> Calls do_work_pending(), and in turn calls do_signal(), get_signal(), dequeuer_signal(), which find no signals, and clears the TIF_SIGPENDING bit when recalc_sigpending() is called, then returns zero.
> 
> This causes do_signal() to examine r0 and return 1 (-ERESTARTNOINTR), which is propogated to the assembly code by do_work_pending().
> Having r0 equal zero causes a branch to local_restart, which restarts the very same write system call in an endless loop.
> No scheduling is possible, so the cleanup_net() cannot finish and release rtnl, which in turn causes the endless restarting of the write system call.
> 
> I have sent this to linux-arm-kernel and got a response from Russel King saying that (relating to addrconf_fixup_forwarding, net/ipv6/addrconf.c ):
> 
> "
> I think the problem is that:
> 
>         if (!rtnl_trylock())
>                 return restart_syscall();
> 
> 
> 
> which, if it didn't do a trylock, it would put this thread to sleep
> and allow other threads to run (potentially allowing the holder of
> the lock to release it.)
> 
> What's more odd about this is that it's very unusual and strange for
> a kernel function to invoke the restart mechanism because a lock is
> being held - the point of the restart mechanism is to allow userspace
> signal handlers to run, so it should only be used when there's a
> signal pending. I think this is a hack in the IPv6 code to work
> around some other issue.

The trylock was added intentionally to handle a different deadlock.
Going back to a blocking lock would cause that problem.

There was a deadlock between device unregistration and sysfs access.
Unregistration wants to remove sysfs entry while holding RTNL.
Sysfs access graps sysfs file entry lock then acquires RTNL.

The patch back in 2.6.30 followed by multiple revisions was to
restart the sysfs write syscall.
