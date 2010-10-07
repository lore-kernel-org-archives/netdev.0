From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: BUG ? ipip unregister_netdevice_many()
Date: Thu, 7 Oct 2010 10:48:12 +0200
Message-ID: <201010071048.12817.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:49577 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177Ab0JGIsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 04:48:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
I'm trying to exit a network name space and it doesn't work (or am I doing something wrong?)
The only netdevices left are lo and the tunnels ip6tnl0, sit0 and tunl0 when exiting netns.

A netns is created by lxc-execute with two interfaces eth0 eth1 (macvlan)
(see conf file at the end)

Kernel: net-next-2.6 top from 4 october 2010

I added some printk's inn ipip.c  ipip_exit_net()
...
        rtnl_lock();
        printk(KERN_ERR "ipip_exit_net(enter)\n");
        ipip_destroy_tunnels(ipn, &list);
        printk(KERN_ERR "ipip_exit_net(1)\n");
        unregister_netdevice_queue(ipn->fb_tunnel_dev, &list);
        printk(KERN_ERR "ipip_exit_net(2)\n");
        unregister_netdevice_many(&list);
        printk(KERN_ERR "ipip_exit_net(3)\n");
        rtnl_unlock();
        printk(KERN_ERR "ipip_exit_net(exit)\n");


Exit steps:
===== Screen dump =====

 # ifconfig eth0  0.0.0.0  down
 # ifconfig eth1  0.0.0.0  down
 # ifconfig lo  0.0.0.0  down
 # ip li de eth0
 # ip li de eth1
 # ifconfig -a
ip6tnl0   Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
          NOARP  MTU:1460  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          LOOPBACK  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

sit0      Link encap:IPv6-in-IPv4  
          NOARP  MTU:1480  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

tunl0     Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
          NOARP  MTU:1480  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

 # ps
  PID USER       VSZ STAT COMMAND
    1 root     12412 S    /usr/lib64/lxc/lxc-init -- /var/bin/init
    2 root      4540 S    /bin/ash /var/bin/init
    7 root      6640 S    inetd
    8 root      4544 S    /bin/ash
   26 root      4544 R    ps
 # lsmod 
Module                  Size  Used by    Not tainted
macvlan                 8709  0 
pcnet32                29549  0 
tg3                   112093  0 
libphy                 21043  1 tg3
 # kill 7 2
 # ps
  PID USER       VSZ STAT COMMAND
    1 root     12412 S    /usr/lib64/lxc/lxc-init -- /var/bin/init
    8 root      4544 S    /bin/ash
   28 root      4544 R    ps
 # exit  ( here is the exit from netns  )
 # ipip_exit_net(enter)
ipip_exit_net(1)
ipip_exit_net(2)
------------[ cut here ]------------
WARNING: at /home/hans/evip/kvm/net-next-2.6/kernel/sysctl.c:1953 unregister_sysctl_table+0xc7/0xf9()
Hardware name: Bochs
Modules linked in: macvlan pcnet32 tg3 libphy
Pid: 5, comm: kworker/u:0 Not tainted 2.6.36-rc3+ #7
Call Trace:
 [<ffffffff8103e281>] warn_slowpath_common+0x85/0x9d
 [<ffffffff8103e2b3>] warn_slowpath_null+0x1a/0x1c
 [<ffffffff81045e64>] unregister_sysctl_table+0xc7/0xf9
 [<ffffffff812c86a5>] neigh_sysctl_unregister+0x27/0x3f
 [<ffffffff81342108>] addrconf_ifdown+0x415/0x45e
 [<ffffffff81342b98>] addrconf_notify+0x756/0x7fe
 [<ffffffff812cacfb>] ? neigh_ifdown+0xc3/0xd4
 [<ffffffff813622b3>] ? ip6mr_device_event+0x8d/0x9e
 [<ffffffff8105eddb>] notifier_call_chain+0x37/0x63
 [<ffffffff8105ee8b>] raw_notifier_call_chain+0x14/0x16
 [<ffffffff812c15c7>] call_netdevice_notifiers+0x4a/0x4f
 [<ffffffff812c1c1b>] rollback_registered_many+0x121/0x208
 [<ffffffff812c1d1d>] unregister_netdevice_many+0x1b/0x71
 [<ffffffff81324209>] ipip_exit_net+0xea/0x11a
 [<ffffffff812bc941>] ? cleanup_net+0x0/0x198
 [<ffffffff812bc2cf>] ops_exit_list+0x2a/0x5b
 [<ffffffff812bca39>] cleanup_net+0xf8/0x198
 [<ffffffff810568c7>] process_one_work+0x2a2/0x44d
 [<ffffffff81056e35>] worker_thread+0x1db/0x34e
 [<ffffffff81056c5a>] ? worker_thread+0x0/0x34e
 [<ffffffff8105a030>] kthread+0x82/0x8a
 [<ffffffff81003954>] kernel_thread_helper+0x4/0x10
 [<ffffffff81059fae>] ? kthread+0x0/0x8a
 [<ffffffff81003950>] ? kernel_thread_helper+0x0/0x10
---[ end trace 939b5185219f32e7 ]---
ipip_exit_net(3)
ipip_exit_net(exit)
unregister_netdevice: waiting for lo to become free. Usage count = 4
unregister_netdevice: waiting for lo to become free. Usage count = 4
unregister_netdevice: waiting for lo to become free. Usage count = 4
....
...
===== End of screen dump =====

lxc conf file:
# Container with network virtualized using the vlan device driver
# Local eth0 uplink
lxc.utsname = fee_0
lxc.network.type = macvlan
lxc.network.flags = up
lxc.network.link = eth1
lxc.network.hwaddr = 00:00:04:01:01:01
lxc.network.ipv4 = 192.168.1.21/24
lxc.network.ipv6 = 2003::2:1:1/96
# local eth1 downlink - to the RS farm
lxc.network.type = macvlan
lxc.network.flags = up
lxc.network.link = eth0
lxc.network.hwaddr = 00:00:03:01:01:01
lxc.network.ipv4 = 192.168.0.21/24
lxc.network.ipv6 = 2003::1:1:1/96
lxc.mount.entry = /var/lib/lxc/fee_0/var /var none rw,bind 0 0



Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
