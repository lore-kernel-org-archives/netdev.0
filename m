From: Michal Kubecek <mkubecek@suse.cz>
Subject: blocking ops when !TASK_RUNNING in vsock_stream_sendmsg() (again)
Date: Fri, 21 Apr 2017 10:14:58 +0200
Message-ID: <20170421081458.GI13789@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andy King <acking@vmware.com>,
        George Zhang <georgezhang@vmware.com>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33748 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1036560AbdDUIPA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 04:15:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

one of openSUSE Leap 42.2 users encountered (repeatedly) a warning

[ 4057.170653] WARNING: CPU: 1 PID: 3471 at ../kernel/sched/core.c:7913 __might_sleep+0x76/0x80()
[ 4057.170661] do not call blocking ops when !TASK_RUNNING; state=1 set at [<ffffffff810c25ab>] prepare_to_wait+0x2b/0x80

with stack

[ 4057.170786]  [<ffffffff81019e69>] dump_trace+0x59/0x320
[ 4057.170789]  [<ffffffff8101a22a>] show_stack_log_lvl+0xfa/0x180
[ 4057.170792]  [<ffffffff8101afd1>] show_stack+0x21/0x40
[ 4057.170798]  [<ffffffff81327657>] dump_stack+0x5c/0x85
[ 4057.170803]  [<ffffffff8107e821>] warn_slowpath_common+0x81/0xb0
[ 4057.170806]  [<ffffffff8107e89c>] warn_slowpath_fmt+0x4c/0x50
[ 4057.170809]  [<ffffffff810a3106>] __might_sleep+0x76/0x80
[ 4057.170814]  [<ffffffff816071ac>] mutex_lock+0x1c/0x38
[ 4057.170822]  [<ffffffffa0cfb477>] vmci_qpair_produce_free_space+0x97/0xd0 [vmw_vmci]
[ 4057.170848]  [<ffffffffa0d10d36>] vsock_stream_sendmsg+0x1f6/0x320 [vsock]
[ 4057.170855]  [<ffffffff814f6fb0>] sock_sendmsg+0x30/0x40
[ 4057.170859]  [<ffffffff814f7039>] sock_write_iter+0x79/0xd0
[ 4057.170864]  [<ffffffff81204d49>] __vfs_write+0xa9/0xf0
[ 4057.170867]  [<ffffffff8120534d>] vfs_write+0x9d/0x190
[ 4057.170870]  [<ffffffff81206012>] SyS_write+0x42/0xa0
[ 4057.170873]  [<ffffffff816093f2>] entry_SYSCALL_64_fastpath+0x16/0x71

The kernel is 4.4.27 but it already has commit f7f9b5e7f8ec ("AF_VSOCK:
Shrink the area influenced by prepare_to_wait") applied. The issue comes
from this part of vsock_stream_sendmsg():

                prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
                while (vsock_stream_has_space(vsk) == 0 &&
                       sk->sk_err == 0 &&
                       !(sk->sk_shutdown & SEND_SHUTDOWN) &&
                       !(vsk->peer_shutdown & RCV_SHUTDOWN)) {

where vsock_stream_has_space() can sleep:

  vsock_stream_has_space
    vmci_transport_stream_has_space
      vmci_qpair_produce_free_space
        qp_lock
          qp_acquire_queue_mutex
            mutex_lock

but this is not allowed between prepare_to_wait() and either the actual
waiting or finish_wait().

I tried to think about a solution but there doesn't seem to be an easy
way to fix this in vmw_stream_sendmsg() as moving prepare_to_wait()
inside the loop would result in missed wake-ups (that was the problem
with the original fix); IMHO the right way to resolve the issue would be
rewriting the vmci queue pair code to allow performing the has_space()
check without taking a mutex.

                                                        Michal Kubecek
