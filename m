From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 09:06:02 -0700
Message-ID: <m1d3rk3c0l.fsf@fess.ebiederm.org>
References: <201010071048.12817.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51007 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952Ab0JHQGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:06:11 -0400
In-Reply-To: <201010071048.12817.hans.schillstrom@ericsson.com> (Hans
	Schillstrom's message of "Thu, 7 Oct 2010 10:48:12 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans Schillstrom <hans.schillstrom@ericsson.com> writes:

> Hello
> I'm trying to exit a network name space and it doesn't work (or am I doing something wrong?)
> The only netdevices left are lo and the tunnels ip6tnl0, sit0 and tunl0 when exiting netns.
>
> A netns is created by lxc-execute with two interfaces eth0 eth1 (macvlan)
> (see conf file at the end)
>
> Kernel: net-next-2.6 top from 4 october 2010
>
> I added some printk's inn ipip.c  ipip_exit_net()
> ...
>         rtnl_lock();
>         printk(KERN_ERR "ipip_exit_net(enter)\n");
>         ipip_destroy_tunnels(ipn, &list);
>         printk(KERN_ERR "ipip_exit_net(1)\n");
>         unregister_netdevice_queue(ipn->fb_tunnel_dev, &list);
>         printk(KERN_ERR "ipip_exit_net(2)\n");
>         unregister_netdevice_many(&list);
>         printk(KERN_ERR "ipip_exit_net(3)\n");
>         rtnl_unlock();
>         printk(KERN_ERR "ipip_exit_net(exit)\n");
>
>
> Exit steps:
> ===== Screen dump =====
>
>  # ifconfig eth0  0.0.0.0  down
>  # ifconfig eth1  0.0.0.0  down
>  # ifconfig lo  0.0.0.0  down
>  # ip li de eth0
>  # ip li de eth1
>  # ifconfig -a
> ip6tnl0   Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
>           NOARP  MTU:1460  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0 
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>
> lo        Link encap:Local Loopback  
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           LOOPBACK  MTU:16436  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0 
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>
> sit0      Link encap:IPv6-in-IPv4  
>           NOARP  MTU:1480  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0 
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>
> tunl0     Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
>           NOARP  MTU:1480  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0 
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>
>  # ps
>   PID USER       VSZ STAT COMMAND
>     1 root     12412 S    /usr/lib64/lxc/lxc-init -- /var/bin/init
>     2 root      4540 S    /bin/ash /var/bin/init
>     7 root      6640 S    inetd
>     8 root      4544 S    /bin/ash
>    26 root      4544 R    ps
>  # lsmod 
> Module                  Size  Used by    Not tainted
> macvlan                 8709  0 
> pcnet32                29549  0 
> tg3                   112093  0 
> libphy                 21043  1 tg3
>  # kill 7 2
>  # ps
>   PID USER       VSZ STAT COMMAND
>     1 root     12412 S    /usr/lib64/lxc/lxc-init -- /var/bin/init
>     8 root      4544 S    /bin/ash
>    28 root      4544 R    ps
>  # exit  ( here is the exit from netns  )
>  # ipip_exit_net(enter)
> ipip_exit_net(1)
> ipip_exit_net(2)
> ------------[ cut here ]------------
> WARNING: at /home/hans/evip/kvm/net-next-2.6/kernel/sysctl.c:1953
>   unregister_sysctl_table+0xc7/0xf9()

This warning is caused by removing the parent directory
before the child in the sysctl tables.  Not strictly fatal but
it is a problem.  It may be worth looking at which sysctl
tables ipip registers to see if we can rectify this.

> Hardware name: Bochs
> Modules linked in: macvlan pcnet32 tg3 libphy
> Pid: 5, comm: kworker/u:0 Not tainted 2.6.36-rc3+ #7
> Call Trace:
>  [<ffffffff8103e281>] warn_slowpath_common+0x85/0x9d
>  [<ffffffff8103e2b3>] warn_slowpath_null+0x1a/0x1c
>  [<ffffffff81045e64>] unregister_sysctl_table+0xc7/0xf9
>  [<ffffffff812c86a5>] neigh_sysctl_unregister+0x27/0x3f
>  [<ffffffff81342108>] addrconf_ifdown+0x415/0x45e
>  [<ffffffff81342b98>] addrconf_notify+0x756/0x7fe
>  [<ffffffff812cacfb>] ? neigh_ifdown+0xc3/0xd4
>  [<ffffffff813622b3>] ? ip6mr_device_event+0x8d/0x9e
>  [<ffffffff8105eddb>] notifier_call_chain+0x37/0x63
>  [<ffffffff8105ee8b>] raw_notifier_call_chain+0x14/0x16
>  [<ffffffff812c15c7>] call_netdevice_notifiers+0x4a/0x4f
>  [<ffffffff812c1c1b>] rollback_registered_many+0x121/0x208
>  [<ffffffff812c1d1d>] unregister_netdevice_many+0x1b/0x71
>  [<ffffffff81324209>] ipip_exit_net+0xea/0x11a
>  [<ffffffff812bc941>] ? cleanup_net+0x0/0x198
>  [<ffffffff812bc2cf>] ops_exit_list+0x2a/0x5b
>  [<ffffffff812bca39>] cleanup_net+0xf8/0x198
>  [<ffffffff810568c7>] process_one_work+0x2a2/0x44d
>  [<ffffffff81056e35>] worker_thread+0x1db/0x34e
>  [<ffffffff81056c5a>] ? worker_thread+0x0/0x34e
>  [<ffffffff8105a030>] kthread+0x82/0x8a
>  [<ffffffff81003954>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81059fae>] ? kthread+0x0/0x8a
>  [<ffffffff81003950>] ? kernel_thread_helper+0x0/0x10
> ---[ end trace 939b5185219f32e7 ]---
> ipip_exit_net(3)
> ipip_exit_net(exit)
> unregister_netdevice: waiting for lo to become free. Usage count = 4
> unregister_netdevice: waiting for lo to become free. Usage count = 4
> unregister_netdevice: waiting for lo to become free. Usage count = 4

Nasty. Someone has left a reference lying around to one of the network
devices.  It is a reference that we can transfer to the loopback device
at device exit time, but we never drop the reference and so the loopback
interface never frees up.

Ouch!

There is the painful method of instrumenting of dev_hold and dev_release
that may give you a clue.  It may also be worth seeing which kinds of
device reference we transfer from the loopback device when a device
exits.

Eric
