From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [bug, 2.6.24-rc1] sysfs: duplicate filename 'eth0' can not be
 created
Date: Mon, 29 Oct 2007 14:49:06 -0700
Message-ID: <47265552.1010209@hp.com>
References: <20071029211746.GA19876@elte.hu> <4726520F.1020605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:53748 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868AbXJ2VtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:49:10 -0400
In-Reply-To: <4726520F.1020605@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Ingo Molnar wrote:
> 
>> hm, this seems to have popped up in the last few days, never had it 
>> before:
>>
>>   sysfs: duplicate filename 'eth0' can not be created
>>   WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
>>
>>   Call Trace:
>>    [<ffffffff802de00a>] sysfs_add_one+0x54/0xbd
>>    [<ffffffff802dee61>] sysfs_create_link+0xc6/0x11d
>>    [<ffffffff8047c491>] device_rename+0x175/0x1d6
>>    [<ffffffff806180a6>] dev_change_name+0x118/0x211
>>    [<ffffffff8061893c>] dev_ioctl+0x4fa/0x5f8
>>    [<ffffffff8062eb11>] netlink_insert+0x13c/0x14b
>>    [<ffffffff806a877f>] do_page_fault+0x3eb/0x73f
>>    [<ffffffff8060b909>] sock_ioctl+0x1f2/0x200
>>    [<ffffffff802a5a5d>] do_ioctl+0x21/0x6b
>>    [<ffffffff802a5cea>] vfs_ioctl+0x243/0x25c
>>    [<ffffffff802a5d54>] sys_ioctl+0x51/0x71
>>    [<ffffffff8020c02e>] system_call+0x7e/0x83
>>
>>    net eth0: device_rename: sysfs_create_symlink failed (-17)
>>
>> 32-bit bzImage kernel - config attached. (The 64-bit kernel even lost 
>> connectivity due to this and ifcfg-eth0 got renamed to ifcfg-eth0.bak 
>> by kudzu.)
>>
>> detected order of the interfaces is:
>>
>>   forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @1
>>   eth1: RealTek RTL8139 at 0xffffc200001f2000
>>
>> and that's the ordering in /etc/sysconfig/network-scripts as well.
> 
> 
> Does your setup do anything like try to rename the interfaces?
> 
> I cannot think of anything that changed recently in this area in net, 
> off the top of my head.

Ingo -

You are not alone.  I see very similar stuff when I boot a system with a large 
number of interfaces.  At first it was almost every interface generating the 
messages or ones like them, but now with a patch applied (might have come via Jeff?)

hpcpc103:~/linux-2.6.24-rc1# more dev_change_name.patch
--- a/net/core/dev.c    2007-10-24 06:01:31.000000000 -0700
+++ b/net/core/dev.c    2007-10-24 06:41:18.000000000 -0700
@@ -885,6 +885,9 @@ int dev_change_name(struct net_device *d
         if (!dev_valid_name(newname))
                 return -EINVAL;

+       if (strncmp(newname, dev->name, IFNAMSIZ) == 0)
+               return 0;
+
         memcpy(oldname, dev->name, IFNAMSIZ);

         if (strchr(newname, '%')) {

I see far fewer of them:

GSI 60 (level, low) -> CPU 6 (0x0c00) vector 70
sysfs: duplicate filename 'eth6_rename' can not be created
WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
Call Trace:
  [<a0000001000137c0>] show_stack+0x40/0xa0
                                 sp=e000000159abfb90 bsp=e000000159ab8f48
  [<a000000100013850>] dump_stack+0x30/0x60
                                 sp=e000000159abfd60 bsp=e000000159ab8f30
  [<a000000100206d10>] sysfs_add_one+0xb0/0x240
                                 sp=e000000159abfd60 bsp=e000000159ab8f00
  [<a0000001002092c0>] sysfs_create_link+0x200/0x300
                                 sp=e000000159abfd60 bsp=e000000159ab8ed0
  [<a000000100396bb0>] device_rename+0x2d0/0x380
                                 sp=e000000159abfd80 bsp=e000000159ab8e78
  [<a00000010040b690>] dev_change_name+0x2b0/0x4a0
                                 sp=e000000159abfd80 bsp=e000000159ab8e30
  [<a00000010040bd80>] dev_ifsioc+0x500/0x6c0
                                 sp=e000000159abfd90 bsp=e000000159ab8e00
  [<a00000010040cda0>] dev_ioctl+0xe60/0x1160
                                 sp=e000000159abfda0 bsp=e000000159ab8da0
  [<a0000001003ea7f0>] sock_ioctl+0x610/0x660
                                 sp=e000000159abfe10 bsp=e000000159ab8d68
  [<a000000100170650>] do_ioctl+0x90/0x180
                                 sp=e000000159abfe10 bsp=e000000159ab8d28
  [<a000000100170fa0>] vfs_ioctl+0x860/0x8c0
                                 sp=e000000159abfe10 bsp=e000000159ab8ce0
  [<a0000001001710a0>] sys_ioctl+0xa0/0x120
                                 sp=e000000159abfe20 bsp=e000000159ab8c60
  [<a00000010000af20>] ia64_ret_from_syscall+0x0/0x20
                                 sp=e000000159abfe30 bsp=e000000159ab8c60
  [<a000000000010620>] __start_ivt_text+0xffffffff00010620/0x400
                                 sp=e000000159ac0000 bsp=e000000159ab8c60
:
net eth6_rename: device_rename: sysfs_create_symlink failed (-17)
sysfs: duplicate filename 'eth6' can not be created
WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()

...
net eth6: device_rename: sysfs_create_symlink failed (-17)
udev: renamed network interface eth7 to eth6
sysfs: duplicate filename 'eth7' can not be created
WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()

...

                                 sp=e000000159ac0000 bsp=e000000159ab8c60
net eth7: device_rename: sysfs_create_symlink failed (-17)
udev: renamed network interface eth6_rename to eth7
ACPI: PCI Interrupt 0000:14:01.0[A] -> GSI 60 (level, low) -> IRQ 70


Interestingly (?) when I look at my eth7 interface via ethtool I see:

hpcpc103:~/linux-2.6.24-rc1# ethtool -i eth7
driver: Neterion
version: 2.0.26.5
firmware-version:
bus-info: 0000:0f:01.0

but if I look for it in /proc/interrupts I don't see it:

hpcpc103:~/linux-2.6.24-rc1# cat /proc/interrupts | grep eth7
hpcpc103:~/linux-2.6.24-rc1#

and if I look at all of /proc/interrupts:

hpcpc103:~# cat /proc/interrupts
            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5 
CPU6       CPU7
  28:         12         12         12         12         12         12 
12         12          LSAPIC  cpe_poll
  29:          0          0          0          0          0          0 
  0          0          LSAPIC  cmc_poll
  31:          0          0          0          0          0          0 
  0          0          LSAPIC  cmc_hndlr
  48:          0          0          0          0          0          0 
  0          0  IO-SAPIC-level  acpi
  50:          0          0       1065          0          0          0 
  0          0  IO-SAPIC-level  serial
  52:          0          0          0          0        328          0 
  0          0  IO-SAPIC-level  ehci_hcd:usb1
  54:          0          0          0          0          0          0 
32          0  IO-SAPIC-level  ohci_hcd:usb2
  57:          0          0          0          0          0          0 
  0          0  IO-SAPIC-level  ohci_hcd:usb3
  60:          0          0          0          0      11945          0 
  0          0  IO-SAPIC-level  eth6
  61:          0          0          0          0          0     101072 
  0          0  IO-SAPIC-level  eth6 Neterion 10 Gigabit Ethernet-SR Low Profile 
PCI-X 2.0 DDR A
  70:          0          0          0          0          0          0 
25580          0  IO-SAPIC-level  cciss0
232:          0          0          0          0          0          0 
0          0          LSAPIC  mca_rdzv
238:          0          0          0          0          0          0 
0          0          LSAPIC  perfmon
239:    2376190    2376079    2376009    2376005    2376127    2376121 
2375918    2373020          LSAPIC  timer
240:          0          0          0          0          0          0 
0          0          LSAPIC  mca_wkup
252:          0          0          0          0          0          0 
0          0          LSAPIC  tlb_flush
253:        586        255        449        315        448        982 
497        702          LSAPIC  resched
254:        123        162        161        166        168        154 
109        140          LSAPIC  IPI
ERR:          0

it appears as eth6.

rick jones
...


> 
>     Jeff
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

