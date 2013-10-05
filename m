From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH net-next] net: Separate the close_list and the unreg_list
Date: Sat,  5 Oct 2013 06:18:22 -0700
Message-ID: <5250c0b6.45dc420a.738b.6a58@mx.google.com>
To: fruggeri@aristanetworks.com, netdev@vger.kernel.org,
	ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:35464 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab3JFBp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 21:45:27 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so5620419pbc.31
        for <netdev@vger.kernel.org>; Sat, 05 Oct 2013 18:45:27 -0700 (PDT)
In-reply-To: 87eh818jlx.fsf_-_ () xmission ! com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
I am running some more extensive tests with this patch and I ran into the crash below.

It may be caused by

@@ -1301,7 +1301,7 @@ int dev_close(struct net_device *dev)
 	if (dev->flags & IFF_UP) {
 		LIST_HEAD(single);
 
-		list_add(&dev->unreg_list, &single);
+		list_add(&dev->close_list, &single);
 		dev_close_many(&single);
 		list_del(&single);
 	}

dev_close_many expects net_devices to be linked by unreg_list.
Let me know what you think.

Thanks,
Francesco

<1>BUG: unable to handle kernel NULL pointer dereference at 0000000000000190
<1>IP: [<ffffffff8142c709>] packet_notifier+0x1e/0x163
<4>PGD 94f815067 PUD 0 
<4>Oops: 0000 [#1] SMP 
<4>CPU 1 
<4>Modules linked in: dummy loop tulip veth xt_tcpudp iptable_filter nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf macvlan dm_mirror dm_region_hash dm_log uinput ip6table_filter ip6_tables bonding kvm_intel kvm fuse xt_multiport iptable_nat ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 tun 8021q coretemp hwmon crc32c_intel ghash_clmulni_intel sg joydev iTCO_wdt iTCO_vendor_support pcspkr i2c_i801 microcode i2c_core ioatdma dca raid1 aesni_intel cryptd aes_x86_64 aes_generic isci libsas scsi_transport_sas ehci_hcd igb wmi dm_mod [last unloaded: scsi_wait_scan]
<4>
<4>Pid: 14572, comm: Ira Not tainted 3.4.43-1479218.2011fruggeriArora.1.fc14.x86_64 #1 Supermicro X9DRT/X9DRT
<4>RIP: 0010:[<ffffffff8142c709>]  [<ffffffff8142c709>] packet_notifier+0x1e/0x163
<4>RSP: 0018:ffff881006c1f668  EFLAGS: 00210292
<4>RAX: 0000000000000000 RBX: ffff88108dec1810 RCX: ffffffff81a6df10
<4>RDX: ffff88108dec1810 RSI: 0000000000000009 RDI: ffffffff81a6df10
<4>RBP: ffff881006c1f698 R08: 0000000000000000 R09: 0000000000000003
<4>R10: 0000000000000003 R11: 0000000000000000 R12: ffff88108dec1810
<4>R13: 00000000fffffff3 R14: ffffffffa0207050 R15: 0000000000000009
<4>FS:  0000000000000000(0000) GS:ffff88103fc20000(0063) knlGS:00000000f5630b00
<4>CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
<4>CR2: 0000000000000190 CR3: 0000000b405bb000 CR4: 00000000000007e0
<4>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>Process Ira (pid: 14572, threadinfo ffff881006c1e000, task ffff88094f8d8da0)
<4>Stack:
<4> ffff881006c1f698 ffff88108dec1810 0000000000000009 00000000fffffff3
<4> ffffffffa0207050 ffffffffa02f2060 ffff881006c1f6d8 ffffffff814513a5
<4> ffffea000a276500 0000000000000000 0000000000000009 ffff88108dec1810
<4>Call Trace:
<4> [<ffffffff814513a5>] notifier_call_chain+0x32/0x5e
<4> [<ffffffff8104ec06>] raw_notifier_call_chain+0xf/0x11
<4> [<ffffffff813848f6>] call_netdevice_notifiers+0x45/0x4a
<4> [<ffffffff8138493d>] __dev_close_many+0x42/0xbc
<4> [<ffffffff81384a67>] dev_close_many+0x6e/0xf8
<4> [<ffffffff81384b2b>] dev_close+0x3a/0x4d
<4> [<ffffffff81386b54>] dev_change_net_namespace+0xa4/0x1a0
<4> [<ffffffff8139249e>] do_setlink+0x77/0x78b
<4> [<ffffffff810cb555>] ? pmd_offset+0x14/0x3b
<4> [<ffffffff8144e0b9>] ? _raw_spin_lock+0x9/0xb
<4> [<ffffffff810f8317>] ? full_name_hash+0x19/0x5c
<4> [<ffffffff8138661c>] ? dev_name_hash.clone.50+0x24/0x3c
<4> [<ffffffff81393a9b>] rtnl_newlink+0x24d/0x49a
<4> [<ffffffff8139390d>] ? rtnl_newlink+0xbf/0x49a
<4> [<ffffffff8144e0e9>] ? _raw_spin_unlock_irqrestore+0x12/0x14
<4> [<ffffffff810e7c3b>] ? virt_to_head_page+0x9/0x2c
<4> [<ffffffff8139364f>] rtnetlink_rcv_msg+0x24c/0x262
<4> [<ffffffff81393403>] ? __rtnl_unlock+0x12/0x12
<4> [<ffffffff813a7e44>] netlink_rcv_skb+0x40/0x8c
<4> [<ffffffff81392d80>] rtnetlink_rcv+0x21/0x28
<4> [<ffffffff813a795b>] netlink_unicast+0xec/0x155
<4> [<ffffffff813a7c4c>] netlink_sendmsg+0x288/0x2a6
<4> [<ffffffff8137414a>] __sock_sendmsg+0x6e/0x7a
<4> [<ffffffff81374a29>] sock_sendmsg+0xa3/0xbc
<4> [<ffffffff810b195a>] ? generic_file_aio_write+0xa8/0xb8
<4> [<ffffffff811665b9>] ? ext4_file_write+0x1eb/0x240
<4> [<ffffffff810f1247>] ? fget_light+0x33/0x83
<4> [<ffffffff81374aaa>] ? sockfd_lookup_light+0x1b/0x53
<4> [<ffffffff81375f7b>] sys_sendto+0x12a/0x16c
<4> [<ffffffff810ef8a3>] ? fsnotify_modify+0x5d/0x65
<4> [<ffffffff81375fcc>] sys_send+0xf/0x11
<4> [<ffffffff8139cc9c>] compat_sys_socketcall+0xd7/0x19b
<4> [<ffffffff81455bd6>] sysenter_dispatch+0x7/0x21
<4>Code: ff ff 80 8b 48 04 00 00 01 5b 5b c9 c3 55 48 89 e5 41 57 49 89 f7 41 56 41 55 41 54 49 89 d4 53 48 83 ec 08 48 8b 82 48 04 00 00 <4c> 8b b0 90 01 00 00 e9 06 01 00 00 4c 8b ab 58 04 00 00 4d 85 
<1>RIP  [<ffffffff8142c709>] packet_notifier+0x1e/0x163
<4> RSP <ffff881006c1f668>
<4>CR2: 0000000000000190
