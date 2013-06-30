From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: skbuff: skb_under_panic warning in 3.10rc7+
Date: Sun, 30 Jun 2013 20:29:11 +0200
Message-ID: <20130630182911.GA24201@order.stressinduktion.org>
References: <20130630160246.GA24539@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:46540 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab3F3S3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 14:29:18 -0400
Content-Disposition: inline
In-Reply-To: <20130630160246.GA24539@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 30, 2013 at 12:02:46PM -0400, Dave Jones wrote:
> skbuff: skb_under_panic: text:ffffffff816765f6 len:48 put:40 head:ffff88013deb6df0 data:ffff88013deb6dec tail:0x2c end:0xc0 dev:<NULL>
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:126!
> invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> Modules linked in: dccp_ipv4 dccp 8021q garp bridge stp dlci mpoa snd_seq_dummy sctp fuse hidp tun bnep nfnetlink scsi_transport_iscsi rfcomm can_raw can_bcm af_802154 appletalk caif_socket can caif ipt_ULOG x25 rose af_key pppoe pppox ipx phonet irda llc2 ppp_generic slhc p8023 psnap p8022 llc crc_ccitt atm bluetooth netrom ax25 nfc rfkill rds af_rxrpc coretemp hwmon kvm_intel kvm crc32c_intel snd_hda_codec_realtek ghash_clmulni_intel microcode pcspkr snd_hda_codec_hdmi snd_hda_intel snd_hda_codec snd_hwdep usb_debug snd_seq snd_seq_device snd_pcm e1000e snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
> CPU: 2 PID: 8095 Comm: trinity-child2 Not tainted 3.10.0-rc7+ #37 
> task: ffff8801f52c2520 ti: ffff8801e6430000 task.ti: ffff8801e6430000
> RIP: 0010:[<ffffffff816e759c>]  [<ffffffff816e759c>] skb_panic+0x63/0x65
> RSP: 0018:ffff8801e6431de8  EFLAGS: 00010282
> RAX: 0000000000000086 RBX: ffff8802353d3cc0 RCX: 0000000000000006
> RDX: 0000000000003b90 RSI: ffff8801f52c2ca0 RDI: ffff8801f52c2520
> RBP: ffff8801e6431e08 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000001 R11: 0000000000000001 R12: ffff88022ea0c800
> R13: ffff88022ea0cdf8 R14: ffff8802353ecb40 R15: ffffffff81cc7800
> FS:  00007f5720a10740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000005862000 CR3: 000000022843c000 CR4: 00000000001407e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Stack:
>  ffff88013deb6dec 000000000000002c 00000000000000c0 ffffffff81a3f6e4
>  ffff8801e6431e18 ffffffff8159a9aa ffff8801e6431e90 ffffffff816765f6
>  ffffffff810b756b 0000000700000002 ffff8801e6431e40 0000fea9292aa8c0
> Call Trace:
>  [<ffffffff8159a9aa>] skb_push+0x3a/0x40
>  [<ffffffff816765f6>] ip6_push_pending_frames+0x1f6/0x4d0
>  [<ffffffff810b756b>] ? mark_held_locks+0xbb/0x140
>  [<ffffffff81694919>] udp_v6_push_pending_frames+0x2b9/0x3d0
>  [<ffffffff81694660>] ? udplite_getfrag+0x20/0x20
>  [<ffffffff8162092a>] udp_lib_setsockopt+0x1aa/0x1f0
>  [<ffffffff811cc5e7>] ? fget_light+0x387/0x4f0
>  [<ffffffff816958a4>] udpv6_setsockopt+0x34/0x40
>  [<ffffffff815949f4>] sock_common_setsockopt+0x14/0x20
>  [<ffffffff81593c31>] SyS_setsockopt+0x71/0xd0
>  [<ffffffff816f5d54>] tracesys+0xdd/0xe2
> Code: 00 00 48 89 44 24 10 8b 87 d8 00 00 00 48 89 44 24 08 48 8b 87 e8 00 00 00 48 c7 c7 c0 04 aa 81 48 89 04 24 31 c0 e8 e1 7e ff ff <0f> 0b 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 55 
> RIP  [<ffffffff816e759c>] skb_panic+0x63/0x65
>  RSP <ffff8801e6431de8>

We need to add some logic to reallocate skbs in case of UDP_CORK and if
extension headers are in use. A small test with UDP_CORK and IPV6_DSTOPTS
resulted in this (some lines below your crash in ip6_append_data):

[37598.993962] ------------[ cut here ]------------
[37598.994008] kernel BUG at net/core/skbuff.c:2064!
[37598.994008] invalid opcode: 0000 [#1] SMP 
[37598.994008] Modules linked in: tcp_lp uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev media vfat fat usb_storage fuse ebtable_nat xt_CHECKSUM bridge stp llc ipt_MASQUERADE nf_conntrack_netbios_ns nf_conntrack_broadcast ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi rfcomm bnep iTCO_wdt iTCO_vendor_support snd_hda_codec_conexant arc4 iwldvm mac80211 snd_hda_intel acpi_cpufreq mperf coretemp snd_hda_codec microcode
  cdc_wdm cdc_acm
[37598.994008]  snd_hwdep cdc_ether snd_seq snd_seq_device usbnet mii joydev btusb snd_pcm bluetooth i2c_i801 e1000e lpc_ich mfd_core ptp iwlwifi pps_core snd_page_alloc mei cfg80211 snd_timer thinkpad_acpi snd tpm_tis soundcore rfkill tpm tpm_bios vhost_net tun macvtap macvlan kvm_intel kvm uinput binfmt_misc dm_crypt i915 i2c_algo_bit drm_kms_helper drm i2c_core wmi video
[37598.994008] CPU 0 
[37598.994008] Pid: 27320, comm: t2 Not tainted 3.9.6-200.fc18.x86_64 #1 LENOVO 27744PG/27744PG
[37598.994008] RIP: 0010:[<ffffffff815443a5>]  [<ffffffff815443a5>] skb_copy_and_csum_bits+0x325/0x330
[37598.994008] RSP: 0018:ffff88003670da18  EFLAGS: 00010202
[37598.994008] RAX: ffff88018105c018 RBX: 0000000000000004 RCX: 00000000000006c0
[37598.994008] RDX: ffff88018105a6c0 RSI: ffff88018105a000 RDI: ffff8801e1b0aa00
[37598.994008] RBP: ffff88003670da78 R08: 0000000000000000 R09: ffff88018105c040
[37598.994008] R10: ffff8801e1b0aa00 R11: 0000000000000000 R12: 000000000000fff8
[37598.994008] R13: 00000000000004fc R14: 00000000ffff0504 R15: 0000000000000000
[37598.994008] FS:  00007f28eea59740(0000) GS:ffff88023bc00000(0000) knlGS:0000000000000000
[37598.994008] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[37598.994008] CR2: 0000003d935789e0 CR3: 00000000365cb000 CR4: 00000000000407f0
[37598.994008] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[37598.994008] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[37598.994008] Process t2 (pid: 27320, threadinfo ffff88003670c000, task ffff88022c162ee0)
[37598.994008] Stack:
[37598.994008]  ffff88022e098a00 ffff88020f973fc0 0000000000000008 00000000000004c8
[37598.994008]  ffff88020f973fc0 00000000000004c4 ffff88003670da78 ffff8801e1b0a200
[37598.994008]  0000000000000018 00000000000004c8 ffff88020f973fc0 00000000000004c4
[37598.994008] Call Trace:
[37598.994008]  [<ffffffff815fc21f>] ip6_append_data+0xccf/0xfe0
[37598.994008]  [<ffffffff8158d9f0>] ? ip_copy_metadata+0x1a0/0x1a0
[37598.994008]  [<ffffffff81661f66>] ? _raw_spin_lock_bh+0x16/0x40
[37598.994008]  [<ffffffff8161548d>] udpv6_sendmsg+0x1ed/0xc10
[37598.994008]  [<ffffffff812a2845>] ? sock_has_perm+0x75/0x90
[37598.994008]  [<ffffffff815c3693>] inet_sendmsg+0x63/0xb0
[37598.994008]  [<ffffffff812a2973>] ? selinux_socket_sendmsg+0x23/0x30
[37598.994008]  [<ffffffff8153a450>] sock_sendmsg+0xb0/0xe0
[37598.994008]  [<ffffffff810135d1>] ? __switch_to+0x181/0x4a0
[37598.994008]  [<ffffffff8153d97d>] sys_sendto+0x12d/0x180
[37598.994008]  [<ffffffff810dfb64>] ? __audit_syscall_entry+0x94/0xf0
[37598.994008]  [<ffffffff81020ed1>] ? syscall_trace_enter+0x231/0x240
[37598.994008]  [<ffffffff8166a7e7>] tracesys+0xdd/0xe2
[37598.994008] Code: fe 07 00 00 48 c7 c7 04 28 a6 81 89 45 a0 4c 89 4d b8 44 89 5d a8 e8 1b ac b1 ff 44 8b 5d a8 4c 8b 4d b8 8b 45 a0 e9 cf fe ff ff <0f> 0b 66 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 48 
[37598.994008] RIP  [<ffffffff815443a5>] skb_copy_and_csum_bits+0x325/0x330
[37598.994008]  RSP <ffff88003670da18>
[37599.007323] ---[ end trace d69f6a17f8ac8eee ]---
