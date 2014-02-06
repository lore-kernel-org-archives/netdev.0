From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net] tg3: Fix deadlock in tg3_change_mtu()
Date: Thu, 6 Feb 2014 14:13:05 -0800
Message-ID: <1391724785-13562-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	<stable@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting David Vrabel -
"5780 cards cannot have jumbo frames and TSO enabled together.  When
jumbo frames are enabled by setting the MTU, the TSO feature must be
cleared.  This is done indirectly by calling netdev_update_features()
which will call tg3_fix_features() to actually clear the flags.

netdev_update_features() will also trigger a new netlink message for the
feature change event which will result in a call to tg3_get_stats64()
which deadlocks on the tg3 lock."

tg3_set_mtu() does not need to be under the tg3 lock since converting
the flags to use set_bit(). Move it out to after tg3_netif_stop().

Cc: <stable@vger.kernel.org>
Reported-by: David Vrabel <david.vrabel@citrix.com>
Tested-by: David Vrabel <david.vrabel@citrix.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e2ca03e..0bb79b8 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14113,12 +14113,12 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 
 	tg3_netif_stop(tp);
 
+	tg3_set_mtu(dev, tp, new_mtu);
+
 	tg3_full_lock(tp, 1);
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 
-	tg3_set_mtu(dev, tp, new_mtu);
-
 	/* Reset PHY, otherwise the read DMA engine will be in a mode that
 	 * breaks all requests to 256 bytes.
 	 */
-- 
1.7.9.5
