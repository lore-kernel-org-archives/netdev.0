From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 1/3] gianfar: do not touch net queue in adjust_link phylib
	callback
Date: Mon, 21 Jul 2008 19:17:21 +0400
Message-ID: <20080721151721.GA7989@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:13559 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752610AbYGUPR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:17:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the net queue has not been started, we'll get this nice oops
and non-working ethernet:

PHY: 0:01 - Link is Up - 1000/Full
------------[ cut here ]------------
kernel BUG at net/core/dev.c:1328!
Oops: Exception in kernel mode, sig: 5 [#1]
MPC837x RDB
Modules linked in:
NIP: c02544a0 LR: c01a17d0 CTR: c01a16ac
REGS: cf837e40 TRAP: 0700   Not tainted  (2.6.26-05253-g14b395e)
MSR: 00021032 <ME,IR,DR>  CR: 22042044  XER: 00000000
TASK = cf819400[5] 'events/0' THREAD: cf836000
GPR00: c01a17d0 cf837ef0 cf819400 c03d8d08 cf8469a0 00000064 00000000 00000000
GPR08: c03d8d08 00000001 00000001 cf899ba0 22044044 00000000 0fffd000 00000000
GPR16: 0fff3028 0fff6cf0 00000000 0fff8390 0ff494a0 00000004 00000000 00000000
GPR24: c0361a00 00001058 cf9f6600 00009032 cf846800 cf846b80 00000001 00000014
NIP [c02544a0] __netif_schedule+0x28/0x8c
LR [c01a17d0] adjust_link+0x124/0x1cc
Call Trace:
[cf837ef0] [c03fb3a0] 0xc03fb3a0 (unreliable)
[cf837f10] [c01a17d0] adjust_link+0x124/0x1cc
[cf837f40] [c01a8e28] phy_state_machine+0x2e0/0x448
[cf837f60] [c0040254] run_workqueue+0xc8/0x168
[cf837f90] [c00408d8] worker_thread+0x70/0xd0
[cf837fd0] [c0044630] kthread+0x48/0x84
[cf837ff0] [c0012610] kernel_thread+0x44/0x60
Instruction dump:
7c0803a6 4e800020 3d20c03e 9421ffe0 7c0802a6 7c681b78 39298d08 7c694a78
7d290034 90010024 bfa10014 5529d97e <0f090000> 39600002 38030024 7d200028
---[ end trace 13dfd73ee42d0c30 ]---

Since the driver is using phylib (which is doing netif_carrier_on/off()),
we should simply remove netif_tx_schedule_all() from adjust_link().

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 45a6317..39b45e9 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1725,7 +1725,6 @@ static void adjust_link(struct net_device *dev)
 		if (!priv->oldlink) {
 			new_state = 1;
 			priv->oldlink = 1;
-			netif_tx_schedule_all(dev);
 		}
 	} else if (priv->oldlink) {
 		new_state = 1;
-- 
1.5.5.4

