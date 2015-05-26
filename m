From: Zack Weinberg <zackw@panix.com>
Subject: "ip netns create" hangs forever, spamming console with
 "unregister_netdevice: waiting for lo to become free"
Date: Tue, 26 May 2015 12:21:09 -0400
Message-ID: <CAKCAbMgkpFMX7cQS=c3eD802aKTWesCv1TW7n8mtBvqLF0BN8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from l2mail1.panix.com ([166.84.1.75]:60099 "EHLO l2mail1.panix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbbEZQge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 12:36:34 -0400
Received: from mailbackend.panix.com (mailbackend.panix.com [166.84.1.89])
	by l2mail1.panix.com (Postfix) with ESMTP id DFC97C016
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 12:21:11 -0400 (EDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by mailbackend.panix.com (Postfix) with ESMTPSA id D6A4D15A11
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 12:21:10 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so82987136wic.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:21:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[This was originally posted at
https://bugzilla.kernel.org/show_bug.cgi?id=97811 ]

I have an application that makes heavy use of network namespaces,
creating and destroying them on the fly during operation.  With 100%
reproducibility, the first invocation of "ip netns create" after any
"ip netns del" hangs forever in D-state; only rebooting the machine
clears the condition.  This used to be an intermittent fault, going
back at least as far as 3.16, but 4.0 seems to have upgraded it to an
every-single-time fault.  I'm running 4.0.1 right now, but another
person reports that it happens with 4.0.4 as well.

lockdep hung task detection reports:

May  5 22:48:07 laguz kernel: INFO: task ip:572431 blocked for more
than 120 seconds.
May  5 22:48:07 laguz kernel:      Not tainted 4.0.1-linode55-lockdep #2
May  5 22:48:07 laguz kernel: "echo 0 >
/proc/sys/kernel/hung_task_timeout_secs" disables this message.
May  5 22:48:07 laguz kernel: ip              D ffff88000e28bda8     0
572431 572428 0x00000000
May  5 22:48:07 laguz kernel: ffff88000e28bda8 ffff880058b60000
ffff8801512c6540 ffff88000e28bda8
May  5 22:48:07 laguz kernel: ffff88000e28bfd8 ffff8800a07e6500
ffffffff81ecee88 ffff88000e28be28
May  5 22:48:07 laguz kernel: ffff8801512c6540 ffff88000e28bdc8
ffffffff81964ca9 0000000000000006
May  5 22:48:07 laguz kernel: Call Trace:
May  5 22:48:07 laguz kernel: [<ffffffff81964ca9>] schedule+0x74/0x83
May  5 22:48:07 laguz kernel: [<ffffffff81964cc6>]
schedule_preempt_disabled+0xe/0x10
May  5 22:48:07 laguz kernel: [<ffffffff81965b0f>] mutex_lock_nested+0x200/0x462
May  5 22:48:07 laguz kernel: [<ffffffff8175a651>] ? copy_net_ns+0x79/0x103
May  5 22:48:07 laguz kernel: [<ffffffff8175a61c>] ? copy_net_ns+0x44/0x103
May  5 22:48:07 laguz kernel: [<ffffffff811139d5>] ?
lockdep_trace_alloc+0xca/0xdc
May  5 22:48:07 laguz kernel: [<ffffffff8175a651>] copy_net_ns+0x79/0x103
May  5 22:48:07 laguz kernel: [<ffffffff810f4b40>]
create_new_namespaces+0x103/0x17f
May  5 22:48:07 laguz kernel: [<ffffffff810f4d8b>]
unshare_nsproxy_namespaces+0x8b/0xb0
May  5 22:48:07 laguz kernel: [<ffffffff810da7f0>] SyS_unshare+0x120/0x2aa
May  5 22:48:07 laguz kernel: [<ffffffff8196a2c9>]
system_call_fastpath+0x12/0x17
May  5 22:48:07 laguz kernel: 1 lock held by ip/572431:
May  5 22:48:07 laguz kernel: #0:  (net_mutex){+.+.+.}, at:
[<ffffffff8175a651>] copy_net_ns+0x79/0x103

When the bug manifests, there is invariably also a kworker process
stuck in D-state, but lockdep doesn't pick that up because it's
looping in netdev_wait_allrefs: (the pids don't match below and above
because the machine was restarted in between, but the stack trace for
the ip process is identical) (netdev_wait_allrefs was inlined into
netdev_run_todo):

# ps -e -o pid,stat,comm,wchan | grep D
   PID STAT COMMAND         WCHAN
257795 D    kworker/u12:0   msleep
290845 D+   ip              copy_net_ns

# cat /proc/257795/stack
[<ffffffff8112a9a7>] msleep+0x1e/0x22
[<ffffffff81763b13>] netdev_run_todo+0x17a/0x2a5
[<ffffffff81770284>] rtnl_unlock+0xe/0x10
[<ffffffff81764764>] default_device_exit_batch+0x12c/0x13b
[<ffffffff81759c25>] ops_exit_list+0x2a/0x55
[<ffffffff8175a532>] cleanup_net+0x14c/0x1f2
[<ffffffff810eecf1>] process_one_work+0x216/0x3fb
[<ffffffff810ef17d>] worker_thread+0x278/0x35c
[<ffffffff810f3ec5>] kthread+0x102/0x10a
[<ffffffff8196a218>] ret_from_fork+0x58/0x90

I am not aware of any way to extract the list of held locks for a
specific process, but based on code inspection, this process *should*
be repeatedly acquiring and dropping the rtnl_mutex but not holding
any other locks.

The point where it's stuck in copy_net_ns is

        mutex_lock(&net_mutex);
        rv = setup_net(net, user_ns);
        if (rv == 0) {
                rtnl_lock();
                list_add_tail_rcu(&net->list, &net_namespace_list);
                rtnl_unlock();
        }
        mutex_unlock(&net_mutex);

The assembly around copy_net_ns+0x79 is

   0xffffffff8175a643 <+107>:   xor    %esi,%esi
   0xffffffff8175a645 <+109>:   mov    $0xffffffff81ecee80,%rdi
   0xffffffff8175a64c <+116>:   callq  0xffffffff8196590f <mutex_lock_nested>
   0xffffffff8175a651 <+121>:   mov    %rbx,%rsi
   0xffffffff8175a654 <+124>:   mov    %r12,%rdi
   0xffffffff8175a657 <+127>:   callq  0xffffffff8175a0a5 <setup_net>

(note decimal vs hex offsets) so it's blocked on an attempt to acquire
the net_mutex, which lockdep thinks it *already holds, having acquired
it at that very point*.  This doesn't make any sense to me; I can
imagine some sort of bug in the guts of the mutex implementation, that
would cause it to block forever *after* having acquired the mutex it
was asked to acquire, but that strikes me as extraordinarily unlikely.

A more plausible theory based on code inspection is that it's
_actually_ stuck trying to acquire the rtnl_mutex -- the kworker does
not hold that lock during its calls to msleep() AFAICT, but perhaps
the mutex implementation is so profoundly unfair (in this scenario
anyway) that the lock never gets awarded to the ip process, and
meanwhile the kworker never makes any forward progress because
something on one of the notifier chains called from
netdev_wait_allrefs needs the net_mutex (and is not actually _taking_
that mutex, just noticing that it's already locked and giving up).
But this would entail that the stack trace for the ip process is
completely wrong.

I might try moving the mutex_unlock(&net_mutex) up to right after the
call to setup_net to see what happens, but I'm not sure that's safe
and it may be some time before I know if it helped.

Any advice or assistance anyone can provide would be much appreciated.
I'm happy to test patches.  I'm also happy to provide further
information as requested, but please give specific instructions on how
to gather that information, I have almost no experience debugging the
kernel.

The .config is attached to the bugzilla report; it is Linode's latest
stock 64-bit kernel (as of May 5) + activation of lockdep.

Note I am not subscribed to this mailing list, please cc: me on reples.

thanks,
zw
