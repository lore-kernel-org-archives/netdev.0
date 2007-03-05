From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8132] New: pptp server lockup in
 ppp_asynctty_receive()
Date: Mon, 5 Mar 2007 15:13:31 -0800
Message-ID: <20070305151331.3cdd98dd.akpm@linux-foundation.org>
References: <200703052226.l25MQUk4011469@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, jura@netams.com,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40662 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259AbXCEXNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 18:13:53 -0500
In-Reply-To: <200703052226.l25MQUk4011469@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Mar 2007 14:26:30 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8132
> 
>            Summary: pptp server lockup in ppp_asynctty_receive()
>     Kernel Version:  2.6.20
>             Status: NEW
>           Severity: high
>              Owner: jgarzik@pobox.com
>          Submitter: jura@netams.com
>                 CC: jura@netams.com
> 
> 
> Already several kernel releases i've expirienced different lockups of  vpn 
> (pptp) server.
> There is more then 200  ppp connections sometimes.
> With kernel debug i was able to retrive next information:
> 
> First:
> Showing all locks held in the system:
> 1 lock held by agetty/4486:
>  #0:  (&tty->atomic_read_lock){--..}, at: [<c01d4e6f>] read_chan+0x41a/0x60b
> 1 lock held by agetty/4487:
>  #0:  (&tty->atomic_read_lock){--..}, at: [<c01d4e6f>] read_chan+0x41a/0x60b
> 1 lock held by agetty/4488:
>  #0:  (&tty->atomic_read_lock){--..}, at: [<c01d4e6f>] read_chan+0x41a/0x60b
> 2 locks held by pptpctrl/4500:
>  #0:  (&tty->atomic_write_lock){--..}, at: [<c01d0f8f>] tty_write+0x83/0x1d0
>  #1:  (&ap->recv_lock){....}, at: [<c02241fe>] 
> ppp_asynctty_receive+0x2e/0x710
> 
> =============================================
> BUG: spinlock lockup on CPU#1, pppd/4504, df5048c4
>  [<c01c42c6>] _raw_spin_lock+0x100/0x134
>  [<c0223f03>] ppp_async_ioctl+0xa7/0x1d0
>  [<c0221b7c>] ppp_ioctl+0xa5/0xbff
>  [<c012f2a5>] down_read+0x29/0x3a
>  [<c0223e5c>] ppp_async_ioctl+0x0/0x1d0
>  [<c0221ba5>] ppp_ioctl+0xce/0xbff
>  [<c029b78f>] _spin_unlock+0x14/0x1c
>  [<c014a22a>] do_wp_page+0x256/0x4ba
>  [<c014c1e9>] __handle_mm_fault+0x74e/0xa22
>  [<c0167224>] do_ioctl+0x64/0x6d
>  [<c016727d>] vfs_ioctl+0x50/0x273
>  [<c01674d4>] sys_ioctl+0x34/0x50
>  [<c0102dae>] sysenter_past_esp+0x5f/0x99
>  =======================
> BUG: soft lockup detected on CPU#0!
>  [<c013ce27>] softlockup_tick+0x8d/0xbc
>  [<c0123784>] update_process_times+0x28/0x5e
>  [<c010d9c4>] smp_apic_timer_interrupt+0x80/0x9c
>  [<c0103903>] apic_timer_interrupt+0x33/0x38
>  [<c01c2e9d>] delay_tsc+0x9/0x13
>  [<c01c2ed3>] __delay+0x6/0x7
>  [<c01c426f>] _raw_spin_lock+0xa9/0x134
>  [<c01d0f8f>] tty_write+0x83/0x1d0
>  [<c01cf418>] tty_ldisc_try+0x2f/0x33
>  [<c029bc8c>] lock_kernel+0x19/0x24
>  [<c01d1017>] tty_write+0x10b/0x1d0
>  [<c01d35cf>] write_chan+0x0/0x320
>  [<c015d502>] vfs_write+0x87/0xf0
>  [<c01d0f0c>] tty_write+0x0/0x1d0
>  [<c015daa9>] sys_write+0x41/0x6a
>  [<c0102dae>] sysenter_past_esp+0x5f/0x99
>  =======================
> 
> 
> Second)
> <0>BUG: spinlock lockup on CPU#0, pppd/5209, de3e2884
>  [<c01c42c6>] _raw_spin_lock+0x100/0x134
> BUG: spinlock lockup on CPU#1, ip-down/7524, c0353300
>  [<c01c42c6>] _raw_spin_lock+0x100/0x134
>  [<c029bc8c>] lock_kernel+0x19/0x24
>  [<c015f234>] chrdev_open+0x8a/0x16e
>  [<c015f1aa>] chrdev_open+0x0/0x16e
>  [<c015ba94>] __dentry_open+0xaf/0x1a0
>  [<c015bc12>] nameidata_to_filp+0x31/0x3a
>  [<c015bc54>] do_filp_open+0x39/0x40
>  [<c029b78f>] _spin_unlock+0x14/0x1c
>  [<c015b9d4>] get_unused_fd+0xaa/0xbb
>  [<c015bc95>] do_sys_open+0x3a/0x6d
>  [<c015bd03>] sys_open+0x1c/0x20
>  [<c0102dae>] sysenter_past_esp+0x5f/0x99
>  =======================
>  [<c0223f03>] ppp_async_ioctl+0xa7/0x1d0
>  [<c0221b7c>] ppp_ioctl+0xa5/0xbff
>  [<c012f2a5>] down_read+0x29/0x3a
>  [<c0223e5c>] ppp_async_ioctl+0x0/0x1d0
>  [<c0221ba5>] ppp_ioctl+0xce/0xbff
>  [<c029b78f>] _spin_unlock+0x14/0x1c
>  [<c014a22a>] do_wp_page+0x256/0x4ba
>  [<c014c1e9>] __handle_mm_fault+0x74e/0xa22
>  [<c0167224>] do_ioctl+0x64/0x6d
>  [<c016727d>] vfs_ioctl+0x50/0x273
>  [<c01674d4>] sys_ioctl+0x34/0x50
>  [<c0102dae>] sysenter_past_esp+0x5f/0x99
>  =======================
> 
> Third)
> BUG: soft lockup detected on CPU#0!
>  [<c013ce27>] softlockup_tick+0x8d/0xbc
>  [<c0123784>] update_process_times+0x28/0x5e
>  [<c010d9c4>] smp_apic_timer_interrupt+0x80/0x9c
>  [<c0103903>] apic_timer_interrupt+0x33/0x38
>  [<c01c2e9d>] delay_tsc+0x9/0x13
>  [<c01c2ed3>] __delay+0x6/0x7
>  [<c01c426f>] _raw_spin_lock+0xa9/0x134
>  [<c01cf418>] tty_ldisc_try+0x2f/0x33
>  [<c029bc8c>] lock_kernel+0x19/0x24
>  [<c01d1984>] tty_read+0x5a/0xbe
>  [<c015d5f0>] vfs_read+0x85/0xee
>  [<c01d192a>] tty_read+0x0/0xbe
>  [<c015da3f>] sys_read+0x41/0x6a
>  [<c0102dae>] sysenter_past_esp+0x5f/0x99
>  =======================
> BUG: soft lockup detected on CPU#0!
>  [<c013ce27>] softlockup_tick+0x8d/0xbc
>  [<c0123784>] update_process_times+0x28/0x5e
>  [<c010d9c4>] smp_apic_timer_interrupt+0x80/0x9c
>  [<c0103903>] apic_timer_interrupt+0x33/0x38
>  [<c01c00d8>] prio_tree_insert+0xe8/0x23b
>  [<c01c4275>] _raw_spin_lock+0xaf/0x134
>  [<c01cf418>] tty_ldisc_try+0x2f/0x33
>  [<c029bc8c>] lock_kernel+0x19/0x24
>  [<c01d1984>] tty_read+0x5a/0xbe
>  [<c015d5f0>] vfs_read+0x85/0xee
>  [<c01d192a>] tty_read+0x0/0xbe
>  [<c015da3f>] sys_read+0x41/0x6a
>  [<c0102dae>] sysenter_past_esp+0x5f/0x99
> 
> 
> Next via SysRq:
> 
> Showing all locks held in the system:
> 1 lock held by agetty/5057:
>  #0:  (&tty->atomic_read_lock){--..}, at: [<c01d4e6f>] read_chan+0x41a/0x60b
> 1 lock held by agetty/5058:
>  #0:  (&tty->atomic_read_lock){--..}, at: [<c01d4e6f>] read_chan+0x41a/0x60b
> 1 lock held by agetty/5059:
>  #0:  (&tty->atomic_read_lock){--..}, at: [<c01d4e6f>] read_chan+0x41a/0x60b
> 2 locks held by pptpctrl/5071:
>  #0:  (&tty->atomic_write_lock){--..}, at: [<c01d0f8f>] tty_write+0x83/0x1d0
>  #1:  (&ap->recv_lock){....}, at: [<c02241fe>] 
> ppp_asynctty_receive+0x2e/0x710
> 
> 
> ~#SysRq : Show Blocked State
> 
>                          free                        sibling
>   task             PC    stack   pid father child younger older
> pptpctrl      D C02A18E0     0  5071   4646  5074    5094  5064 (L-TLB)
>        df3a3bd0 00000082 0029b837 c02a18e0 00000246 00000000 dd4f131c 
> dd563cac
>        def86030 c140864c 00000000 00000000 00000009 def86030 2ccaa8e5 
> 0000017d
>        3b9aca00 def8613c c1407cc0 00000000 006a9953 00000000 de8f503c 
> 00000046
> Call Trace:
>  [<c029b5b0>] __down+0x8c/0xf4
>  [<c0116209>] default_wake_function+0x0/0xc
>  [<c029b397>] __down_failed+0x7/0xc
>  [<c0223de4>] ppp_asynctty_close+0x28/0x98
>  [<c0223e4f>] ppp_asynctty_close+0x93/0x98
>  [<c0223e59>] ppp_asynctty_hangup+0x5/0x8
>  [<c01d0c8a>] do_tty_hangup+0x119/0x391
>  [<c01d0612>] release_dev+0x154/0x69b
>  [<c0158a01>] poison_obj+0x20/0x3d
>  [<c0158a01>] poison_obj+0x20/0x3d
>  [<c0158c70>] cache_free_debugcheck+0xc7/0x1dd
>  [<c016ddd5>] destroy_inode+0x20/0x33
>  [<c016c88c>] dput+0xd9/0x145
>  [<c01d0b68>] tty_release+0xf/0x18
>  [<c015dd96>] __fput+0x3c/0xe7
>  [<c015b906>] filp_close+0x3e/0x62
>  [<c011c73b>] put_files_struct+0xa5/0xb8
>  [<c011d808>] do_exit+0x124/0x7e2
>  [<c01e1710>] vgacon_set_cursor_size+0x2d/0xeb
>  [<c0104392>] do_trap+0x0/0xa9
>  [<c0104bf5>] do_invalid_op+0x0/0xab
>  [<c0104c97>] do_invalid_op+0xa2/0xab
>  [<c024d1e4>] skb_under_panic+0x59/0x5d
>  [<c0113ecc>] __wake_up+0x32/0x43
>  [<c011af94>] release_console_sem+0x22d/0x239
>  [<c011b4f1>] vprintk+0x1fb/0x37c
>  [<c029bd4c>] error_code+0x7c/0x84
>  [<c024d1e4>] skb_under_panic+0x59/0x5d
>  [<c02248a2>] ppp_asynctty_receive+0x6d2/0x710
>  [<c02248b0>] ppp_asynctty_receive+0x6e0/0x710
>  [<c01d5a09>] pty_write+0x39/0x41
>  [<c01d37e1>] write_chan+0x212/0x320
>  [<c0116209>] default_wake_function+0x0/0xc
>  [<c01d1028>] tty_write+0x11c/0x1d0
>  [<c01d35cf>] write_chan+0x0/0x320
>  [<c015d502>] vfs_write+0x87/0xf0
>  [<c01d0f0c>] tty_write+0x0/0x1d0
>  [<c015daa9>] sys_write+0x41/0x6a
>  [<c0102dae>] sysenter_past_esp+0x5f/0x99
>  =======================
> 
> Dump registers
> Pid: 13874, comm:             pptpctrl
> EIP: 0060:[<c01c2e94>] CPU: 0
> EIP is at delay_tsc+0x0/0x13
>  EFLAGS: 00000246    Not tainted  (2.6.20-gentoo #10)
> EAX: 00000001 EBX: c0353300 ECX: f52a298e EDX: c799bc55
> ESI: 492d5b81 EDI: 00000000 EBP: 8eb4e7d4 DS: 007b ES: 007b GS: 00d8
> CR0: 8005003b CR2: b7e598b8 CR3: 0e6f3000 CR4: 000006d0
>  [<c01c2ed3>] __delay+0x6/0x7
>  [<c01c426f>] _raw_spin_lock+0xa9/0x134
>  [<c01cf418>] tty_ldisc_try+0x2f/0x33
>  [<c029bc8c>] lock_kernel+0x19/0x24
>  [<c01d1984>] tty_read+0x5a/0xbe
>  [<c015d5f0>] vfs_read+0x85/0xee
>  [<c01d192a>] tty_read+0x0/0xbe
>  [<c015da3f>] sys_read+0x41/0x6a
>  [<c0102dae>] sysenter_past_esp+0x5f/0x99
>  =======================
> 
> 
> Information about system:
>  sh scripts/ver_linux
> If some fields are empty or look unusual you may have an old version.
> Compare to the current minimal requirements in Documentation/Changes.
> 
> Linux vpn2 2.6.20-gentoo #10 SMP Mon Mar 5 11:07:33 MSK 2007 i686 Intel(R) 
> Pentium(R) 4 CPU 2.40GHz GenuineIntel GNU/Linux
> 
> Gnu C                  4.1.2
> Gnu make               3.81
> binutils               2.17
> util-linux             2.12r
> mount                  2.12r
> module-init-tools      3.2.2
> e2fsprogs              1.39
> reiserfsprogs          3.6.19
> PPP                    2.4.4
> Linux C Library        > libc.2.5
> Dynamic linker (ldd)   2.5
> Procps                 3.2.7
> Net-tools              1.60
> Kbd                    1.12
> Sh-utils               6.7
> udev                   104
> Modules Loaded         8021q ipt_TCPMSS xt_tcpudp xt_pkttype iptable_filter 
> ip_tables x_tables i2c_i801 i2c_core
> 

This could be an interaction between the tty-layer locking changes and ppp?
