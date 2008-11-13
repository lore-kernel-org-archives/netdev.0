From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] net/ucc_geth: Fix oops in uec_get_ethtool_stats()
Date: Thu, 13 Nov 2008 21:26:27 +0300
Message-ID: <20081113182627.GA5104@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: David Miller <davem@davemloft.net>, Li Yang <leoli@freescale.com>,
	Timur Tabi <timur@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:48749 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751066AbYKMS03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 13:26:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

p_{tx,rx}_fw_statistics_pram are special: they're available only when
a device is open. If the device is closed, we should just fill the data
with zeroes.

Fixes the following oops:

root@b1:~# ifconfig eth1 down
root@b1:~# ethtool -S eth1
Unable to handle kernel paging request for data at address 0x00000000
Faulting instruction address: 0xc01e1dcc
Oops: Kernel access of bad area, sig: 11 [#1]
[...]
NIP [c01e1dcc] uec_get_ethtool_stats+0x98/0x124
LR [c0287cc8] ethtool_get_stats+0xfc/0x23c
Call Trace:
[cfaadde0] [c0287ca8] ethtool_get_stats+0xdc/0x23c (unreliable)
[cfaade20] [c0288340] dev_ethtool+0x2fc/0x588
[cfaade50] [c0285648] dev_ioctl+0x290/0x33c
[cfaadea0] [c0272238] sock_ioctl+0x80/0x2ec
[cfaadec0] [c00b5ae4] vfs_ioctl+0x40/0xc0
[cfaadee0] [c00b5fa8] do_vfs_ioctl+0x78/0x20c
[cfaadf10] [c00b617c] sys_ioctl+0x40/0x74
[cfaadf40] [c00142d8] ret_from_syscall+0x0/0x38
[...]
---[ end trace b941007b2dfb9759 ]---
Segmentation fault

p.s. While at it, also remove u64 casts, they aren't needed.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth_ethtool.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index cfbbfee..7ed1638 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -324,17 +324,17 @@ static void uec_get_ethtool_stats(struct net_device *netdev,
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE) {
 		base = (u32 __iomem *)&ugeth->ug_regs->tx64;
 		for (i = 0; i < UEC_HW_STATS_LEN; i++)
-			data[j++] = (u64)in_be32(&base[i]);
+			data[j++] = in_be32(&base[i]);
 	}
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
 		base = (u32 __iomem *)ugeth->p_tx_fw_statistics_pram;
 		for (i = 0; i < UEC_TX_FW_STATS_LEN; i++)
-			data[j++] = (u64)in_be32(&base[i]);
+			data[j++] = base ? in_be32(&base[i]) : 0;
 	}
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX) {
 		base = (u32 __iomem *)ugeth->p_rx_fw_statistics_pram;
 		for (i = 0; i < UEC_RX_FW_STATS_LEN; i++)
-			data[j++] = (u64)in_be32(&base[i]);
+			data[j++] = base ? in_be32(&base[i]) : 0;
 	}
 }
 
-- 
1.5.6.3
