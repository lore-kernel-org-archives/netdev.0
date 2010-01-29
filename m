From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Thu, 28 Jan 2010 20:11:32 -0500
Message-ID: <1264727492.2793.207.camel@tonnant>
References: <1264657559.2793.103.camel@tonnant>
	 <1264658364.2793.105.camel@tonnant>  <4B6180D1.6050609@trash.net>
	 <1264720891.2793.205.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264720891.2793.205.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I turned on a few more debug options (eventually, I guess through
timing/sheer chance, it becomes less likely to trigger). With lockdep,
kobject, and spinlock debugging on, all I get in addition is a lockdep
warning from libvirtd:

virbr0: starting userspace STP failed, starting kernel STP

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.33-rc5 #1
-------------------------------------------------------
libvirtd/2908 is trying to acquire lock:
 (s_active){++++.+}, at: [<ffffffff81168c6e>] sysfs_addrm_finish
+0x36/0x55

but task is already holding lock:
 (rtnl_mutex){+.+.+.}, at: [<ffffffff813b618d>] rtnl_lock+0x17/0x19

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #4 (rtnl_mutex){+.+.+.}:
       [<ffffffff8107b8a2>] __lock_acquire+0xb71/0xd19
       [<ffffffff8107bb26>] lock_acquire+0xdc/0x102
       [<ffffffff8143bdae>] __mutex_lock_common+0x4b/0x392
       [<ffffffff8143c1b9>] mutex_lock_nested+0x3e/0x43
       [<ffffffff813b618d>] rtnl_lock+0x17/0x19
       [<ffffffff813b7974>] linkwatch_event+0xe/0x2c
       [<ffffffff810650c8>] worker_thread+0x266/0x35f
       [<ffffffff8106913c>] kthread+0x9a/0xa2
       [<ffffffff8100aa64>] kernel_thread_helper+0x4/0x10

-> #3 ((linkwatch_work).work){+.+.+.}:
       [<ffffffff8107b8a2>] __lock_acquire+0xb71/0xd19
       [<ffffffff8107bb26>] lock_acquire+0xdc/0x102
       [<ffffffff810650bf>] worker_thread+0x25d/0x35f
       [<ffffffff8106913c>] kthread+0x9a/0xa2
       [<ffffffff8100aa64>] kernel_thread_helper+0x4/0x10

-> #2 (events){+.+.+.}:
       [<ffffffff8107b8a2>] __lock_acquire+0xb71/0xd19
       [<ffffffff8107bb26>] lock_acquire+0xdc/0x102
       [<ffffffff81065a01>] flush_workqueue+0x63/0xb1
       [<ffffffff81065a64>] flush_scheduled_work+0x15/0x17
       [<ffffffff813685ff>] do_md_stop+0x2c0/0x508
       [<ffffffff8136ab07>] md_ioctl+0x92f/0xf49
       [<ffffffff8120afcd>] __blkdev_driver_ioctl+0x39/0xa3
       [<ffffffff8120b968>] blkdev_ioctl+0x67d/0x6b1
       [<ffffffff811364e8>] block_ioctl+0x37/0x3b
       [<ffffffff8111d8a4>] vfs_ioctl+0x32/0xa6
       [<ffffffff8111de24>] do_vfs_ioctl+0x490/0x4d6
       [<ffffffff8111dec0>] sys_ioctl+0x56/0x79
       [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b

-> #1 (&new->reconfig_mutex){+.+.+.}:
       [<ffffffff8107b8a2>] __lock_acquire+0xb71/0xd19
       [<ffffffff8107bb26>] lock_acquire+0xdc/0x102
       [<ffffffff8143bdae>] __mutex_lock_common+0x4b/0x392
       [<ffffffff8143c133>] mutex_lock_interruptible_nested+0x3e/0x43
       [<ffffffff81362d1e>] mddev_lock+0x17/0x19
       [<ffffffff81362ff5>] md_attr_show+0x32/0x5d
       [<ffffffff81167af4>] sysfs_read_file+0xbd/0x17f
       [<ffffffff81110ff5>] vfs_read+0xab/0x108
       [<ffffffff81111112>] sys_read+0x4a/0x6e
       [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b

-> #0 (s_active){++++.+}:
       [<ffffffff8107b74c>] __lock_acquire+0xa1b/0xd19
       [<ffffffff8107bb26>] lock_acquire+0xdc/0x102
       [<ffffffff8116867b>] sysfs_deactivate+0x9a/0x103
       [<ffffffff81168c6e>] sysfs_addrm_finish+0x36/0x55
       [<ffffffff81168cc3>] remove_dir+0x36/0x3e
       [<ffffffff81168d78>] sysfs_remove_dir+0x9d/0xbe
       [<ffffffff8121714b>] kobject_del+0x16/0x37
       [<ffffffff81217233>] kobject_release+0xc7/0x1d9
       [<ffffffff81218319>] kref_put+0x43/0x4d
       [<ffffffff812170c6>] kobject_put+0x47/0x4b
       [<ffffffffa02f6ec5>] br_sysfs_delbr+0x21/0x43 [bridge]
       [<ffffffffa02f30d5>] del_br+0x5a/0x6f [bridge]
       [<ffffffffa02f349e>] br_del_bridge+0x59/0x67 [bridge]
       [<ffffffffa02f4740>] br_ioctl_deviceless_stub+0x1fb/0x21b
[bridge]
       [<ffffffff8139a7d5>] sock_ioctl+0x141/0x20d
       [<ffffffff8111d8a4>] vfs_ioctl+0x32/0xa6
       [<ffffffff8111de24>] do_vfs_ioctl+0x490/0x4d6
       [<ffffffff8111dec0>] sys_ioctl+0x56/0x79
       [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b

other info that might help us debug this:

2 locks held by libvirtd/2908:
 #0:  (br_ioctl_mutex){+.+.+.}, at: [<ffffffff8139a7ba>] sock_ioctl
+0x126/0x20d
 #1:  (rtnl_mutex){+.+.+.}, at: [<ffffffff813b618d>] rtnl_lock+0x17/0x19

stack backtrace:
Pid: 2908, comm: libvirtd Not tainted 2.6.33-rc5 #1
Call Trace:
 [<ffffffff8107a90f>] print_circular_bug+0xa8/0xb6
 [<ffffffff8107b74c>] __lock_acquire+0xa1b/0xd19
 [<ffffffff8107bb26>] lock_acquire+0xdc/0x102
 [<ffffffff81168c6e>] ? sysfs_addrm_finish+0x36/0x55
 [<ffffffff810795fe>] ? lockdep_init_map+0x9e/0x113
 [<ffffffff8116867b>] sysfs_deactivate+0x9a/0x103
 [<ffffffff81168c6e>] ? sysfs_addrm_finish+0x36/0x55
 [<ffffffff81078d72>] ? trace_hardirqs_off+0xd/0xf
 [<ffffffff8143bbcd>] ? __mutex_unlock_slowpath+0x120/0x132
 [<ffffffff81168c6e>] sysfs_addrm_finish+0x36/0x55
 [<ffffffff81168cc3>] remove_dir+0x36/0x3e
 [<ffffffff81168d78>] sysfs_remove_dir+0x9d/0xbe
 [<ffffffff8121714b>] kobject_del+0x16/0x37
 [<ffffffff81217233>] kobject_release+0xc7/0x1d9
 [<ffffffff8121716c>] ? kobject_release+0x0/0x1d9
 [<ffffffff81218319>] kref_put+0x43/0x4d
 [<ffffffff812170c6>] kobject_put+0x47/0x4b
 [<ffffffff8105b24c>] ? del_timer_sync+0x0/0xa6
 [<ffffffffa02f6ec5>] br_sysfs_delbr+0x21/0x43 [bridge]
 [<ffffffffa02f30d5>] del_br+0x5a/0x6f [bridge]
 [<ffffffffa02f349e>] br_del_bridge+0x59/0x67 [bridge]
 [<ffffffffa02f4740>] br_ioctl_deviceless_stub+0x1fb/0x21b [bridge]
 [<ffffffff8139a7d5>] sock_ioctl+0x141/0x20d
 [<ffffffff8111d8a4>] vfs_ioctl+0x32/0xa6
 [<ffffffff8111de24>] do_vfs_ioctl+0x490/0x4d6
 [<ffffffff8111dec0>] sys_ioctl+0x56/0x79
 [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
device vnet0 entered promiscuous mode
br0: port 2(vnet0) entering forwarding state
device vnet1 entered promiscuous mode
br0: port 3(vnet1) entering forwarding state
SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
SELinux: initialized (dev proc, type proc), uses genfs_contexts
SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
lo: Disabled Privacy Extensions
SELinux: initialized (dev proc, type proc), uses genfs_contexts
vnet0: no IPv6 routers present
vnet1: no IPv6 routers present
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:16:52:54:00:75:4b:ad:86:dd
SRC=0000:0000:0000:0000:0000:0000:0000:0000
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:16:52:54:00:75:4b:ad:86:dd
SRC=0000:0000:0000:0000:0000:0000:0000:0000
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:ff:75:4b:ad:52:54:00:75:4b:ad:86:dd
SRC=0000:0000:0000:0000:0000:0000:0000:0000
DST=ff02:0000:0000:0000:0000:0001:ff75:4bad LEN=64 TC=0 HOPLIMIT=255
FLOWLBL=0 PROTO=ICMPv6 TYPE=135 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:02:52:54:00:75:4b:ad:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe75:4bad
DST=ff02:0000:0000:0000:0000:0000:0000:0002 LEN=56 TC=0 HOPLIMIT=255
FLOWLBL=0 PROTO=ICMPv6 TYPE=133 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:02:52:54:00:75:4b:ad:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe75:4bad
DST=ff02:0000:0000:0000:0000:0000:0000:0002 LEN=56 TC=0 HOPLIMIT=255
FLOWLBL=0 PROTO=ICMPv6 TYPE=133 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:02:52:54:00:75:4b:ad:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe75:4bad
DST=ff02:0000:0000:0000:0000:0000:0000:0002 LEN=56 TC=0 HOPLIMIT=255
FLOWLBL=0 PROTO=ICMPv6 TYPE=133 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:16:52:54:00:75:4b:ad:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe75:4bad
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:16:52:54:00:75:4b:ad:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe75:4bad
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:16:52:54:00:4c:c6:65:86:dd
SRC=0000:0000:0000:0000:0000:0000:0000:0000
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:ff:4c:c6:65:52:54:00:4c:c6:65:86:dd
SRC=0000:0000:0000:0000:0000:0000:0000:0000
DST=ff02:0000:0000:0000:0000:0001:ff4c:c665 LEN=64 TC=0 HOPLIMIT=255
FLOWLBL=0 PROTO=ICMPv6 TYPE=135 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:02:52:54:00:4c:c6:65:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe4c:c665
DST=ff02:0000:0000:0000:0000:0000:0000:0002 LEN=56 TC=0 HOPLIMIT=255
FLOWLBL=0 PROTO=ICMPv6 TYPE=133 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:16:52:54:00:4c:c6:65:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe4c:c665
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:02:52:54:00:4c:c6:65:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe4c:c665
DST=ff02:0000:0000:0000:0000:0000:0000:0002 LEN=56 TC=0 HOPLIMIT=255
FLOWLBL=0 PROTO=ICMPv6 TYPE=133 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:02:52:54:00:4c:c6:65:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe4c:c665
DST=ff02:0000:0000:0000:0000:0000:0000:0002 LEN=56 TC=0 HOPLIMIT=255
FLOWLBL=0 PROTO=ICMPv6 TYPE=133 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:16:52:54:00:4c:c6:65:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe4c:c665
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0 
TRACE: raw:PREROUTING:policy:2 IN=br0 OUT=
MAC=33:33:00:00:00:16:52:54:00:4c:c6:65:86:dd
SRC=fe80:0000:0000:0000:5054:00ff:fe4c:c665
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0 
device vnet2 entered promiscuous mode
br0: port 4(vnet2) entering forwarding state
vnet2: no IPv6 routers present
BUG: unable to handle kernel paging request at ffff8805f74c8598
IP: [<ffffffff813ca6c8>] __nf_conntrack_find+0x53/0xb1
PGD 1a3c063 PUD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/virtual/block/md0/md/sync_speed
CPU 2 
Pid: 3226, comm: qemu-kvm Not tainted 2.6.33-rc5 #1 0F9382/Precision
WorkStation 490    
RIP: 0010:[<ffffffff813ca6c8>]  [<ffffffff813ca6c8>] __nf_conntrack_find
+0x53/0xb1
RSP: 0018:ffff8801b92c5768  EFLAGS: 00010282
RAX: ffff8805f74c8598 RBX: ffff8801b92c5878 RCX: 00000000b1528e8e
RDX: ffff8801b9272400 RSI: 0000000081b01fa0 RDI: 0000000000000246
RBP: ffff8801b92c57a8 R08: 0000000098466e0d R09: 0000000044ad0faf
R10: 00000000f1118f58 R11: ffff8801b92c589c R12: ffffffff82967ef0
R13: ffff8801b92c5878 R14: ffffffffffffffb8 R15: 000000007d1b90b3
FS:  00007f7b1d26b780(0000) GS:ffff88002fc00000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff8805f74c8598 CR3: 00000001baf3c000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process qemu-kvm (pid: 3226, threadinfo ffff8801b92c4000, task
ffff8801b9272400)
Stack:
 ffff880214fc04e0 00000003e8dc8598 ffffffffffffffb8 ffffffff82967ef0
<0> ffff880214fc04e0 ffff8801b92c5878 ffffffffffffffb8 ffffffff82967ef0
<0> ffff8801b92c57f8 ffffffff813ca759 ffff880214fc04e0 ffff880214fc04e0
Call Trace:
 [<ffffffff813ca759>] nf_conntrack_find_get+0x33/0xb7
 [<ffffffff813cb810>] nf_conntrack_in+0x209/0x7d0
 [<ffffffff8140f2b3>] ipv4_conntrack_local+0x40/0x49
 [<ffffffff813c85c9>] nf_iterate+0x4d/0xab
 [<ffffffff813da338>] ? dst_output+0x0/0x12
 [<ffffffff813c869f>] nf_hook_slow+0x78/0xe0
 [<ffffffff813da338>] ? dst_output+0x0/0x12
 [<ffffffff81069602>] ? autoremove_wake_function+0x24/0x39
 [<ffffffff813db42a>] __ip_local_out+0x8b/0x8d
 [<ffffffff813db442>] ip_local_out+0x16/0x27
 [<ffffffff813dba70>] ip_queue_xmit+0x30e/0x36e
 [<ffffffff813ed9c8>] tcp_transmit_skb+0x707/0x745
 [<ffffffff813f003a>] tcp_write_xmit+0x7cb/0x8ba
 [<ffffffff813f018e>] __tcp_push_pending_frames+0x2f/0x5d
 [<ffffffff813e2dab>] tcp_push+0x88/0x8a
 [<ffffffff813e50cc>] tcp_sendmsg+0x760/0x85b
 [<ffffffff8139b42c>] __sock_sendmsg+0x5e/0x69
 [<ffffffff8139b742>] sock_sendmsg+0xa8/0xc1
 [<ffffffff81111999>] ? fget_light+0x57/0xf2
 [<ffffffff81111940>] ? rcu_read_unlock+0x21/0x23
 [<ffffffff81111999>] ? fget_light+0x57/0xf2
 [<ffffffff81140cca>] ? eventfd_write+0x94/0x186
 [<ffffffff8139b7d2>] ? sockfd_lookup_light+0x20/0x58
 [<ffffffff8139d497>] sys_sendto+0x110/0x152
 [<ffffffff81110670>] ? fsnotify_modify+0x6c/0x74
 [<ffffffff81118ddf>] ? path_put+0x22/0x26
 [<ffffffff810a1671>] ? audit_syscall_entry+0x11e/0x14a
 [<ffffffff8143cf2a>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b
Code: 48 89 df e8 c9 f4 ff ff 41 89 c7 45 89 ff e8 fb 93 c8 ff 4a 8d 04
fd 00 00 00 00 48 89 45 c8 48 8b 45 c8 49 03 84 24 90 06 00 00 <4c> 8b
28 eb 14 65 83 40 04 01 e8 d0 94 c8 ff eb 3b 65 83 00 01 
RIP  [<ffffffff813ca6c8>] __nf_conntrack_find+0x53/0xb1
 RSP <ffff8801b92c5768>
CR2: ffff8805f74c8598
---[ end trace d624218af5f5f65a ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 3226, comm: qemu-kvm Tainted: G      D    2.6.33-rc5 #1
Call Trace:
 [<ffffffff8143a899>] panic+0x7a/0x142
 [<ffffffff8143ed83>] oops_end+0xb7/0xc7
 [<ffffffff8102f719>] no_context+0x1fc/0x20b
 [<ffffffff8102f8ba>] __bad_area_nosemaphore+0x192/0x1b5
 [<ffffffff8107a4db>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff8102f8f0>] bad_area_nosemaphore+0x13/0x15
 [<ffffffff81440875>] do_page_fault+0x159/0x2aa
 [<ffffffff8143e0f5>] page_fault+0x25/0x30
 [<ffffffff813ca6c8>] ? __nf_conntrack_find+0x53/0xb1
 [<ffffffff813ca6b0>] ? __nf_conntrack_find+0x3b/0xb1
 [<ffffffff813ca759>] nf_conntrack_find_get+0x33/0xb7
 [<ffffffff813cb810>] nf_conntrack_in+0x209/0x7d0
 [<ffffffff8140f2b3>] ipv4_conntrack_local+0x40/0x49
 [<ffffffff813c85c9>] nf_iterate+0x4d/0xab
 [<ffffffff813da338>] ? dst_output+0x0/0x12
 [<ffffffff813c869f>] nf_hook_slow+0x78/0xe0
 [<ffffffff813da338>] ? dst_output+0x0/0x12
 [<ffffffff81069602>] ? autoremove_wake_function+0x24/0x39
 [<ffffffff813db42a>] __ip_local_out+0x8b/0x8d
 [<ffffffff813db442>] ip_local_out+0x16/0x27
 [<ffffffff813dba70>] ip_queue_xmit+0x30e/0x36e
 [<ffffffff813ed9c8>] tcp_transmit_skb+0x707/0x745
 [<ffffffff813f003a>] tcp_write_xmit+0x7cb/0x8ba
 [<ffffffff813f018e>] __tcp_push_pending_frames+0x2f/0x5d
 [<ffffffff813e2dab>] tcp_push+0x88/0x8a
 [<ffffffff813e50cc>] tcp_sendmsg+0x760/0x85b
 [<ffffffff8139b42c>] __sock_sendmsg+0x5e/0x69
 [<ffffffff8139b742>] sock_sendmsg+0xa8/0xc1
 [<ffffffff81111999>] ? fget_light+0x57/0xf2
 [<ffffffff81111940>] ? rcu_read_unlock+0x21/0x23
 [<ffffffff81111999>] ? fget_light+0x57/0xf2
 [<ffffffff81140cca>] ? eventfd_write+0x94/0x186
 [<ffffffff8139b7d2>] ? sockfd_lookup_light+0x20/0x58
 [<ffffffff8139d497>] sys_sendto+0x110/0x152
 [<ffffffff81110670>] ? fsnotify_modify+0x6c/0x74
 [<ffffffff81118ddf>] ? path_put+0x22/0x26
 [<ffffffff810a1671>] ? audit_syscall_entry+0x11e/0x14a
 [<ffffffff8143cf2a>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b
[drm:drm_fb_helper_panic] *ERROR* panic occurred, switching back to text
console
Rebooting in 30 sec

Jon.


