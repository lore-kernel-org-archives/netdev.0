From: David Miller <davem@davemloft.net>
Subject: Re: net-next: warnings from sysctl_net_exit
Date: Sun, 27 Feb 2011 15:34:18 -0800 (PST)
Message-ID: <20110227.153418.245395393.davem@davemloft.net>
References: <AANLkTi=mhj3Ftq8hFPPzZYJvp8mgOeV89oX_vHZVxwzY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: lucian.grijincu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751913Ab1B0Xdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 18:33:41 -0500
In-Reply-To: <AANLkTi=mhj3Ftq8hFPPzZYJvp8mgOeV89oX_vHZVxwzY@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date: Mon, 28 Feb 2011 00:37:09 +0200

> Stephen Hemminger <shemminger <at> vyatta.com> writes:
>> [26207.669740]  [<ffffffff814154ad>] ? sysctl_net_exit+0x2a/0x2c
>> [26207.669742]  [<ffffffff8136144e>] ? ops_exit_list+0x2a/0x5b
>> [26207.669745]  [<ffffffff813618f0>] ? cleanup_net+0xfa/0x19a
> 
> 
> David: it looks like someone registered a /proc/sys table with
> register_net_sysctl_table but forgot to remove it (or someone wrote
> something in the 'struct net*' and buffer overflowed into
> &net->sysctls.list).

Hmmm, we might therefore want to inspect this commit carefully:

commit bf36076a67db6d7423d09d861a072337866f0dd9
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Mon Jan 31 20:54:17 2011 -0800

    net: Fix ipv6 neighbour unregister_sysctl_table warning
    
    In my testing of 2.6.37 I was occassionally getting a warning about
    sysctl table entries being unregistered in the wrong order.  Digging
    in it turns out this dates back to the last great sysctl reorg done
    where Al Viro introduced the requirement that sysctl directories
    needed to be created before and destroyed after the files in them.
    
    It turns out that in that great reorg /proc/sys/net/ipv6/neigh was
    overlooked.  So this patch fixes that oversight and makes an annoying
    warning message go away.
    
    >------------[ cut here ]------------
    >WARNING: at kernel/sysctl.c:1992 unregister_sysctl_table+0x134/0x164()
    >Pid: 23951, comm: kworker/u:3 Not tainted 2.6.37-350888.2010AroraKernelBeta.fc14.x86_64 #1
    >Call Trace:
    > [<ffffffff8103e034>] warn_slowpath_common+0x80/0x98
    > [<ffffffff8103e061>] warn_slowpath_null+0x15/0x17
    > [<ffffffff810452f8>] unregister_sysctl_table+0x134/0x164
    > [<ffffffff810e7834>] ? kfree+0xc4/0xd1
    > [<ffffffff813439b2>] neigh_sysctl_unregister+0x22/0x3a
    > [<ffffffffa02cd14e>] addrconf_ifdown+0x33f/0x37b [ipv6]
    > [<ffffffff81331ec2>] ? skb_dequeue+0x5f/0x6b
    > [<ffffffffa02ce4a5>] addrconf_notify+0x69b/0x75c [ipv6]
    > [<ffffffffa02eb953>] ? ip6mr_device_event+0x98/0xa9 [ipv6]
    > [<ffffffff813d2413>] notifier_call_chain+0x32/0x5e
    > [<ffffffff8105bdea>] raw_notifier_call_chain+0xf/0x11
    > [<ffffffff8133cdac>] call_netdevice_notifiers+0x45/0x4a
    > [<ffffffff8133d2b0>] rollback_registered_many+0x118/0x201
    > [<ffffffff8133d3af>] unregister_netdevice_many+0x16/0x6d
    > [<ffffffff8133d571>] default_device_exit_batch+0xa4/0xb8
    > [<ffffffff81337c42>] ? cleanup_net+0x0/0x194
    > [<ffffffff81337a2a>] ops_exit_list+0x4e/0x56
    > [<ffffffff81337d36>] cleanup_net+0xf4/0x194
    > [<ffffffff81053318>] process_one_work+0x187/0x280
    > [<ffffffff8105441b>] worker_thread+0xff/0x19f
    > [<ffffffff8105431c>] ? worker_thread+0x0/0x19f
    > [<ffffffff8105776d>] kthread+0x7d/0x85
    > [<ffffffff81003824>] kernel_thread_helper+0x4/0x10
    > [<ffffffff810576f0>] ? kthread+0x0/0x85
    > [<ffffffff81003820>] ? kernel_thread_helper+0x0/0x10
    >---[ end trace 8a7e9310b35e9486 ]---
    
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

