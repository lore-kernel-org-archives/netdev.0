From: Ben Greear <greearb@candelatech.com>
Subject: NULL pointer dereference in br_device_event, 2.6.31-rc3 stock kernel.
Date: Thu, 16 Jul 2009 11:25:01 -0700
Message-ID: <4A5F707D.9030202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44888 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932979AbZGPSZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 14:25:02 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n6GIP11q003690
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 11:25:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just saw this crash while shutting down the system.  This was on a stock 2.6.31-rc3 kernel,
pulled yesterday afternoon.

Kernel config is here:
http://www.candelatech.com/oss/i7_config.txt

This is the same system that reports the disable_lro issue in the ixgbe driver,
but I don't think the problems are related.  This is the first time I saw this,
and I've rebooted several times (though mostly using my hacked kernel), so seems
to be some sort of a race.


Jul 16 11:10:24 localhost acpid: exiting
Jul 16 11:10:25 localhost ntpd[1953]: ntpd exiting on signal 15
Jul 16 11:10:25 localhost kernel: Bridge firewalling registered
Jul 16 11:10:25 localhost kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000160
Jul 16 11:10:25 localhost kernel: IP: [<ffffffffa0257666>] br_device_event+0xc6/0x124 [bridge]
Jul 16 11:10:25 localhost kernel: PGD 1b3483067 PUD 1b5195067 PMD 0
Jul 16 11:10:25 localhost kernel: Oops: 0000 [#1] PREEMPT SMP
Jul 16 11:10:25 localhost kernel: last sysfs file: /sys/module/stp/initstate
Jul 16 11:10:25 localhost kernel: CPU 7
Jul 16 11:10:25 localhost kernel: Modules linked in: bridge(+) veth 8021q garp fuse arc4 michael_mic macvlan pktgen sco stp llc bnep l2cap bluetooth nfs lockd 
fscache nfs_acl auth_rpcgss sunrpc ipv6 dm_multipath uinput ixgbe i2c_i801 i2c_core e1000e pcspkr dca mdio iTCO_wdt iTCO_vendor_support ata_generic pata_acpi 
[last unloaded: nf_nat]
Jul 16 11:10:25 localhost kernel: Pid: 6109, comm: modprobe Not tainted 2.6.31-rc3 #1 X8STi
Jul 16 11:10:25 localhost kernel: RIP: 0010:[<ffffffffa0257666>]  [<ffffffffa0257666>] br_device_event+0xc6/0x124 [bridge]
Jul 16 11:10:25 localhost kernel: RSP: 0018:ffff8801b356be38  EFLAGS: 00010246
Jul 16 11:10:25 localhost kernel: RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000000000000
Jul 16 11:10:25 localhost kernel: RDX: ffff8801b933a000 RSI: 0000000000000001 RDI: ffffffffa0260490
Jul 16 11:10:25 localhost kernel: RBP: ffff8801b356be58 R08: 0000000000000000 R09: ffff8801b356bc88
Jul 16 11:10:25 localhost kernel: R10: ffff8801bfc04200 R11: ffffffffa01a0f70 R12: ffff8801b9006f6c
Jul 16 11:10:25 localhost kernel: R13: ffff8801b93471b0 R14: ffff8801b933a000 R15: 0000000000000000
Jul 16 11:10:25 localhost kernel: FS:  00007f1cc039e6f0(0000) GS:ffff8800280ff000(0000) knlGS:0000000000000000
Jul 16 11:10:25 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Jul 16 11:10:25 localhost kernel: CR2: 0000000000000160 CR3: 00000001b0c9e000 CR4: 00000000000006e0
Jul 16 11:10:25 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Jul 16 11:10:25 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Jul 16 11:10:25 localhost kernel: Process modprobe (pid: 6109, threadinfo ffff8801b356a000, task ffff8801ab952de0)
Jul 16 11:10:25 localhost kernel: Stack:
Jul 16 11:10:25 localhost kernel: ffffffffa0260490 ffffffff818dad60 ffff8801b933a000 0000000000000000
Jul 16 11:10:25 localhost kernel: <0> ffff8801b356bea8 ffffffff81345d16 ffffffffa0264000 ffffffff818dadd0
Jul 16 11:10:25 localhost kernel: <0> ffff8801b7c32b48 0000000000000000 ffffffffa0264000 0000000000000000
Jul 16 11:10:25 localhost kernel: Call Trace:
Jul 16 11:10:25 localhost kernel: [<ffffffff81345d16>] register_netdevice_notifier+0x91/0x185
Jul 16 11:10:25 localhost kernel: [<ffffffffa0264000>] ? br_init+0x0/0xcf [bridge]
Jul 16 11:10:25 localhost kernel: [<ffffffffa0264000>] ? br_init+0x0/0xcf [bridge]
Jul 16 11:10:25 localhost kernel: [<ffffffffa0264066>] br_init+0x66/0xcf [bridge]
Jul 16 11:10:25 localhost kernel: [<ffffffff8100a05c>] do_one_initcall+0x56/0x136
Jul 16 11:10:25 localhost kernel: [<ffffffff81066eef>] ? up_read+0x9/0xb
Jul 16 11:10:25 localhost kernel: [<ffffffff810678ba>] ? __blocking_notifier_call_chain+0x56/0x62
Jul 16 11:10:25 localhost kernel: [<ffffffff81077f95>] sys_init_module+0xd1/0x208
Jul 16 11:10:25 localhost kernel: [<ffffffff81011b42>] system_call_fastpath+0x16/0x1b
Jul 16 11:10:25 localhost kernel: Code: 4c 89 e7 e8 a7 fc 18 e1 49 8b 44 24 18 f6 80 60 01 00 00 01 74 2e 4c 89 ef e8 bd 13 00 00 eb 24 f6 42 48 04 75 33 49 8b 
44 24 18 <f6> 80 60 01 00 00 01 74 25 4c 89 e7 e8 73 fc 18 e1 4c 89 ef e8
Jul 16 11:10:25 localhost kernel: RIP  [<ffffffffa0257666>] br_device_event+0xc6/0x124 [bridge]
Jul 16 11:10:25 localhost kernel: RSP <ffff8801b356be38>
Jul 16 11:10:25 localhost kernel: CR2: 0000000000000160
Jul 16 11:10:25 localhost kernel: ---[ end trace 71049551bce4d406 ]---
Jul 16 11:10:25 localhost bluetoothd[1916]: Can't remove GN bridge
Jul 16 11:10:25 localhost bluetoothd[1916]: Can't remove GN bridge
Jul 16 11:10:25 localhost bluetoothd[1916]: Stopping SDP server
Jul 16 11:10:25 localhost bluetoothd[1916]: Exit
...


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

