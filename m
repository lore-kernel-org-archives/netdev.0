From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: bonding: stacking bonding interfaces may lead to oops.
Date: Sat, 22 Jan 2011 23:27:33 +0100
Message-ID: <4D3B59D5.2030909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42451 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab1AVW1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 17:27:36 -0500
Received: by wwa36 with SMTP id 36so3123541wwa.1
        for <netdev@vger.kernel.org>; Sat, 22 Jan 2011 14:27:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While doing some tests with bonding over bonding, I discovered that the following commands cause the 
following errors on 2.6.38-rc1 (from net-next-2.6) :

modprobe bonding max_bonds=0
echo +bond0>/sys/class/net/bonding_masters
echo +bond1>/sys/class/net/bonding_masters
echo +eth1>/sys/class/net/bond1/bonding/slaves
echo +bond1>/sys/class/net/bond0/bonding/slaves
modprobe -r bonding

[  300.525641] bonding: Ethernet Channel Bonding Driver: v3.7.0 (June 2, 2010)
[  300.527813] bonding: bond0 is being created...
[  300.533931] bonding: bond1 is being created...
[  300.538494] bonding: bond1: doing slave updates when interface is down.
[  300.539884] bonding: bond1: Adding slave eth1.
[  300.540872] bonding: bond1: master_dev is not up in bond_enslave
[  300.616961] e1000: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[  300.674624] bonding: bond1: enslaving eth1 as an active interface with an up link.
[  300.681524] bonding: bond0: doing slave updates when interface is down.
[  300.682433] bonding: bond0: Adding slave bond1.
[  300.683055] bonding: bond0: master_dev is not up in bond_enslave
[  300.697352] bonding: bond0: Warning: failed to get speed and duplex from bond1, assumed to be 
100Mb/sec and Full.
[  300.699066] bonding: bond0: enslaving bond1 as an active interface with an up link.
[  321.419266] bonding: bond0: released all slaves
[  321.538024] bonding: bond1: released all slaves
[  321.552104] PGD 236e8067 PUD 2f619067 PMD 0
[  321.552104] CPU 1
[  321.552104] Modules linked in: bonding(-) loop snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm 
snd_timer tpm_tis snd tpm i2c_piix4 psmouse tpm_bios parport_pc evdev serio_raw pcspkr parport 
i2c_core soundcore ac processor snd_page_alloc battery button thermal_sys ext3 jbd mbcache 
ide_gd_mod ide_cd_mod cdrom ata_generic ata_piix libata scsi_mod ohci_hcd piix ehci_hcd usbcore 
ide_core floppy e1000 nls_base [last unloaded: bonding]
[  321.561295]
[  321.561295] Pid: 1437, comm: modprobe Not tainted 2.6.38-rc1+ #2 /VirtualBox
[  321.561295] RIP: 0010:[<ffffffff8127a22a>]  [<ffffffff8127a22a>] qdisc_destroy+0x9/0x9e
[  321.561295] RSP: 0018:ffff88003db1be28  EFLAGS: 00010296
[  321.561295] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88003e1e4180
[  321.561295] RDX: ffffffff8163f780 RSI: 0000000000000000 RDI: 0000000000000000
[  321.561295] RBP: ffff88003db1be88 R08: ffffffff81623a40 R09: ffff8800302725a0
[  321.561295] R10: 00000000012944d0 R11: ffffffff81043d55 R12: ffff880023728000
[  321.561295] R13: ffff88003db1be88 R14: ffffffff817fe0b8 R15: 00000000012944d0
[  321.561295] FS:  00007f58fd01f700(0000) GS:ffff88003fd00000(0000) knlGS:0000000000000000
[  321.561295] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  321.561295] CR2: 0000000000000010 CR3: 000000003005b000 CR4: 00000000000006e0
[  321.561295] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  321.561295] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  321.561295] Process modprobe (pid: 1437, threadinfo ffff88003db1a000, task ffff880030028000)
[  321.561295]  ffff88003db1be88 ffff88003db1bd28 ffff88003db1be88 ffffffff8127a31a
[  321.561295]  ffff88003db1bd28 ffffffff81262f36 ffff88003db1be88 ffffffff817fe040
[  321.561295]  ffffffff817fe038 ffffffff81263037 ffffffffa041e0d0 ffffffff8126e757
[  321.561295]  [<ffffffff8127a31a>] ? dev_shutdown+0x3e/0x67
[  321.561295]  [<ffffffff81262f36>] ? rollback_registered_many+0x12a/0x21d
[  321.561295]  [<ffffffff81263037>] ? unregister_netdevice_many+0xe/0x62
[  321.561295]  [<ffffffff8126e757>] ? __rtnl_link_unregister+0x75/0xc4
[  321.561295]  [<ffffffff8126ea7c>] ? rtnl_link_unregister+0x18/0x21
[  321.561295]  [<ffffffffa0418c8b>] ? bonding_exit+0x37/0x62 [bonding]
[  321.561295]  [<ffffffff81073072>] ? sys_delete_module+0x1ca/0x249
[  321.561295]  [<ffffffff810d287d>] ? do_munmap+0x307/0x329
[  321.561295]  [<ffffffff81317c15>] ? page_fault+0x25/0x30
[  321.561295]  [<ffffffff81009992>] ? system_call_fastpath+0x16/0x1b
[  321.561295]  RSP <ffff88003db1be28>
[  321.634938] ---[ end trace f286ae8c6c72cd08 ]---

After this, any commands that use the network interfaces hang forever : ipconfig, ip addr, ...

Even shutting down the system is not possible... forced to power off.

Only tested under VirtualBox.

	Nicolas.
