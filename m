From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/3] ucc_geth: do not touch net queue in adjust_link phylib
	callback
Date: Mon, 21 Jul 2008 19:17:35 +0400
Message-ID: <20080721151735.GB7989@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:13565 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753454AbYGUPRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:17:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the net queue has not been started, we'll get this nice oops
and non-working ethernet:

------------[ cut here ]------------
Kernel BUG at c01f4648 [verbose debug info unavailable]
Oops: Exception in kernel mode, sig: 5 [#1]
MPC836x RDK
Modules linked in:
NIP: c01f4648 LR: c01c0a10 CTR: c01c08e4
REGS: cf839e40 TRAP: 0700   Not tainted  (2.6.26-05254-gc7b9969)
MSR: 00021032 <ME,IR,DR>  CR: 22042044  XER: 00000000
TASK = cf828c30[4] 'events/0' THREAD: cf838000
GPR00: c01c0a10 cf839ef0 cf828c30 c035ceb0 cf8469a0 00000064 00000000 00000000
GPR08: c035ceb0 00000001 00000001 cf99c280 22044044 7ca81020 0fffc000 00000000
GPR16: 0fff2544 0fff63c0 00000000 0fff78e0 0ffa5580 00000004 00000000 00000000
GPR24: 02082000 cf9d0000 d1068000 00009032 cf846800 cf846b80 00000001 00000014
NIP [c01f4648] __netif_schedule+0x28/0x8c
LR [c01c0a10] adjust_link+0x12c/0x1e4
Call Trace:
[cf839ef0] [c0380f50] 0xc0380f50 (unreliable)
[cf839f10] [c01c0a10] adjust_link+0x12c/0x1e4
[cf839f40] [c01c2628] phy_state_machine+0x2e0/0x448
[cf839f60] [c00425e8] run_workqueue+0xc8/0x168
[cf839f90] [c0042c6c] worker_thread+0x70/0xd0
[cf839fd0] [c0046954] kthread+0x48/0x84
[cf839ff0] [c0012488] kernel_thread+0x44/0x60
Instruction dump:
7c0803a6 4e800020 3d20c036 9421ffe0 7c0802a6 7c681b78 3929ceb0 7c694a78
7d290034 90010024 bfa10014 5529d97e <0f090000> 39600002 38030024 7d200028
---[ end trace a57d367843bd2904 ]---

Since the driver is using phylib (which is doing netif_carrier_on/off()),
we should simply remove netif_tx_schedule_all() from adjust_link().

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 756ba10..8f944e5 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1588,7 +1588,6 @@ static void adjust_link(struct net_device *dev)
 		if (!ugeth->oldlink) {
 			new_state = 1;
 			ugeth->oldlink = 1;
-			netif_tx_schedule_all(dev);
 		}
 	} else if (ugeth->oldlink) {
 			new_state = 1;
-- 
1.5.5.4

