From: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: unregister_netdevice: waiting for lo to become free. Usage count
	= 1
Date: Fri, 23 Jun 2017 15:00:41 -0700
Message-ID: <20170623220040.GA7946@gmail.com>
References: <CANaxB-xvAYaeb90HsO45vC3yQoGHaXnqQO_6SkRiRfo45R9y0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANaxB-xvAYaeb90HsO45vC3yQoGHaXnqQO_6SkRiRfo45R9y0A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2017 at 02:49:58PM -0700, Andrei Vagin wrote:
> Hello Everyone,
> 
> Today I've met a problem, when any attempts to create a new network
> namespace hang up.
> I see that one of previous namespaces can't be destroyed, because a
> usage count for one
> of its devices isn't zero. To reproduce the problem, you need to
> executed an attached program
> in a separate network namespace:
> 
> [root@fc24 net]# cat run.sh
> ip link set up dev lo
> ./tcp-bug
> [root@fc24 net]# unshare -n sh run.sh

If this program is executed in a new user, pid, mnt, and net namespaces,
the kernel reports a bug:

[root@fc24 net]# unshare -Urmfpn sh run.sh
[root@fc24 net]# unshare -Urmfpn sh run.sh
^C

[   30.592295] unregister_netdevice: waiting for lo to become free. Usage count = 1
[   37.958180] =============================================================================
[   37.963675] BUG kmalloc-1024 (Not tainted): Poison overwritten
[   37.966160] -----------------------------------------------------------------------------

[   37.969497] Disabling lock debugging due to kernel taint
[   37.971181] INFO: 0xffff93eef8bc3760-0xffff93eef8bc3760. First byte 0x38 instead of 0x6b
[   37.973066] INFO: Slab 0xffffe69fc1e2f000 objects=15 used=15 fp=0x          (null) flags=0x1fffc000008100
[   37.974902] INFO: Object 0xffff93eef8bc35a8 @offset=13736 fp=0xffff93eef8bc1088

[   37.976618] Redzone ffff93eef8bc35a0: bb bb bb bb bb bb bb bb                          ........
[   37.978355] Object ffff93eef8bc35a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.980239] Object ffff93eef8bc35b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.982209] Object ffff93eef8bc35c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.984072] Object ffff93eef8bc35d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.985729] Object ffff93eef8bc35e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.987273] Object ffff93eef8bc35f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.988930] Object ffff93eef8bc3608: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.990582] Object ffff93eef8bc3618: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.991921] Object ffff93eef8bc3628: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.993541] Object ffff93eef8bc3638: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.994922] Object ffff93eef8bc3648: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.996745] Object ffff93eef8bc3658: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.998135] Object ffff93eef8bc3668: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   37.999350] Object ffff93eef8bc3678: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.000656] Object ffff93eef8bc3688: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.001920] Object ffff93eef8bc3698: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.003142] Object ffff93eef8bc36a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.004549] Object ffff93eef8bc36b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.005925] Object ffff93eef8bc36c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.007296] Object ffff93eef8bc36d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.008852] Object ffff93eef8bc36e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.010375] Object ffff93eef8bc36f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.011686] Object ffff93eef8bc3708: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.012967] Object ffff93eef8bc3718: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.014244] Object ffff93eef8bc3728: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.015513] Object ffff93eef8bc3738: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.016796] Object ffff93eef8bc3748: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.018101] Object ffff93eef8bc3758: 6b 6b 6b 6b 6b 6b 6b 6b 38 6b 6b 6b 6b 6b 6b 6b  kkkkkkkk8kkkkkkk
[   38.019151] Object ffff93eef8bc3768: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.020349] Object ffff93eef8bc3778: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.021622] Object ffff93eef8bc3788: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.022931] Object ffff93eef8bc3798: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.024223] Object ffff93eef8bc37a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.025443] Object ffff93eef8bc37b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.026741] Object ffff93eef8bc37c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.028013] Object ffff93eef8bc37d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.029277] Object ffff93eef8bc37e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.030549] Object ffff93eef8bc37f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.031861] Object ffff93eef8bc3808: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.033624] Object ffff93eef8bc3818: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.035191] Object ffff93eef8bc3828: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.036293] Object ffff93eef8bc3838: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.037468] Object ffff93eef8bc3848: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.038772] Object ffff93eef8bc3858: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.040272] Object ffff93eef8bc3868: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.041721] Object ffff93eef8bc3878: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.043095] Object ffff93eef8bc3888: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.044513] Object ffff93eef8bc3898: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.045920] Object ffff93eef8bc38a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.047164] Object ffff93eef8bc38b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.048417] Object ffff93eef8bc38c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.049652] Object ffff93eef8bc38d8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.050974] Object ffff93eef8bc38e8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.052494] Object ffff93eef8bc38f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.053808] Object ffff93eef8bc3908: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.055004] Object ffff93eef8bc3918: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.056275] Object ffff93eef8bc3928: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.057578] Object ffff93eef8bc3938: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.058885] Object ffff93eef8bc3948: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.059926] Object ffff93eef8bc3958: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.060832] Object ffff93eef8bc3968: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.061992] Object ffff93eef8bc3978: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.063182] Object ffff93eef8bc3988: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   38.064431] Object ffff93eef8bc3998: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[   38.065729] Redzone ffff93eef8bc39a8: bb bb bb bb bb bb bb bb                          ........
[   38.066917] Padding ffff93eef8bc39b8: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
[   38.068062] CPU: 0 PID: 359 Comm: systemd-hostnam Tainted: G    B           4.12.0-rc6-00102-ga38371c-dirty #284
[   38.069374] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.fc25 04/01/2014
[   38.070525] Call Trace:
[   38.071085]  dump_stack+0x86/0xcf
[   38.071778]  print_trailer+0x144/0x220
[   38.072439]  check_bytes_and_report+0xc1/0x100
[   38.073074]  check_object+0x250/0x2a0
[   38.073569]  ? __alloc_skb+0x87/0x1d0
[   38.074109]  alloc_debug_processing+0x10a/0x1b0
[   38.074776]  ___slab_alloc+0x583/0x5f0
[   38.075440]  ? __alloc_skb+0x87/0x1d0
[   38.076230]  ? __alloc_skb+0x87/0x1d0
[   38.076779]  __slab_alloc+0x51/0x90
[   38.077218]  ? __slab_alloc+0x51/0x90
[   38.077824]  __kmalloc_node_track_caller+0xdf/0x3d0
[   38.078426]  ? __alloc_skb+0x87/0x1d0
[   38.078932]  __kmalloc_reserve.isra.34+0x31/0x90
[   38.079572]  ? __alloc_skb+0x5b/0x1d0
[   38.080048]  __alloc_skb+0x87/0x1d0
[   38.080480]  ? _raw_spin_unlock_irqrestore+0x5b/0x60
[   38.081357]  alloc_skb_with_frags+0x5a/0x1d0
[   38.081950]  ? lock_acquire+0xe3/0x1d0
[   38.082433]  sock_alloc_send_pskb+0x1f0/0x220
[   38.083005]  unix_dgram_sendmsg+0x17d/0x700
[   38.083547]  ? rw_copy_check_uvector+0x91/0x140
[   38.084120]  sock_sendmsg+0x38/0x50
[   38.084592]  ___sys_sendmsg+0x2d6/0x2f0
[   38.085284]  ? seccomp_run_filters+0x52/0xb0
[   38.085905]  ? __might_fault+0x85/0x90
[   38.086432]  ? __seccomp_filter+0x37/0x250
[   38.087000]  __sys_sendmsg+0x54/0x90
[   38.087485]  ? __sys_sendmsg+0x54/0x90
[   38.088018]  SyS_sendmsg+0x12/0x20
[   38.088472]  do_syscall_64+0x6c/0x1c0
[   38.089125]  entry_SYSCALL64_slow_path+0x25/0x25
[   38.089756] RIP: 0033:0x7f6870f24367
[   38.090226] RSP: 002b:00007ffecc05dfa8 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
[   38.091228] RAX: ffffffffffffffda RBX: 00007ffecc05dfb0 RCX: 00007f6870f24367
[   38.092191] RDX: 0000000000004000 RSI: 00007ffecc05dfb0 RDI: 0000000000000003
[   38.093188] RBP: 00007ffecc05e870 R08: 000000000000fefe R09: 0000000000000097
[   38.094116] R10: 0000000000000073 R11: 0000000000000246 R12: 00007ffecc05e030
[   38.094985] R13: 00007ffecc05ea60 R14: 0000000000000000 R15: 00007ffecc05dff0
[   38.096058] FIX kmalloc-1024: Restoring 0xffff93eef8bc3760-0xffff93eef8bc3760=0x6b

[   38.097845] FIX kmalloc-1024: Marking all objects used
[   40.840195] unregister_netdevice: waiting for lo to become free. Usage count = 1
[   51.080197] unregister_netdevice: waiting for lo to become free. Usage count = 1


> [root@fc24 net]# echo $?
> 0
> [root@fc24 ~]# cat /proc/40/stack
> [<ffffffffa211989e>] msleep+0x3e/0x50
> [<ffffffffa2786eea>] netdev_run_todo+0x12a/0x320
> [<ffffffffa279542e>] rtnl_unlock+0xe/0x10
> [<ffffffffa277d56a>] default_device_exit_batch+0x14a/0x170
> [<ffffffffa2772d12>] ops_exit_list.isra.6+0x52/0x60
> [<ffffffffa277402e>] cleanup_net+0x1ee/0x2f0
> [<ffffffffa20ac9f5>] process_one_work+0x205/0x620
> [<ffffffffa20ace5e>] worker_thread+0x4e/0x3b0
> [<ffffffffa20b4344>] kthread+0x114/0x150
> [<ffffffffa29619fa>] ret_from_fork+0x2a/0x40
> [<ffffffffffffffff>] 0xffffffffffffffff
> [root@fc24 ~]# dmesg | tail
> [   97.071533] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> [   97.079561] systemd-journald[180]: Sent WATCHDOG=1 notification.
> [  107.319260] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> [  117.567180] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> [  127.807401] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> [  138.055324] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> [  148.303308] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> [  158.559118] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> [  168.807423] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> [  179.055590] unregister_netdevice: waiting for lo to become free.
> Usage count = 1
> 
> This program creates a server tcp socket, then it creates a pair of
> connected tcp sockets
> and then it does actions which trigger this problem. It calls
> connect() with AF_UNSPEC
> for one of connected sockets and then call connect() with the address
> of the server socket.
> 
> 
> Thanks,
> Andrei

> #include <string.h>
> #include <sys/socket.h>
> #include <arpa/inet.h>  /* for sockaddr_in and inet_ntoa() */
> 
> #include <stdio.h>
> #include <sys/types.h>
> #include <unistd.h>
> #include <string.h>
> #include <errno.h>
> #include <stdlib.h>
> #include <signal.h>
> #include <netinet/tcp.h>
> #include <arpa/inet.h>
> 
> 
> #define pr_err(fmt, ...)                                           \
>         printf("Error: " fmt, ##__VA_ARGS__)
> 
> #define pr_perror(fmt, ...)                                             \
>         pr_err(fmt ": %s\n", ##__VA_ARGS__, strerror(errno))
> 
> #define fail(fmt, ...)                                             \
>         pr_err(fmt ": %s\n", ##__VA_ARGS__, strerror(errno))
> 
> union sockaddr_inet {
> 	struct sockaddr addr;
> 	struct sockaddr_in v4;
> 	struct sockaddr_in6 v6;
> };
> 
> int tcp_init_server(int family, int *port)
> {
> 	union sockaddr_inet addr;
> 	int sock;
> 	int yes = 1, ret;
> 
> 	memset(&addr,0,sizeof(addr));
> 	if (family == AF_INET) {
> 		addr.v4.sin_family = family;
> 		inet_pton(family, "0.0.0.0", &(addr.v4.sin_addr));
> 	} else if (family == AF_INET6){
> 		addr.v6.sin6_family = family;
> 		inet_pton(family, "::0", &(addr.v6.sin6_addr));
> 	} else
> 		return -1;
> 
> 	sock = socket(family, SOCK_STREAM, IPPROTO_TCP);
> 	if (sock == -1) {
> 		pr_perror("socket() failed");
> 		return -1;
> 	}
> 
> 	if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1 ) {
> 		pr_perror("setsockopt() error");
> 		return -1;
> 	}
> 
> 	while (1) {
> 		if (family == AF_INET)
> 			addr.v4.sin_port = htons(*port);
> 		else if (family == AF_INET6)
> 			addr.v6.sin6_port = htons(*port);
> 
> 		ret = bind(sock, (struct sockaddr *) &addr, sizeof(addr));
> 
> 		/* criu doesn't restore sock opts, so we need this hack */
> 		if (ret == -1 && errno == EADDRINUSE) {
> 			(*port)++;
> 			continue;
> 		}
> 		break;
> 	}
> 
> 	if (ret == -1) {
> 		pr_perror("bind() failed");
> 		return -1;
> 	}
> 
> 	if (listen(sock, 1) == -1) {
> 		pr_perror("listen() failed");
> 		return -1;
> 	}
> 	return sock;
> }
> 
> int tcp_accept_server(int sock)
> {
> 	struct sockaddr_in maddr;
> 	int sock2;
> 	socklen_t addrlen;
> #ifdef DEBUG
> 	test_msg ("Waiting for connection..........\n");
> #endif
> 	addrlen = sizeof(maddr);
> 	sock2 = accept(sock,(struct sockaddr *) &maddr, &addrlen);
> 
> 	if (sock2 == -1) {
> 		pr_perror("accept() failed");
> 		return -1;
> 	}
> 
> #ifdef DEBUG
> 	test_msg ("Connection!!\n");
> #endif
> 	return sock2;
> }
> 
> int __tcp_init_client(int sock, int family, char *servIP, unsigned short servPort)
> {
> 	union sockaddr_inet servAddr;
> 
> 	/* Construct the server address structure */
> 	memset(&servAddr, 0, sizeof(servAddr));
> 	if (family == AF_INET) {
> 		servAddr.v4.sin_family      = AF_INET;
> 		servAddr.v4.sin_port        = htons(servPort);
> 		inet_pton(AF_INET, servIP, &servAddr.v4.sin_addr);
> 	} else {
> 		servAddr.v6.sin6_family      = AF_INET6;
> 		servAddr.v6.sin6_port        = htons(servPort);
> 		inet_pton(AF_INET6, servIP, &servAddr.v6.sin6_addr);
> 	}
> 	if (connect(sock, (struct sockaddr *) &servAddr, sizeof(servAddr)) < 0) {
> 		pr_perror("can't connect to server");
> 		return -1;
> 	}
> 	return sock;
> }
> 
> int tcp_init_client(int family, char *servIP, unsigned short servPort)
> {
> 	int sock;
> 
> 	if ((sock = socket(family, SOCK_STREAM, IPPROTO_TCP)) < 0) {
> 		pr_perror("can't create socket");
> 		return -1;
> 	}
> 	return __tcp_init_client(sock, family, servIP, servPort);
> }
> 
> #ifdef ZDTM_IPV6
> #define ZDTM_FAMILY AF_INET6
> #else
> #define ZDTM_FAMILY AF_INET
> #endif
> static int port = 8880;
> 
> int main(int argc, char **argv)
> {
> 	int fd, fd_s, clt, sk;
> 	union sockaddr_inet src_addr, dst_addr, addr;
> 	socklen_t aux;
> 	char c = 5;
> 
> 	sk = socket(ZDTM_FAMILY, SOCK_STREAM, 0);
> 	if (sk < 0) {
> 		pr_perror("socket");
> 		return 1;
> 	}
> 
> 	if ((fd_s = tcp_init_server(ZDTM_FAMILY, &port)) < 0) {
> 		pr_err("initializing server failed\n");
> 		return 1;
> 	}
> 
> 	clt = tcp_init_client(ZDTM_FAMILY, "localhost", port);
> 	if (clt < 0)
> 		return 1;
> 
> 	/*
> 	 * parent is server of TCP connection
> 	 */
> 	fd = tcp_accept_server(fd_s);
> 	if (fd < 0) {
> 		pr_err("can't accept client connection\n");
> 		return 1;
> 	}
> 
> 	shutdown(clt, SHUT_WR);
> 
> 	{
> 		union sockaddr_inet addr;
> 		int fd1;
> 
> 		memset(&addr, 0, sizeof(addr));
> 		addr.v4.sin_family      = AF_UNSPEC;
> 		if (connect(fd, (struct sockaddr *) &addr, sizeof(addr)))
> 			return 1;
> 
> 		if (__tcp_init_client(fd, ZDTM_FAMILY, "localhost", port) < 0)
> 			return 1;
> 
> 		return 0;
> 		fd1 = tcp_accept_server(fd_s);
> 		if (fd1 < 0) {
> 			pr_err("can't accept client connection\n");
> 			return 1;
> 		}
> 	}
> 
> 	return 0;
> }
