From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] via-rhine: fix VLAN receive handling regression.
Date: Thu, 15 Oct 2015 00:14:37 +0200
Message-ID: <20151014221437.GA8065@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Andrej Ota <andrej@ota.si>,
	Nix <nix@esperi.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51150 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbbJNWPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 18:15:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrej Ota <andrej@ota.si>

Because eth_type_trans() consumes ethernet header worth of bytes, a call
to read TCI from end of packet using rhine_rx_vlan_tag() no longer works
as it's reading from an invalid offset.

Tested to be working on PCEngines Alix board.

Fixes: 810f19bcb862 ("via-rhine: add consistent memory barrier in vlan receive code.")
Signed-off-by: Andrej Ota <andrej@ota.si>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>

---

 Applies fine as of 0f8b8e28fb3241f9fd82ce13bac2b40c35e987e0
 ("tipc: eliminate risk of stalled link synchronization").

 Andrej posted it on l-k the 2015/10/04, see
 http://marc.info/?l=linux-kernel&m=144398918324349

 Kernel v4.2 exhibits the regression. Stable v4.[01] kernels don't.

 drivers/net/ethernet/via/via-rhine.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index a832637..2b7550c 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2134,10 +2134,11 @@ static int rhine_rx(struct net_device *dev, int limit)
 			}
 
 			skb_put(skb, pkt_len);
-			skb->protocol = eth_type_trans(skb, dev);
 
 			rhine_rx_vlan_tag(skb, desc, data_size);
 
+			skb->protocol = eth_type_trans(skb, dev);
+
 			netif_receive_skb(skb);
 
 			u64_stats_update_begin(&rp->rx_stats.syncp);
-- 
2.4.3
