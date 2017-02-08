From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page recycling
Date: Wed, 8 Feb 2017 12:29:15 +0200
Message-ID: <677b41a2-fa33-b2e7-0535-ac78823b67d9@gmail.com>
References: <20170207030240.31357-1-edumazet@google.com>
 <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
 <029a2e2e-eb06-e452-e00e-56dc9c4f3a47@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35791 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752206AbdBHKi0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:38:26 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so32494199wmu.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:37:41 -0800 (PST)
In-Reply-To: <029a2e2e-eb06-e452-e00e-56dc9c4f3a47@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 08/02/2017 11:02 AM, Tariq Toukan wrote:
>
>
> On 07/02/2017 5:50 PM, Tariq Toukan wrote:
>> Hi Eric,
>>
>> Thanks for your series.
>>
>> On 07/02/2017 5:02 AM, Eric Dumazet wrote:
>>> As mentioned half a year ago, we better switch mlx4 driver to order-0
>>> allocations and page recycling.
>>>
>>> This reduces vulnerability surface thanks to better skb->truesize 
>>> tracking
>>> and provides better performance in most cases.
>> The series makes significant change in the RX data-path, that 
>> requires deeper checks, in addition to code review.
>> We applied your series and started running both our functional and 
>> performance regression.
>> We will have results by tomorrow morning, and will analyze them 
>> during the day. I'll update about that.
> We hit a kernel panic when running traffic after configuring a large 
> MTU (9000).
> I will take deeper look into this soon and will keep you updated.
Doesn't happen before applying patch 9/9:
mlx4: add page recycling in receive path
>
> [56136.982183] BUG: unable to handle kernel paging request at 
> 000000022f9e7020
> [56136.990426] IP: mlx4_en_complete_rx_desc+0x130/0x2e0 [mlx4_en]
> [56136.995303] PGD 220b7c067
> [56136.995304] PUD 0
> [56136.997941]
> [56137.001807] Oops: 0000 [#1] SMP
> [56137.004540] Modules linked in: netconsole mlx4_ib mlx4_en(E) 
> mlx4_core(E) nfsv3 nfs fscache rpcrdma ib_isert iscsi_target_mod 
> ib_iser libiscsi scsi_transport_iscsi ib_srpt target_core_mod ib_srp 
> scsi_transport_srp ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm 
> dm_mirror dm_region_hash dm_log ib_cm dm_mod iw_cm ppdev parport_pc 
> i2c_piix4 sg virtio_balloon parport pcspkr acpi_cpufreq nfsd 
> auth_rpcgss nfs_acl lockd grace sunrpc ip_tables mlx5_ib sd_mod 
> ata_generic pata_acpi ib_core mlx5_core cirrus drm_kms_helper 
> syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ata_piix floppy 
> libata ptp e1000 crc32c_intel virtio_pci pps_core serio_raw 
> virtio_ring i2c_core virtio [last unloaded: netconsole]
> [56137.046028] CPU: 1 PID: 16 Comm: ksoftirqd/1 Tainted: G            
> E   4.10.0-rc6+ #26
> [56137.051501] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
> [56137.055817] task: ffff880236245200 task.stack: ffffc90000d04000
> [56137.060154] RIP: 0010:mlx4_en_complete_rx_desc+0x130/0x2e0 [mlx4_en]
> [56137.064712] RSP: 0018:ffffc90000d07c90 EFLAGS: 00010282
> [56137.068646] RAX: 0000000000000003 RBX: 000000022f9e7000 RCX: 
> ffff880234988880
> [56137.073588] RDX: ffff8802349888e0 RSI: 0000000000000000 RDI: 
> ffff880235dad0a0
> [56137.078563] RBP: ffffc90000d07ce0 R08: 0000000000000000 R09: 
> ffff8802225a08c0
> [56137.083370] R10: ffff8802335c7800 R11: 0000000000000000 R12: 
> ffffc90001da1048
> [56137.088123] R13: 0000000000000b36 R14: ffff8802225af040 R15: 
> 0000000000000b36
> [56137.092837] FS:  0000000000000000(0000) GS:ffff88023fc40000(0000) 
> knlGS:0000000000000000
> [56137.098495] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [56137.102626] CR2: 000000022f9e7020 CR3: 000000023441f000 CR4: 
> 00000000000006e0
> [56137.107581] Call Trace:
> [56137.109955]  mlx4_en_process_rx_cq+0x35c/0xda0 [mlx4_en]
> [56137.113894]  ? mlx4_en_free_tx_desc+0x14e/0x350 [mlx4_en]
> [56137.117992]  ? load_balance+0x1ac/0x900
> [56137.121285]  mlx4_en_poll_rx_cq+0x30/0xa0 [mlx4_en]
> [56137.125023]  net_rx_action+0x23d/0x3a0
> [56137.128146]  __do_softirq+0xd1/0x2a2
> [56137.131178]  run_ksoftirqd+0x29/0x50
> [56137.134180]  smpboot_thread_fn+0x110/0x160
> [56137.137530]  kthread+0x101/0x140
> [56137.140330]  ? sort_range+0x30/0x30
> [56137.143255]  ? kthread_park+0x90/0x90
> [56137.146304]  ? __kthread_parkme+0x50/0x70
> [56137.149466]  ret_from_fork+0x2c/0x40
> [56137.152426] Code: c0 8b 45 cc 41 8b 8a cc 00 00 00 48 63 d0 49 03 
> 8a d0 00 00 00 48 83 c2 03 48 c1 e2 04 48 01 ca 48 89 1a 44 89 5a 08 
> 44 89 7a 0c <48> 8b 53 20 f6 c2 01 0f 85 76 01 00 00 48 89 da 48 83 7a 
> 10 ff
> [56137.164855] RIP: mlx4_en_complete_rx_desc+0x130/0x2e0 [mlx4_en] 
> RSP: ffffc90000d07c90
> [56137.170211] CR2: 000000022f9e7020
> [56137.175430] ---[ end trace 6a259f16967a0cff ]---
>
>
>>>
>>> Worth noting this patch series deletes more than 100 lines of code ;)
>>>
>>> Eric Dumazet (9):
>>>    mlx4: use __skb_fill_page_desc()
>>>    mlx4: dma_dir is a mlx4_en_priv attribute
>>>    mlx4: remove order field from mlx4_en_frag_info
>>>    mlx4: get rid of frag_prefix_size
>>>    mlx4: rx_headroom is a per port attribute
>>>    mlx4: reduce rx ring page_cache size
>>>    mlx4: removal of frag_sizes[]
>>>    mlx4: use order-0 pages for RX
>>>    mlx4: add page recycling in receive path
>>>
>>>   drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 350 
>>> +++++++++------------------
>>>   drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   4 +-
>>>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  28 +--
>>>   3 files changed, 129 insertions(+), 253 deletions(-)
>>>
>> Thanks,
>> Tariq
>
