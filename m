From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH 2/2] sh_eth: Fix asynchronous external abort
Date: Thu, 13 Nov 2014 16:02:15 +0900
Message-ID: <1415862135-27972-3-git-send-email-ykaneko0929@gmail.com>
References: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

When clock is disabled, Ethernet register access raise Bus error.

----
[  792.240535] Unhandled fault: asynchronous external abort (0x1211) at 0x00000000
[  792.262485] Internal error: : 1211 [#1] PREEMPT SMP ARM
[  792.278165] Modules linked in:
[  792.287340] CPU: 1 PID: 1495 Comm: ethtool Not tainted 3.10.31-ltsi-00046-gefa0b46-dirty #1089
[  792.313195] task: d68e30c0 ti: d6878000 task.ti: d6878000
[  792.329404] PC is at sh_eth_reset+0x2cc/0x3a8
[  792.342476] LR is at sh_eth_dmac_init+0x18/0x374
[  792.356327] pc : [<c029907c>]    lr : [<c029ed20>]    psr: 20070013
[  792.356327] sp : d6879d78  ip : d6879d98  fp : d6879d94
[  792.390792] r10: d6385c80  r9 : d6878000  r8 : 00000000
[  792.406470] r7 : 00000000  r6 : 00000000  r5 : 00000001  r4 : d6385800
[  792.426061] r3 : e78dc200  r2 : e78dc000  r1 : 00000000  r0 : d6385800
[  792.445653] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
[  792.467072] Control: 30c53c7d  Table: 55c0a140  DAC: 55555555
[  792.484315] Process ethtool (pid: 1495, stack limit = 0xd6878238)
[  792.502601] Stack: (0xd6879d78 to 0xd687a000)
[  792.515669] 9d60:                                                       c049ca32 d6385800
[  792.540221] 9d80: 00000000 00000000 d6879dbc d6879d98 c029ed20 c0298dbc c049ca32 d6385800
[  792.564771] 9da0: 00000000 c06502c0 00000000 00000000 d6879dec d6879dc0 c029f7c8 c029ed14
[  792.589321] 9dc0: c029f610 be976b6c 00000011 c06502c0 00000000 00000000 d6878000 d6385800
[  792.613871] 9de0: d6879e6c d6879df0 c03b70f0 c029f61c 00004000 00000000 d6879e1c 00000011
[  792.638420] 9e00: 00000000 00000000 00000000 d6160000 00000011 00000400 00000000 00000000
[  792.662969] 9e20: 00000400 00000400 00000000 00000000 00000040 00000000 d6879e5c d6879e48
[  792.687519] 9e40: c0452f20 00008946 be976c20 c06502c0 00000000 00000000 d6878000 be976c20
[  792.712069] 9e60: d6879ec4 d6879e70 c03c4870 c03b64f0 000000d0 d69d1a40 30687465 00000000
[  792.736618] 9e80: 00000000 00000000 be976b6c 00000000 00000000 00000000 c03f85e0 00008946
[  792.761168] 9ea0: fffffdfd be976c20 00008946 d65686a0 d6878000 be976c20 d6879ee4 d6879ec8
[  792.785717] 9ec0: c039feb0 c03c435c c039fc48 be976c20 d6ae38c0 00000003 d6879ef4 d6879ee8
[  792.810267] 9ee0: c00c8540 c039fc54 d6879f74 d6879ef8 c00c9114 c00c851c d6879fac d6879f08
[  792.834817] 9f00: c0009288 c001b168 d6879f40 00000003 d6879f3c d6879f20 c00bafe0 c00bae6c
[  792.859366] 9f20: d6879f44 d6879f30 d6879f44 d6879f38 c0454c04 c0049738 d6879f64 d6879f48
[  792.883916] 9f40: c00d2978 c0454be4 00000003 be976c20 d6ae38c0 00000000 00008946 00000003
[  792.908466] 9f60: d6878000 00000000 d6879fa4 d6879f78 c00c91ac c00c8b84 d6879fb0 00000000
[  792.933015] 9f80: d6879fac be976c18 be976b88 be976b60 00000036 c000f068 00000000 d6879fa8
[  792.957565] 9fa0: c000eec0 c00c9178 be976c18 be976b88 00000003 00008946 be976c20 be976c18
[  792.982114] 9fc0: be976c18 be976b88 be976b60 00000036 be976b5c be976b58 be976b80 0001f754
[  793.006664] 9fe0: 000433f0 be976b4c 0000d8e8 b6e035ac 200d0010 00000003 c90515a9 0f9c2043
[  793.031212] Backtrace:
[  793.038564] [<c0298db0>] (sh_eth_reset+0x0/0x3a8) from [<c029ed20>] (sh_eth_dmac_init+0x18/0x374)
[  793.065199]  r6:00000000 r5:00000000 r4:d6385800 r3:c049ca32
[  793.082257] [<c029ed08>] (sh_eth_dmac_init+0x0/0x374) from [<c029f7c8>] (sh_eth_set_ringparam+0x1b8/0x2cc)
[  793.111241]  r8:00000000 r7:00000000 r6:c06502c0 r5:00000000 r4:d6385800
r3:c049ca32
[  793.134860] [<c029f610>] (sh_eth_set_ringparam+0x0/0x2cc) from [<c03b70f0>] (dev_ethtool+0xc0c/0x1e4c)
[  793.162807] [<c03b64e4>] (dev_ethtool+0x0/0x1e4c) from [<c03c4870>] (dev_ioctl+0x520/0x688)
[  793.187881] [<c03c4350>] (dev_ioctl+0x0/0x688) from [<c039feb0>] (sock_ioctl+0x268/0x2a0)
[  793.212435] [<c039fc48>] (sock_ioctl+0x0/0x2a0) from [<c00c8540>] (vfs_ioctl+0x30/0x44)
[  793.236461]  r6:00000003 r5:d6ae38c0 r4:be976c20 r3:c039fc48
[  793.253516] [<c00c8510>] (vfs_ioctl+0x0/0x44) from [<c00c9114>] (do_vfs_ioctl+0x59c/0x5f4)
[  793.278328] [<c00c8b78>] (do_vfs_ioctl+0x0/0x5f4) from [<c00c91ac>] (SyS_ioctl+0x40/0x68)
[  793.302882] [<c00c916c>] (SyS_ioctl+0x0/0x68) from [<c000eec0>] (ret_fast_syscall+0x0/0x30)
[  793.327952]  r8:c000f068 r7:00000036 r6:be976b60 r5:be976b88 r4:be976c18
[  793.348155] Code: e0823003 e5935000 f57ff04f e3855001 (f57ff04f)
[  793.366445] ---[ end trace 6885a6a6c1fc41e3 ]---
----

Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 862a691..dadbd00 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1839,6 +1839,9 @@ static int sh_eth_set_settings(struct net_device *ndev,
 	unsigned long flags;
 	int ret;
 
+	if (!mdp->is_opened)
+		return -EAGAIN;
+
 	spin_lock_irqsave(&mdp->lock, flags);
 
 	/* disable tx and rx */
@@ -1975,6 +1978,9 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 	mdp->num_rx_ring = ring->rx_pending;
 	mdp->num_tx_ring = ring->tx_pending;
 
+	if (!mdp->is_opened)
+		return 0;
+
 	ret = sh_eth_ring_init(ndev);
 	if (ret < 0) {
 		netdev_err(ndev, "%s: sh_eth_ring_init failed.\n", __func__);
-- 
1.9.1

