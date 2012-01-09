From: Maxim Uvarov <maxim.uvarov@oracle.com>
Subject: Re: [PATCH] bond_alb: don't disable softirq under bond_alb_xmit
Date: Mon, 09 Jan 2012 10:59:47 -0800
Message-ID: <4F0B3923.4020707@oracle.com>
References: <1325881423-19309-1-git-send-email-maxim.uvarov@oracle.com>	<7449.1325885605@death> <20120107.101450.2214394343146869929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, andy@greyhouse.net,
	amwang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:20425 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932546Ab2AITCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 14:02:22 -0500
In-Reply-To: <20120107.101450.2214394343146869929.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2012 10:14 AM, David Miller wrote:
> From: Jay Vosburgh<fubar@us.ibm.com>
> Date: Fri, 06 Jan 2012 13:33:25 -0800
>
>> Maxim Uvarov<maxim.uvarov@oracle.com>  wrote:
>>
>>> No need to lock soft irqs under bond_alb_xmit()
>>> which already has softirq disabled.
>>
>> 	In commit:
>>
>> commit 6603a6f25e4bca922a7dfbf0bf03072d98850176
>> Author: Jay Vosburgh<fubar@us.ibm.com>
>> Date:   Wed Oct 17 17:37:50 2007 -0700
>>
>>      bonding: Convert more locks to _bh, acquire rtnl, for new locking
>>
>>          Convert more lock acquisitions to _bh flavor to avoid deadlock
>>      with workqueue activity and add acquisition of RTNL in appropriate places.
>>      Affects ALB mode, as well as core bonding functions and sysfs.
>>
>>      Signed-off-by: Andy Gospodarek<andy@greyhouse.net>
>>      Signed-off-by: Jay Vosburgh<fubar@us.ibm.com>
>>      Signed-off-by: Jeff Garzik<jeff@garzik.org>
>>
>> 	the _lock_tx_hashtbl was upgraded from regular to _bh to prevent
>> deadlocks.  I don't recall right offhand what deadlock this prevented,
>> but are we sure there are no possible issues with converting this lock
>> back to a non-_bh acquisition?
>
> Maxim's patch is not changing the BH'ness of the list.
>
>
> He's just avoiding a BH disable which is unnecessary because BH is
> already disabled in the effected code path(s).
>

Yes, I only removed disabling BH for tlb_choose_channel(). In other 
places this lock still disables BH. This makes lock more accurate,
because there are 2 paths for execution: 1. dev_queue_xmit() and BH
are already disabled. 2. netpoll and irqs are disabled. So no need to 
enable/disable BH.

This patch also removes waring:
WARNING: at kernel/softirq.c:159 local_bh_enable_ip+0x69/0x80()
   [<c0461b59>] ? local_bh_enable_ip+0x69/0x80
   [<c045aea1>] warn_slowpath_common+0x81/0xa0
   [<c0461b59>] ? local_bh_enable_ip+0x69/0x80
   [<c045aee2>] warn_slowpath_null+0x22/0x30
   [<c0461b59>] local_bh_enable_ip+0x69/0x80
   [<c086ab83>] _raw_spin_unlock_bh+0x13/0x20
   [<f82b2150>] tlb_choose_channel+0x50/0xb0 [bonding]
   [<f82b3387>] bond_alb_xmit+0x207/0x210 [bonding]
   [<f82ab647>] __bond_start_xmit+0x177/0x1a0 [bonding]
   [<f82abe66>] bond_start_xmit+0x46/0x80 [bonding]
   [<c07c9681>] netpoll_send_skb_on_dev+0x121/0x1a0
   [<c07a9afe>] ? __alloc_skb+0x7e/0x120
   [<c07c996c>] netpoll_send_udp+0x1dc/0x1f0
   [<f838e73f>] write_msg+0x8f/0xc0 [netconsole]
   [<f838e6b0>] ? store_remote_port+0x60/0x60 [netconsole]
   [<c045b2a7>] __call_console_drivers+0x77/0x90
   [<c045b311>] _call_console_drivers+0x51/0x90
   [<c045b60b>] call_console_drivers+0x8b/0xd0
   [<c045b867>] console_unlock+0x37/0xc0
   [<c045be59>] vprintk+0x159/0x300
   [<c0541215>] ? path_openat+0xc5/0x360
   [<c0541595>] ? do_filp_open+0x35/0x80
   [<c045c020>] printk+0x20/0x30
   [<c06acc9d>] __handle_sysrq+0x3d/0x110
   [<c05aaaee>] ? security_file_permission+0x1e/0x90
   [<c06acdba>] write_sysrq_trigger+0x4a/0x50
   [<c06acd70>] ? __handle_sysrq+0x110/0x110
   [<c057e28d>] proc_reg_write+0x5d/0x80
   [<c0534ffb>] vfs_write+0x9b/0x160
   [<c04aff91>] ? audit_syscall_exit+0x381/0x3f0
   [<c057e230>] ? proc_reg_poll+0x80/0x80
   [<c0535622>] sys_write+0x42/0x70
   [<c087231f>] sysenter_do_call+0x12/0x28

Maxim.
