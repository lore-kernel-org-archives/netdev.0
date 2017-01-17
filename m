From: Elad Nachman <EladN@gilat.com>
Subject: Kernel 4.6.7-rt14 kernel workqueue lockup - rtnl deadlock plus
 syscall endless loop
Date: Tue, 17 Jan 2017 17:39:03 +0000
Message-ID: <AM5PR0701MB187338B2418A19E1B4B55C98A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0076.outbound.protection.outlook.com ([104.47.0.76]:43232
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751071AbdAQRjL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 12:39:11 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am experiencing sporadic work queue lockups on kernel 4.6.7-rt14 (mach-so=
cfpga).

Using a HW debugger I got the following information:

A process containing a network namespace is terminating itself (SIGKILL), w=
hich causes cleanup_net() to be scheduled to kworker/u4:2 to clean up the n=
etwork namespace running on the process.

Kworker/u4:2 got preempted (plus there are a lot of other work queue items,=
 like vmstat_shepherd, wakeup_dirtytime_writeback, phy_state_machine, neigh=
_periodic_work, check_lifetime plus another one by a LKM) while holding the=
 rtnl lock.

A processing running waitpid() on the terminated process starts a new proce=
ss, which forks busybox to run sysctl -w net.ipv6.conf.all.forwarding =3D 1=
 .
This in turn starts making a write syscall, calling in turn vfs_write, proc=
_sys_call_handler, addrconf_sysctl_forward, and finally addrconf_fixup_forw=
arding().

addrconf_fixup_forwarding() runs the following code:

if (!rtnl_trylock())
                 return restart_syscall();

This fails and restart_syscall() does the following:

set_tsk_thread_flag(current, TIF_SIGPENDING);
         return -ERESTARTNOINTR;

Now the system call goes back to ret_fast_syscall (arch/arm/kernel/entry-co=
mmon.S)
Testing the flags in the task_struct (which contain TIF_SIGPENDING) the cod=
e branches to fast_work_pending, then falls through to slow_work_pending, w=
hich
Calls do_work_pending(), and in turn calls do_signal(), get_signal(), deque=
uer_signal(), which find no signals, and clears the TIF_SIGPENDING bit when=
 recalc_sigpending() is called, then returns zero.

This causes do_signal() to examine r0 and return 1 (-ERESTARTNOINTR), which=
 is propogated to the assembly code by do_work_pending().
Having r0 equal zero causes a branch to local_restart, which restarts the v=
ery same write system call in an endless loop.
No scheduling is possible, so the cleanup_net() cannot finish and release r=
tnl, which in turn causes the endless restarting of the write system call.

I have sent this to linux-arm-kernel and got a response from Russel King sa=
ying that (relating to addrconf_fixup_forwarding, net/ipv6/addrconf.c ):

"
I think the problem is that:

        if (!rtnl_trylock())
                return restart_syscall();



which, if it didn't do a trylock, it would put this thread to sleep
and allow other threads to run (potentially allowing the holder of
the lock to release it.)

What's more odd about this is that it's very unusual and strange for
a kernel function to invoke the restart mechanism because a lock is
being held - the point of the restart mechanism is to allow userspace
signal handlers to run, so it should only be used when there's a
signal pending. I think this is a hack in the IPv6 code to work
around some other issue.
"

Any reason we cannot change the above two lines to rtnl_lock() ?

Thanks,

Elad.



IMPORTANT - This email and any attachments is intended for the above named =
addressee(s), and may contain information which is confidential or privileg=
ed. If you are not the intended recipient, please inform the sender immedia=
tely and delete this email: you should not copy or use this e-mail for any =
purpose nor disclose its contents to any person.
