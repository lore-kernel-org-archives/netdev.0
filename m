From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 2/2] ucc_geth: Fix deadlock
Date: Fri, 12 Nov 2010 14:55:09 +0100
Message-ID: <1289570109-8160-2-git-send-email-Joakim.Tjernlund@transmode.se>
References: <1289570109-8160-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:48030 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757592Ab0KLNzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Nov 2010 08:55:17 -0500
In-Reply-To: <1289570109-8160-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This script:
 while [ 1==1 ] ; do ifconfig eth0 up; usleep 1950000 ;ifconfig eth0 down; dmesg -c ;done
causes in just a second or two:
INFO: task ifconfig:572 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ifconfig      D 0ff65760     0   572    369 0x00000000
Call Trace:
[c6157be0] [c6008460] 0xc6008460 (unreliable)
[c6157ca0] [c0008608] __switch_to+0x4c/0x6c
[c6157cb0] [c028fecc] schedule+0x184/0x310
[c6157ce0] [c0290e54] __mutex_lock_slowpath+0xa4/0x150
[c6157d20] [c0290c48] mutex_lock+0x44/0x48
[c6157d30] [c01aba74] phy_stop+0x20/0x70
[c6157d40] [c01aef40] ucc_geth_stop+0x30/0x98
[c6157d60] [c01b18fc] ucc_geth_close+0x9c/0xdc
[c6157d80] [c01db0cc] __dev_close+0xa0/0xd0
[c6157d90] [c01deddc] __dev_change_flags+0x8c/0x148
[c6157db0] [c01def54] dev_change_flags+0x1c/0x64
[c6157dd0] [c0237ac8] devinet_ioctl+0x678/0x784
[c6157e50] [c0239a58] inet_ioctl+0xb0/0xbc
[c6157e60] [c01cafa8] sock_ioctl+0x174/0x2a0
[c6157e80] [c009a16c] vfs_ioctl+0xcc/0xe0
[c6157ea0] [c009a998] do_vfs_ioctl+0xc4/0x79c
[c6157f10] [c009b0b0] sys_ioctl+0x40/0x74
[c6157f40] [c00117c4] ret_from_syscall+0x0/0x38

The reason appears to be ucc_geth_stop meets adjust_link as the
PHY reports PHY changes. I belive adjust_link hangs somewhere,
holding the PHY lock, because ucc_geth_stop disabled the
controller HW.
Fix is to stop the PHY before disabling the controller.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 6c254ed..06a5db3 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2050,12 +2050,16 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 
 	ugeth_vdbg("%s: IN", __func__);
 
+	/*
+	 * Tell the kernel the link is down.
+	 * Must be done before disabling the controller
+	 * or deadlock may happen.
+	 */
+	phy_stop(phydev);
+
 	/* Disable the controller */
 	ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
 
-	/* Tell the kernel the link is down */
-	phy_stop(phydev);
-
 	/* Mask all interrupts */
 	out_be32(ugeth->uccf->p_uccm, 0x00000000);
 
-- 
1.7.2.2

