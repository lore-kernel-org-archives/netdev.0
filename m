From: Chuck Ebbert <cebbert@redhat.com>
Subject: 3c59x: multiple problems
Date: Tue, 19 Jun 2007 14:58:28 -0400
Message-ID: <46782754.1060408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763177AbXFSS6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 14:58:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More and more people are reporting this error message:

Jun 18 19:54:33 loki kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 18 19:54:33 loki kernel: eth0: transmit timed out, tx_status 00 status 8601.
Jun 18 19:54:33 loki kernel:   diagnostics: net 0ccc media 8880 dma 0000003a fifo 0000
Jun 18 19:54:33 loki kernel: eth0: Interrupt posted but not delivered -- IRQ
blocked by another device?
Jun 18 19:54:33 loki kernel:   Flags; bus-master 1, dirty 80643(3) current 80643(3)
Jun 18 19:54:33 loki kernel:   Transmit list 00000000 vs. ffff81007852d3e0.
Jun 18 19:54:33 loki kernel:   0: @ffff81007852d200  length 8000004a status 0c01004a
Jun 18 19:54:33 loki kernel:   1: @ffff81007852d2a0  length 8000002a status 8001002a
Jun 18 19:54:33 loki kernel:   2: @ffff81007852d340  length 8000002a status 8001002a
Jun 18 19:54:33 loki kernel:   3: @ffff81007852d3e0  length 8000003e status 0001003e
Jun 18 19:54:33 loki kernel:   4: @ffff81007852d480  length 8000003e status 0001003e
Jun 18 19:54:33 loki kernel:   5: @ffff81007852d520  length 8000003e status 0001003e
Jun 18 19:54:33 loki kernel:   6: @ffff81007852d5c0  length 80000055 status 0c010055
Jun 18 19:54:33 loki kernel:   7: @ffff81007852d660  length 80000055 status 0c010055
Jun 18 19:54:33 loki kernel:   8: @ffff81007852d700  length 8000002a status 0001002a
Jun 18 19:54:33 loki kernel:   9: @ffff81007852d7a0  length 80000055 status 0c010055
Jun 18 19:54:33 loki kernel:   10: @ffff81007852d840  length 80000055 status 0c010055
Jun 18 19:54:33 loki kernel:   11: @ffff81007852d8e0  length 8000002a status 0001002a
Jun 18 19:54:33 loki kernel:   12: @ffff81007852d980  length 80000055 status 0c010055
Jun 18 19:54:33 loki kernel:   13: @ffff81007852da20  length 80000055 status 0c010055
Jun 18 19:54:33 loki kernel:   14: @ffff81007852dac0  length 8000002a status 0001002a
Jun 18 19:54:33 loki kernel:   15: @ffff81007852db60  length 8000004a status 0c01004a


And now, a new one from the same driver -- apparently it does request_irq() before
it's really ready to receive an interrupt:

Jun 17 21:16:22 loki kernel: Unable to handle kernel NULL pointer dereference at
00000000000000e0 RIP:
Jun 17 21:16:22 loki kernel:  [<ffffffff881660f8>] :3c59x:boomerang_rx+0x1c0/0x509
Jun 17 21:16:22 loki kernel: PGD 36110067 PUD 3c30e067 PMD 0
Jun 17 21:16:23 loki kernel: Oops: 0000 [1] SMP
Jun 17 21:16:23 loki kernel: last sysfs file: /class/net/eth0/address
Jun 17 21:16:23 loki kernel: CPU 0
Jun 17 21:16:23 loki kernel: Modules linked in: vfat fat usb_storage hfsplus
nf_nat_ftp iptable_nat nf_nat iptable_mangle nf_conntrack_ftp autofs4 it87
hwmon_vid i2c_isa eeprom sunrpc ipv6 nf_conntrack_netbios_ns nf_conntrack_ipv4
xt_state nf_conntrack nfnetlink xt_tcpudp ipt_REJECT iptable_filter ip_tables
x_tables dm_multipath raid1 video sbs i2c_ec button dock battery ac lp loop
snd_hda_intel snd_hda_codec snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm parport_pc snd_timer parport
serio_raw snd pcspkr k8_edac soundcore edac_mc k8temp hwmon snd_page_alloc
i2c_nforce2 3c59x i2c_core mii shpchp forcedeth sr_mod cdrom sg dm_snapshot
dm_zero dm_mirror dm_mod pata_amd ata_generic sata_nv libata sd_mod scsi_mod
raid456 xor ext3 jbd mbcache ehci_hcd ohci_hcd uhci_hcd
Jun 17 21:16:23 loki kernel: Pid: 4824, comm: ip Not tainted 2.6.21-1.3228.fc7 #1
Jun 17 21:16:23 loki kernel: RIP: 0010:[<ffffffff881660f8>] 
[<ffffffff881660f8>] :3c59x:boomerang_rx+0x1c0/0x509
Jun 17 21:16:23 loki kernel: RSP: 0018:ffff81003dd23c98  EFLAGS: 00010246
Jun 17 21:16:23 loki kernel: RAX: 0000000000000000 RBX: ffff810065e41d80 RCX: 0000000000000000
Jun 17 21:16:23 loki kernel: RDX: ffff81007f0eb000 RSI: 0000000000000000 RDI: ffff81007f557870
Jun 17 21:16:23 loki kernel: RBP: ffff81007f0eb700 R08: 0000000000000000 R09: ffff810065e41d80
Jun 17 21:16:23 loki kernel: R10: 00007fff5a892ea4 R11: 0000000000000246 R12: 000000000000000c
Jun 17 21:16:23 loki kernel: R13: 000000000000003c R14: 000000000000003c R15: 000000006000803c
Jun 17 21:16:23 loki kernel: FS:  00002aaaaaab5810(0000) GS:ffffffff8059d000(0000) knlGS:0000000000000000
Jun 17 21:16:23 loki kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Jun 17 21:16:23 loki kernel: CR2: 00000000000000e0 CR3: 000000003c30d000 CR4: 00000000000006e0
Jun 17 21:16:23 loki kernel: Process ip (pid: 4824, threadinfo ffff81003dd22000, task ffff810016309100)
Jun 17 21:16:23 loki kernel: Stack:  ffff81007f0eb000 0000078000001000 ffffc20000028000 0000001f7fee5d40
Jun 17 21:16:23 loki kernel:  000000006ad23812 00000000fffffff4 ffff810058115680 0000000000008601
Jun 17 21:16:23 loki kernel:  ffff81007f0eb700 ffff81007f0eb000 0000000000000010 ffffffff88166e57
Jun 17 21:16:23 loki kernel: Call Trace:
Jun 17 21:16:23 loki kernel:  [<ffffffff88166e57>] :3c59x:boomerang_interrupt+0x13b/0x3f1
Jun 17 21:16:23 loki kernel:  [<ffffffff88166d1c>] :3c59x:boomerang_interrupt+0x0/0x3f1
Jun 17 21:16:23 loki kernel:  [<ffffffff802ae090>] request_irq+0xcc/0xfd
Jun 17 21:16:23 loki kernel:  [<ffffffff88169033>] :3c59x:vortex_open+0x44/0x20c
Jun 17 21:16:23 loki kernel:  [<ffffffff803f0da0>] dev_open+0x2f/0x6e
Jun 17 21:16:23 loki kernel:  [<ffffffff803ef650>] dev_change_flags+0x5a/0x11a
Jun 17 21:16:23 loki kernel:  [<ffffffff80422705>] devinet_ioctl+0x235/0x59c
Jun 17 21:16:23 loki kernel:  [<ffffffff803e7f35>] sock_ioctl+0x1c8/0x1e5
Jun 17 21:16:23 loki kernel:  [<ffffffff8023d539>] do_ioctl+0x21/0x6b
Jun 17 21:16:23 loki kernel:  [<ffffffff8022deac>] vfs_ioctl+0x24e/0x267
Jun 17 21:16:23 loki kernel:  [<ffffffff8024737b>] sys_ioctl+0x59/0x78
Jun 17 21:16:23 loki kernel:  [<ffffffff8025711e>] system_call+0x7e/0x83


[https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=243960]
