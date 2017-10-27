From: ChunYu Wang <chunwang@redhat.com>
Subject: Re: WARNING in refcount_sub_and_test
Date: Fri, 27 Oct 2017 10:30:05 +0800
Message-ID: <CAOm2TWzdKiHUbGLMphzmPdX8bK9gngnSiahgXs3pto8es0FRWQ@mail.gmail.com>
References: <001a11441d867b940f055c4c0b40@google.com> <CAOm2TWwoJhsT==euSyC0EDCbWXzTVWBBmvbX8HgmdjxvW0wVbw@mail.gmail.com>
 <CACT4Y+bWsMoMOY6A5f0RLqRBGKwmELCrQUJhxPzkpHasdrn=5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: syzbot
        <bot+a004c8dcbae7c160bf1bbd6e6af2e9cf4fa54f84@syzkaller.appspotmail.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        syzkaller-bugs@googlegroups.com,
        Vladislav Yasevich <vyasevich@gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:46274 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751483AbdJ0CaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 22:30:06 -0400
Received: by mail-qk0-f196.google.com with SMTP id k123so6765592qke.3
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 19:30:06 -0700 (PDT)
In-Reply-To: <CACT4Y+bWsMoMOY6A5f0RLqRBGKwmELCrQUJhxPzkpHasdrn=5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe I have just made some mistakes on understanding the reproduction
methods, will try it again.

Thanks,
- ChunYu

On Thu, Oct 26, 2017 at 10:49 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Thu, Oct 26, 2017 at 10:53 AM, ChunYu Wang <chunwang@redhat.com> wrote:
>> Hi all,
>>
>> I am failed to reproduce it on target kernel with the reproducer file
>> or replaying the target syzkaller description log file, do I made
>> something wrong or there exists more subjects then the line in
>> repro.txt:
>>
>> #{Threaded:true Collide:true Repeat:false Procs:1 Sandbox:namespace
>> Fault:false FaultCall:-1 FaultNth:0 EnableTun:false UseTmpDir:true
>> HandleSegv:false WaitRepeat:false Debug:false Repro:false}
>
>
> Hi ChunYu,
>
> I've just re-tested the C repro and was able to trigger the bug in a second.
> I've checked out 49ca1943a7adb429b11b8e05d81bc821694b76c7, copied the
> provided config, run make olddefconfig, built with gcc-7 (you can get
> the exact one here
> https://storage.googleapis.com/syzkaller/gcc-7.tar.gz). Then run in
> qemu (most of the flags are probably irrelevant):
>
> qemu-system-x86_64 -hda wheezy.img -net
> user,host=10.0.2.10,hostfwd=tcp::10022-:22 -net nic -nographic -kernel
> arch/x86/boot/bzImage -append "kvm-intel.nested=1
> kvm-intel.unrestricted_guest=1 kvm-intel.ept=1
> kvm-intel.flexpriority=1 kvm-intel.vpid=1
> kvm-intel.emulate_invalid_guest_state=1 kvm-intel.eptad=1
> kvm-intel.enable_shadow_vmcs=1 kvm-intel.pml=1
> kvm-intel.enable_apicv=1 console=ttyS0 root=/dev/sda
> earlyprintk=serial slub_debug=UZ vsyscall=native rodata=n oops=panic
> panic_on_warn=1 panic=86400" -enable-kvm -pidfile vm_pid -m 2G -smp 4
> -cpu host -usb -usbdevice mouse -usbdevice tablet -soundhw all
>
> And running the provided C program instantly spewed the following.
>
> Is there anything you did differently? I would like to understand
> common reasons why syzbot reproducers don't work and outline them
> here:
> https://github.com/google/syzkaller/blob/master/docs/syzbot.md
>
> Thanks
>
>
> [  588.444300] refcount_t: underflow; use-after-free.
> [  588.445812] ------------[ cut here ]------------
> [  588.447026] WARNING: CPU: 1 PID: 3086 at lib/refcount.c:186
> refcount_sub_and_test+0x167/0x1b0
> [  588.449082] Kernel panic - not syncing: panic_on_warn set ...
> [  588.449082]
> [  588.450737] CPU: 1 PID: 3086 Comm: a.out Not tainted 4.14.0-rc5+ #9
> [  588.452160] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS Bochs 01/01/2011
> [  588.454059] Call Trace:
> [  588.454658]  dump_stack+0x194/0x257
> [  588.455538]  ? arch_local_irq_restore+0x53/0x53
> [  588.456630]  panic+0x1e4/0x417
> [  588.457367]  ? __warn+0x1d9/0x1d9
> [  588.458171]  ? show_regs_print_info+0x65/0x65
> [  588.459234]  ? refcount_sub_and_test+0x167/0x1b0
> [  588.460262]  __warn+0x1c4/0x1d9
> [  588.460958]  ? refcount_sub_and_test+0x167/0x1b0
> [  588.461965]  report_bug+0x211/0x2d0
> [  588.462756]  fixup_bug+0x40/0x90
> [  588.463597]  do_trap+0x260/0x390
> [  588.464304]  do_error_trap+0x120/0x390
> [  588.465105]  ? vprintk_emit+0x49b/0x590
> [  588.465929]  ? do_trap+0x390/0x390
> [  588.466661]  ? refcount_sub_and_test+0x167/0x1b0
> [  588.467646]  ? vprintk_emit+0x3ea/0x590
> [  588.468475]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [  588.469482]  do_invalid_op+0x1b/0x20
> [  588.470262]  invalid_op+0x18/0x20
> [  588.470988] RIP: 0010:refcount_sub_and_test+0x167/0x1b0
> [  588.472080] RSP: 0018:ffff88006550e9c8 EFLAGS: 00010282
> [  588.473224] RAX: 0000000000000026 RBX: 0000000000000001 RCX: 0000000000000000
> [  588.474643] RDX: 0000000000000026 RSI: 1ffff1000caa1cf9 RDI: ffffed000caa1d2d
> [  588.476091] RBP: ffff88006550ea58 R08: 0000000000000000 R09: 1ffff1000caa1ccb
> [  588.477520] R10: ffff88006550e7f8 R11: ffffffff85b2cb78 R12: 1ffff1000caa1d3a
> [  588.478967] R13: 00000000ffffff01 R14: 0000000000000100 R15: ffff88006a7f4a7c
> [  588.480413]  ? refcount_sub_and_test+0x167/0x1b0
> [  588.481337]  ? refcount_inc+0x50/0x50
> [  588.482081]  ? __sctp_outq_teardown+0xa5b/0x1230
> [  588.483004]  ? sctp_association_free+0x2d0/0x930
> [  588.484291]  ? sctp_do_sm+0x271b/0x6a30
> [  588.485247]  ? sctp_primitive_SHUTDOWN+0xa0/0xd0
> [  588.486295]  ? sctp_close+0x3c6/0x980
> [  588.487058]  ? inet_release+0xed/0x1c0
> [  588.488370]  ? sock_release+0x8d/0x1e0
> [  588.489080]  ? sock_close+0x16/0x20
> [  588.489759]  sctp_wfree+0x183/0x620
> [  588.490430]  ? entry_SYSCALL_64_fastpath+0xbc/0xbe
> [  588.491323]  ? __sctp_write_space+0x910/0x910
> [  588.492177]  skb_release_head_state+0x124/0x200
> [  588.493078]  skb_release_all+0x15/0x60
> [  588.493938]  consume_skb+0x153/0x490
> [  588.494605]  ? sctp_chunk_put+0x99/0x420
> [  588.495388]  ? alloc_skb_with_frags+0x750/0x750
> [  588.496119]  ? sctp_chunk_hold+0x20/0x20
> [  588.496757]  ? sctp_sched_dequeue_common+0x2aa/0x5d0
> [  588.497554]  ? refcount_sub_and_test+0x115/0x1b0
> [  588.498296]  ? refcount_inc+0x50/0x50
> [  588.498888]  ? trace_hardirqs_off+0xd/0x10
> [  588.499567]  ? quarantine_put+0xeb/0x190
> [  588.500215]  sctp_chunk_put+0x29c/0x420
> [  588.500836]  ? sctp_chunk_hold+0x20/0x20
> [  588.501491]  ? sctp_transport_dst_confirm+0x50/0x50
> [  588.502266]  ? sctp_sched_fcfs_dequeue+0x198/0x290
> [  588.503027]  ? sctp_sched_dequeue_common+0x5d0/0x5d0
> [  588.504001]  sctp_chunk_free+0x53/0x60
> [  588.504692]  __sctp_outq_teardown+0xa5b/0x1230
> [  588.505493]  ? sctp_inq_set_th_handler+0x1b0/0x1b0
> [  588.506322]  ? debug_check_no_locks_freed+0x3c0/0x3c0
> [  588.507264]  ? debug_check_no_locks_freed+0x3c0/0x3c0
> [  588.508089]  ? check_preempt_wakeup+0x1320/0x1320
> [  588.508804]  ? debug_check_no_locks_freed+0x3c0/0x3c0
> [  588.509632]  ? default_wake_function+0x30/0x50
> [  588.510368]  ? autoremove_wake_function+0x78/0x350
> [  588.511101]  ? lock_acquire+0x1d5/0x580
> [  588.511686]  ? lock_acquire+0x1d5/0x580
> [  588.512299]  ? finish_wait+0x490/0x490
> [  588.512888]  ? lock_acquire+0x1d5/0x580
> [  588.513583]  ? lock_acquire+0x1d5/0x580
> [  588.514178]  ? lock_acquire+0x1d5/0x580
> [  588.514774]  ? __wake_up_common_lock+0x1c2/0x310
> [  588.515526]  ? lock_acquire+0x1d5/0x580
> [  588.516121]  ? sock_def_wakeup+0x1f9/0x350
> [  588.516752]  ? lock_downgrade+0x990/0x990
> [  588.517385]  ? lock_release+0xa40/0xa40
> [  588.517982]  ? trace_raw_output_tick_stop+0x130/0x130
> [  588.518766]  sctp_outq_free+0x15/0x20
> [  588.519391]  sctp_association_free+0x2d0/0x930
> [  588.520136]  ? sctp_asconf_queue_teardown+0x700/0x700
> [  588.521000]  ? sock_def_wakeup+0x222/0x350
> [  588.521702]  ? sk_dst_check+0x560/0x560
> [  588.522387]  ? bpf_prog_kallsyms_find+0xbd/0x440
> [  588.523228]  sctp_do_sm+0x271b/0x6a30
> [  588.523880]  ? sctp_do_8_2_transport_strike.isra.16+0x8a0/0x8a0
> [  588.524728]  ? do_raw_spin_trylock+0x190/0x190
> [  588.525378]  ? SyS_setgroups+0x250/0x250
> [  588.525951]  ? debug_check_no_locks_freed+0x3c0/0x3c0
> [  588.526690]  ? debug_check_no_locks_freed+0x3c0/0x3c0
> [  588.527857]  ? lock_acquire+0x1d5/0x580
> [  588.528737]  ? lock_acquire+0x1d5/0x580
> [  588.529615]  ? skb_dequeue+0x12a/0x180
> [  588.530476]  ? lock_downgrade+0x990/0x990
> [  588.531445]  ? do_raw_spin_trylock+0x190/0x190
> [  588.532466]  ? lock_release+0xa40/0xa40
> [  588.533432]  ? trace_hardirqs_on+0xd/0x10
> [  588.534373]  sctp_primitive_SHUTDOWN+0xa0/0xd0
> [  588.535412]  sctp_close+0x3c6/0x980
> [  588.536208]  ? sctp_apply_peer_addr_params+0xf30/0xf30
> [  588.537322]  ? debug_check_no_locks_freed+0x3c0/0x3c0
> [  588.538409]  ? lock_acquire+0x1d5/0x580
> [  588.539262]  ? locks_remove_file+0x3fa/0x5a0
> [  588.540192]  ? cmp_ex_search+0x76/0xa0
> [  588.541006]  ? fcntl_setlk+0x10c0/0x10c0
> [  588.541858]  ? bsearch+0x83/0xa0
> [  588.542563]  ? __fsnotify_parent+0xb4/0x3a0
> [  588.543572]  ? ip_mc_drop_socket+0x1ce/0x230
> [  588.544336]  inet_release+0xed/0x1c0
> [  588.544975]  sock_release+0x8d/0x1e0
> [  588.545618]  ? sock_release+0x1e0/0x1e0
> [  588.546300]  sock_close+0x16/0x20
> [  588.546908]  __fput+0x327/0x7e0
> [  588.547495]  ? fput+0x140/0x140
> [  588.548067]  ? __bad_area_nosemaphore+0x1f4/0x3e0
> [  588.548897]  ____fput+0x15/0x20
> [  588.549461]  task_work_run+0x199/0x270
> [  588.550127]  ? task_work_cancel+0x210/0x210
> [  588.550859]  ? __do_page_fault+0x3d6/0xd60
> [  588.551602]  get_signal+0x1343/0x16d0
> [  588.552253]  ? mm_fault_error+0x2c0/0x2c0
> [  588.552964]  ? ptrace_notify+0x130/0x130
> [  588.553746]  ? __do_page_fault+0xd60/0xd60
> [  588.554473]  ? do_page_fault+0xee/0x720
> [  588.555168]  ? lock_downgrade+0x990/0x990
> [  588.555896]  ? __do_page_fault+0xd60/0xd60
> [  588.556634]  ? do_raw_spin_trylock+0x190/0x190
> [  588.557411]  ? lock_acquire+0x1d5/0x580
> [  588.558091]  ? lock_acquire+0x1d5/0x580
> [  588.558777]  do_signal+0x94/0x1ee0
> [  588.559400]  ? lock_acquire+0x1d5/0x580
> [  588.560070]  ? lock_acquire+0x1d5/0x580
> [  588.560721]  ? put_unused_fd+0x62/0x70
> [  588.561360]  ? lock_downgrade+0x990/0x990
> [  588.562044]  ? setup_sigcontext+0x7d0/0x7d0
> [  588.562755]  ? do_raw_spin_trylock+0x190/0x190
> [  588.563526]  ? task_work_add+0x10e/0x1b0
> [  588.564254]  ? __put_unused_fd+0x183/0x250
> [  588.564943]  ? alloc_fdtable+0x280/0x280
> [  588.565605]  ? cpumask_weight.constprop.3+0x45/0x45
> [  588.566421]  ? _copy_to_user+0xa2/0xc0
> [  588.567081]  ? _raw_spin_unlock+0x22/0x30
> [  588.567755]  ? fput+0xd2/0x140
> [  588.568273]  ? SYSC_accept4+0x4ec/0x850
> [  588.568915]  ? kernel_accept+0x2f0/0x2f0
> [  588.569575]  exit_to_usermode_loop+0x214/0x310
> [  588.570318]  ? trace_event_raw_event_sys_exit+0x260/0x260
> [  588.571219]  ? __do_page_fault+0xd60/0xd60
> [  588.571911]  syscall_return_slowpath+0x42f/0x510
> [  588.572675]  ? finish_task_switch+0x1aa/0x740
> [  588.573397]  ? prepare_exit_to_usermode+0x2d0/0x2d0
> [  588.574297]  ? prepare_exit_to_usermode+0x1a0/0x2d0
> [  588.575119]  ? perf_trace_sys_enter+0xc20/0xc20
> [  588.575883]  ? trace_hardirqs_on_thunk+0x1a/0x1c
> [  588.576656]  entry_SYSCALL_64_fastpath+0xbc/0xbe
> [  588.577445] RIP: 0033:0x44cfe9
> [  588.577963] RSP: 002b:00007ff97ff43db8 EFLAGS: 00000293 ORIG_RAX:
> 0000000000000120
> [  588.579224] RAX: fffffffffffffff2 RBX: 0000000000000000 RCX: 000000000044cfe9
> [  588.580397] RDX: 0000000020137ffc RSI: 0000000020b53ff0 RDI: 0000000000000003
> [  588.581557] RBP: 00007ff97ff43dd0 R08: 00007ff97ff44700 R09: 0000000000000000
> [  588.582718] R10: 0000000000080000 R11: 0000000000000293 R12: 0000000000000000
> [  588.583964] R13: 0000000000000000 R14: 00007ff97ff449c0 R15: 00007ff97ff44700
> [  588.585673] Kernel Offset: disabled
> [  588.586263] Rebooting in 86400 seconds..
