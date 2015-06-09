From: Alexander Popov <alex.popov@linux.com>
Subject: [PATCH 1/1] net: fs_enet: Disable NETIF_F_SG feature for Freescale MPC5121
Date: Wed, 10 Jun 2015 02:57:42 +0300
Message-ID: <1433894262-28900-1-git-send-email-alex.popov@linux.com>
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Leroy Christophe <christophe.leroy@c-s.fr>,
	Alexander Popov <alex.popov@linux.com>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 4fc9b87bae25 ("net: fs_enet: Implement NETIF_F_SG feature")
brings a trouble to Freescale MPC512x: a kernel oops happens
during sending non-linear sk_buff with .data not aligned by 4.

Log quotation:

Unable to handle kernel paging request for data at address 0xd067c000
Faulting instruction address: 0xc000cd44
Oops: Kernel access of bad area, sig: 11 [#1]
MPC512x generic
Modules linked in:
CPU: 0 PID: 983 Comm: kworker/0:1H Not tainted 4.1.0-rc7-00047-g5879ae5 #1
Workqueue: rpciod rpc_async_schedule
task: cf3415b0 ti: cf330000 task.ti: cf330000
NIP: c000cd44 LR: c000c720 CTR: 0000020d
REGS: cf331ac0 TRAP: 0300   Not tainted  (4.1.0-rc7-00047-g5879ae5)
MSR: 00009032 <EE,ME,IR,DR,RI>  CR: 42004082  XER: 00000000
DAR: d067c000 DSISR: 20000000
GPR00: c0279d70 cf331b70 cf3415b0 d067c000 0000020d 0000001f 00000001 00000001
GPR08: 00000000 d067c000 d068019e 00013b36 82002082 00000000 c002e46c cf3405e0
GPR16: c044cb10 c04b0000 cf331c48 00000000 00000001 fde03164 00000000 0000000c
GPR24: 00000030 0000419e cf99d6e0 0000000c 00000001 cf873210 00002f99 00000000
NIP [c000cd44] clean_dcache_range+0x1c/0x30
LR [c000c720] dma_direct_map_page+0x40/0x94
Call Trace:
[cf331b70] [cf99db60] 0xcf99db60 (unreliable)
[cf331b90] [c0279d70] fs_enet_start_xmit+0x1c8/0x42c
[cf331bd0] [c02ff660] dev_hard_start_xmit+0x2dc/0x3d4
[cf331c40] [c0319bb0] sch_direct_xmit+0xcc/0x1cc
[cf331c70] [c02ff910] __dev_queue_xmit+0x1b8/0x47c
[cf331ca0] [c032a338] ip_finish_output+0x1fc/0x9a8
[cf331ce0] [c032c26c] ip_send_skb+0x1c/0xa4
[cf331cf0] [c035107c] udp_send_skb+0xe4/0x2e8
[cf331d10] [c03512b8] udp_push_pending_frames+0x38/0x84
[cf331d20] [c0353708] udp_sendpage+0x134/0x174
[cf331d70] [c0384f24] xs_sendpages+0x21c/0x250
[cf331db0] [c038520c] xs_udp_send_request+0x50/0xf8
[cf331de0] [c0382e58] xprt_transmit+0x64/0x280
[cf331e20] [c03800cc] call_transmit+0x168/0x234
[cf331e40] [c0387868] __rpc_execute+0x88/0x2b0
[cf331e80] [c00296f8] process_one_work+0x124/0x2fc
[cf331ea0] [c0029a00] worker_thread+0x130/0x480
[cf331ef0] [c002e528] kthread+0xbc/0xd0
[cf331f40] [c000e4a8] ret_from_kernel_thread+0x5c/0x64
Instruction dump:
7c70faa6 60630800 7c70fba6 4c00012c 4e800020 38a0001f 7c632878 7c832050
7c842a14 5484d97f 4d820020 7c8903a6 <7c00186c> 38630020 4200fff8 7c0004ac
---[ end trace 08fef9a8ee013f63 ]---

The reason:

MPC5121 FEC requires 4-byte alignment for TX data buffer and calls
tx_skb_align_workaround() for copying sk_buff with not aligned .data to a new
sk_buff with aligned one. But tx_skb_align_workaround() uses
skb_copy_from_linear_data() which doesn't work well for non-linear sk_buff:
a new sk_buff has non-zero nr_frags and zero .data_len.

So disabling NETIF_F_SG for Freescale MPC5121 might be better than handling
improper alignment for sk_buff.data and all the fragments.

Signed-off-by: Alexander Popov <alex.popov@linux.com>
---
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 9b3639e..1450477 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1040,7 +1040,9 @@ static int fs_enet_probe(struct platform_device *ofdev)
 
 	netif_carrier_off(ndev);
 
+#ifndef CONFIG_FS_ENET_MPC5121_FEC
 	ndev->features |= NETIF_F_SG;
+#endif
 
 	ret = register_netdev(ndev);
 	if (ret)
-- 
1.9.1
