From: Rainer Weikusat <rweikusat@cyberadapt.com>
Subject: Re: possible circular locking dependency detected (bisected)
Date: Wed, 31 Aug 2016 21:16:25 +0100
Message-ID: <87zinsbso6.fsf@doppelsaurus.mobileactivedefense.com>
References: <1018744655.2694243.1472223057200.JavaMail.zimbra@redhat.com>
        <812527981.484636.1472591145655.JavaMail.zimbra@redhat.com>
        <1934642616.820579.1472672257777.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        <security@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: CAI Qian <caiqian@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0045.outbound.protection.outlook.com ([104.47.40.45]:4991
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1760650AbcHaUvF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 16:51:05 -0400
In-Reply-To: <1934642616.820579.1472672257777.JavaMail.zimbra@redhat.com> (CAI
        Qian's message of "Wed, 31 Aug 2016 15:37:37 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAI Qian <caiqian@redhat.com> writes:
> Reverted the patch below fixes this problem.
>
> c845acb324aa85a39650a14e7696982ceea75dc1
> af_unix: Fix splice-bind deadlock

Reverting a patch fixing one deadlock in order to avoid another deadlock
leaves the 'net situation' unchanged. The idea of the other patch was to
change unix_mknod such that it doesn't do __sb_start_write with
u->readlock held anymore. As far as I understand the output below,
overlayfs introduce an additional codepath where unix_mknod end up doing
__sb_start_write again. That's already the original deadlock re-added,
cf,

    B: splice() from a pipe to /mnt/regular_file
        does sb_start_write() on /mnt
    C: try to freeze /mnt
        wait for B to finish with /mnt
    A: bind() try to bind our socket to /mnt/new_socket_name
        lock our socket, see it not bound yet
        decide that it needs to create something in /mnt
        try to do sb_start_write() on /mnt, block (it's
        waiting for C).
    D: splice() from the same pipe to our socket
        lock the pipe, see that socket is connected
        try to lock the socket, block waiting for A
    B:  get around to actually feeding a chunk from
        pipe to file, try to lock the pipe.  Deadlock.


as A will again acquire the readlock and then call __sb_start_write.
        
>
>    CAI Qian
>
> ----- Original Message -----
>> From: "CAI Qian" <caiqian@redhat.com>
>> To: security@kernel.org
>> Cc: "Miklos Szeredi" <mszeredi@redhat.com>, "Eric Sandeen" <esandeen@redhat.com>
>> Sent: Tuesday, August 30, 2016 5:05:45 PM
>> Subject: Re: possible circular locking dependency detected
>> 
>> FYI, this one can only be reproduced using the overlayfs docker backend.
>> The device-mapper works fine. The XFS below has ftype=1.
>> 
>> # cp recvmsg01 /mnt
>> # docker run -it -v /mnt/:/mnt/ rhel7 bash
>> [root@c33c99aedd93 /]# mount
>> overlay on / type overlay
>> (rw,relatime,seclabel,lowerdir=l/I5VXL74ENBNAEARZ4M2SIN3XD6:l/KZGBKPXLDXUGHYWMERFUBM4FRP,upperdir=9a7c1f735166b1f63d220b4b6c59cc37f3922719ef810c97182b814c1ab336df/diff,workdir=9a7c1f735166b1f63d220b4b6c59cc37f3922719ef810c97182b814c1ab336df/work)
>> ...
>> [root@c33c99aedd93 /]# /mnt/recvmsg01
>>     CAI Qian
>> 
>> ----- Original Message -----
>> > From: "CAI Qian" <caiqian@redhat.com>
>> > To: security@kernel.org
>> > Sent: Friday, August 26, 2016 10:50:57 AM
>> > Subject: possible circular locking dependency detected
>> > 
>> > FYI, just want to give a head up to see if there is anything obvious so
>> > we can avoid a possible DoS somehow.
>> > 
>> > Running the LTP syscalls tests inside a container until this test trigger
>> > below,
>> > https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/recvmsg/recvmsg01.c
>> > 
>> > [ 4441.904103] open04 (42409) used greatest stack depth: 20552 bytes left
>> > [ 4605.419167]
>> > [ 4605.420831] ======================================================
>> > [ 4605.427727] [ INFO: possible circular locking dependency detected ]
>> > [ 4605.434720] 4.8.0-rc3+ #3 Not tainted
>> > [ 4605.438803] -------------------------------------------------------
>> > [ 4605.445796] recvmsg01/42878 is trying to acquire lock:
>> > [ 4605.451528]  (sb_writers#8){.+.+.+}, at: [<ffffffff816a6d34>]
>> > __sb_start_write+0xb4/0xf0
>> > [ 4605.460642]
>> > [ 4605.460642] but task is already holding lock:
>> > [ 4605.467150]  (&u->readlock){+.+.+.}, at: [<ffffffff825242e9>]
>> > unix_bind+0x299/0xdf0
>> > [ 4605.475749]
>> > [ 4605.475749] which lock already depends on the new lock.
>> > [ 4605.475749]
>> > [ 4605.484882]
>> > [ 4605.484882] the existing dependency chain (in reverse order) is:
>> > [ 4605.493234]
>> > [ 4605.493234] -> #2 (&u->readlock){+.+.+.}:
>> > [ 4605.497943]        [<ffffffff812b4b5a>] lock_acquire+0x1fa/0x440
>> > [ 4605.504659]        [<ffffffff826948fd>]
>> > mutex_lock_interruptible_nested+0xdd/0x920
>> > [ 4605.513119]        [<ffffffff825242e9>] unix_bind+0x299/0xdf0
>> > [ 4605.519540]        [<ffffffff821f6918>] SYSC_bind+0x1d8/0x240
>> > [ 4605.525964]        [<ffffffff821fb6fe>] SyS_bind+0xe/0x10
>> > [ 4605.531998]        [<ffffffff81007b56>] do_syscall_64+0x1a6/0x500
>> > [ 4605.538811]        [<ffffffff8269e6bf>] return_from_SYSCALL_64+0x0/0x7a
>> > [ 4605.546203]
>> > [ 4605.546203] -> #1 (&type->i_mutex_dir_key#3/1){+.+.+.}:
>> > [ 4605.552292]        [<ffffffff812b4b5a>] lock_acquire+0x1fa/0x440
>> > [ 4605.559002]        [<ffffffff812a0f6e>] down_write_nested+0x5e/0xe0
>> > [ 4605.566008]        [<ffffffff816d1b55>] filename_create+0x155/0x470
>> > [ 4605.573013]        [<ffffffff816d403f>] SyS_mkdir+0xaf/0x1f0
>> > [ 4605.579339]        [<ffffffff8269e5fc>]
>> > entry_SYSCALL_64_fastpath+0x1f/0xbd
>> > [ 4605.587119]
>> > [ 4605.587119] -> #0 (sb_writers#8){.+.+.+}:
>> > [ 4605.591835]        [<ffffffff812b31f3>] __lock_acquire+0x3043/0x3dd0
>> > [ 4605.598935]        [<ffffffff812b4b5a>] lock_acquire+0x1fa/0x440
>> > [ 4605.605646]        [<ffffffff812a138f>] percpu_down_read+0x4f/0xa0
>> > [ 4605.612552]        [<ffffffff816a6d34>] __sb_start_write+0xb4/0xf0
>> > [ 4605.619459]        [<ffffffff817050d1>] mnt_want_write+0x41/0xb0
>> > [ 4605.626173]        [<ffffffffa0ce4be6>] ovl_want_write+0x76/0xa0
>> > [overlay]
>> > [ 4605.633860]        [<ffffffffa0cebd63>] ovl_create_object+0xa3/0x2d0
>> > [overlay]
>> > [ 4605.641942]        [<ffffffffa0cebfc1>] ovl_mknod+0x31/0x40 [overlay]
>> > [ 4605.649138]        [<ffffffff816c16db>] vfs_mknod+0x34b/0x560
>> > [ 4605.655570]        [<ffffffff8252451a>] unix_bind+0x4ca/0xdf0
>> > [ 4605.661991]        [<ffffffff821f6918>] SYSC_bind+0x1d8/0x240
>> > [ 4605.668412]        [<ffffffff821fb6fe>] SyS_bind+0xe/0x10
>> > [ 4605.674456]        [<ffffffff81007b56>] do_syscall_64+0x1a6/0x500
>> > [ 4605.681266]        [<ffffffff8269e6bf>] return_from_SYSCALL_64+0x0/0x7a
>> > [ 4605.688657]
>> > [ 4605.688657] other info that might help us debug this:
>> > [ 4605.688657]
>> > [ 4605.697590] Chain exists of:
>> > [ 4605.697590]   sb_writers#8 --> &type->i_mutex_dir_key#3/1 -->
>> > &u->readlock
>> > [ 4605.697590]
>> > [ 4605.707287]  Possible unsafe locking scenario:
>> > [ 4605.707287]
>> > [ 4605.713890]        CPU0                    CPU1
>> > [ 4605.718943]        ----                    ----
>> > [ 4605.723995]   lock(&u->readlock);
>> > [ 4605.727708]
>> > lock(&type->i_mutex_dir_key#3/1);
>> > [ 4605.735613]                                lock(&u->readlock);
>> > [ 4605.742146]   lock(sb_writers#8);
>> > [ 4605.745880]
>> > [ 4605.745880]  *** DEADLOCK ***
>> > [ 4605.745880]
>> > [ 4605.752486] 3 locks held by recvmsg01/42878:
>> > [ 4605.757247]  #0:  (sb_writers#13){.+.+.+}, at: [<ffffffff816a6d34>]
>> > __sb_start_write+0xb4/0xf0
>> > [ 4605.766930]  #1:  (&sb->s_type->i_mutex_key#16/1){+.+.+.}, at:
>> > [<ffffffff816d1b55>] filename_create+0x155/0x470
>> > [ 4605.778269]  #2:  (&u->readlock){+.+.+.}, at: [<ffffffff825242e9>]
>> > unix_bind+0x299/0xdf0
>> > [ 4605.787350]
>> > [ 4605.787350] stack backtrace:
>> > [ 4605.792213] CPU: 38 PID: 42878 Comm: recvmsg01 Not tainted 4.8.0-rc3+ #3
>> > [ 4605.799691] Hardware name: Intel Corporation S2600WTT/S2600WTT, BIOS
>> > GRNDSDP1.86B.0044.R00.1501191641 01/19/2015
>> > [ 4605.811047]  0000000000000000 000000009cc8af78 ffff8803c2c37770
>> > ffffffff81a63fb1
>> > [ 4605.819341]  ffffffff842a0590 ffffffff842c0ae0 ffff8803c2c377c0
>> > ffffffff812ac0d6
>> > [ 4605.827633]  ffffffff842a0590 ffff8804619f0d08 ffff8803c2c378e0
>> > ffff8804619f0d08
>> > [ 4605.835927] Call Trace:
>> > [ 4605.838656]  [<ffffffff81a63fb1>] dump_stack+0x85/0xc4
>> > [ 4605.844390]  [<ffffffff812ac0d6>] print_circular_bug+0x356/0x460
>> > [ 4605.851092]  [<ffffffff812b31f3>] __lock_acquire+0x3043/0x3dd0
>> > [ 4605.857602]  [<ffffffff81632710>] ? kfree+0x310/0x370
>> > [ 4605.863238]  [<ffffffff812b01b0>] ?
>> > debug_check_no_locks_freed+0x2c0/0x2c0
>> > [ 4605.870912]  [<ffffffff818be5f2>] ? avc_has_perm+0xa2/0x480
>> > [ 4605.877130]  [<ffffffff818be792>] ? avc_has_perm+0x242/0x480
>> > [ 4605.883443]  [<ffffffff818be7b1>] ? avc_has_perm+0x261/0x480
>> > [ 4605.889758]  [<ffffffff818be5f2>] ? avc_has_perm+0xa2/0x480
>> > [ 4605.895977]  [<ffffffff812b4b5a>] lock_acquire+0x1fa/0x440
>> > [ 4605.902098]  [<ffffffff816a6d34>] ? __sb_start_write+0xb4/0xf0
>> > [ 4605.908607]  [<ffffffff812a138f>] percpu_down_read+0x4f/0xa0
>> > [ 4605.914921]  [<ffffffff816a6d34>] ? __sb_start_write+0xb4/0xf0
>> > [ 4605.921429]  [<ffffffff816a6d34>] __sb_start_write+0xb4/0xf0
>> > [ 4605.927742]  [<ffffffff817050d1>] mnt_want_write+0x41/0xb0
>> > [ 4605.933875]  [<ffffffffa0ce4be6>] ovl_want_write+0x76/0xa0 [overlay]
>> > [ 4605.940967]  [<ffffffffa0cebd63>] ovl_create_object+0xa3/0x2d0 [overlay]
>> > [ 4605.948445]  [<ffffffffa0cebcc0>] ?
>> > ovl_create_or_link.part.3+0xc70/0xc70
>> > [overlay]
>> > [ 4605.956990]  [<ffffffff818c55c2>] ? selinux_inode_mknod+0x42/0x80
>> > [ 4605.963790]  [<ffffffffa0cebfc1>] ovl_mknod+0x31/0x40 [overlay]
>> > [ 4605.970395]  [<ffffffff816c16db>] vfs_mknod+0x34b/0x560
>> > [ 4605.976224]  [<ffffffff8252451a>] unix_bind+0x4ca/0xdf0
>> > [ 4605.982053]  [<ffffffff82524050>] ? unix_autobind.isra.24+0x600/0x600
>> > [ 4605.989244]  [<ffffffff815a7d86>] ? __might_fault+0xf6/0x1b0
>> > [ 4605.995550]  [<ffffffff821f6918>] SYSC_bind+0x1d8/0x240
>> > [ 4606.001381]  [<ffffffff821f6740>] ?
>> > move_addr_to_kernel.part.13+0xe0/0xe0
>> > [ 4606.008958]  [<ffffffff813d1af5>] ? __audit_syscall_entry+0x325/0x6f0
>> > [ 4606.016144]  [<ffffffff813d1af5>] ? __audit_syscall_entry+0x325/0x6f0
>> > [ 4606.023332]  [<ffffffff81007a02>] ? do_syscall_64+0x52/0x500
>> > [ 4606.029645]  [<ffffffff821fb6f0>] ? SyS_socketpair+0x470/0x470
>> > [ 4606.036154]  [<ffffffff821fb6fe>] SyS_bind+0xe/0x10
>> > [ 4606.041595]  [<ffffffff81007b56>] do_syscall_64+0x1a6/0x500
>> > [ 4606.047813]  [<ffffffff8100401a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
>> > [ 4606.055000]  [<ffffffff8269e6bf>] entry_SYSCALL64_slow_path+0x25/0x25
