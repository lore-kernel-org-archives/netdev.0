From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch next 3/4] netxen: fix bonding support
Date: Thu, 22 Oct 2009 22:57:51 -0700
Message-ID: <m1ljj2ps80.fsf@fess.ebiederm.org>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
	<1241586309-12112-4-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47368 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbZJWF5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 01:57:48 -0400
In-Reply-To: <1241586309-12112-4-git-send-email-dhananjay@netxen.com> (Dhananjay Phadke's message of "Tue\,  5 May 2009 22\:05\:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke <dhananjay@netxen.com> writes:

> o Pause traffic during mac addr change.
> o Enable setting mac address for NX3031.

In 2.6.31 when I try and use bonding with the netxen or
even simply set the mac address after the driver has
first loaded but before the nic is brought up I get:

As I read that oops. The problem is that netxen_send_cmd_descs
is being called before tx_ring->txq has been initialized.  
tx_ring->txq happens in open, when the device is brought up.

Any chance you can look at the problem?

Eric


BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
IP: [<ffffffffa0128942>] netxen_send_cmd_descs.clone.2+0x26/0xfe [netxen_nic]
PGD 1fe76067 PUD b4d05067 PMD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
CPU 2 
Modules linked in: ipt_REDIRECT vfat fat loop appletalk ipx p8023 rose ax25 tulip xt_hl ipt_LOG xt_limit ipt_REJECT xt_state xt_tcpudp dummy iptable_filter veth macvlan nfsd lockd nfs_acl auth_rpcgss exportfs sco bridge stp bnep l2cap bluetooth sunrpc cpufreq_ondemand acpi_cpufreq freq_table ext4 jbd2 crc16 dm_mirror dm_region_hash dm_log dm_multipath dm_mod uinput bonding ipv6 kvm_intel kvm fuse xt_multiport iptable_nat ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 tun 8021q i2c_i801 igb i2c_core i5k_amb hwmon i5400_edac edac_core iTCO_wdt iTCO_vendor_support pcspkr shpchp myri10ge floppy netxen_nic sr_mod cdrom serio_raw sg ata_generic pata_acpi ata_piix libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
Pid: 22313, comm: ip Not tainted 2.6.31.2-193574.2006Arora.fc11.x86_64 #1 X7DWU
RIP: 0010:[<ffffffffa0128942>]  [<ffffffffa0128942>] netxen_send_cmd_descs.clone.2+0x26/0xfe [netxen_nic]
RSP: 0018:ffff88005753d638  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000001 RSI: ffff88005753d688 RDI: ffff88012dc8f580
RBP: ffff88005753d678 R08: ffff88012dc8f580 R09: ffff88005753d688
R10: 00000000a388069b R11: 0000000000000246 R12: ffff88012dc8f580
R13: ffff88001fcb6c00 R14: ffff88005753d738 R15: 0000000000000020
FS:  00007f4360f656f0(0000) GS:ffff88002805a000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000020 CR3: 00000000b4de5000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ip (pid: 22313, threadinfo ffff88005753c000, task ffff88002fbdb700)
Stack:
 0000000000000000 00000000a388069b ffffea000136a578 00000000a388069b
<0> ffff88005753d778 ffff88012dc8f580 ffff88012e2cf910 ffff88001fcb6c00
<0> ffff88005753d6d8 ffffffffa0128ae5 000000000a000000 0000000000010001
Call Trace:
 [<ffffffffa0128ae5>] nx_p3_sre_macaddr_change+0x60/0x76 [netxen_nic]
 [<ffffffffa0128ca8>] nx_p3_nic_add_mac+0x129/0x14c [netxen_nic]
 [<ffffffffa0128d57>] netxen_p3_nic_set_multi+0x8c/0x169 [netxen_nic]
 [<ffffffffa0128e54>] netxen_p3_nic_set_mac_addr+0x20/0x38 [netxen_nic]
 [<ffffffffa0129ed2>] netxen_nic_set_mac+0x96/0xd6 [netxen_nic]
 [<ffffffff813128b1>] do_setlink+0x17c/0x360
 [<ffffffff81312e97>] rtnl_newlink+0x2e1/0x4e6
 [<ffffffff81312c53>] ? rtnl_newlink+0x9d/0x4e6
 [<ffffffff810ec697>] ? page_add_new_anon_rmap+0x4d/0x73
 [<ffffffff812f8920>] ? sock_rmalloc+0x39/0xa8
 [<ffffffff810fdc8c>] ? virt_to_head_page+0x1c/0x51
 [<ffffffff813122fe>] rtnetlink_rcv_msg+0x1d0/0x201
 [<ffffffff81327856>] ? netlink_sendmsg+0x18f/0x2ac
 [<ffffffff8131212e>] ? rtnetlink_rcv_msg+0x0/0x201
 [<ffffffff81327b7d>] netlink_rcv_skb+0x4d/0xb4
 [<ffffffff81312113>] rtnetlink_rcv+0x30/0x4b
 [<ffffffff8132764a>] netlink_unicast+0x12f/0x1ac
 [<ffffffff81327950>] netlink_sendmsg+0x289/0x2ac
 [<ffffffff812f4146>] __sock_sendmsg+0x6b/0x8a
 [<ffffffff812f4abf>] sock_sendmsg+0xd6/0x103
 [<ffffffff812f494b>] ? sock_recvmsg+0xd9/0x106
 [<ffffffff8106a257>] ? autoremove_wake_function+0x0/0x5a
 [<ffffffff812ff6b4>] ? verify_iovec+0x5b/0xaf
 [<ffffffff812f4d08>] sys_sendmsg+0x21c/0x2a0
 [<ffffffff810e3711>] ? handle_mm_fault+0x2d6/0x681
 [<ffffffff811ced89>] ? __up_read+0x9c/0xbb
 [<ffffffff8106e264>] ? up_read+0x1c/0x32
 [<ffffffff813a9c3f>] ? do_page_fault+0x260/0x2a4
 [<ffffffff8100bdc2>] system_call_fastpath+0x16/0x1b
Code: 5b 41 5c c9 c3 55 48 89 e5 41 55 41 54 49 89 fc 53 48 83 ec 28 65 48 8b 04 25 28 00 00 00 48 89 45 d8 31 c0 48 8b 9f 28 01 00 00 <4c> 8b 6b 20 48 89 75 c8 49 8d 7d 40 e8 5e e9 27 e1 65 8b 04 25 
RIP  [<ffffffffa0128942>] netxen_send_cmd_descs.clone.2+0x26/0xfe [netxen_nic]
 RSP <ffff88005753d638>
CR2: 0000000000000020
