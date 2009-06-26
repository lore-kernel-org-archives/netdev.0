From: sdrb <sdrb@onet.eu>
Subject: Re: hunging ifenslave command
Date: Fri, 26 Jun 2009 15:49:48 +0200
Message-ID: <4A44D1FC.8090001@onet.eu>
References: <4A3A3DEA.20602@onet.eu> <4A3CE5D5.8070308@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010304010107020907080100"
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3m5.poczta.onet.pl ([213.180.138.34]:35587 "EHLO
	smtp3m5.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177AbZFZNvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 09:51:23 -0400
Received: from ip-83-238-22-2.netia.com.pl ([83.238.22.2]:45180 "EHLO
	[192.168.242.54]" rhost-flags-OK-FAIL-OK-FAIL) by ps3.mod5.onet
	with ESMTPSA id S50347530AbZFZNvX4a8rK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 15:51:23 +0200
In-Reply-To: <4A3CE5D5.8070308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010304010107020907080100
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit

Jarek Poplawski pisze:
> sdrb wrote, On 06/18/2009 03:15 PM:
> 
>> Hello,
>>
>> I have got problem with hunging "ifenslave" command.
>> I configured bond0 interfaces with 3 slaved interfaces: eth0, eth1 and 
>> eth2. While I'm removing one of it - sometimes only the "ifenslave" 
>> command hangs up but sometimes the whole system is hanging up completely 
>> - so it's not possible to even write on the console.
>>
>> I'm using linux kernel 2.6.27.10 with bonding driver version v3.3.0 
>> (June 10, 2008) and ethernet card driver r8168 version 8.006.00-NAPI.
>>
>> Anyone knows where is the problem with it?
> 
> 
> Hi,
> 
> I don't know, but I guess, if anyone knew it would be fixed now. So, I'd
> recommend trying the current stable (2.6.30), and if no difference, maybe
> some debugging like turning on lockdep (lock debugging with prove
> locking correctness). If still nothing reported, try to get a few SysRq
> logs when it happens e.g. Alt-PrtScr with t, d, w, q, and send them with
> .config and dmesg (gzipped or as attachments to the bugzilla report).

Ok, I dig a little in the 2.6.27.10 kernel and I've taken the newest 
driver (ver 8.012.00) from the realtek website.
Sorry - I haven't tested it under 2.6.30, because I had to fix it just 
for 2.6.27.10.

I investigated this problem and I noticed that probably there is problem 
with rtnl_lock().
Below there is backtrace for three tasks I've got from logs:


<6>SysRq : Show Blocked State
<6>  task                        PC stack   pid father
<6>events/2      D ffff88003e155d50     0    13      2
<0> ffff88003e155d20 0000000000000046 0000000000000000 ffff88003e2fe15d
<0> 0000000000000001 ffff88003e0c6140 ffff88003e155cb8 00000001000e5496
<0> ffff88003e150430 ffff88003e150200 0000000000000001 0000000000000000
<0>Call Trace:
<0> [<ffffffff806cddf5>] mutex_lock_nested+0xe5/0x290
<0> [<ffffffff806204d2>] ? rtnl_lock+0x12/0x20
<0> [<ffffffff8025d28d>] ? trace_hardirqs_on+0xd/0x10
<0> [<ffffffff80623060>] ? linkwatch_event+0x0/0x40
<0> [<ffffffff806204d2>] rtnl_lock+0x12/0x20
<0> [<ffffffff8062306d>] linkwatch_event+0xd/0x40
<0> [<ffffffff80249c39>] ? run_workqueue+0x19/0x210
<0> [<ffffffff80249d07>] run_workqueue+0xe7/0x210
<0> [<ffffffff80249cb4>] ? run_workqueue+0x94/0x210
<0> [<ffffffff8025d28d>] ? trace_hardirqs_on+0xd/0x10
<0> [<ffffffff80249ecc>] worker_thread+0x9c/0xf0
<0> [<ffffffff8024e180>] ? autoremove_wake_function+0x0/0x40
<0> [<ffffffff8025d28d>] ? trace_hardirqs_on+0xd/0x10
<0> [<ffffffff8024e180>] ? autoremove_wake_function+0x0/0x40
<0> [<ffffffff80249e30>] ? worker_thread+0x0/0xf0
<0> [<ffffffff8024d9f8>] kthread+0x68/0xa0
<0> [<ffffffff8020d3b9>] child_rip+0xa/0x11
<0> [<ffffffff8020c9ef>] ? restore_args+0x0/0x30
<0> [<ffffffff8024d990>] ? kthread+0x0/0xa0
<0> [<ffffffff8020d3af>] ? child_rip+0x0/0x11
<0>
<6>snmpd         D ffff88003e477c68     0 10287      1
<0> ffff88003e477c38 0000000000200046 0000000000000000 ffff88003e1e3160
<0> ffffffff80231d50 ffff88003e122fa0 ffff88003e477bd0 00000001000e556a
<0> ffff88003e1e3390 ffff88003e1e3160 000000003e1e3160 0000000000000000
<0>Call Trace:
<0> [<ffffffff80231d50>] ? default_wake_function+0x0/0x10
<0> [<ffffffff806cddf5>] mutex_lock_nested+0xe5/0x290
<0> [<ffffffff806204d2>] ? rtnl_lock+0x12/0x20
<0> [<ffffffff806204d2>] rtnl_lock+0x12/0x20
<0> [<ffffffff806186f0>] dev_ioctl+0x1b0/0x540
<0> [<ffffffff80607f08>] sock_ioctl+0x128/0x250
<0> [<ffffffff802b4d22>] vfs_ioctl+0xa2/0xc0
<0> [<ffffffff802b4dcb>] do_vfs_ioctl+0x8b/0x2d0
<0> [<ffffffff802b5092>] sys_ioctl+0x82/0xa0
<0> [<ffffffff802e105f>] dev_ifconf+0xef/0x230
<0> [<ffffffff802e33d9>] compat_sys_ioctl+0x2e9/0x3e0
<0> [<ffffffff806cf87d>] ? lockdep_sys_exit_thunk+0x35/0x67
<0> [<ffffffff806cf807>] ? trace_hardirqs_on_thunk+0x3a/0x3f
<0> [<ffffffff80229f52>] ia32_sysret+0x0/0xa
<0>
<6>ifenslave     D ffff880027425a50     0 14957  14950
<0> ffff880027425908 0000000000000046 0000000000000000 ffff8800010eeb80
<0> ffff8800010eeb80 ffff88003e0c6140 ffff8800274258a0 00000001000e54a3
<0> ffff88002f69c430 ffff88002f69c200 00000000010eec18 0000000000000000
<0>Call Trace:
<0> [<ffffffff8022f990>] ? finish_task_switch+0x0/0xe0
<0> [<ffffffff806cda06>] schedule_timeout+0xb6/0xc0
<0> [<ffffffff8025d28d>] ? trace_hardirqs_on+0xd/0x10
<0> [<ffffffff806cffeb>] ? _spin_unlock_irq+0x2b/0x40
<0> [<ffffffff806cd52c>] wait_for_common+0xcc/0x1a0
<0> [<ffffffff80231d50>] ? default_wake_function+0x0/0x10
<0> [<ffffffff80231e2e>] ? __wake_up+0x4e/0x70
<0> [<ffffffff80231d50>] ? default_wake_function+0x0/0x10
<0> [<ffffffff806cd618>] wait_for_completion+0x18/0x20
<0> [<ffffffff8024a04b>] flush_cpu_workqueue+0x8b/0xb0
<0> [<ffffffff80249f20>] ? wq_barrier_func+0x0/0x10
<0> [<ffffffff8024a0da>] flush_workqueue+0x6a/0x90
<0> [<ffffffff8024a070>] ? flush_workqueue+0x0/0x90
<0> [<ffffffff8024a590>] flush_scheduled_work+0x10/0x20
<0> [<ffffffffa006e3b0>] rtl8168_down+0x60/0xf0 [r8168]
<0> [<ffffffffa006e46f>] rtl8168_close+0x2f/0xc0 [r8168]
<0> [<ffffffff8061512f>] dev_close+0x6f/0xa0
<0> [<ffffffffa0102fcd>] bond_release+0x21d/0x410 [bonding]
<0> [<ffffffff806cffb6>] ? _read_unlock+0x26/0x30
<0> [<ffffffffa0105fab>] bond_do_ioctl+0x4cb/0x540 [bonding]
<0> [<ffffffff806cdec8>] ? mutex_lock_nested+0x1b8/0x290
<0> [<ffffffff806204d2>] ? rtnl_lock+0x12/0x20
<0> [<ffffffff8061838a>] dev_ifsioc+0x12a/0x2e0
<0> [<ffffffff806186ca>] dev_ioctl+0x18a/0x540
<0> [<ffffffffa002387a>] ? aufs_fault+0x14a/0x310 [aufs]
<0> [<ffffffff80607f08>] sock_ioctl+0x128/0x250
<0> [<ffffffff802b4d22>] vfs_ioctl+0xa2/0xc0
<0> [<ffffffff802b4dcb>] do_vfs_ioctl+0x8b/0x2d0
<0> [<ffffffff802b5092>] sys_ioctl+0x82/0xa0
<0> [<ffffffff802e1362>] bond_ioctl+0x122/0x140
<0> [<ffffffff802e33d9>] compat_sys_ioctl+0x2e9/0x3e0
<0> [<ffffffff806cf87d>] ? lockdep_sys_exit_thunk+0x35/0x67
<0> [<ffffffff806cf807>] ? trace_hardirqs_on_thunk+0x3a/0x3f
<0> [<ffffffff80229f52>] ia32_sysret+0x0/0xa


I've made some patch for r8168 driver and it seems it works, but I'm not 
sure if I did it correctly or if it isn't too dangerous solution :)
The patch is in attachment. With this patch the "ifenslave" command 
doesn't hang as earlier.
Can anyone review it?


sdrb


--------------010304010107020907080100
Content-Type: text/plain;
 name="r8168_n.c.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8168_n.c.diff"

--- r8168_n.c	2009-04-21 05:05:33.000000000 +0200
+++ r8168_n.c	2009-06-26 15:04:12.988842186 +0200
@@ -5752,7 +5752,7 @@ rtl8168_down(struct net_device *dev)
 	rtl8168_delete_esd_timer(dev, &tp->esd_timer);
 	rtl8168_delete_link_timer(dev, &tp->link_timer);
 
-	flush_scheduled_work();
+	cancel_delayed_work(&tp->task);
 
 #ifdef CONFIG_R8168_NAPI
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)

--------------010304010107020907080100--
