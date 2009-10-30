From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Fri, 30 Oct 2009 15:57:40 -0700
Message-ID: <m1639wo5gb.fsf@fess.ebiederm.org>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
	<20091030.124153.00934819.davem@davemloft.net>
	<21200.1256937150@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33649 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933004AbZJ3W5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 18:57:39 -0400
In-Reply-To: <21200.1256937150@death.nxdomain.ibm.com> (Jay Vosburgh's message of "Fri\, 30 Oct 2009 14\:12\:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> writes:

> David Miller <davem@davemloft.net> wrote:
>
>>From: ebiederm@xmission.com (Eric W. Biederman)
>>Date: Thu, 29 Oct 2009 17:16:54 -0700
>>
>>> I recently had it pointed out to me that the bonding driver does not
>>> work in a network namespace.  So I have simplified the bonding driver
>>> a bit, added support for ip link add and ip link del, and finally made
>>> the bonding driver work in multiple network namespaces.
>>> 
>>> The most note worthy change in the patchset is the addition of support
>>> in the networking core for registering a sysfs group for a device.
>>> 
>>> Using this in the bonding driver simplifies the code and removes a
>>> userspace race between actions triggered by the netlink event and the
>>> bonding sysfs attributes appearing.
>>
>>I've tossed patches 1-7 into net-next-2.6, thanks Eric.
>
> 	I put patches 1-7 on a recent net-next-2.6, and from a simple
> "insmod bonding.ko; rmmod bonding" I'm seeing the following:
>
> ------------[ cut here ]------------
> WARNING: at fs/proc/generic.c:847 remove_proc_entry+0x1a8/0x1c7()
> Hardware name: IBM eserver xSeries 220 -[8645]-
> remove_proc_entry: removing non-empty directory 'net/bonding', leaking at least 
> 'bond0'
> Modules linked in: bonding(-) ipv6 microcode loop ppdev sworks_agp parport_pc tg
> 3 e100 agpgart parport mii libphy e1000 edd pata_serverworks [last unloaded: spe
> edstep_lib]
> Pid: 6216, comm: rmmod Not tainted 2.6.32-rc3-devel #19
> Call Trace:
>  [<c012ec9d>] warn_slowpath_common+0x60/0x90
>  [<c012ed01>] warn_slowpath_fmt+0x24/0x27
>  [<c01e3e55>] remove_proc_entry+0x1a8/0x1c7
>  [<e0906435>] ? bond_net_exit+0x0/0xa3 [bonding]
>  [<e09064c3>] bond_net_exit+0x8e/0xa3 [bonding]
>  [<c02e6ee8>] unregister_pernet_gen_subsys+0x23/0x3d
>  [<e0910baa>] bonding_exit+0x3a/0x66 [bonding]
>  [<c015ccf3>] sys_delete_module+0x191/0x1f1
>  [<c0147a30>] ? up_read+0x16/0x2a
>  [<c0102a18>] ? restore_all_notrace+0x0/0x18
>  [<c0353357>] ? do_page_fault+0x0/0x393
>  [<c0102904>] sysenter_do_call+0x12/0x32
> ---[ end trace 8f3eaeee682a572c ]---
>
> 	Any thoughts?  I have not as yet investigated further.

Weird.

We have already run:
rtnl_link_unregister. 
  rtnl_kill_links
    dellink(bond0)
      unregister_netdevice(bond0)
          bond_uninit
             bond_remove_proc_entry


So the proc entry should no longer be there.  I'm a little nervous about
the new unregister_netdevice_many but I don't see any obvious problems with
that code.

Were there by any chance any earlier errors that could have prevented the uninit?
You weren't inserting multiple copies of the bonding driver?

Eric
