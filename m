From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Wed, 15 Apr 2009 13:55:26 -0700
Message-ID: <20090415135526.2afc4d18@nehalam>
References: <20090411174801.GG6822@linux.vnet.ibm.com>
	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>
	<20090412173108.GO6822@linux.vnet.ibm.com>
	<20090412.181330.23529546.davem@davemloft.net>
	<20090413040413.GQ6822@linux.vnet.ibm.com>
	<20090413095309.631cf395@nehalam>
	<49E48136.5060700@trash.net>
	<49E49C65.8060808@cosmosbay.com>
	<20090414074554.7fa73e2f@nehalam>
	<49E4B0A5.70404@cosmosbay.com>
	<b6a2187b0904140951r3c6a41fdnc26b149202bdfa84@mail.gmail.com>
	<20090414111716.28585806@nehalam>
	<49E4E3E8.5090201@cosmosbay.com>
	<20090414141351.0f63ac98@nehalam>
	<49E502B5.7070700@cosmosbay.com>
	<49E5BDF7.8090502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E5BDF7.8090502@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like there is some recursive path into ip_tables that makes the
per-cpu spinlock break.  I get lockup's with KVM networking.

Suggestions?

[ 1931.788787] virbr3: port 1(vnet2) entering forwarding state
[ 2106.068500] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6
[ 2106.068501] Call Trace:
[ 2106.068503]  <IRQ>  [<ffffffff80393a09>] ? _raw_spin_lock+0xdd/0x105
[ 2106.068513]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2106.068516]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2106.068521]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2106.068525]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2106.068528]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2106.068536]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2106.068540]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2106.068544]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2106.068547]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2106.068550]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2106.068552]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2106.068555]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2106.068557]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2106.068559]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2106.068562]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2106.068566]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2106.068569]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2106.068571]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2106.068575]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2106.068578]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2106.068581]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2106.068584]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2106.068587]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2106.068589]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2106.068591]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2106.068594]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2106.068596]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2106.068598]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2106.068601]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2106.068604]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2106.068610]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2106.068616]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2106.068619]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2106.068625]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2106.068631]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2106.068633]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2106.068639]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2106.068641]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2106.068647]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2106.068652]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2106.068655]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2106.068657]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2106.068660]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2106.068663]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2106.068665]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2106.068668]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2106.068671]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2106.068672]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2106.068676]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2106.068680]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2106.068684]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2106.068687]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2106.068691]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2106.068701]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2106.068704]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2106.068706]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2106.068709]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2106.068711]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2106.068714]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2171.106240] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2171.106283] CPU 6:
[ 2171.106284] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2171.106322] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2171.106324] RIP: 0010:[<ffffffff8039039f>]  [<ffffffff8039039f>] delay_tsc+0x26/0x57
[ 2171.106330] RSP: 0018:ffff8800281a34f8  EFLAGS: 00000202
[ 2171.106332] RAX: 00000547850e39df RBX: 0000000000000006 RCX: 00000000850e39df
[ 2171.106333] RDX: 00000000850e39df RSI: 0000000000000001 RDI: 0000000000000001
[ 2171.106335] RBP: ffffffff8020bbd3 R08: ffffffff850e39a4 R09: 0000000000013a4b
[ 2171.106337] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2171.106339] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2171.106341] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2171.106343] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2171.106344] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2171.106346] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2171.106348] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2171.106349] Call Trace:
[ 2171.106350]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 2171.106356]  [<ffffffff803903cf>] ? delay_tsc+0x56/0x57
[ 2171.106359]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2171.106364]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2171.106367]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2171.106372]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2171.106376]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2171.106379]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2171.106387]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2171.106391]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2171.106395]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2171.106398]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2171.106401]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2171.106403]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2171.106405]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2171.106408]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2171.106410]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2171.106412]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2171.106416]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2171.106418]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2171.106421]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2171.106424]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2171.106428]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2171.106431]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2171.106434]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2171.106436]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2171.106439]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2171.106441]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2171.106443]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2171.106445]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2171.106448]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2171.106451]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2171.106453]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2171.106460]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2171.106466]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2171.106469]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2171.106474]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2171.106480]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2171.106483]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2171.106488]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2171.106491]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2171.106496]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2171.106502]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2171.106505]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2171.106507]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2171.106510]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2171.106512]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2171.106515]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2171.106518]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2171.106521]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2171.106522]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2171.106526]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2171.106530]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2171.106533]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2171.106536]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2171.106539]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2171.106549]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2171.106552]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2171.106554]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2171.106556]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2171.106559]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2171.106563]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2236.604439] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2236.604494] CPU 6:
[ 2236.604496] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2236.604543] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2236.604545] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 2236.604551] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 2236.604552] RAX: 000000004ae54875 RBX: 0000000000000006 RCX: 000000004ae54852
[ 2236.604554] RDX: 0000000000000570 RSI: 0000000000000001 RDI: 0000000000000001
[ 2236.604556] RBP: ffffffff8020bbd3 R08: 000000004ae54837 R09: 0000000000013a4b
[ 2236.604558] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2236.604561] R13: 0000000000000006 R14: 000001fc89170ac9 R15: ffffffff8021d470
[ 2236.604563] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2236.604566] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2236.604568] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2236.604570] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2236.604573] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2236.604575] Call Trace:
[ 2236.604577]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 2236.604586]  [<ffffffff80390382>] ? delay_tsc+0x9/0x57
[ 2236.604590]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2236.604595]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2236.604598]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2236.604603]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2236.604607]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2236.604610]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2236.604618]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2236.604622]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2236.604626]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2236.604629]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2236.604632]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2236.604634]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2236.604636]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2236.604639]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2236.604641]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2236.604643]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2236.604647]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2236.604650]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2236.604653]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2236.604656]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2236.604660]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2236.604663]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2236.604666]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2236.604668]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2236.604670]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2236.604672]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2236.604675]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2236.604677]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2236.604679]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2236.604682]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2236.604685]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2236.604691]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2236.604697]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2236.604700]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2236.604706]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2236.604711]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2236.604714]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2236.604719]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2236.604722]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2236.604727]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2236.604733]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2236.604736]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2236.604738]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2236.604741]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2236.604743]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2236.604746]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2236.604748]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2236.604751]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2236.604752]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2236.604756]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2236.604760]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2236.604763]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2236.604766]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2236.604769]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2236.604779]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2236.604782]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2236.604784]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2236.604787]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2236.604789]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2236.604792]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2302.102637] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2302.102680] CPU 6:
[ 2302.102681] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2302.102719] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2302.102721] RIP: 0010:[<ffffffff80210d95>]  [<ffffffff80210d95>] native_read_tsc+0x0/0x11
[ 2302.102727] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000206
[ 2302.102728] RAX: 0000059910bc579f RBX: 0000000000000006 RCX: 0000000010bc579f
[ 2302.102730] RDX: 0000000010bc579f RSI: 0000000000000001 RDI: 0000000000000001
[ 2302.102732] RBP: ffffffff8020bbd3 R08: 0000000010bc5776 R09: 0000000000013a4b
[ 2302.102733] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2302.102735] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2302.102737] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2302.102739] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2302.102741] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2302.102742] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2302.102744] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2302.102746] Call Trace:
[ 2302.102747]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 2302.102754]  [<ffffffff803903dc>] ? __delay+0x0/0xa
[ 2302.102757]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2302.102762]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2302.102765]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2302.102769]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2302.102773]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2302.102776]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2302.102784]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2302.102788]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2302.102791]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2302.102794]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2302.102797]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2302.102799]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2302.102801]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2302.102804]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2302.102806]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2302.102808]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2302.102812]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2302.102814]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2302.102817]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2302.102820]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2302.102824]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2302.102827]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2302.102830]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2302.102832]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2302.102835]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2302.102837]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2302.102839]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2302.102841]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2302.102844]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2302.102846]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2302.102849]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2302.102855]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2302.102862]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2302.102864]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2302.102870]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2302.102876]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2302.102878]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2302.102884]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2302.102886]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2302.102892]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2302.102897]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2302.102900]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2302.102903]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2302.102905]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2302.102908]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2302.102910]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2302.102913]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2302.102915]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2302.102917]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2302.102921]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2302.102924]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2302.102928]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2302.102930]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2302.102934]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2302.102944]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2302.102946]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2302.102948]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2302.102951]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2302.102953]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2302.102956]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2367.600835] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2367.600879] CPU 6:
[ 2367.600880] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2367.600918] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2367.600920] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 2367.600925] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 2367.600927] RAX: 00000000d69365df RBX: 0000000000000006 RCX: 00000000d69365bc
[ 2367.600929] RDX: 00000000000005c1 RSI: 0000000000000001 RDI: 0000000000000001
[ 2367.600930] RBP: ffffffff8020bbd3 R08: ffffffffd69365a4 R09: 0000000000013a4b
[ 2367.600932] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2367.600934] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2367.600936] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2367.600938] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2367.600939] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2367.600941] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2367.600943] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2367.600944] Call Trace:
[ 2367.600946]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 2367.600952]  [<ffffffff80390380>] ? delay_tsc+0x7/0x57
[ 2367.600956]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2367.600961]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2367.600964]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2367.600969]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2367.600973]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2367.600976]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2367.600984]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2367.600987]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2367.600991]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2367.600994]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2367.600997]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2367.600999]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2367.601001]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2367.601004]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2367.601006]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2367.601009]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2367.601012]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2367.601015]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2367.601017]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2367.601021]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2367.601024]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2367.601027]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2367.601030]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2367.601032]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2367.601035]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2367.601037]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2367.601039]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2367.601041]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2367.601044]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2367.601047]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2367.601049]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2367.601056]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2367.601062]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2367.601065]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2367.601070]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2367.601076]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2367.601079]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2367.601084]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2367.601087]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2367.601092]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2367.601098]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2367.601100]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2367.601103]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2367.601106]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2367.601108]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2367.601111]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2367.601114]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2367.601116]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2367.601118]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2367.601122]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2367.601126]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2367.601129]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2367.601132]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2367.601136]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2367.601145]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2367.601148]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2367.601150]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2367.601153]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2367.601155]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2367.601158]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2433.099031] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2433.099074] CPU 6:
[ 2433.099076] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2433.099114] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2433.099115] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 2433.099121] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 2433.099123] RAX: 000000009c6a7306 RBX: ffff8800281b2730 RCX: 000000009c6a72ee
[ 2433.099124] RDX: 00000000000005ea RSI: 0000000000000001 RDI: 0000000000000001
[ 2433.099126] RBP: ffffffff8020bbd3 R08: ffffffff9c6a72ee R09: 0000000000013a4b
[ 2433.099128] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2433.099130] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2433.099132] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2433.099134] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2433.099136] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2433.099137] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2433.099139] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2433.099140] Call Trace:
[ 2433.099142]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 2433.099149]  [<ffffffff803939b1>] ? _raw_spin_lock+0x85/0x105
[ 2433.099152]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2433.099156]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2433.099159]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2433.099164]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2433.099168]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2433.099171]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2433.099179]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2433.099183]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2433.099187]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2433.099190]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2433.099193]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2433.099195]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2433.099197]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2433.099200]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2433.099202]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2433.099205]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2433.099208]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2433.099211]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2433.099214]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2433.099217]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2433.099221]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2433.099224]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2433.099227]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2433.099229]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2433.099231]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2433.099234]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2433.099236]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2433.099238]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2433.099241]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2433.099244]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2433.099246]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2433.099252]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2433.099259]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2433.099261]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2433.099267]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2433.099273]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2433.099275]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2433.099281]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2433.099284]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2433.099289]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2433.099295]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2433.099297]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2433.099300]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2433.099302]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2433.099305]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2433.099307]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2433.099310]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2433.099313]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2433.099314]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2433.099318]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2433.099322]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2433.099325]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2433.099328]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2433.099331]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2433.099341]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2433.099344]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2433.099346]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2433.099348]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2433.099351]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2433.099354]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
Apr 15 08:28:38 nehalam syslogd 1.5.0#5ubuntu3: restart.
[ 2498.597229] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2498.597272] CPU 6:
[ 2498.597274] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2498.597312] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2498.597313] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 2498.597319] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 2498.597321] RAX: 00000000624181c5 RBX: 0000000000000006 RCX: 00000000624181a2
[ 2498.597323] RDX: 0000000000000613 RSI: 0000000000000001 RDI: 0000000000000001
[ 2498.597324] RBP: ffffffff8020bbd3 R08: 000000006241818a R09: 0000000000013a4b
[ 2498.597326] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2498.597328] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2498.597330] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2498.597332] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2498.597333] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2498.597335] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2498.597337] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2498.597338] Call Trace:
[ 2498.597340]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 2498.597347]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2498.597349]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2498.597354]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2498.597357]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2498.597362]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2498.597366]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2498.597369]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2498.597377]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2498.597381]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2498.597385]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2498.597388]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2498.597390]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2498.597393]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2498.597395]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2498.597398]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2498.597400]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2498.597402]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2498.597406]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2498.597409]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2498.597411]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2498.597415]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2498.597418]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2498.597421]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2498.597424]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2498.597426]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2498.597429]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2498.597431]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2498.597433]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2498.597436]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2498.597438]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2498.597441]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2498.597443]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2498.597450]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2498.597456]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2498.597458]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2498.597464]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2498.597470]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2498.597472]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2498.597478]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2498.597480]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2498.597486]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2498.597491]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2498.597494]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2498.597497]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2498.597499]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2498.597502]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2498.597504]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2498.597507]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2498.597509]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2498.597511]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2498.597515]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2498.597519]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2498.597522]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2498.597525]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2498.597529]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2498.597539]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2498.597542]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2498.597544]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2498.597546]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2498.597549]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2498.597552]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2564.096427] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2564.096470] CPU 6:
[ 2564.096472] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2564.096512] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2564.096513] RIP: 0010:[<ffffffff80390382>]  [<ffffffff80390382>] delay_tsc+0x9/0x57
[ 2564.096519] RSP: 0018:ffff8800281a3530  EFLAGS: 00000202
[ 2564.096521] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 00000000284159f4
[ 2564.096523] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 2564.096525] RBP: ffffffff8020bbd3 R08: 00000000284159f4 R09: 0000000000013a4b
[ 2564.096526] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34b0
[ 2564.096528] R13: 000000002471c8ef R14: 0000000028188f77 R15: ffffffff8021d470
[ 2564.096530] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2564.096532] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2564.096534] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2564.096536] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2564.096537] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2564.096539] Call Trace:
[ 2564.096540]  <IRQ>  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2564.096549]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2564.096552]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2564.096557]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2564.096561]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2564.096564]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2564.096572]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2564.096576]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2564.096580]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2564.096583]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2564.096585]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2564.096588]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2564.096590]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2564.096593]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2564.096595]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2564.096597]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2564.096601]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2564.096604]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2564.096606]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2564.096610]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2564.096613]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2564.096616]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2564.096619]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2564.096622]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2564.096624]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2564.096626]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2564.096629]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2564.096631]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2564.096633]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2564.096636]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2564.096639]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2564.096645]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2564.096651]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2564.096654]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2564.096660]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2564.096666]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2564.096668]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2564.096674]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2564.096676]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2564.096682]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2564.096687]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2564.096690]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2564.096693]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2564.096695]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2564.096698]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2564.096700]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2564.096704]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2564.096707]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2564.096708]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2564.096712]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2564.096716]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2564.096720]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2564.096723]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2564.096727]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2564.096736]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2564.096739]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2564.096741]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2564.096744]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2564.096746]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2564.096749]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2629.594624] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2629.594668] CPU 6:
[ 2629.594669] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2629.594707] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2629.594709] RIP: 0010:[<ffffffff803903c5>]  [<ffffffff803903c5>] delay_tsc+0x4c/0x57
[ 2629.594715] RSP: 0018:ffff8800281a34f8  EFLAGS: 00000206
[ 2629.594717] RAX: 0000000000000012 RBX: 0000000000000006 RCX: 00000000ee1867ed
[ 2629.594718] RDX: 00000000ee1867ed RSI: 0000000000000001 RDI: 0000000000000001
[ 2629.594720] RBP: ffffffff8020bbd3 R08: ffffffffee1867ed R09: 0000000000013a4b
[ 2629.594722] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2629.594724] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2629.594726] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2629.594728] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2629.594729] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2629.594731] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2629.594733] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2629.594735] Call Trace:
[ 2629.594736]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 2629.594742]  [<ffffffff803939a9>] ? _raw_spin_lock+0x7d/0x105
[ 2629.594745]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2629.594749]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2629.594752]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2629.594757]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2629.594761]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2629.594764]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2629.594772]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2629.594776]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2629.594780]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2629.594783]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2629.594786]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2629.594788]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2629.594791]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2629.594793]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2629.594796]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2629.594798]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2629.594801]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2629.594804]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2629.594806]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2629.594810]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2629.594814]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2629.594817]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2629.594820]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2629.594822]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2629.594824]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2629.594827]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2629.594829]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2629.594831]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2629.594834]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2629.594837]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2629.594839]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2629.594845]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2629.594852]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2629.594854]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2629.594860]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2629.594866]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2629.594868]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2629.594874]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2629.594877]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2629.594882]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2629.594888]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2629.594890]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2629.594893]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2629.594896]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2629.594898]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2629.594901]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2629.594904]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2629.594906]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2629.594908]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2629.594912]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2629.594916]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2629.594919]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2629.594922]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2629.594925]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2629.594935]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2629.594937]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2629.594940]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2629.594942]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2629.594945]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2629.594948]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2695.092824] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2695.092867] CPU 6:
[ 2695.092868] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2695.092907] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2695.092909] RIP: 0010:[<ffffffff803903a7>]  [<ffffffff803903a7>] delay_tsc+0x2e/0x57
[ 2695.092915] RSP: 0018:ffff8800281a34f8  EFLAGS: 00000202
[ 2695.092917] RAX: ffffffffb3ef768f RBX: 0000000000000006 RCX: 00000000b3ef768f
[ 2695.092918] RDX: 00000000b3ef768f RSI: 0000000000000001 RDI: 0000000000000001
[ 2695.092920] RBP: ffffffff8020bbd3 R08: ffffffffb3ef768f R09: 0000000000013a4b
[ 2695.092922] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2695.092924] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2695.092926] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2695.092928] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2695.092930] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2695.092931] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2695.092933] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2695.092935] Call Trace:
[ 2695.092936]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 2695.092943]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2695.092945]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2695.092950]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2695.092953]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2695.092958]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2695.092962]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2695.092965]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2695.092973]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2695.092977]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2695.092981]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2695.092984]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2695.092986]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2695.092988]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2695.092991]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2695.092993]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2695.092996]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2695.092998]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2695.093001]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2695.093004]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2695.093007]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2695.093010]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2695.093014]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2695.093017]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2695.093020]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2695.093022]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2695.093025]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2695.093027]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2695.093030]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2695.093032]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2695.093034]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2695.093037]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2695.093040]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2695.093046]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2695.093052]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2695.093055]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2695.093061]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2695.093067]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2695.093069]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2695.093075]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2695.093078]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2695.093083]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2695.093089]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2695.093092]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2695.093094]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2695.093097]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2695.093100]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2695.093102]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2695.093105]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2695.093108]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2695.093109]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2695.093113]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2695.093117]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2695.093120]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2695.093124]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2695.093128]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2695.093138]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2695.093141]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2695.093143]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2695.093146]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2695.093148]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2695.093151]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2760.591021] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2760.591065] CPU 6:
[ 2760.591066] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2760.591104] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2760.591106] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 2760.591112] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 2760.591114] RAX: 0000000079c68488 RBX: ffff8800281b2730 RCX: 0000000079c6846d
[ 2760.591115] RDX: 00000000000006b6 RSI: 0000000000000001 RDI: 0000000000000001
[ 2760.591117] RBP: ffffffff8020bbd3 R08: 0000000079c6846d R09: 0000000000013a4b
[ 2760.591119] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2760.591121] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2760.591123] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2760.591125] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2760.591126] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2760.591128] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2760.591130] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2760.591132] Call Trace:
[ 2760.591133]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 2760.591140]  [<ffffffff803903dc>] ? __delay+0x0/0xa
[ 2760.591143]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2760.591148]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2760.591151]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2760.591156]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2760.591160]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2760.591163]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2760.591171]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2760.591175]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2760.591178]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2760.591181]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2760.591183]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2760.591185]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2760.591188]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2760.591190]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2760.591193]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2760.591195]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2760.591198]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2760.591201]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2760.591204]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2760.591207]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2760.591211]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2760.591214]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2760.591217]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2760.591219]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2760.591222]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2760.591224]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2760.591226]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2760.591229]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2760.591231]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2760.591234]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2760.591236]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2760.591243]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2760.591249]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2760.591252]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2760.591257]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2760.591263]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2760.591266]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2760.591271]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2760.591274]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2760.591279]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2760.591285]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2760.591288]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2760.591290]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2760.591293]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2760.591295]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2760.591298]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2760.591301]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2760.591303]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2760.591304]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2760.591309]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2760.591312]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2760.591316]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2760.591318]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2760.591322]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2760.591332]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2760.591334]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2760.591336]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2760.591339]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2760.591341]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2760.591344]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2826.089219] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2826.089263] CPU 6:
[ 2826.089265] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2826.089303] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2826.089305] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 2826.089311] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 2826.089313] RAX: 000000003f9d9365 RBX: ffff8800281b2730 RCX: 000000003f9d934d
[ 2826.089315] RDX: 00000000000006df RSI: 0000000000000001 RDI: 0000000000000001
[ 2826.089317] RBP: ffffffff8020bbd3 R08: 000000003f9d934d R09: 0000000000013a4b
[ 2826.089318] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2826.089320] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2826.089322] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2826.089324] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2826.089326] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2826.089328] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2826.089330] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2826.089331] Call Trace:
[ 2826.089333]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 2826.089340]  [<ffffffff803939a9>] ? _raw_spin_lock+0x7d/0x105
[ 2826.089343]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2826.089348]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2826.089351]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2826.089356]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2826.089360]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2826.089363]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2826.089371]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2826.089375]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2826.089380]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2826.089383]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2826.089385]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2826.089387]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2826.089390]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2826.089393]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2826.089395]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2826.089397]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2826.089401]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2826.089404]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2826.089406]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2826.089410]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2826.089413]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2826.089416]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2826.089419]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2826.089421]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2826.089424]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2826.089426]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2826.089429]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2826.089431]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2826.089433]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2826.089436]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2826.089439]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2826.089446]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2826.089452]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2826.089455]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2826.089461]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2826.089466]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2826.089469]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2826.089475]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2826.089477]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2826.089483]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2826.089489]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2826.089491]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2826.089494]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2826.089496]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2826.089499]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2826.089502]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2826.089505]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2826.089508]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2826.089509]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2826.089513]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2826.089517]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2826.089521]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2826.089524]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2826.089527]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2826.089537]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2826.089540]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2826.089542]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2826.089545]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2826.089547]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2826.089550]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2891.587418] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2891.587462] CPU 6:
[ 2891.587464] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2891.587503] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2891.587504] RIP: 0010:[<ffffffff803903c5>]  [<ffffffff803903c5>] delay_tsc+0x4c/0x57
[ 2891.587511] RSP: 0018:ffff8800281a34f8  EFLAGS: 00000206
[ 2891.587512] RAX: 0000000000000012 RBX: 0000000000000006 RCX: 000000000574a13d
[ 2891.587514] RDX: 000000000574a13d RSI: 0000000000000001 RDI: 0000000000000001
[ 2891.587516] RBP: ffffffff8020bbd3 R08: 000000000574a13d R09: 0000000000013a4b
[ 2891.587518] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 2891.587520] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 2891.587522] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2891.587524] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2891.587525] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2891.587527] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2891.587529] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2891.587531] Call Trace:
[ 2891.587532]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 2891.587538]  [<ffffffff803903dc>] ? __delay+0x0/0xa
[ 2891.587541]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 2891.587546]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2891.587549]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2891.587554]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2891.587558]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2891.587561]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2891.587569]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2891.587573]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2891.587577]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2891.587580]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2891.587583]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2891.587585]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2891.587587]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2891.587590]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2891.587592]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2891.587595]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2891.587599]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2891.587602]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2891.587604]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2891.587608]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2891.587611]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2891.587614]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2891.587617]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2891.587620]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2891.587622]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2891.587624]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2891.587627]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2891.587629]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2891.587631]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2891.587634]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2891.587637]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2891.587643]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2891.587650]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2891.587652]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2891.587658]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2891.587664]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2891.587667]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2891.587672]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2891.587675]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2891.587680]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2891.587686]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2891.587689]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2891.587691]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2891.587694]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2891.587696]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2891.587699]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2891.587702]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2891.587705]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2891.587706]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2891.587710]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2891.587714]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2891.587717]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2891.587720]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2891.587723]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2891.587733]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2891.587736]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2891.587738]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2891.587741]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2891.587743]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2891.587746]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 2957.085615] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2957.085659] CPU 6:
[ 2957.085661] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 2957.085700] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 2957.085701] RIP: 0010:[<ffffffff803939bc>]  [<ffffffff803939bc>] _raw_spin_lock+0x90/0x105
[ 2957.085707] RSP: 0018:ffff8800281a3558  EFLAGS: 00000246
[ 2957.085709] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 00000000cb4bae55
[ 2957.085711] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 2957.085713] RBP: ffffffff8020bbd3 R08: ffffffffcb4bae55 R09: 0000000000013a4b
[ 2957.085714] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 2957.085716] R13: 0000000045b83c35 R14: 0000000000000001 R15: ffffffff8021d470
[ 2957.085718] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 2957.085720] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 2957.085722] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 2957.085724] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2957.085726] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2957.085727] Call Trace:
[ 2957.085729]  <IRQ>  [<ffffffff803939b1>] ? _raw_spin_lock+0x85/0x105
[ 2957.085736]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 2957.085739]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 2957.085744]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 2957.085748]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 2957.085751]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 2957.085760]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 2957.085763]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 2957.085767]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2957.085770]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2957.085772]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2957.085775]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 2957.085777]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 2957.085780]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 2957.085782]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 2957.085785]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 2957.085788]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 2957.085791]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 2957.085793]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 2957.085797]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 2957.085801]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 2957.085803]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 2957.085806]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2957.085809]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2957.085811]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2957.085813]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 2957.085816]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 2957.085818]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 2957.085821]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 2957.085824]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 2957.085826]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2957.085833]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 2957.085839]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 2957.085842]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 2957.085848]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 2957.085854]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 2957.085856]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 2957.085862]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2957.085865]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 2957.085870]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 2957.085876]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 2957.085878]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 2957.085881]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 2957.085884]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 2957.085886]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 2957.085889]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 2957.085892]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 2957.085895]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 2957.085896]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 2957.085900]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 2957.085904]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 2957.085908]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 2957.085911]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 2957.085916]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 2957.085926]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 2957.085928]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 2957.085931]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 2957.085933]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 2957.085936]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 2957.085939]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3022.583814] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3022.583859] CPU 6:
[ 3022.583860] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3022.583899] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3022.583900] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 3022.583906] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 3022.583908] RAX: 000000009122bda2 RBX: 0000000000000006 RCX: 000000009122bd7f
[ 3022.583910] RDX: 0000000000000759 RSI: 0000000000000001 RDI: 0000000000000001
[ 3022.583911] RBP: ffffffff8020bbd3 R08: ffffffff9122bd64 R09: 0000000000013a4b
[ 3022.583913] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3022.583915] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3022.583917] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3022.583919] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3022.583921] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3022.583923] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3022.583924] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3022.583926] Call Trace:
[ 3022.583927]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 3022.583935]  [<ffffffff803939a9>] ? _raw_spin_lock+0x7d/0x105
[ 3022.583937]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3022.583942]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3022.583945]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3022.583950]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3022.583954]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3022.583957]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3022.583966]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3022.583970]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3022.583974]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3022.583977]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3022.583979]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3022.583981]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3022.583984]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3022.583987]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3022.583989]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3022.583991]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3022.583995]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3022.583998]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3022.584000]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3022.584004]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3022.584008]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3022.584011]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3022.584014]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3022.584016]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3022.584019]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3022.584021]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3022.584023]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3022.584026]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3022.584028]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3022.584031]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3022.584033]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3022.584040]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3022.584046]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3022.584049]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3022.584055]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3022.584060]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3022.584063]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3022.584068]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3022.584071]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3022.584076]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3022.584082]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3022.584085]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3022.584087]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3022.584090]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3022.584093]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3022.584095]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3022.584098]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3022.584100]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3022.584102]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3022.584106]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3022.584110]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3022.584113]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3022.584116]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3022.584121]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3022.584130]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3022.584133]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3022.584136]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3022.584138]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3022.584141]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3022.584144]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3088.082011] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3088.082056] CPU 6:
[ 3088.082057] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3088.082097] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3088.082099] RIP: 0010:[<ffffffff80210da2>]  [<ffffffff80210da2>] native_read_tsc+0xd/0x11
[ 3088.082104] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000206
[ 3088.082106] RAX: 0000078200000000 RBX: 0000000000000006 RCX: 0000000056f9cad2
[ 3088.082108] RDX: 0000000056f9cad2 RSI: 0000000000000001 RDI: 0000000000000001
[ 3088.082110] RBP: ffffffff8020bbd3 R08: 0000000056f9caa5 R09: 0000000000013a4b
[ 3088.082112] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3088.082114] R13: 0000000000000006 R14: 000002c2ce8ec94b R15: ffffffff8021d470
[ 3088.082116] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3088.082118] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3088.082119] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3088.082121] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3088.082123] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3088.082125] Call Trace:
[ 3088.082126]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 3088.082133]  [<ffffffff80390380>] ? delay_tsc+0x7/0x57
[ 3088.082137]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3088.082141]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3088.082144]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3088.082149]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3088.082154]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3088.082157]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3088.082165]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3088.082169]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3088.082173]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3088.082176]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3088.082179]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3088.082181]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3088.082183]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3088.082186]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3088.082188]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3088.082191]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3088.082194]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3088.082197]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3088.082199]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3088.082203]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3088.082207]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3088.082210]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3088.082213]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3088.082215]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3088.082218]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3088.082220]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3088.082222]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3088.082225]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3088.082227]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3088.082230]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3088.082233]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3088.082239]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3088.082245]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3088.082248]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3088.082254]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3088.082259]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3088.082262]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3088.082268]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3088.082270]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3088.082276]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3088.082281]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3088.082284]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3088.082287]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3088.082289]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3088.082292]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3088.082294]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3088.082297]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3088.082300]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3088.082301]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3088.082305]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3088.082309]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3088.082312]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3088.082315]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3088.082318]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3088.082328]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3088.082331]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3088.082333]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3088.082336]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3088.082338]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3088.082341]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3153.580209] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3153.580254] CPU 6:
[ 3153.580255] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3153.580295] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3153.580296] RIP: 0010:[<ffffffff803939bc>]  [<ffffffff803939bc>] _raw_spin_lock+0x90/0x105
[ 3153.580302] RSP: 0018:ffff8800281a3558  EFLAGS: 00000246
[ 3153.580304] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 000000001cd0d825
[ 3153.580306] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 3153.580308] RBP: ffffffff8020bbd3 R08: 000000001cd0d825 R09: 0000000000013a4b
[ 3153.580310] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 3153.580311] R13: 00000000051c61dd R14: 0000000000000001 R15: ffffffff8021d470
[ 3153.580314] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3153.580315] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3153.580317] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3153.580319] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3153.580321] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3153.580322] Call Trace:
[ 3153.580324]  <IRQ>  [<ffffffff803939b1>] ? _raw_spin_lock+0x85/0x105
[ 3153.580331]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3153.580335]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3153.580340]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3153.580344]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3153.580347]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3153.580355]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3153.580359]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3153.580363]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3153.580366]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3153.580369]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3153.580371]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3153.580374]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3153.580376]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3153.580379]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3153.580381]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3153.580384]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3153.580387]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3153.580389]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3153.580393]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3153.580397]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3153.580400]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3153.580403]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3153.580405]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3153.580408]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3153.580410]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3153.580412]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3153.580415]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3153.580417]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3153.580420]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3153.580422]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3153.580429]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3153.580435]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3153.580438]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3153.580444]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3153.580449]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3153.580452]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3153.580458]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3153.580460]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3153.580466]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3153.580471]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3153.580474]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3153.580477]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3153.580479]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3153.580482]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3153.580484]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3153.580487]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3153.580490]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3153.580491]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3153.580496]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3153.580499]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3153.580503]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3153.580506]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3153.580509]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3153.580519]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3153.580522]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3153.580524]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3153.580527]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3153.580529]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3153.580532]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3219.078407] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3219.078451] CPU 6:
[ 3219.078452] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3219.078491] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3219.078493] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 3219.078499] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 3219.078500] RAX: 00000000e2a7e845 RBX: ffff8800281b2730 RCX: 00000000e2a7e82d
[ 3219.078502] RDX: 00000000000007d3 RSI: 0000000000000001 RDI: 0000000000000001
[ 3219.078504] RBP: ffffffff8020bbd3 R08: ffffffffe2a7e82d R09: 0000000000013a4b
[ 3219.078506] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3219.078508] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3219.078510] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3219.078512] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3219.078513] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3219.078515] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3219.078517] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3219.078519] Call Trace:
[ 3219.078520]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 3219.078527]  [<ffffffff803903cb>] ? delay_tsc+0x52/0x57
[ 3219.078531]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3219.078536]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3219.078539]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3219.078544]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3219.078548]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3219.078551]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3219.078559]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3219.078563]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3219.078566]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3219.078569]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3219.078572]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3219.078574]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3219.078576]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3219.078579]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3219.078581]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3219.078584]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3219.078587]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3219.078590]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3219.078592]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3219.078596]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3219.078600]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3219.078602]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3219.078605]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3219.078608]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3219.078610]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3219.078613]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3219.078615]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3219.078617]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3219.078620]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3219.078623]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3219.078625]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3219.078632]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3219.078638]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3219.078641]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3219.078646]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3219.078652]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3219.078655]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3219.078660]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3219.078663]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3219.078668]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3219.078674]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3219.078677]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3219.078679]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3219.078682]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3219.078685]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3219.078687]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3219.078690]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3219.078692]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3219.078694]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3219.078698]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3219.078702]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3219.078705]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3219.078708]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3219.078711]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3219.078721]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3219.078724]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3219.078726]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3219.078729]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3219.078731]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3219.078734]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3284.576604] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3284.576648] CPU 6:
[ 3284.576650] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3284.576690] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3284.576692] RIP: 0010:[<ffffffff80390382>]  [<ffffffff80390382>] delay_tsc+0x9/0x57
[ 3284.576698] RSP: 0018:ffff8800281a3530  EFLAGS: 00000206
[ 3284.576699] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 00000000a87ef632
[ 3284.576701] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 3284.576703] RBP: ffffffff8020bbd3 R08: ffffffffa87ef632 R09: 0000000000013a4b
[ 3284.576705] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34b0
[ 3284.576707] R13: 000000004521ae9a R14: ffffffffa8562b7f R15: ffffffff8021d470
[ 3284.576709] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3284.576711] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3284.576712] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3284.576714] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3284.576716] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3284.576717] Call Trace:
[ 3284.576719]  <IRQ>  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3284.576727]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3284.576730]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3284.576735]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3284.576739]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3284.576742]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3284.576750]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3284.576754]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3284.576758]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3284.576761]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3284.576764]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3284.576766]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3284.576769]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3284.576771]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3284.576774]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3284.576776]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3284.576779]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3284.576782]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3284.576784]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3284.576788]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3284.576792]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3284.576795]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3284.576798]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3284.576800]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3284.576803]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3284.576805]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3284.576807]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3284.576810]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3284.576812]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3284.576815]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3284.576817]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3284.576824]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3284.576830]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3284.576833]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3284.576839]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3284.576845]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3284.576847]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3284.576853]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3284.576856]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3284.576861]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3284.576867]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3284.576869]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3284.576872]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3284.576875]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3284.576877]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3284.576880]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3284.576883]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3284.576886]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3284.576887]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3284.576892]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3284.576895]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3284.576899]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3284.576902]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3284.576905]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3284.576915]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3284.576918]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3284.576920]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3284.576923]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3284.576925]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3284.576928]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3350.074802] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3350.074846] CPU 6:
[ 3350.074847] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3350.074886] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3350.074887] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 3350.074893] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 3350.074895] RAX: 000000006e560376 RBX: 0000000000000006 RCX: 000000006e560364
[ 3350.074896] RDX: 0000000000000825 RSI: 0000000000000001 RDI: 0000000000000001
[ 3350.074898] RBP: ffffffff8020bbd3 R08: 000000006e56034c R09: 0000000000013a4b
[ 3350.074900] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3350.074902] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3350.074904] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3350.074906] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3350.074908] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3350.074910] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3350.074911] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3350.074913] Call Trace:
[ 3350.074915]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 3350.074922]  [<ffffffff803903dc>] ? __delay+0x0/0xa
[ 3350.074925]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3350.074929]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3350.074933]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3350.074938]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3350.074942]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3350.074945]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3350.074953]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3350.074957]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3350.074961]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3350.074964]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3350.074966]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3350.074969]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3350.074971]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3350.074974]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3350.074976]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3350.074978]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3350.074982]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3350.074984]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3350.074987]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3350.074991]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3350.074994]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3350.074997]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3350.075000]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3350.075003]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3350.075005]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3350.075007]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3350.075010]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3350.075012]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3350.075014]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3350.075017]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3350.075020]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3350.075026]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3350.075032]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3350.075035]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3350.075041]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3350.075047]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3350.075049]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3350.075055]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3350.075058]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3350.075063]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3350.075069]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3350.075072]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3350.075074]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3350.075077]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3350.075079]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3350.075082]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3350.075085]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3350.075087]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3350.075089]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3350.075093]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3350.075097]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3350.075100]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3350.075103]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3350.075106]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3350.075116]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3350.075119]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3350.075121]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3350.075124]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3350.075126]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3350.075129]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3415.573001] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3415.573046] CPU 6:
[ 3415.573047] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3415.573086] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3415.573087] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 3415.573093] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 3415.573095] RAX: 00000000342d1169 RBX: ffff8800281b2730 RCX: 00000000342d1151
[ 3415.573097] RDX: 000000000000084e RSI: 0000000000000001 RDI: 0000000000000001
[ 3415.573099] RBP: ffffffff8020bbd3 R08: 00000000342d1151 R09: 0000000000013a4b
[ 3415.573100] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3415.573102] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3415.573104] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3415.573106] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3415.573108] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3415.573110] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3415.573112] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3415.573113] Call Trace:
[ 3415.573115]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 3415.573123]  [<ffffffff80221ed7>] ? __ticket_spin_trylock+0x12/0x19
[ 3415.573126]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3415.573131]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3415.573134]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3415.573139]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3415.573143]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3415.573146]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3415.573154]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3415.573158]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3415.573162]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3415.573166]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3415.573168]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3415.573170]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3415.573173]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3415.573175]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3415.573178]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3415.573180]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3415.573183]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3415.573186]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3415.573188]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3415.573192]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3415.573196]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3415.573199]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3415.573202]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3415.573204]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3415.573206]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3415.573209]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3415.573211]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3415.573214]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3415.573216]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3415.573219]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3415.573221]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3415.573228]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3415.573234]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3415.573237]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3415.573243]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3415.573248]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3415.573251]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3415.573257]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3415.573259]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3415.573265]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3415.573270]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3415.573273]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3415.573276]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3415.573278]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3415.573281]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3415.573283]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3415.573287]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3415.573289]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3415.573291]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3415.573295]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3415.573299]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3415.573302]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3415.573306]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3415.573309]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3415.573319]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3415.573322]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3415.573324]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3415.573327]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3415.573329]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3415.573332]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3481.071199] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3481.071243] CPU 6:
[ 3481.071244] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3481.071283] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3481.071285] RIP: 0010:[<ffffffff803939bc>]  [<ffffffff803939bc>] _raw_spin_lock+0x90/0x105
[ 3481.071291] RSP: 0018:ffff8800281a3558  EFLAGS: 00000246
[ 3481.071292] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 00000000fa041ff6
[ 3481.071294] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 3481.071296] RBP: ffffffff8020bbd3 R08: fffffffffa041ff6 R09: 0000000000013a4b
[ 3481.071298] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 3481.071300] R13: 000000009df34429 R14: ffff8800281a34c0 R15: ffffffff8021d470
[ 3481.071302] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3481.071304] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3481.071305] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3481.071307] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3481.071309] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3481.071311] Call Trace:
[ 3481.071312]  <IRQ>  [<ffffffff803939b1>] ? _raw_spin_lock+0x85/0x105
[ 3481.071320]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3481.071323]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3481.071328]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3481.071332]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3481.071335]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3481.071343]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3481.071347]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3481.071351]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3481.071354]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3481.071357]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3481.071359]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3481.071362]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3481.071364]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3481.071367]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3481.071369]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3481.071373]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3481.071376]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3481.071379]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3481.071382]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3481.071386]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3481.071389]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3481.071392]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3481.071394]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3481.071397]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3481.071399]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3481.071402]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3481.071404]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3481.071406]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3481.071409]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3481.071412]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3481.071418]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3481.071424]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3481.071427]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3481.071433]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3481.071439]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3481.071441]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3481.071447]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3481.071450]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3481.071455]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3481.071461]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3481.071464]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3481.071466]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3481.071469]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3481.071472]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3481.071474]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3481.071477]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3481.071480]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3481.071481]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3481.071486]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3481.071490]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3481.071493]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3481.071496]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3481.071501]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3481.071511]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3481.071513]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3481.071516]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3481.071518]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3481.071521]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3481.071524]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3546.569396] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3546.569440] CPU 6:
[ 3546.569442] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3546.569481] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3546.569483] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 3546.569488] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 3546.569490] RAX: 00000000bfdb2e36 RBX: ffff8800281b2730 RCX: 00000000bfdb2e1e
[ 3546.569492] RDX: 000000000000089f RSI: 0000000000000001 RDI: 0000000000000001
[ 3546.569494] RBP: ffffffff8020bbd3 R08: ffffffffbfdb2e1e R09: 0000000000013a4b
[ 3546.569496] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3546.569497] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3546.569500] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3546.569502] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3546.569503] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3546.569505] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3546.569507] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3546.569508] Call Trace:
[ 3546.569510]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 3546.569518]  [<ffffffff80221ed7>] ? __ticket_spin_trylock+0x12/0x19
[ 3546.569522]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3546.569526]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3546.569530]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3546.569535]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3546.569539]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3546.569542]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3546.569550]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3546.569554]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3546.569557]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3546.569560]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3546.569562]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3546.569565]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3546.569567]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3546.569570]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3546.569572]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3546.569574]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3546.569578]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3546.569580]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3546.569583]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3546.569586]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3546.569590]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3546.569593]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3546.569596]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3546.569598]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3546.569601]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3546.569603]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3546.569605]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3546.569608]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3546.569610]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3546.569613]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3546.569615]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3546.569622]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3546.569628]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3546.569631]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3546.569637]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3546.569642]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3546.569645]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3546.569651]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3546.569653]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3546.569658]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3546.569664]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3546.569667]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3546.569669]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3546.569672]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3546.569675]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3546.569677]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3546.569680]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3546.569683]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3546.569684]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3546.569688]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3546.569692]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3546.569695]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3546.569699]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3546.569703]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3546.569713]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3546.569715]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3546.569718]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3546.569720]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3546.569723]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3546.569726]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3612.067594] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3612.067638] CPU 6:
[ 3612.067639] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3612.067678] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3612.067680] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 3612.067685] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 3612.067687] RAX: 0000000085b23c6d RBX: 0000000000000006 RCX: 0000000085b23c5b
[ 3612.067689] RDX: 00000000000008c8 RSI: 0000000000000001 RDI: 0000000000000001
[ 3612.067691] RBP: ffffffff8020bbd3 R08: ffffffff85b23c2f R09: 0000000000013a4b
[ 3612.067693] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3612.067694] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3612.067697] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3612.067699] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3612.067700] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3612.067702] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3612.067704] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3612.067705] Call Trace:
[ 3612.067707]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 3612.067714]  [<ffffffff803903cf>] ? delay_tsc+0x56/0x57
[ 3612.067717]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3612.067722]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3612.067725]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3612.067730]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3612.067734]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3612.067737]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3612.067745]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3612.067749]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3612.067753]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3612.067756]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3612.067759]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3612.067761]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3612.067764]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3612.067766]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3612.067768]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3612.067771]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3612.067775]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3612.067778]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3612.067780]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3612.067784]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3612.067788]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3612.067791]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3612.067794]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3612.067796]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3612.067799]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3612.067801]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3612.067803]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3612.067806]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3612.067808]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3612.067811]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3612.067814]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3612.067820]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3612.067826]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3612.067829]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3612.067835]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3612.067840]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3612.067843]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3612.067849]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3612.067851]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3612.067857]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3612.067862]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3612.067865]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3612.067868]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3612.067870]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3612.067873]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3612.067875]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3612.067878]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3612.067881]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3612.067882]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3612.067886]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3612.067890]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3612.067894]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3612.067896]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3612.067900]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3612.067910]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3612.067912]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3612.067915]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3612.067917]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3612.067920]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3612.067923]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3677.565792] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3677.565836] CPU 6:
[ 3677.565837] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3677.565876] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3677.565878] RIP: 0010:[<ffffffff80210d9c>]  [<ffffffff80210d9c>] native_read_tsc+0x7/0x11
[ 3677.565883] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 3677.565885] RAX: 00000000000008f1 RBX: 0000000000000006 RCX: 000000004b894982
[ 3677.565887] RDX: 00000000000008f1 RSI: 0000000000000001 RDI: 0000000000000001
[ 3677.565888] RBP: ffffffff8020bbd3 R08: 000000004b894958 R09: 0000000000013a4b
[ 3677.565890] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3677.565892] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3677.565894] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3677.565896] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3677.565898] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3677.565900] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3677.565901] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3677.565903] Call Trace:
[ 3677.565904]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 3677.565913]  [<ffffffff80221ed0>] ? __ticket_spin_trylock+0xb/0x19
[ 3677.565916]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3677.565921]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3677.565924]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3677.565929]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3677.565933]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3677.565936]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3677.565944]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3677.565948]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3677.565951]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3677.565954]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3677.565956]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3677.565959]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3677.565961]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3677.565964]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3677.565966]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3677.565968]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3677.565972]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3677.565974]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3677.565977]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3677.565981]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3677.565984]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3677.565987]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3677.565990]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3677.565992]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3677.565995]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3677.565997]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3677.566000]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3677.566002]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3677.566004]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3677.566008]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3677.566010]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3677.566017]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3677.566023]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3677.566026]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3677.566032]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3677.566037]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3677.566040]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3677.566046]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3677.566048]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3677.566054]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3677.566059]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3677.566062]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3677.566065]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3677.566067]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3677.566070]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3677.566072]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3677.566076]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3677.566078]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3677.566080]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3677.566084]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3677.566088]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3677.566091]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3677.566094]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3677.566097]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3677.566107]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3677.566110]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3677.566112]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3677.566115]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3677.566117]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3677.566121]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3743.064484] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3743.064528] CPU 6:
[ 3743.064529] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3743.064568] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3743.064570] RIP: 0010:[<ffffffff803939bc>]  [<ffffffff803939bc>] _raw_spin_lock+0x90/0x105
[ 3743.064576] RSP: 0018:ffff8800281a3558  EFLAGS: 00000246
[ 3743.064577] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 0000000011748295
[ 3743.064579] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 3743.064581] RBP: ffffffff8020bbd3 R08: 0000000011748295 R09: 0000000000013a4b
[ 3743.064583] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 3743.064585] R13: 000000006ef5396e R14: 0000000000000001 R15: ffffffff8021d470
[ 3743.064587] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3743.064589] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3743.064590] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3743.064592] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3743.064594] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3743.064596] Call Trace:
[ 3743.064597]  <IRQ>  [<ffffffff803939b1>] ? _raw_spin_lock+0x85/0x105
[ 3743.064605]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3743.064608]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3743.064613]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3743.064617]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3743.064620]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3743.064628]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3743.064632]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3743.064636]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3743.064639]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3743.064642]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3743.064644]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3743.064646]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3743.064649]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3743.064651]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3743.064654]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3743.064657]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3743.064660]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3743.064662]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3743.064666]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3743.064670]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3743.064673]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3743.064676]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3743.064678]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3743.064681]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3743.064683]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3743.064685]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3743.064688]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3743.064690]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3743.064693]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3743.064695]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3743.064702]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3743.064708]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3743.064711]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3743.064717]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3743.064722]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3743.064725]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3743.064731]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3743.064733]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3743.064739]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3743.064744]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3743.064747]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3743.064750]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3743.064753]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3743.064755]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3743.064758]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3743.064760]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3743.064763]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3743.064765]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3743.064769]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3743.064773]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3743.064776]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3743.064779]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3743.064782]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3743.064792]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3743.064795]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3743.064797]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3743.064800]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3743.064802]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3743.064805]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3808.562418] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3808.562462] CPU 6:
[ 3808.562463] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3808.562503] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3808.562504] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 3808.562510] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 3808.562512] RAX: 00000000d740cea4 RBX: 0000000000000006 RCX: 00000000d740ce92
[ 3808.562513] RDX: 0000000000000942 RSI: 0000000000000001 RDI: 0000000000000001
[ 3808.562515] RBP: ffffffff8020bbd3 R08: ffffffffd740ce66 R09: 0000000000013a4b
[ 3808.562517] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3808.562519] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3808.562521] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3808.562523] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3808.562525] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3808.562526] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3808.562528] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3808.562530] Call Trace:
[ 3808.562531]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 3808.562538]  [<ffffffff803903cb>] ? delay_tsc+0x52/0x57
[ 3808.562542]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3808.562546]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3808.562549]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3808.562554]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3808.562558]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3808.562561]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3808.562570]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3808.562574]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3808.562578]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3808.562581]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3808.562583]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3808.562585]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3808.562588]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3808.562591]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3808.562593]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3808.562595]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3808.562599]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3808.562601]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3808.562604]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3808.562607]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3808.562611]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3808.562614]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3808.562617]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3808.562619]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3808.562622]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3808.562624]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3808.562626]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3808.562629]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3808.562631]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3808.562634]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3808.562637]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3808.562643]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3808.562649]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3808.562652]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3808.562658]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3808.562663]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3808.562666]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3808.562672]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3808.562674]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3808.562680]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3808.562685]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3808.562688]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3808.562691]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3808.562693]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3808.562696]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3808.562698]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3808.562701]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3808.562704]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3808.562705]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3808.562710]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3808.562713]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3808.562717]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3808.562720]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3808.562724]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3808.562734]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3808.562736]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3808.562739]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3808.562742]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3808.562744]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3808.562747]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3874.060789] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3874.060832] CPU 6:
[ 3874.060834] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3874.060872] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3874.060874] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 3874.060880] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 3874.060882] RAX: 000000009d1ee6b5 RBX: 0000000000000006 RCX: 000000009d1ee692
[ 3874.060883] RDX: 000000000000096b RSI: 0000000000000001 RDI: 0000000000000001
[ 3874.060885] RBP: ffffffff8020bbd3 R08: ffffffff9d1ee67a R09: 0000000000013a4b
[ 3874.060887] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3874.060889] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3874.060891] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3874.060893] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3874.060895] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3874.060896] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3874.060898] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3874.060900] Call Trace:
[ 3874.060901]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 3874.060909]  [<ffffffff803939b1>] ? _raw_spin_lock+0x85/0x105
[ 3874.060912]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3874.060916]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3874.060919]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3874.060924]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3874.060928]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3874.060931]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3874.060939]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3874.060944]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3874.060948]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3874.060951]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3874.060953]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3874.060956]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3874.060958]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3874.060961]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3874.060963]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3874.060965]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3874.060969]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3874.060971]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3874.060974]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3874.060978]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3874.060981]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3874.060984]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3874.060987]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3874.060990]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3874.060992]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3874.060994]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3874.060997]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3874.060999]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3874.061001]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3874.061004]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3874.061007]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3874.061013]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3874.061020]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3874.061023]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3874.061028]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3874.061034]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3874.061037]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3874.061042]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3874.061045]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3874.061050]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3874.061056]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3874.061059]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3874.061061]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3874.061064]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3874.061067]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3874.061069]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3874.061072]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3874.061074]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3874.061076]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3874.061080]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3874.061084]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3874.061087]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3874.061090]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3874.061093]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3874.061103]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3874.061106]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3874.061108]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3874.061111]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3874.061113]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3874.061116]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 3939.559568] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3939.559610] CPU 6:
[ 3939.559611] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 3939.559651] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 3939.559652] RIP: 0010:[<ffffffff80210da5>]  [<ffffffff80210da5>] native_read_tsc+0x10/0x11
[ 3939.559657] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 3939.559659] RAX: 00000994630db0b0 RBX: ffff8800281b2730 RCX: 00000000630db0b0
[ 3939.559661] RDX: 00000000630db0b0 RSI: 0000000000000001 RDI: 0000000000000001
[ 3939.559662] RBP: ffffffff8020bbd3 R08: 00000000630db098 R09: 0000000000013a4b
[ 3939.559664] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 3939.559666] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 3939.559668] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 3939.559670] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 3939.559672] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 3939.559674] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3939.559675] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3939.559677] Call Trace:
[ 3939.559678]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 3939.559685]  [<ffffffff803939bc>] ? _raw_spin_lock+0x90/0x105
[ 3939.559688]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 3939.559692]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 3939.559695]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 3939.559700]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 3939.559704]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 3939.559707]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 3939.559715]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 3939.559719]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 3939.559723]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3939.559725]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3939.559728]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3939.559730]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 3939.559733]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 3939.559735]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 3939.559737]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 3939.559740]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 3939.559743]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 3939.559746]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 3939.559748]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 3939.559752]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 3939.559756]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 3939.559759]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 3939.559762]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3939.559764]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3939.559766]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3939.559769]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 3939.559771]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 3939.559773]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 3939.559776]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 3939.559779]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 3939.559781]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3939.559787]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 3939.559794]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 3939.559796]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 3939.559802]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 3939.559808]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 3939.559810]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 3939.559816]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3939.559819]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 3939.559824]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 3939.559830]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 3939.559832]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 3939.559835]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 3939.559838]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 3939.559840]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 3939.559843]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 3939.559845]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 3939.559848]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 3939.559849]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 3939.559853]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 3939.559857]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 3939.559860]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 3939.559863]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 3939.559866]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 3939.559876]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 3939.559878]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 3939.559881]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 3939.559883]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 3939.559886]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 3939.559889]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4005.057732] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4005.057776] CPU 6:
[ 4005.057777] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4005.057815] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4005.057817] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 4005.057823] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 4005.057825] RAX: 0000000028e359a2 RBX: 0000000000000006 RCX: 0000000028e3597f
[ 4005.057826] RDX: 00000000000009bd RSI: 0000000000000001 RDI: 0000000000000001
[ 4005.057828] RBP: ffffffff8020bbd3 R08: 0000000028e35964 R09: 0000000000013a4b
[ 4005.057830] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4005.057832] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4005.057834] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4005.057836] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4005.057838] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4005.057840] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4005.057841] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4005.057843] Call Trace:
[ 4005.057844]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 4005.057853]  [<ffffffff80221ed0>] ? __ticket_spin_trylock+0xb/0x19
[ 4005.057856]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4005.057861]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4005.057864]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4005.057869]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4005.057873]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4005.057876]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4005.057884]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4005.057888]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4005.057892]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4005.057894]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4005.057897]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4005.057899]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4005.057902]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4005.057904]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4005.057907]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4005.057909]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4005.057912]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4005.057915]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4005.057917]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4005.057921]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4005.057925]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4005.057928]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4005.057931]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4005.057933]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4005.057935]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4005.057938]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4005.057940]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4005.057942]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4005.057945]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4005.057948]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4005.057950]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4005.057957]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4005.057963]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4005.057966]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4005.057971]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4005.057977]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4005.057980]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4005.057985]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4005.057988]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4005.057993]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4005.057999]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4005.058002]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4005.058004]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4005.058007]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4005.058010]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4005.058012]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4005.058015]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4005.058018]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4005.058019]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4005.058023]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4005.058027]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4005.058030]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4005.058033]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4005.058036]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4005.058046]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4005.058049]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4005.058051]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4005.058054]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4005.058056]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4005.058059]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
Apr 15 08:54:48 nehalam bonobo-activation-server (shemminger-19713): could not associate with desktop session: Failed to connect to socket /tmp/dbus-z9XxFF6Gr5: Connection refused
[ 4070.556255] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4070.556299] CPU 6:
[ 4070.556300] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4070.556339] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4070.556340] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 4070.556346] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000206
[ 4070.556348] RAX: 00000000eec7b224 RBX: 0000000000000006 RCX: 00000000eec7b212
[ 4070.556350] RDX: 00000000000009e5 RSI: 0000000000000001 RDI: 0000000000000001
[ 4070.556351] RBP: ffffffff8020bbd3 R08: ffffffffeec7b1e6 R09: 0000000000013a4b
[ 4070.556353] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4070.556355] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4070.556357] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4070.556359] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4070.556361] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4070.556363] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4070.556364] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4070.556366] Call Trace:
[ 4070.556367]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 4070.556375]  [<ffffffff803939a9>] ? _raw_spin_lock+0x7d/0x105
[ 4070.556377]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4070.556382]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4070.556385]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4070.556390]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4070.556394]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4070.556397]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4070.556405]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4070.556409]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4070.556413]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4070.556416]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4070.556419]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4070.556421]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4070.556424]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4070.556426]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4070.556428]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4070.556431]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4070.556434]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4070.556437]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4070.556439]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4070.556443]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4070.556447]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4070.556449]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4070.556452]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4070.556455]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4070.556457]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4070.556459]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4070.556462]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4070.556464]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4070.556467]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4070.556469]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4070.556472]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4070.556478]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4070.556485]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4070.556487]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4070.556493]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4070.556499]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4070.556502]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4070.556507]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4070.556510]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4070.556515]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4070.556521]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4070.556523]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4070.556526]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4070.556529]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4070.556531]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4070.556534]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4070.556536]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4070.556539]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4070.556540]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4070.556544]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4070.556548]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4070.556551]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4070.556554]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4070.556558]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4070.556567]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4070.556570]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4070.556572]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4070.556575]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4070.556577]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4070.556580]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4133.531555] Xorg          D 0000000000000000     0  7152      1
[ 4133.531558]  ffff8801bf120000 0000000000000046 0000000000000000 ffffffff8053a015
[ 4133.531561]  0000000000011a00 000000000000cc78 ffff8801bc4fbec0 ffff8801bc4fc250
[ 4133.531565]  0000000500000046 ffff880028197a18 ffff880028192c78 ffff8801bc4fc250
[ 4133.531568] Call Trace:
[ 4133.531573]  [<ffffffff8053a015>] ? __schedule+0x131/0x941
[ 4133.531576]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4133.531578]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4133.531581]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4133.531584]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4133.531586]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4133.531589]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4133.531592]  [<ffffffff8024b7c1>] ? synchronize_rcu+0x49/0x50
[ 4133.531595]  [<ffffffff8024b649>] ? wakeme_after_rcu+0x0/0x9
[ 4133.531597]  [<ffffffff8053cc1b>] ? _spin_unlock+0x17/0x20
[ 4133.531603]  [<ffffffffa00e9136>] ? evdev_release+0x58/0x9f [evdev]
[ 4133.531606]  [<ffffffff802b5cfe>] ? __fput+0xe7/0x1b3
[ 4133.531609]  [<ffffffff802b319e>] ? filp_close+0x5b/0x62
[ 4133.531611]  [<ffffffff802b3244>] ? sys_close+0x9f/0xdd
[ 4133.531614]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4133.531616] INFO: lockdep is turned off.
[ 4136.054116] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4136.054156] CPU 6:
[ 4136.054157] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4136.054198] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4136.054199] RIP: 0010:[<ffffffff803903cb>]  [<ffffffff803903cb>] delay_tsc+0x52/0x57
[ 4136.054204] RSP: 0018:ffff8800281a3540  EFLAGS: 00000296
[ 4136.054206] RAX: 0000000000000012 RBX: ffff8800281b2730 RCX: 00000000b491091e
[ 4136.054208] RDX: 00000000b491091e RSI: 0000000000000001 RDI: 0000000000000001
[ 4136.054209] RBP: ffffffff8020bbd3 R08: ffffffffb491091e R09: 0000000000013a4b
[ 4136.054211] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34c0
[ 4136.054213] R13: 00000000855541cc R14: 00000000b4683e4e R15: ffffffff8021d470
[ 4136.054215] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4136.054217] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4136.054219] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4136.054221] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4136.054222] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4136.054224] Call Trace:
[ 4136.054225]  <IRQ>  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4136.054232]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4136.054235]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4136.054239]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4136.054243]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4136.054246]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4136.054253]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4136.054257]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4136.054260]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4136.054263]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4136.054265]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4136.054268]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4136.054270]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4136.054273]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4136.054275]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4136.054277]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4136.054280]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4136.054283]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4136.054285]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4136.054289]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4136.054292]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4136.054295]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4136.054298]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4136.054301]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4136.054303]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4136.054305]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4136.054308]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4136.054310]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4136.054313]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4136.054315]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4136.054318]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4136.054324]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4136.054330]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4136.054333]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4136.054339]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4136.054345]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4136.054347]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4136.054353]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4136.054356]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4136.054361]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4136.054367]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4136.054370]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4136.054372]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4136.054375]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4136.054377]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4136.054380]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4136.054382]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4136.054385]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4136.054386]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4136.054390]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4136.054394]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4136.054397]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4136.054400]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4136.054403]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4136.054412]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4136.054415]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4136.054417]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4136.054420]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4136.054422]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4136.054425]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4201.552295] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4201.552335] CPU 6:
[ 4201.552336] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4201.552375] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4201.552377] RIP: 0010:[<ffffffff803939a9>]  [<ffffffff803939a9>] _raw_spin_lock+0x7d/0x105
[ 4201.552381] RSP: 0018:ffff8800281a3558  EFLAGS: 00000287
[ 4201.552383] RAX: 0000000000000012 RBX: ffff8800281b2730 RCX: 000000007a674b19
[ 4201.552385] RDX: 000000007a674b19 RSI: 0000000000000001 RDI: 0000000000000001
[ 4201.552387] RBP: ffffffff8020bbd3 R08: 000000007a674b19 R09: 0000000000013a4b
[ 4201.552389] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 4201.552390] R13: 00000000064e1b4e R14: 0000000000000001 R15: ffffffff8021d470
[ 4201.552393] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4201.552395] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4201.552396] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4201.552398] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4201.552400] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4201.552401] Call Trace:
[ 4201.552402]  <IRQ>  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4201.552409]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4201.552412]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4201.552416]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4201.552420]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4201.552423]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4201.552430]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4201.552434]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4201.552437]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4201.552440]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4201.552442]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4201.552444]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4201.552447]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4201.552449]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4201.552452]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4201.552454]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4201.552457]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4201.552459]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4201.552462]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4201.552465]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4201.552469]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4201.552472]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4201.552475]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4201.552477]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4201.552480]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4201.552482]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4201.552484]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4201.552487]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4201.552489]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4201.552492]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4201.552494]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4201.552500]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4201.552506]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4201.552509]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4201.552515]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4201.552521]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4201.552523]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4201.552529]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4201.552532]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4201.552537]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4201.552543]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4201.552545]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4201.552548]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4201.552551]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4201.552553]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4201.552556]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4201.552558]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4201.552560]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4201.552562]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4201.552566]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4201.552569]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4201.552573]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4201.552575]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4201.552578]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4201.552588]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4201.552590]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4201.552593]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4201.552595]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4201.552598]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4201.552600]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4253.511078] Xorg          D 0000000000000000     0  7152      1
[ 4253.511081]  ffff8801bf120000 0000000000000046 0000000000000000 ffffffff8053a015
[ 4253.511085]  0000000000011a00 000000000000cc78 ffff8801bc4fbec0 ffff8801bc4fc250
[ 4253.511088]  0000000500000046 ffff880028197a18 ffff880028192c78 ffff8801bc4fc250
[ 4253.511091] Call Trace:
[ 4253.511095]  [<ffffffff8053a015>] ? __schedule+0x131/0x941
[ 4253.511098]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4253.511100]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4253.511103]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4253.511105]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4253.511108]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4253.511111]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4253.511114]  [<ffffffff8024b7c1>] ? synchronize_rcu+0x49/0x50
[ 4253.511116]  [<ffffffff8024b649>] ? wakeme_after_rcu+0x0/0x9
[ 4253.511119]  [<ffffffff8053cc1b>] ? _spin_unlock+0x17/0x20
[ 4253.511124]  [<ffffffffa00e9136>] ? evdev_release+0x58/0x9f [evdev]
[ 4253.511127]  [<ffffffff802b5cfe>] ? __fput+0xe7/0x1b3
[ 4253.511129]  [<ffffffff802b319e>] ? filp_close+0x5b/0x62
[ 4253.511131]  [<ffffffff802b3244>] ? sys_close+0x9f/0xdd
[ 4253.511134]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4253.511135] INFO: lockdep is turned off.
[ 4253.511141] killall5      D 0000000000000000     0 20049  20037
[ 4253.511144]  ffff8801bf0dbec0 0000000000000046 0000000000000000 ffffffff802850d0
[ 4253.511148]  0000000000011a00 000000000000cc78 ffff8801b8ffaf10 ffff8801b8ffb2a0
[ 4253.511151]  0000000400000000 ffff88002817da18 ffff880028178c78 ffff8801b8ffb2a0
[ 4253.511154] Call Trace:
[ 4253.511158]  [<ffffffff802850d0>] ? find_get_page+0x0/0xc1
[ 4253.511161]  [<ffffffff8028da00>] ? ____pagevec_lru_add+0x142/0x172
[ 4253.511164]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4253.511166]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4253.511169]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4253.511171]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4253.511174]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4253.511176]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4253.511179]  [<ffffffff8028dafd>] ? lru_add_drain_per_cpu+0x0/0x5
[ 4253.511181]  [<ffffffff8024a56b>] ? flush_work+0xd4/0xe9
[ 4253.511183]  [<ffffffff8024a4cc>] ? flush_work+0x35/0xe9
[ 4253.511186]  [<ffffffff8022c29e>] ? __wake_up_common+0x44/0x73
[ 4253.511188]  [<ffffffff80249fa4>] ? wq_barrier_func+0x0/0x9
[ 4253.511191]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4253.511193]  [<ffffffff8024a8af>] ? schedule_on_each_cpu+0xc6/0x102
[ 4253.511196]  [<ffffffff8029c604>] ? sys_mlockall+0x31/0xbf
[ 4253.511199]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4253.511200] INFO: lockdep is turned off.
[ 4267.050770] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4267.050809] CPU 6:
[ 4267.050811] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4267.050850] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4267.050852] RIP: 0010:[<ffffffff80221ed0>]  [<ffffffff80221ed0>] __ticket_spin_trylock+0xb/0x19
[ 4267.050857] RSP: 0018:ffff8800281a3550  EFLAGS: 00000297
[ 4267.050859] RAX: 000000000000c2c1 RBX: ffff8800281b2730 RCX: 000000004049ac98
[ 4267.050861] RDX: 000000000000c3c1 RSI: 0000000000000001 RDI: ffff8800281b2730
[ 4267.050863] RBP: ffffffff8020bbd3 R08: 000000004049ac98 R09: 0000000000013a4b
[ 4267.050865] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 4267.050867] R13: 0000000026a24493 R14: 0000000000000001 R15: ffffffff8021d470
[ 4267.050869] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4267.050871] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4267.050872] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4267.050874] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4267.050876] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4267.050877] Call Trace:
[ 4267.050879]  <IRQ>  [<ffffffff803939b1>] ? _raw_spin_lock+0x85/0x105
[ 4267.050885]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4267.050888]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4267.050892]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4267.050897]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4267.050900]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4267.050907]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4267.050911]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4267.050914]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4267.050916]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4267.050919]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4267.050921]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4267.050923]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4267.050926]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4267.050928]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4267.050931]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4267.050934]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4267.050936]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4267.050938]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4267.050942]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4267.050946]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4267.050948]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4267.050951]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4267.050954]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4267.050956]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4267.050959]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4267.050961]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4267.050963]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4267.050966]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4267.050968]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4267.050971]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4267.050977]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4267.050983]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4267.050986]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4267.050992]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4267.050998]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4267.051000]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4267.051006]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4267.051009]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4267.051014]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4267.051020]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4267.051022]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4267.051025]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4267.051028]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4267.051030]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4267.051033]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4267.051036]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4267.051038]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4267.051039]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4267.051043]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4267.051047]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4267.051050]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4267.051053]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4267.051056]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4267.051066]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4267.051068]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4267.051071]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4267.051073]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4267.051075]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4267.051078]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4332.548525] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4332.548569] CPU 6:
[ 4332.548570] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4332.548609] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4332.548611] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 4332.548616] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 4332.548618] RAX: 00000000060ea447 RBX: ffff8800281b2730 RCX: 00000000060ea42f
[ 4332.548620] RDX: 0000000000000a89 RSI: 0000000000000001 RDI: 0000000000000001
[ 4332.548622] RBP: ffffffff8020bbd3 R08: 00000000060ea42f R09: 0000000000013a4b
[ 4332.548623] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4332.548625] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4332.548627] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4332.548629] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4332.548631] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4332.548633] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4332.548634] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4332.548636] Call Trace:
[ 4332.548637]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 4332.548645]  [<ffffffff803939b1>] ? _raw_spin_lock+0x85/0x105
[ 4332.548647]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4332.548652]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4332.548655]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4332.548660]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4332.548664]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4332.548668]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4332.548675]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4332.548679]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4332.548683]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4332.548686]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4332.548689]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4332.548691]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4332.548694]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4332.548696]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4332.548698]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4332.548701]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4332.548705]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4332.548708]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4332.548710]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4332.548714]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4332.548717]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4332.548720]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4332.548723]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4332.548725]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4332.548728]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4332.548730]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4332.548733]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4332.548735]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4332.548737]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4332.548740]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4332.548743]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4332.548749]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4332.548755]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4332.548758]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4332.548764]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4332.548770]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4332.548772]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4332.548778]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4332.548780]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4332.548786]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4332.548792]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4332.548794]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4332.548797]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4332.548800]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4332.548802]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4332.548805]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4332.548807]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4332.548810]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4332.548811]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4332.548816]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4332.548819]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4332.548823]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4332.548825]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4332.548829]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4332.548839]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4332.548841]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4332.548843]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4332.548846]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4332.548848]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4332.548851]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4373.491588] Xorg          D 0000000000000000     0  7152      1
[ 4373.491591]  ffff8801bf120000 0000000000000046 0000000000000000 ffffffff8053a015
[ 4373.491595]  0000000000011a00 000000000000cc78 ffff8801bc4fbec0 ffff8801bc4fc250
[ 4373.491598]  0000000500000046 ffff880028197a18 ffff880028192c78 ffff8801bc4fc250
[ 4373.491602] Call Trace:
[ 4373.491606]  [<ffffffff8053a015>] ? __schedule+0x131/0x941
[ 4373.491609]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4373.491612]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4373.491614]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4373.491617]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4373.491619]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4373.491622]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4373.491626]  [<ffffffff8024b7c1>] ? synchronize_rcu+0x49/0x50
[ 4373.491628]  [<ffffffff8024b649>] ? wakeme_after_rcu+0x0/0x9
[ 4373.491631]  [<ffffffff8053cc1b>] ? _spin_unlock+0x17/0x20
[ 4373.491637]  [<ffffffffa00e9136>] ? evdev_release+0x58/0x9f [evdev]
[ 4373.491640]  [<ffffffff802b5cfe>] ? __fput+0xe7/0x1b3
[ 4373.491642]  [<ffffffff802b319e>] ? filp_close+0x5b/0x62
[ 4373.491644]  [<ffffffff802b3244>] ? sys_close+0x9f/0xdd
[ 4373.491648]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4373.491649] INFO: lockdep is turned off.
[ 4373.491656] killall5      D 0000000000000000     0 20049  20037
[ 4373.491659]  ffff8801bf0dbec0 0000000000000046 0000000000000000 ffffffff802850d0
[ 4373.491663]  0000000000011a00 000000000000cc78 ffff8801b8ffaf10 ffff8801b8ffb2a0
[ 4373.491666]  0000000400000000 ffff88002817da18 ffff880028178c78 ffff8801b8ffb2a0
[ 4373.491669] Call Trace:
[ 4373.491673]  [<ffffffff802850d0>] ? find_get_page+0x0/0xc1
[ 4373.491676]  [<ffffffff8028da00>] ? ____pagevec_lru_add+0x142/0x172
[ 4373.491679]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4373.491681]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4373.491684]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4373.491686]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4373.491689]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4373.491691]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4373.491694]  [<ffffffff8028dafd>] ? lru_add_drain_per_cpu+0x0/0x5
[ 4373.491696]  [<ffffffff8024a56b>] ? flush_work+0xd4/0xe9
[ 4373.491699]  [<ffffffff8024a4cc>] ? flush_work+0x35/0xe9
[ 4373.491701]  [<ffffffff8022c29e>] ? __wake_up_common+0x44/0x73
[ 4373.491703]  [<ffffffff80249fa4>] ? wq_barrier_func+0x0/0x9
[ 4373.491706]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4373.491708]  [<ffffffff8024a8af>] ? schedule_on_each_cpu+0xc6/0x102
[ 4373.491711]  [<ffffffff8029c604>] ? sys_mlockall+0x31/0xbf
[ 4373.491714]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4373.491715] INFO: lockdep is turned off.
[ 4398.046541] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4398.046581] CPU 6:
[ 4398.046582] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4398.046621] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4398.046623] RIP: 0010:[<ffffffff8039039f>]  [<ffffffff8039039f>] delay_tsc+0x26/0x57
[ 4398.046628] RSP: 0018:ffff8800281a34f8  EFLAGS: 00000202
[ 4398.046629] RAX: 00000ab1cbde457f RBX: 0000000000000006 RCX: 00000000cbde457f
[ 4398.046631] RDX: 00000000cbde457f RSI: 0000000000000001 RDI: 0000000000000001
[ 4398.046633] RBP: ffffffff8020bbd3 R08: ffffffffcbde4544 R09: 0000000000013a4b
[ 4398.046635] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4398.046637] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4398.046639] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4398.046641] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4398.046643] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4398.046644] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4398.046646] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4398.046648] Call Trace:
[ 4398.046649]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 4398.046654]  [<ffffffff803939a9>] ? _raw_spin_lock+0x7d/0x105
[ 4398.046657]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4398.046661]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4398.046663]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4398.046668]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4398.046672]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4398.046675]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4398.046682]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4398.046686]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4398.046689]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4398.046692]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4398.046694]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4398.046696]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4398.046699]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4398.046702]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4398.046704]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4398.046706]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4398.046709]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4398.046711]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4398.046714]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4398.046717]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4398.046721]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4398.046724]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4398.046727]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4398.046729]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4398.046732]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4398.046734]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4398.046737]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4398.046739]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4398.046741]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4398.046744]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4398.046747]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4398.046753]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4398.046759]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4398.046762]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4398.046767]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4398.046773]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4398.046776]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4398.046782]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4398.046784]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4398.046790]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4398.046795]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4398.046798]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4398.046801]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4398.046803]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4398.046806]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4398.046808]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4398.046811]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4398.046813]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4398.046815]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4398.046819]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4398.046822]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4398.046826]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4398.046828]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4398.046831]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4398.046841]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4398.046844]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4398.046846]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4398.046848]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4398.046851]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4398.046854]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4463.544802] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4463.544841] CPU 6:
[ 4463.544843] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4463.544881] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4463.544883] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 4463.544887] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 4463.544888] RAX: 0000000091b7e77b RBX: 0000000000000006 RCX: 0000000091b7e758
[ 4463.544890] RDX: 0000000000000ada RSI: 0000000000000001 RDI: 0000000000000001
[ 4463.544892] RBP: ffffffff8020bbd3 R08: ffffffff91b7e740 R09: 0000000000013a4b
[ 4463.544894] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4463.544896] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4463.544898] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4463.544900] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4463.544901] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4463.544903] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4463.544905] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4463.544906] Call Trace:
[ 4463.544908]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 4463.544913]  [<ffffffff803939a9>] ? _raw_spin_lock+0x7d/0x105
[ 4463.544916]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4463.544920]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4463.544923]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4463.544927]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4463.544931]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4463.544934]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4463.544941]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4463.544945]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4463.544948]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4463.544950]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4463.544953]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4463.544955]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4463.544958]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4463.544960]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4463.544962]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4463.544965]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4463.544968]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4463.544970]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4463.544972]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4463.544976]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4463.544980]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4463.544982]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4463.544985]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4463.544988]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4463.544990]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4463.544992]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4463.544995]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4463.544997]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4463.545000]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4463.545002]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4463.545005]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4463.545011]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4463.545017]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4463.545020]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4463.545026]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4463.545031]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4463.545034]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4463.545040]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4463.545042]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4463.545048]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4463.545053]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4463.545056]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4463.545059]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4463.545061]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4463.545064]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4463.545066]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4463.545069]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4463.545071]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4463.545072]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4463.545077]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4463.545080]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4463.545083]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4463.545086]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4463.545089]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4463.545098]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4463.545101]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4463.545103]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4463.545106]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4463.545108]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4463.545111]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4493.472921] Xorg          D 0000000000000000     0  7152      1
[ 4493.472924]  ffff8801bf120000 0000000000000046 0000000000000000 ffffffff8053a015
[ 4493.472928]  0000000000011a00 000000000000cc78 ffff8801bc4fbec0 ffff8801bc4fc250
[ 4493.472931]  0000000500000046 ffff880028197a18 ffff880028192c78 ffff8801bc4fc250
[ 4493.472935] Call Trace:
[ 4493.472938]  [<ffffffff8053a015>] ? __schedule+0x131/0x941
[ 4493.472941]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4493.472944]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4493.472946]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4493.472949]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4493.472951]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4493.472954]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4493.472957]  [<ffffffff8024b7c1>] ? synchronize_rcu+0x49/0x50
[ 4493.472959]  [<ffffffff8024b649>] ? wakeme_after_rcu+0x0/0x9
[ 4493.472962]  [<ffffffff8053cc1b>] ? _spin_unlock+0x17/0x20
[ 4493.472967]  [<ffffffffa00e9136>] ? evdev_release+0x58/0x9f [evdev]
[ 4493.472970]  [<ffffffff802b5cfe>] ? __fput+0xe7/0x1b3
[ 4493.472972]  [<ffffffff802b319e>] ? filp_close+0x5b/0x62
[ 4493.472974]  [<ffffffff802b3244>] ? sys_close+0x9f/0xdd
[ 4493.472977]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4493.472979] INFO: lockdep is turned off.
[ 4493.472985] killall5      D 0000000000000000     0 20049  20037
[ 4493.472988]  ffff8801bf0dbec0 0000000000000046 0000000000000000 ffffffff802850d0
[ 4493.472991]  0000000000011a00 000000000000cc78 ffff8801b8ffaf10 ffff8801b8ffb2a0
[ 4493.472994]  0000000400000000 ffff88002817da18 ffff880028178c78 ffff8801b8ffb2a0
[ 4493.472998] Call Trace:
[ 4493.473000]  [<ffffffff802850d0>] ? find_get_page+0x0/0xc1
[ 4493.473004]  [<ffffffff8028da00>] ? ____pagevec_lru_add+0x142/0x172
[ 4493.473006]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4493.473008]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4493.473011]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4493.473013]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4493.473016]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4493.473018]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4493.473021]  [<ffffffff8028dafd>] ? lru_add_drain_per_cpu+0x0/0x5
[ 4493.473023]  [<ffffffff8024a56b>] ? flush_work+0xd4/0xe9
[ 4493.473026]  [<ffffffff8024a4cc>] ? flush_work+0x35/0xe9
[ 4493.473028]  [<ffffffff8022c29e>] ? __wake_up_common+0x44/0x73
[ 4493.473030]  [<ffffffff80249fa4>] ? wq_barrier_func+0x0/0x9
[ 4493.473033]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4493.473035]  [<ffffffff8024a8af>] ? schedule_on_each_cpu+0xc6/0x102
[ 4493.473038]  [<ffffffff8029c604>] ? sys_mlockall+0x31/0xbf
[ 4493.473041]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4493.473042] INFO: lockdep is turned off.
[ 4529.043293] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4529.043332] CPU 6:
[ 4529.043334] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4529.043373] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4529.043374] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 4529.043379] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000206
[ 4529.043380] RAX: 00000000579aece4 RBX: 0000000000000006 RCX: 00000000579aecd2
[ 4529.043382] RDX: 0000000000000b03 RSI: 0000000000000001 RDI: 0000000000000001
[ 4529.043384] RBP: ffffffff8020bbd3 R08: 00000000579aeca9 R09: 0000000000013a4b
[ 4529.043386] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4529.043388] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4529.043390] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4529.043392] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4529.043394] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4529.043395] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4529.043397] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4529.043399] Call Trace:
[ 4529.043400]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 4529.043405]  [<ffffffff803903cb>] ? delay_tsc+0x52/0x57
[ 4529.043408]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4529.043412]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4529.043415]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4529.043420]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4529.043424]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4529.043427]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4529.043434]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4529.043438]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4529.043441]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4529.043443]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4529.043446]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4529.043448]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4529.043451]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4529.043453]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4529.043456]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4529.043458]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4529.043461]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4529.043463]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4529.043466]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4529.043469]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4529.043473]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4529.043476]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4529.043479]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4529.043481]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4529.043484]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4529.043486]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4529.043488]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4529.043491]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4529.043493]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4529.043496]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4529.043498]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4529.043504]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4529.043511]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4529.043513]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4529.043519]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4529.043525]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4529.043528]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4529.043533]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4529.043536]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4529.043541]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4529.043547]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4529.043550]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4529.043552]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4529.043555]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4529.043558]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4529.043560]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4529.043563]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4529.043565]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4529.043566]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4529.043570]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4529.043574]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4529.043577]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4529.043580]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4529.043583]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4529.043592]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4529.043595]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4529.043597]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4529.043600]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4529.043602]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4529.043605]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4594.542000] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4594.542039] CPU 6:
[ 4594.542041] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4594.542079] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4594.542081] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 4594.542085] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 4594.542087] RAX: 000000001d86bf79 RBX: ffff8800281b2730 RCX: 000000001d86bf61
[ 4594.542089] RDX: 0000000000000b2c RSI: 0000000000000001 RDI: 0000000000000001
[ 4594.542090] RBP: ffffffff8020bbd3 R08: 000000001d86bf61 R09: 0000000000013a4b
[ 4594.542092] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4594.542094] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4594.542096] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4594.542098] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4594.542100] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4594.542102] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4594.542103] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4594.542105] Call Trace:
[ 4594.542106]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 4594.542113]  [<ffffffff80221ed7>] ? __ticket_spin_trylock+0x12/0x19
[ 4594.542116]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4594.542120]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4594.542123]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4594.542127]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4594.542131]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4594.542134]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4594.542141]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4594.542145]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4594.542148]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4594.542150]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4594.542153]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4594.542155]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4594.542158]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4594.542160]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4594.542162]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4594.542165]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4594.542168]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4594.542170]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4594.542172]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4594.542176]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4594.542180]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4594.542182]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4594.542185]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4594.542188]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4594.542190]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4594.542192]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4594.542195]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4594.542197]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4594.542199]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4594.542202]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4594.542205]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4594.542211]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4594.542217]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4594.542220]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4594.542225]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4594.542231]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4594.542234]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4594.542239]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4594.542242]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4594.542247]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4594.542253]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4594.542256]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4594.542258]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4594.542261]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4594.542264]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4594.542266]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4594.542269]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4594.542271]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4594.542272]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4594.542276]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4594.542280]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4594.542283]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4594.542286]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4594.542289]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4594.542298]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4594.542301]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4594.542303]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4594.542306]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4594.542308]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4594.542311]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4613.455028] Xorg          D 0000000000000000     0  7152      1
[ 4613.455031]  ffff8801bf120000 0000000000000046 0000000000000000 ffffffff8053a015
[ 4613.455034]  0000000000011a00 000000000000cc78 ffff8801bc4fbec0 ffff8801bc4fc250
[ 4613.455038]  0000000500000046 ffff880028197a18 ffff880028192c78 ffff8801bc4fc250
[ 4613.455041] Call Trace:
[ 4613.455047]  [<ffffffff8053a015>] ? __schedule+0x131/0x941
[ 4613.455049]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4613.455052]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4613.455054]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4613.455058]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4613.455060]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4613.455064]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4613.455068]  [<ffffffff8024b7c1>] ? synchronize_rcu+0x49/0x50
[ 4613.455070]  [<ffffffff8024b649>] ? wakeme_after_rcu+0x0/0x9
[ 4613.455073]  [<ffffffff8053cc1b>] ? _spin_unlock+0x17/0x20
[ 4613.455082]  [<ffffffffa00e9136>] ? evdev_release+0x58/0x9f [evdev]
[ 4613.455085]  [<ffffffff802b5cfe>] ? __fput+0xe7/0x1b3
[ 4613.455088]  [<ffffffff802b319e>] ? filp_close+0x5b/0x62
[ 4613.455090]  [<ffffffff802b3244>] ? sys_close+0x9f/0xdd
[ 4613.455094]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4613.455095] INFO: lockdep is turned off.
[ 4613.455103] killall5      D 0000000000000000     0 20049  20037
[ 4613.455105]  ffff8801bf0dbec0 0000000000000046 0000000000000000 ffffffff802850d0
[ 4613.455109]  0000000000011a00 000000000000cc78 ffff8801b8ffaf10 ffff8801b8ffb2a0
[ 4613.455112]  0000000400000000 ffff88002817da18 ffff880028178c78 ffff8801b8ffb2a0
[ 4613.455116] Call Trace:
[ 4613.455119]  [<ffffffff802850d0>] ? find_get_page+0x0/0xc1
[ 4613.455123]  [<ffffffff8028da00>] ? ____pagevec_lru_add+0x142/0x172
[ 4613.455125]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4613.455127]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4613.455130]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4613.455133]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4613.455135]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4613.455137]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4613.455140]  [<ffffffff8028dafd>] ? lru_add_drain_per_cpu+0x0/0x5
[ 4613.455142]  [<ffffffff8024a56b>] ? flush_work+0xd4/0xe9
[ 4613.455145]  [<ffffffff8024a4cc>] ? flush_work+0x35/0xe9
[ 4613.455147]  [<ffffffff8022c29e>] ? __wake_up_common+0x44/0x73
[ 4613.455150]  [<ffffffff80249fa4>] ? wq_barrier_func+0x0/0x9
[ 4613.455152]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4613.455155]  [<ffffffff8024a8af>] ? schedule_on_each_cpu+0xc6/0x102
[ 4613.455158]  [<ffffffff8029c604>] ? sys_mlockall+0x31/0xbf
[ 4613.455160]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4613.455162] INFO: lockdep is turned off.
[ 4660.039940] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4660.039984] CPU 6:
[ 4660.039985] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4660.040024] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4660.040026] RIP: 0010:[<ffffffff80390379>]  [<ffffffff80390379>] delay_tsc+0x0/0x57
[ 4660.040032] RSP: 0018:ffff8800281a3550  EFLAGS: 00000206
[ 4660.040034] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 00000000e35344d6
[ 4660.040035] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 4660.040037] RBP: ffffffff8020bbd3 R08: ffffffffe35344d6 R09: 0000000000013a4b
[ 4660.040039] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 4660.040041] R13: 0000000048506dde R14: 0000000000000001 R15: ffffffff8021d470
[ 4660.040043] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4660.040045] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4660.040047] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4660.040049] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4660.040050] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4660.040052] Call Trace:
[ 4660.040053]  <IRQ>  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4660.040062]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4660.040065]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4660.040070]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4660.040074]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4660.040077]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4660.040085]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4660.040089]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4660.040092]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4660.040095]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4660.040098]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4660.040100]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4660.040102]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4660.040105]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4660.040107]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4660.040110]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4660.040113]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4660.040116]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4660.040118]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4660.040122]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4660.040126]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4660.040129]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4660.040132]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4660.040134]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4660.040137]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4660.040139]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4660.040141]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4660.040144]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4660.040146]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4660.040149]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4660.040152]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4660.040158]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4660.040164]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4660.040167]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4660.040173]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4660.040179]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4660.040182]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4660.040187]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4660.040190]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4660.040195]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4660.040201]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4660.040204]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4660.040206]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4660.040209]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4660.040211]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4660.040214]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4660.040217]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4660.040220]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4660.040221]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4660.040225]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4660.040229]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4660.040233]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4660.040236]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4660.040240]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4660.040250]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4660.040253]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4660.040255]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4660.040258]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4660.040260]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4660.040263]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4725.537911] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4725.537951] CPU 6:
[ 4725.537952] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4725.537991] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4725.537993] RIP: 0010:[<ffffffff803903dc>]  [<ffffffff803903dc>] __delay+0x0/0xa
[ 4725.537998] RSP: 0018:ffff8800281a3550  EFLAGS: 00000216
[ 4725.537999] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 00000000a9211a35
[ 4725.538001] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 4725.538003] RBP: ffffffff8020bbd3 R08: ffffffffa9211a35 R09: 0000000000013a4b
[ 4725.538005] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 4725.538006] R13: 0000000068adec60 R14: 0000000000000001 R15: ffffffff8021d470
[ 4725.538009] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4725.538011] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4725.538012] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4725.538014] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4725.538016] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4725.538017] Call Trace:
[ 4725.538018]  <IRQ>  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4725.538025]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4725.538028]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4725.538032]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4725.538036]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4725.538039]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4725.538046]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4725.538050]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4725.538053]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4725.538055]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4725.538057]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4725.538060]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4725.538062]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4725.538065]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4725.538067]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4725.538069]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4725.538072]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4725.538075]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4725.538077]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4725.538081]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4725.538084]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4725.538087]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4725.538090]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4725.538092]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4725.538095]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4725.538097]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4725.538100]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4725.538102]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4725.538104]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4725.538107]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4725.538110]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4725.538116]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4725.538122]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4725.538125]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4725.538130]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4725.538136]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4725.538139]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4725.538144]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4725.538147]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4725.538152]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4725.538158]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4725.538161]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4725.538163]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4725.538166]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4725.538169]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4725.538171]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4725.538174]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4725.538176]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4725.538177]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4725.538182]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4725.538185]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4725.538188]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4725.538191]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4725.538194]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4725.538204]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4725.538206]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4725.538208]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4725.538211]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4725.538213]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4725.538216]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4733.441024] Xorg          D 0000000000000000     0  7152      1
[ 4733.441027]  ffff8801bf120000 0000000000000046 0000000000000000 ffffffff8053a015
[ 4733.441030]  0000000000011a00 000000000000cc78 ffff8801bc4fbec0 ffff8801bc4fc250
[ 4733.441034]  0000000500000046 ffff880028197a18 ffff880028192c78 ffff8801bc4fc250
[ 4733.441037] Call Trace:
[ 4733.441041]  [<ffffffff8053a015>] ? __schedule+0x131/0x941
[ 4733.441044]  [<ffffffff8053a8d7>] ? schedule+0x9/0x1d
[ 4733.441046]  [<ffffffff8053abae>] ? schedule_timeout+0x1f/0x166
[ 4733.441049]  [<ffffffff8053a9dd>] ? wait_for_common+0x39/0x14f
[ 4733.441052]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4733.441054]  [<ffffffff8053aa85>] ? wait_for_common+0xe1/0x14f
[ 4733.441057]  [<ffffffff80231dfb>] ? default_wake_function+0x0/0x9
[ 4733.441061]  [<ffffffff8024b7c1>] ? synchronize_rcu+0x49/0x50
[ 4733.441063]  [<ffffffff8024b649>] ? wakeme_after_rcu+0x0/0x9
[ 4733.441066]  [<ffffffff8053cc1b>] ? _spin_unlock+0x17/0x20
[ 4733.441072]  [<ffffffffa00e9136>] ? evdev_release+0x58/0x9f [evdev]
[ 4733.441075]  [<ffffffff802b5cfe>] ? __fput+0xe7/0x1b3
[ 4733.441077]  [<ffffffff802b319e>] ? filp_close+0x5b/0x62
[ 4733.441079]  [<ffffffff802b3244>] ? sys_close+0x9f/0xdd
[ 4733.441082]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4733.441084] INFO: lockdep is turned off.
[ 4791.036883] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4791.036927] CPU 6:
[ 4791.036928] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4791.036968] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4791.036969] RIP: 0010:[<ffffffff80390379>]  [<ffffffff80390379>] delay_tsc+0x0/0x57
[ 4791.036976] RSP: 0018:ffff8800281a3550  EFLAGS: 00000206
[ 4791.036977] RAX: 0000000000000000 RBX: ffff8800281b2730 RCX: 000000006f17bae6
[ 4791.036979] RDX: 000000000000c300 RSI: 0000000000000001 RDI: 0000000000000001
[ 4791.036981] RBP: ffffffff8020bbd3 R08: 000000006f17bae6 R09: 0000000000013a4b
[ 4791.036983] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a34d0
[ 4791.036985] R13: 0000000088b84b41 R14: 0000000000000001 R15: ffffffff8021d470
[ 4791.036987] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4791.036989] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4791.036990] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4791.036992] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4791.036994] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4791.036996] Call Trace:
[ 4791.036997]  <IRQ>  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4791.037005]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4791.037008]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4791.037013]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4791.037017]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4791.037020]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4791.037028]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4791.037032]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4791.037037]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4791.037040]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4791.037042]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4791.037044]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4791.037047]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4791.037050]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4791.037052]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4791.037054]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4791.037057]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4791.037060]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4791.037063]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4791.037066]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4791.037070]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4791.037073]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4791.037076]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4791.037078]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4791.037081]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4791.037083]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4791.037086]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4791.037088]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4791.037090]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4791.037093]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4791.037096]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4791.037102]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4791.037109]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4791.037112]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4791.037117]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4791.037123]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4791.037126]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4791.037131]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4791.037134]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4791.037139]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4791.037145]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4791.037148]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4791.037151]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4791.037153]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4791.037156]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4791.037158]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4791.037162]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4791.037165]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4791.037166]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4791.037170]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4791.037174]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4791.037178]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4791.037181]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4791.037184]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4791.037194]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4791.037197]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4791.037199]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4791.037202]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4791.037204]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4791.037207]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4856.534855] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4856.534895] CPU 6:
[ 4856.534897] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4856.534936] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4856.534938] RIP: 0010:[<ffffffff80210d95>]  [<ffffffff80210d95>] native_read_tsc+0x0/0x11
[ 4856.534943] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000202
[ 4856.534944] RAX: 00000bcf34e590d0 RBX: 0000000000000006 RCX: 0000000034e590d0
[ 4856.534946] RDX: 0000000034e590d0 RSI: 0000000000000001 RDI: 0000000000000001
[ 4856.534948] RBP: ffffffff8020bbd3 R08: 0000000034e590b5 R09: 0000000000013a4b
[ 4856.534950] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4856.534951] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4856.534953] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4856.534955] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4856.534957] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4856.534959] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4856.534961] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4856.534962] Call Trace:
[ 4856.534963]  <IRQ>  [<ffffffff8039039f>] ? delay_tsc+0x26/0x57
[ 4856.534969]  [<ffffffff803903dc>] ? __delay+0x0/0xa
[ 4856.534972]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4856.534976]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4856.534979]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4856.534983]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4856.534987]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4856.534990]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4856.534997]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4856.535001]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4856.535004]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4856.535007]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4856.535009]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4856.535011]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4856.535014]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4856.535017]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4856.535019]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4856.535021]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4856.535024]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4856.535027]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4856.535029]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4856.535032]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4856.535036]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4856.535039]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4856.535042]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4856.535044]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4856.535047]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4856.535049]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4856.535051]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4856.535054]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4856.535056]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4856.535059]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4856.535061]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4856.535067]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4856.535074]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4856.535076]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4856.535082]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4856.535088]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4856.535091]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4856.535096]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4856.535099]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4856.535104]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4856.535110]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4856.535113]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4856.535115]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4856.535118]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4856.535120]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4856.535123]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4856.535125]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4856.535128]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4856.535129]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4856.535133]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4856.535137]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4856.535140]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4856.535142]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4856.535146]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4856.535155]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4856.535158]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4856.535160]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4856.535163]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4856.535165]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4856.535168]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
[ 4922.032827] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4922.032871] CPU 6:
[ 4922.032872] Modules linked in: tun binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm pci_slot cpufreq_powersave cpufreq_ondemand cpufreq_conservative cpufreq_userspace snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse snd pcspkr serio_raw evdev wmi rtc_cmos soundcore snd_page_alloc sg sr_mod cdrom hid_belkin usbhid mvsas pata_marvell pata_acpi libsas ata_piix ahci scsi_transport_sas sky2 igb dca floppy fuse
[ 4922.032911] Pid: 12397, comm: kvm Not tainted 2.6.30-rc1 #6 System Product Name
[ 4922.032913] RIP: 0010:[<ffffffff80210d97>]  [<ffffffff80210d97>] native_read_tsc+0x2/0x11
[ 4922.032918] RSP: 0018:ffff8800281a34f0  EFLAGS: 00000292
[ 4922.032920] RAX: 00000000fab36795 RBX: ffff8800281b2730 RCX: 00000000fab3676c
[ 4922.032922] RDX: 0000000000000bf7 RSI: 0000000000000001 RDI: 0000000000000001
[ 4922.032924] RBP: ffffffff8020bbd3 R08: fffffffffab3676c R09: 0000000000013a4b
[ 4922.032925] R10: ffffffff8023a5e7 R11: ffffffff80390379 R12: ffff8800281a3470
[ 4922.032927] R13: 0000000000000006 R14: 0000000000000001 R15: ffffffff8021d470
[ 4922.032929] FS:  00007fa315516950(0000) GS:ffff8800281a0000(0000) knlGS:0000000000000000
[ 4922.032931] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4922.032933] CR2: 00000000b7ff1000 CR3: 000000015cec1000 CR4: 00000000000026e0
[ 4922.032935] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4922.032937] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4922.032938] Call Trace:
[ 4922.032940]  <IRQ>  [<ffffffff80390393>] ? delay_tsc+0x1a/0x57
[ 4922.032947]  [<ffffffff803903cf>] ? delay_tsc+0x56/0x57
[ 4922.032950]  [<ffffffff803939c4>] ? _raw_spin_lock+0x98/0x105
[ 4922.032954]  [<ffffffffa024041d>] ? ipt_do_table+0x102/0x5f1 [ip_tables]
[ 4922.032958]  [<ffffffff8048d4e0>] ? skb_checksum+0x4c/0x257
[ 4922.032963]  [<ffffffffa025f1fc>] ? manip_pkt+0x80/0xf4 [nf_nat]
[ 4922.032967]  [<ffffffffa025f432>] ? nf_nat_icmp_reply_translation+0x1c2/0x245 [nf_nat]
[ 4922.032970]  [<ffffffff8048f632>] ? __alloc_skb+0x6b/0x13d
[ 4922.032978]  [<ffffffffa0246cfe>] ? nf_conntrack_in+0x45e/0x5ac [nf_conntrack]
[ 4922.032982]  [<ffffffffa01602b1>] ? nf_nat_fn+0xc1/0x14d [iptable_nat]
[ 4922.032986]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4922.032989]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4922.032991]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4922.032993]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
[ 4922.032996]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
[ 4922.032999]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
[ 4922.033001]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
[ 4922.033003]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0x33e
[ 4922.033007]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
[ 4922.033009]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
[ 4922.033012]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
[ 4922.033015]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJECT]
[ 4922.033019]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_tables]
[ 4922.033022]  [<ffffffff804b37a0>] ? rt_intern_hash+0x46f/0x48a
[ 4922.033025]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4922.033027]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4922.033030]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4922.033032]  [<ffffffff804b7d94>] ? ip_forward_finish+0x0/0x3b
[ 4922.033035]  [<ffffffff804b8070>] ? ip_forward+0x2a1/0x321
[ 4922.033037]  [<ffffffff804b69c6>] ? ip_rcv_finish+0x31e/0x338
[ 4922.033039]  [<ffffffff804b6c15>] ? ip_rcv+0x235/0x27a
[ 4922.033042]  [<ffffffff804957ee>] ? netif_receive_skb+0x4b6/0x4f3
[ 4922.033045]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4922.033051]  [<ffffffffa0228a24>] ? br_handle_frame_finish+0x110/0x148 [bridge]
[ 4922.033057]  [<ffffffffa022cdf9>] ? br_nf_pre_routing_finish+0x300/0x30f [bridge]
[ 4922.033060]  [<ffffffff804b01ff>] ? nf_hook_slow+0xf3/0x104
[ 4922.033066]  [<ffffffffa022caf9>] ? br_nf_pre_routing_finish+0x0/0x30f [bridge]
[ 4922.033072]  [<ffffffffa022d51e>] ? br_nf_pre_routing+0x716/0x730 [bridge]
[ 4922.033074]  [<ffffffff804b00d0>] ? nf_iterate+0x41/0x7d
[ 4922.033080]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4922.033083]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
[ 4922.033088]  [<ffffffffa0228914>] ? br_handle_frame_finish+0x0/0x148 [bridge]
[ 4922.033094]  [<ffffffffa0228bf8>] ? br_handle_frame+0x19c/0x1c0 [bridge]
[ 4922.033097]  [<ffffffff804956d2>] ? netif_receive_skb+0x39a/0x4f3
[ 4922.033099]  [<ffffffff8049548d>] ? netif_receive_skb+0x155/0x4f3
[ 4922.033102]  [<ffffffff804958aa>] ? process_backlog+0x7f/0xb4
[ 4922.033105]  [<ffffffff80493b65>] ? net_rx_action+0xa8/0x1d5
[ 4922.033107]  [<ffffffff80493c4f>] ? net_rx_action+0x192/0x1d5
[ 4922.033110]  [<ffffffff8023f041>] ? __do_softirq+0xac/0x173
[ 4922.033112]  [<ffffffff8020c1cc>] ? call_softirq+0x1c/0x28
[ 4922.033114]  <EOI>  [<ffffffff8020d3be>] ? do_softirq+0x3a/0x82
[ 4922.033118]  [<ffffffff80495e89>] ? netif_rx_ni+0x19/0x1d
[ 4922.033121]  [<ffffffffa026d4ae>] ? tun_chr_aio_write+0x347/0x3a6 [tun]
[ 4922.033125]  [<ffffffffa026d167>] ? tun_chr_aio_write+0x0/0x3a6 [tun]
[ 4922.033128]  [<ffffffff802b480d>] ? do_sync_readv_writev+0xc0/0x107
[ 4922.033131]  [<ffffffff8024d8bf>] ? autoremove_wake_function+0x0/0x2e
[ 4922.033141]  [<ffffffffa01eea62>] ? kvm_vcpu_ioctl+0x5eb/0x5fe [kvm]
[ 4922.033143]  [<ffffffff802b4699>] ? rw_copy_check_uvector+0x6d/0xe4
[ 4922.033146]  [<ffffffff802b4f22>] ? do_readv_writev+0xb2/0x18b
[ 4922.033148]  [<ffffffff802b5a80>] ? fget_light+0x46/0xd9
[ 4922.033151]  [<ffffffff802b5121>] ? sys_writev+0x45/0x93
[ 4922.033154]  [<ffffffff8020afc2>] ? system_call_fastpath+0x16/0x1b
