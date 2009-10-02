From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from
 invalid context at mm/slub.c:1719
Date: Fri, 02 Oct 2009 11:52:16 +0200
Message-ID: <4AC5CD50.7060904@hartkopp.net>
References: <4AC59D8A.6000102@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:64407 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754AbZJBJwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 05:52:20 -0400
In-Reply-To: <4AC59D8A.6000102@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a reproducible bug.

When creating a ppp dialup connection a second time there is a lockdep annotation:

[ 1477.716936] PPP generic driver version 2.4.2
[ 1477.738035] BUG: sleeping function called from invalid context at
mm/slub.c:1719
[ 1477.738046] in_atomic(): 1, irqs_disabled(): 0, pid: 5057, name: pppd
[ 1477.738053] 3 locks held by pppd/5057:
[ 1477.738058]  #0:  (rfcomm_mutex){+.+.+.}, at: [<fa5dd2a1>]
rfcomm_dlc_open+0x28/0x2d6 [rfcomm]
[ 1477.738083]  #1:  (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.+.}, at:
[<fa53f4f8>] l2cap_sock_connect+0x62/0x2c6 [l2cap]
[ 1477.738105]  #2:  (&hdev->lock){+...+.}, at: [<fa53f5b4>]
l2cap_sock_connect+0x11e/0x2c6 [l2cap]
[ 1477.738129] Pid: 5057, comm: pppd Not tainted 2.6.31-08939-gdb8abec-dirty #21
[ 1477.738135] Call Trace:
[ 1477.738148]  [<c1042a2b>] ? __debug_show_held_locks+0x1e/0x20
[ 1477.738160]  [<c10212a1>] __might_sleep+0xc9/0xce
[ 1477.738171]  [<c1078b62>] __kmalloc+0x6d/0xfb
[ 1477.738181]  [<c119e739>] ? kzalloc+0xb/0xd
[ 1477.738190]  [<c119e739>] kzalloc+0xb/0xd
[ 1477.738199]  [<c119ef1a>] device_private_init+0x15/0x3d
[ 1477.738209]  [<c11a0e1b>] dev_set_drvdata+0x18/0x26
[ 1477.738233]  [<f88f9a1b>] hci_conn_init_sysfs+0x3d/0xc7 [bluetooth]
[ 1477.738253]  [<f88f61b3>] hci_conn_add+0x1c0/0x1d5 [bluetooth]
[ 1477.738271]  [<f88f6360>] hci_connect+0x71/0x17d [bluetooth]
[ 1477.738285]  [<fa53f62c>] l2cap_sock_connect+0x196/0x2c6 [l2cap]
[ 1477.738298]  [<c1246e3d>] kernel_connect+0xd/0x12
[ 1477.738311]  [<fa5dd3c3>] rfcomm_dlc_open+0x14a/0x2d6 [rfcomm]
[ 1477.738326]  [<fa5df0fa>] ? rfcomm_tty_open+0x73/0x227 [rfcomm]
[ 1477.738341]  [<fa5df130>] rfcomm_tty_open+0xa9/0x227 [rfcomm]
[ 1477.738352]  [<c1022e3f>] ? default_wake_function+0x0/0xd
[ 1477.738363]  [<c1180c79>] tty_open+0x29e/0x399
[ 1477.738374]  [<c107e9bd>] chrdev_open+0x13f/0x156
[ 1477.738384]  [<c107b0d3>] __dentry_open+0x11b/0x20f
[ 1477.738394]  [<c107b261>] nameidata_to_filp+0x2c/0x43
[ 1477.738403]  [<c107e87e>] ? chrdev_open+0x0/0x156
[ 1477.738414]  [<c1084e9e>] do_filp_open+0x3c6/0x70a
[ 1477.738426]  [<c108d3e4>] ? alloc_fd+0xc8/0xd2
[ 1477.738436]  [<c108d3e4>] ? alloc_fd+0xc8/0xd2
[ 1477.738446]  [<c107aebc>] do_sys_open+0x4a/0xe7
[ 1477.738456]  [<c1002acc>] ? restore_all_notrace+0x0/0x18
[ 1477.738466]  [<c107af9b>] sys_open+0x1e/0x26
[ 1477.738475]  [<c1002a18>] sysenter_do_call+0x12/0x36
[ 1484.844933] PPP BSD Compression module registered
[ 1484.870946] PPP Deflate Compression module registered
[ 4335.008503] CE: hpet increasing min_delta_ns to 15000 nsec
[ 7605.540870] INFO: trying to register non-static key.
[ 7605.540879] the code is fine but needs lockdep annotation.
[ 7605.540884] turning off the locking correctness validator.
[ 7605.540894] Pid: 0, comm: swapper Not tainted 2.6.31-08939-gdb8abec-dirty #21
[ 7605.540900] Call Trace:
[ 7605.540915]  [<c12e4fb2>] ? printk+0xf/0x11
[ 7605.540928]  [<c1042214>] register_lock_class+0x5a/0x295
[ 7605.540939]  [<c1043af2>] __lock_acquire+0x9b/0xc03
[ 7605.540949]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
[ 7605.540967]  [<fa53b168>] ? l2cap_get_chan_by_scid+0x35/0x43 [l2cap]
[ 7605.540977]  [<c104491f>] ? lock_release_non_nested+0x17b/0x1db
[ 7605.540990]  [<fa53b168>] ? l2cap_get_chan_by_scid+0x35/0x43 [l2cap]
[ 7605.541001]  [<c10426fd>] ? trace_hardirqs_off+0xb/0xd
[ 7605.541010]  [<c10446b6>] lock_acquire+0x5c/0x73
[ 7605.541021]  [<c124cd14>] ? skb_dequeue+0x12/0x4c
[ 7605.541031]  [<c12e6e23>] _spin_lock_irqsave+0x24/0x34
[ 7605.541039]  [<c124cd14>] ? skb_dequeue+0x12/0x4c
[ 7605.541048]  [<c124cd14>] skb_dequeue+0x12/0x4c
[ 7605.541057]  [<c124d579>] skb_queue_purge+0x14/0x1b
[ 7605.541070]  [<fa53de3f>] l2cap_recv_frame+0xe9e/0x129a [l2cap]
[ 7605.541080]  [<c10421d1>] ? register_lock_class+0x17/0x295
[ 7605.541091]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
[ 7605.541114]  [<c104464b>] ? __lock_acquire+0xbf4/0xc03
[ 7605.541125]  [<c120de74>] ? uhci_giveback_urb+0xf2/0x162
[ 7605.541148]  [<f88f4c45>] ? hci_rx_task+0xfe/0x1f8 [bluetooth]
[ 7605.541162]  [<fa53e2e4>] l2cap_recv_acldata+0xa9/0x1be [l2cap]
[ 7605.541174]  [<fa53e23b>] ? l2cap_recv_acldata+0x0/0x1be [l2cap]
[ 7605.541193]  [<f88f4c77>] hci_rx_task+0x130/0x1f8 [bluetooth]
[ 7605.541204]  [<c102a098>] tasklet_action+0x6b/0xb2
[ 7605.541213]  [<c102a46b>] __do_softirq+0x82/0x101
[ 7605.541222]  [<c102a515>] do_softirq+0x2b/0x43
[ 7605.541231]  [<c102a619>] irq_exit+0x35/0x68
[ 7605.541241]  [<c1004513>] do_IRQ+0x80/0x96
[ 7605.541250]  [<c10030ae>] common_interrupt+0x2e/0x34
[ 7605.541260]  [<c104007b>] ? tick_device_uses_broadcast+0x71/0x7c
[ 7605.541271]  [<c11747a8>] ? acpi_idle_enter_simple+0x103/0x12e
[ 7605.541281]  [<c1174515>] acpi_idle_enter_bm+0xc3/0x253
[ 7605.541291]  [<c1238b6f>] cpuidle_idle_call+0x60/0x91
[ 7605.541300]  [<c1001d44>] cpu_idle+0x49/0x65
[ 7605.541310]  [<c12e2f0e>] start_secondary+0x190/0x195


Oliver Hartkopp wrote:
> Hello Marcel,
> 
> with current net-2.6 tree ...
> 
> While starting my PPP Bluetooth dialup networking, i got this:
> 
> [  722.461549] PPP generic driver version 2.4.2
> [  722.477519] BUG: sleeping function called from invalid context at
> mm/slub.c:1719
> [  722.477530] in_atomic(): 1, irqs_disabled(): 0, pid: 4677, name: pppd
> [  722.477537] 3 locks held by pppd/4677:
> [  722.477542]  #0:  (rfcomm_mutex){+.+.+.}, at: [<fa5df2a1>]
> rfcomm_dlc_open+0x28/0x2d6 [rfcomm]
> [  722.477568]  #1:  (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.+.}, at:
> [<fa5414f8>] l2cap_sock_connect+0x62/0x2c6 [l2cap]
> [  722.477589]  #2:  (&hdev->lock){+...+.}, at: [<fa5415b4>]
> l2cap_sock_connect+0x11e/0x2c6 [l2cap]
> [  722.477613] Pid: 4677, comm: pppd Not tainted 2.6.31-08939-gdb8abec-dirty #21
> [  722.477619] Call Trace:
> [  722.477633]  [<c1042a2b>] ? __debug_show_held_locks+0x1e/0x20
> [  722.477644]  [<c10212a1>] __might_sleep+0xc9/0xce
> [  722.477655]  [<c1078b62>] __kmalloc+0x6d/0xfb
> [  722.477666]  [<c119e739>] ? kzalloc+0xb/0xd
> [  722.477674]  [<c119e739>] kzalloc+0xb/0xd
> [  722.477683]  [<c119ef1a>] device_private_init+0x15/0x3d
> [  722.477693]  [<c11a0e1b>] dev_set_drvdata+0x18/0x26
> [  722.477718]  [<f8b7ca1b>] hci_conn_init_sysfs+0x3d/0xc7 [bluetooth]
> [  722.477737]  [<f8b791b3>] hci_conn_add+0x1c0/0x1d5 [bluetooth]
> [  722.477756]  [<f8b79360>] hci_connect+0x71/0x17d [bluetooth]
> [  722.477769]  [<fa54162c>] l2cap_sock_connect+0x196/0x2c6 [l2cap]
> [  722.477782]  [<c1246e3d>] kernel_connect+0xd/0x12
> [  722.477795]  [<fa5df3c3>] rfcomm_dlc_open+0x14a/0x2d6 [rfcomm]
> [  722.477810]  [<fa5e10fa>] ? rfcomm_tty_open+0x73/0x227 [rfcomm]
> [  722.477825]  [<fa5e1130>] rfcomm_tty_open+0xa9/0x227 [rfcomm]
> [  722.477836]  [<c1022e3f>] ? default_wake_function+0x0/0xd
> [  722.477847]  [<c1180c79>] tty_open+0x29e/0x399
> [  722.477858]  [<c107e9bd>] chrdev_open+0x13f/0x156
> [  722.477868]  [<c107b0d3>] __dentry_open+0x11b/0x20f
> [  722.477878]  [<c107b261>] nameidata_to_filp+0x2c/0x43
> [  722.477888]  [<c107e87e>] ? chrdev_open+0x0/0x156
> [  722.477898]  [<c1084e9e>] do_filp_open+0x3c6/0x70a
> [  722.477910]  [<c108d3e4>] ? alloc_fd+0xc8/0xd2
> [  722.477920]  [<c108d3e4>] ? alloc_fd+0xc8/0xd2
> [  722.477930]  [<c107aebc>] do_sys_open+0x4a/0xe7
> [  722.477940]  [<c1002acc>] ? restore_all_notrace+0x0/0x18
> [  722.477950]  [<c107af9b>] sys_open+0x1e/0x26
> [  722.477959]  [<c1002a18>] sysenter_do_call+0x12/0x36
> [  729.658613] PPP BSD Compression module registered
> [  729.684789] PPP Deflate Compression module registered
> 
> Any idea?
> 
> Regards,
> Oliver
> 

