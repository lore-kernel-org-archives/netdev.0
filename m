From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 0/5] Checksum fixes
Date: Sun, 15 Jun 2014 08:45:52 -0700
Message-ID: <CA+mtBx8ReQjfNDhmrgtTFbDjmZzJKWTRYjVon5iQ-uunNi48Gg@mail.gmail.com>
References: <alpine.DEB.2.02.1406142312290.17261@tomh.mtv.corp.google.com>
	<20140615.010113.950904601534084657.davem@davemloft.net>
	<CAJZOPZJ=WfQ9CNpcX=+us=M7ZhN4u8MDr22wUspSAaKyfO=p7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:60592 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbaFOPpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 11:45:53 -0400
Received: by mail-ig0-f178.google.com with SMTP id hn18so2084326igb.17
        for <netdev@vger.kernel.org>; Sun, 15 Jun 2014 08:45:52 -0700 (PDT)
In-Reply-To: <CAJZOPZJ=WfQ9CNpcX=+us=M7ZhN4u8MDr22wUspSAaKyfO=p7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 15, 2014 at 5:29 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Sun, Jun 15, 2014 at 11:01 AM, David Miller <davem@davemloft.net> wrote:
>>
>> From: Tom Herbert <therbert@google.com>
>> Date: Sat, 14 Jun 2014 23:23:44 -0700 (PDT)
>>
>> > Fixes related to some recent checksum modifications.
>> >
>> > - Fix GSO constants to match NETIF flags
>> > - Fix logic in saving checksum complete in __skb_checksum_complete
>> > - Call __skb_checksum_complete from UDP if we are checksumming over
>> >   whole packet in order to save checksum.
>> > - Fixes to VXLAN to work correctly with checksum complete
>>
>> Series applied, thanks Tom.
>
>
>
> OK, so I gave the net tree which contains these fixes (e.g up to
> commit b58537a "net: sctp: fix permissions for rto_alpha and rto_beta
> knobs")
> a try to see how vxlan offloading goes. Things (HW TX/RX checksum, HW
> LSO and GRO come into play) looks basically OK.  I tested with
> Mellanox ConnectX3-pro card and the mlx4 driver with the offloads
> enabled.
>
Thanks for testing the combinations.

> I quickly passed through the four different setups below
>
> 1. veth --> OVS --> OVS VXLAN port --> IP stack ---> mlx4 --> HW
>
> 2. veth --> Bridge --> VXLAN NIC  --> IP stack ---> mlx4 --> HW
>
> 3. bridge --> VXLAN NIC  --> IP stack ---> mlx4 --> HW
>
> 4. VXLAN NIC  --> IP stack ---> mlx4 --> HW
>
> I didn't test yet the path from VM, e.g through vhost and tap to OVS
> and then to VXLAN, will do in the coming days
>
> @ some point, I did stepped on something... the below trace
>
Possibly related to truesize?

> Or.
>
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 11257 at net/core/skbuff.c:3884
> skb_try_coalesce+0x246/0x371()
> Modules linked in: veth bridge stp llc mlx4_en mlx4_ib mlx4_core vxlan
> netconsole nfsv3 nfs_acl auth_rpcgss oid_registry nfsv4 nfs lockd
> autofs4 sunrpc crc32c_generic ib_ucm rdma_ucm rdma_cm iw_cm ib_ipoib
> ib_cm ib_uverbs ib_umad ib_sa ib_mad ib_core ib_addr ipv6 dm_mirror
> dm_region_hash dm_log dm_mod igb ptp pps_core joydev sg microcode
> pcspkr rng_core ehci_pci ehci_hcd ioatdma dca shpchp button sr_mod
> ext3 jbd floppy usb_storage sd_mod crc_t10dif crct10dif_common
> ata_piix libata scsi_mod uhci_hcd radeon ttm drm_kms_helper hwmon
> [last unloaded: veth]
> CPU: 1 PID: 11257 Comm: netserver Tainted: G        W I   3.15.0+ #152
> Hardware name: Supermicro X7DWU/X7DWU, BIOS  1.1 04/30/2008
>  0000000000000f2c ffff88022fc83ac8 ffffffff813d6986 0000000000000f2c
>  0000000000000000 ffff88022fc83b08 ffffffff81039c7c ffff88021ea37e00
>  ffffffff81333adb ffff88021ea37f00 ffff88021ea37b00 ffff88022fc83b84
> Call Trace:
>  <IRQ>  [<ffffffff813d6986>] dump_stack+0x51/0x6b
>  [<ffffffff81039c7c>] warn_slowpath_common+0x7c/0x96
>  [<ffffffff81333adb>] ? skb_try_coalesce+0x246/0x371
>  [<ffffffff81039cab>] warn_slowpath_null+0x15/0x17
>  [<ffffffff81333adb>] skb_try_coalesce+0x246/0x371
>  [<ffffffff8133d3d2>] ? netif_receive_skb_internal+0xed/0xed
>  [<ffffffff81380d49>] tcp_try_coalesce+0x4d/0xa1
>  [<ffffffff81380df5>] tcp_queue_rcv+0x58/0x105
>  [<ffffffff81384282>] tcp_rcv_established+0x3a3/0x5f9
>  [<ffffffff8138b636>] ? tcp_v4_rcv+0x476/0x95b
>  [<ffffffff8138ae97>] tcp_v4_do_rcv+0x102/0x42b
>  [<ffffffff813dae75>] ? _raw_spin_lock_nested+0x3a/0x41
>  [<ffffffff8138b662>] tcp_v4_rcv+0x4a2/0x95b
>  [<ffffffff8136d907>] ? ip_local_deliver_finish+0x2f/0x289
>  [<ffffffff8136da42>] ip_local_deliver_finish+0x16a/0x289
>  [<ffffffff8136d907>] ? ip_local_deliver_finish+0x2f/0x289
>  [<ffffffff8136dbd4>] ip_local_deliver+0x73/0x7a
>  [<ffffffff8136d5d7>] ip_rcv_finish+0x417/0x42f
>  [<ffffffff8136d8a0>] ip_rcv+0x2b1/0x2e9
>  [<ffffffff8133d09c>] __netif_receive_skb_core+0x47e/0x4d4
>  [<ffffffff8133ccde>] ? __netif_receive_skb_core+0xc0/0x4d4
>  [<ffffffff8133d147>] __netif_receive_skb+0x55/0x5a
>  [<ffffffff8133d1fb>] process_backlog+0xaf/0x199
>  [<ffffffff8133d697>] net_rx_action+0xac/0x1f2
>  [<ffffffff8103e3cd>] __do_softirq+0x12b/0x28e
>  [<ffffffff8132e88d>] ? release_sock+0x1c0/0x1c9
>  [<ffffffff813e41cc>] do_softirq_own_stack+0x1c/0x30
>  <EOI>  [<ffffffff8103e074>] do_softirq+0x31/0x4a
>  [<ffffffff8103e1ba>] __local_bh_enable_ip+0x92/0xa5
>  [<ffffffff813db512>] _raw_spin_unlock_bh+0x34/0x38
>  [<ffffffff8132e88d>] release_sock+0x1c0/0x1c9
>  [<ffffffff8137b6b8>] tcp_recvmsg+0x907/0xa4c
>  [<ffffffff8135e794>] ? sch_direct_xmit+0x9e/0x213
>  [<ffffffff8139d5d3>] inet_recvmsg+0xd1/0xeb
>  [<ffffffff8132aa8a>] sock_recvmsg+0x94/0xb2
>  [<ffffffff81073034>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff813db541>] ? _raw_spin_unlock_irq+0x2b/0x38
>  [<ffffffff81126726>] ? __fdget+0xe/0x10
>  [<ffffffff8132ab67>] SyS_recvfrom+0xbf/0x10f
>  [<ffffffff81085e08>] ? rcu_irq_exit+0x7d/0x8f
>  [<ffffffff813dbaa0>] ? retint_restore_args+0xe/0xe
>  [<ffffffff8132e6fd>] ? release_sock+0x30/0x1c9
>  [<ffffffff8132e6fd>] ? release_sock+0x30/0x1c9
>  [<ffffffff813e2962>] system_call_fastpath+0x16/0x1b
> ---[ end trace 665483c39b84f51c ]---
