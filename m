From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: XDP_TX bug report on mlx4
Date: Fri, 16 Sep 2016 21:24:43 +0200
Message-ID: <20160916212443.0eddbeb5@redhat.com>
References: <20160916210340.4a7cdef8@redhat.com>
        <20160916191727.GA8410@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/H+Ym2+L0f1ctKw3M3Utsar8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <rana.shahot@gmail.com>,
        Eran Ben Elisha <eranbe@mellanox.com>, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58248 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933595AbcIPTYt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 15:24:49 -0400
In-Reply-To: <20160916191727.GA8410@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/H+Ym2+L0f1ctKw3M3Utsar8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Fri, 16 Sep 2016 12:17:27 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> On Fri, Sep 16, 2016 at 09:03:40PM +0200, Jesper Dangaard Brouer wrote:
> > Hi Brenden,
> > 
> > I've discovered a bug with XDP_TX recycling of pages in the mlx4 driver.
> > 
> > If I increase the number of RX and TX queues/channels via ethtool cmd:
> >  ethtool -L mlx4p1 rx 10 tx 10
> > 
> > Then when running the xdp2 program, which does XDP_TX, the kernel will
> > crash with page errors, because the page refcnt goes to zero or even
> > minus.  I've noticed pages delivered to mlx4_en_rx_recycle() can have
> > a page refcnt of zero, which is wrong, they should always have 1 (for
> > XDP).
> > 
> > Debugging it further, I find that this can happen when mlx4_en_rx_recycle()
> > is called from mlx4_en_recycle_tx_desc().  This is the TX cleanup function,
> > associated with TX ring queues used for XDP_TX only. No others than the
> > XDP_TX action should be able to place packets into these TX rings
> > which call mlx4_en_recycle_tx_desc().  
> 
> Sounds pretty straightforward, let me look into it.

Here is some debug info I instrumented my kernel with, and I've
attached my minicom output with a warning and a panic.

Enable some driver debug printks via::
 ethtool -s mlx4p1 msglvl drv on

Debug normal situation::

 $ grep recycle_ring minicom_capturefile.log08
 [  520.746610] mlx4_en: mlx4p1: Set tx_ring[56]->recycle_ring = rx_ring[0]
 [  520.747042] mlx4_en: mlx4p1: Set tx_ring[57]->recycle_ring = rx_ring[1]
 [  520.747470] mlx4_en: mlx4p1: Set tx_ring[58]->recycle_ring = rx_ring[2]
 [  520.747918] mlx4_en: mlx4p1: Set tx_ring[59]->recycle_ring = rx_ring[3]
 [  520.748330] mlx4_en: mlx4p1: Set tx_ring[60]->recycle_ring = rx_ring[4]
 [  520.748749] mlx4_en: mlx4p1: Set tx_ring[61]->recycle_ring = rx_ring[5]
 [  520.749181] mlx4_en: mlx4p1: Set tx_ring[62]->recycle_ring = rx_ring[6]
 [  520.749620] mlx4_en: mlx4p1: Set tx_ring[63]->recycle_ring = rx_ring[7]

Change $ ethtool -L mlx4p1 rx 9 tx 9 ::

 [  911.594692] mlx4_en: mlx4p1: Set tx_ring[56]->recycle_ring = rx_ring[0]
 [  911.608345] mlx4_en: mlx4p1: Set tx_ring[57]->recycle_ring = rx_ring[1]
 [  911.622008] mlx4_en: mlx4p1: Set tx_ring[58]->recycle_ring = rx_ring[2]
 [  911.636364] mlx4_en: mlx4p1: Set tx_ring[59]->recycle_ring = rx_ring[3]
 [  911.650015] mlx4_en: mlx4p1: Set tx_ring[60]->recycle_ring = rx_ring[4]
 [  911.663690] mlx4_en: mlx4p1: Set tx_ring[61]->recycle_ring = rx_ring[5]
 [  911.677356] mlx4_en: mlx4p1: Set tx_ring[62]->recycle_ring = rx_ring[6]
 [  911.690924] mlx4_en: mlx4p1: Set tx_ring[63]->recycle_ring = rx_ring[7]
 [  911.704544] mlx4_en: mlx4p1: Set tx_ring[64]->recycle_ring = rx_ring[8]
 [  911.718171] mlx4_en: mlx4p1: Set tx_ring[65]->recycle_ring = rx_ring[9]
 [  911.731772] mlx4_en: mlx4p1: Set tx_ring[66]->recycle_ring = rx_ring[10]
 [  911.745438] mlx4_en: mlx4p1: Set tx_ring[67]->recycle_ring = rx_ring[11]
 [  911.759063] mlx4_en: mlx4p1: Set tx_ring[68]->recycle_ring = rx_ring[12]
 [  911.772741] mlx4_en: mlx4p1: Set tx_ring[69]->recycle_ring = rx_ring[13]
 [  911.786415] mlx4_en: mlx4p1: Set tx_ring[70]->recycle_ring = rx_ring[14]
 [  911.800070] mlx4_en: mlx4p1: Set tx_ring[71]->recycle_ring = rx_ring[15]

Change $ ethtool -L mlx4p1 rx 10 tx 10::

 netif_set_real_num_tx_queues() setting dev->real_num_tx_queues(now:80) = 64
 mlx4_en: mlx4p1:   frag:0 - size:1522 prefix:0 stride:4096
 mlx4_en_init_recycle_ring() Set tx_ring[64]->recycle_ring = rx_ring[0]
 mlx4_en_init_recycle_ring() Set tx_ring[65]->recycle_ring = rx_ring[1]
 mlx4_en_init_recycle_ring() Set tx_ring[66]->recycle_ring = rx_ring[2]
 mlx4_en_init_recycle_ring() Set tx_ring[67]->recycle_ring = rx_ring[3]
 mlx4_en_init_recycle_ring() Set tx_ring[68]->recycle_ring = rx_ring[4]
 mlx4_en_init_recycle_ring() Set tx_ring[69]->recycle_ring = rx_ring[5]
 mlx4_en_init_recycle_ring() Set tx_ring[70]->recycle_ring = rx_ring[6]
 mlx4_en_init_recycle_ring() Set tx_ring[71]->recycle_ring = rx_ring[7]
 mlx4_en_init_recycle_ring() Set tx_ring[72]->recycle_ring = rx_ring[8]
 mlx4_en_init_recycle_ring() Set tx_ring[73]->recycle_ring = rx_ring[9]
 mlx4_en_init_recycle_ring() Set tx_ring[74]->recycle_ring = rx_ring[10]
 mlx4_en_init_recycle_ring() Set tx_ring[75]->recycle_ring = rx_ring[11]
 mlx4_en_init_recycle_ring() Set tx_ring[76]->recycle_ring = rx_ring[12]
 mlx4_en_init_recycle_ring() Set tx_ring[77]->recycle_ring = rx_ring[13]
 mlx4_en_init_recycle_ring() Set tx_ring[78]->recycle_ring = rx_ring[14]
 mlx4_en_init_recycle_ring() Set tx_ring[79]->recycle_ring = rx_ring[15]

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--MP_/H+Ym2+L0f1ctKw3M3Utsar8
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=minicom_capturefile.log17.txt


[   95.777366] systemd[1]: Started Session c1 of user jbrouer.
[   95.783108] systemd[1]: Starting Session c1 of user jbrouer.
[  102.577674] XXX: netif_set_real_num_tx_queues() setting dev->real_num_tx_queues(now:64) = 80
[  102.586160] mlx4_en: mlx4p1: Using 80 TX rings
[  102.590640] mlx4_en: mlx4p1: Using 0 TX rings for XDP
[  102.595702] mlx4_en: mlx4p1: Using 10 RX rings
[  102.600183] mlx4_en: mlx4p1:   frag:0 - size:1522 prefix:0 stride:1536
[  102.612851] mlx4_en: mlx4p1: Setting RSS context tunnel type to RSS on inner headers
[  102.677064] mlx4_en: mlx4p1: Link Down
[  103.830065] mlx4_en: mlx4p1: Link Up
[  171.811607] XXX: netif_set_real_num_tx_queues() calling qdisc_reset_all_tx_gt(64)
[  171.819208] XXX: netif_set_real_num_tx_queues() setting dev->real_num_tx_queues(now:80) = 64
[  171.827796] mlx4_en: mlx4p1:   frag:0 - size:1522 prefix:0 stride:4096
[  171.840921] mlx4_en: mlx4p1: Setting RSS context tunnel type to RSS on inner headers
[  171.877866] XXX: mlx4_en_init_recycle_ring() Set tx_ring[64]->recycle_ring = rx_ring[0]
[  171.886379] XXX: mlx4_en_init_recycle_ring() Set tx_ring[65]->recycle_ring = rx_ring[1]
[  171.894938] XXX: mlx4_en_init_recycle_ring() Set tx_ring[66]->recycle_ring = rx_ring[2]
[  171.903442] XXX: mlx4_en_init_recycle_ring() Set tx_ring[67]->recycle_ring = rx_ring[3]
[  171.911979] XXX: mlx4_en_init_recycle_ring() Set tx_ring[68]->recycle_ring = rx_ring[4]
[  171.920469] XXX: mlx4_en_init_recycle_ring() Set tx_ring[69]->recycle_ring = rx_ring[5]
[  171.929016] XXX: mlx4_en_init_recycle_ring() Set tx_ring[70]->recycle_ring = rx_ring[6]
[  171.937564] XXX: mlx4_en_init_recycle_ring() Set tx_ring[71]->recycle_ring = rx_ring[7]
[  171.946102] XXX: mlx4_en_init_recycle_ring() Set tx_ring[72]->recycle_ring = rx_ring[8]
[  171.954628] XXX: mlx4_en_init_recycle_ring() Set tx_ring[73]->recycle_ring = rx_ring[9]
[  171.963190] XXX: mlx4_en_init_recycle_ring() Set tx_ring[74]->recycle_ring = rx_ring[10]
[  171.971851] XXX: mlx4_en_init_recycle_ring() Set tx_ring[75]->recycle_ring = rx_ring[11]
[  171.980436] XXX: mlx4_en_init_recycle_ring() Set tx_ring[76]->recycle_ring = rx_ring[12]
[  171.989039] XXX: mlx4_en_init_recycle_ring() Set tx_ring[77]->recycle_ring = rx_ring[13]
[  171.997641] XXX: mlx4_en_init_recycle_ring() Set tx_ring[78]->recycle_ring = rx_ring[14]
[  172.006253] XXX: mlx4_en_init_recycle_ring() Set tx_ring[79]->recycle_ring = rx_ring[15]
[  172.025565] mlx4_en: mlx4p1: Link Down
[  173.154950] mlx4_en: mlx4p1: Link Up
[  209.277225] systemd-logind[778]: New session c2 of user jbrouer.
[  209.284629] systemd[1]: Started Session c2 of user jbrouer.
[  209.290519] systemd[1]: Starting Session c2 of user jbrouer.
[  259.151792] XXX: mlx4_en_xmit_frame(cpu:2) tx_drop (tx_ind:66) *doorbell_pending:0
[  259.152002] XXX: mlx4_en_rx_recycle(cpu:6) page refcnt(0) bug cache->index:128/128
[  259.152003] ------------[ cut here ]------------
[  259.152007] WARNING: CPU: 6 PID: 0 at drivers/net/ethernet/mellanox/mlx4/en_rx.c:532 mlx4_en_rx_recycle+0x9c/0xb0 [mlx4_en]
[  259.152018] Modules linked in: coretemp kvm_intel kvm mxm_wmi irqbypass i2c_i801 intel_cstate i2c_smbus intel_rapl_perf sg i2c_core pcspkr shpchp video wmi acpi_pad nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc ip_tables x_tables mlx4_en mlx5_core e1000e ptp sd_mod serio_raw mlx4_core pps_core devlink hid_generic
[  259.152020] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 4.8.0-rc4-xdp02_seperate_xdp_struct+ #89
[  259.152021] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./Z97 Extreme4, BIOS P2.10 05/12/2015
[  259.152022]  0000000000000000 ffff88041fb83d58 ffffffff813a8ccb 0000000000000000
[  259.152023]  0000000000000000 ffff88041fb83d98 ffffffff81060f3b 000002141fb83d70
[  259.152024]  ffff88041fb83dd8 ffff8804081e8000 0000000000000151 0000000000000009
[  259.152024] Call Trace:
[  259.152029]  <IRQ>  [<ffffffff813a8ccb>] dump_stack+0x4d/0x72
[  259.152032]  [<ffffffff81060f3b>] __warn+0xcb/0xf0
[  259.152034]  [<ffffffff8106102d>] warn_slowpath_null+0x1d/0x20
[  259.152035]  [<ffffffffa016a30c>] mlx4_en_rx_recycle+0x9c/0xb0 [mlx4_en]
[  259.152037]  [<ffffffffa0166a2e>] mlx4_en_recycle_tx_desc+0x4e/0xf0 [mlx4_en]
[  259.152038]  [<ffffffffa01678a7>] mlx4_en_poll_tx_cq+0x1e7/0x480 [mlx4_en]
[  259.152040]  [<ffffffff815f0f6c>] net_rx_action+0x1fc/0x350
[  259.152042]  [<ffffffff8170b83e>] __do_softirq+0xce/0x2cf
[  259.152043]  [<ffffffff8106635b>] irq_exit+0xab/0xb0
[  259.152044]  [<ffffffff8170b584>] do_IRQ+0x54/0xd0
[  259.152046]  [<ffffffff81709bbf>] common_interrupt+0x7f/0x7f
[  259.152048]  <EOI>  [<ffffffff815b213f>] ? cpuidle_enter_state+0x12f/0x300
[  259.152049]  [<ffffffff815b2347>] cpuidle_enter+0x17/0x20
[  259.152051]  [<ffffffff810a3c94>] cpu_startup_entry+0x2b4/0x300
[  259.152053]  [<ffffffff8103c611>] start_secondary+0x101/0x120
[  259.152054] ---[ end trace 2b35fea8b90ba9b5 ]---
[  259.152055] page:ffffea000a8e8300 count:0 mapcount:0 mapping:          (null) index:0x0
[  259.152056] flags: 0x2fffff80000000()
[  259.152056] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
[  259.152067] ------------[ cut here ]------------
[  259.152068] kernel BUG at ./include/linux/mm.h:445!
[  259.152068] invalid opcode: 0000 [#1] PREEMPT SMP
[  259.152074] Modules linked in: coretemp kvm_intel kvm mxm_wmi irqbypass i2c_i801 intel_cstate i2c_smbus intel_rapl_perf sg i2c_core pcspkr shpchp video wmi acpi_pad nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc ip_tables x_tables mlx4_en mlx5_core e1000e ptp sd_mod serio_raw mlx4_core pps_core devlink hid_generic
[  259.152075] CPU: 6 PID: 0 Comm: swapper/6 Tainted: G        W       4.8.0-rc4-xdp02_seperate_xdp_struct+ #89
[  259.152076] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./Z97 Extreme4, BIOS P2.10 05/12/2015
[  259.152076] task: ffff88040d5bab80 task.stack: ffff88040d5d0000
[  259.152078] RIP: 0010:[<ffffffffa0166acd>]  [<ffffffffa0166acd>] mlx4_en_recycle_tx_desc+0xed/0xf0 [mlx4_en]
[  259.152079] RSP: 0018:ffff88041fb83dd8  EFLAGS: 00010292
[  259.152079] RAX: 000000000000003e RBX: ffff88040b76d440 RCX: 0000000000000001
[  259.152079] RDX: 0000000000000001 RSI: 0000000000000286 RDI: ffffffff81c40b90
[  259.152080] RBP: ffff88041fb83e00 R08: 0000000000000000 R09: 000000000000003e
[  259.152080] R10: 000000000000000a R11: 0000000000000000 R12: ffff8803f1b40840
[  259.152081] R13: 0000000000000151 R14: 0000000000000009 R15: 0000000000005440
[  259.152081] FS:  0000000000000000(0000) GS:ffff88041fb80000(0000) knlGS:0000000000000000
[  259.152082] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  259.152082] CR2: 00007fd47c1c4520 CR3: 00000003e970a000 CR4: 00000000001406e0
[  259.152082] Stack:
[  259.152084]  ffffea000a8e8300 00000002a3a0c000 0000100000000000 0000000000000150
[  259.152085]  ffff88040b748800 ffff88041fb83e90 ffffffffa01678a7 ffff88040b3ed500
[  259.152086]  0000000000000020 ffff88040b760000 ffff8803f1b40000 0367cd5100000200
[  259.152086] Call Trace:
[  259.152088]  <IRQ> 
[  259.152088]  [<ffffffffa01678a7>] mlx4_en_poll_tx_cq+0x1e7/0x480 [mlx4_en]
[  259.152089]  [<ffffffff815f0f6c>] net_rx_action+0x1fc/0x350
[  259.152090]  [<ffffffff8170b83e>] __do_softirq+0xce/0x2cf
[  259.152091]  [<ffffffff8106635b>] irq_exit+0xab/0xb0
[  259.152092]  [<ffffffff8170b584>] do_IRQ+0x54/0xd0
[  259.152093]  [<ffffffff81709bbf>] common_interrupt+0x7f/0x7f
[  259.152095]  <EOI> 
[  259.152095]  [<ffffffff815b213f>] ? cpuidle_enter_state+0x12f/0x300
[  259.152096]  [<ffffffff815b2347>] cpuidle_enter+0x17/0x20
[  259.152097]  [<ffffffff810a3c94>] cpu_startup_entry+0x2b4/0x300
[  259.152098]  [<ffffffff8103c611>] start_secondary+0x101/0x120
[  259.152108] Code: 5c 5d c3 e8 b6 a4 ff e0 8b 43 14 48 83 c4 18 5b 41 5c 5d c3 48 8b 05 13 80 ab e1 eb a0 0f 0b 48 c7 c6 60 9e 17 a0 e8 a3 8b 01 e1 <0f> 0b 90 0f 1f 44 00 00 55 48 63 c2 89 d1 49 89 f2 48 c1 e0 06 
[  259.152110] RIP  [<ffffffffa0166acd>] mlx4_en_recycle_tx_desc+0xed/0xf0 [mlx4_en]
[  259.152110]  RSP <ffff88041fb83dd8>
[  259.152117] ---[ end trace 2b35fea8b90ba9b6 ]---
[  259.152118] Kernel panic - not syncing: Fatal exception in interrupt
[  259.159443] Kernel Offset: disabled
[  259.640689] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

--MP_/H+Ym2+L0f1ctKw3M3Utsar8--
