From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next] sunvnet: failed trigger should not cause BUG_ON()
Date: Thu, 19 Feb 2015 13:15:49 -0500
Message-ID: <54E62855.5080201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37533 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbbBSSP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 13:15:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An error return from __vnet_tx_trigger() sets the TX descriptor to
VIO_DESC_FREE while leaving port->tx_bufs[txi].skb set. This leads
to a BUG_ON() the next time this descriptor is used.

This patch frees the pending skb when getting a trigger error to
match the VIO_DESC_FREE state.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 2b10b85..0943fb3 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1414,6 +1414,8 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(err < 0)) {
 		netdev_info(dev, "TX trigger error %d\n", err);
 		d->hdr.state = VIO_DESC_FREE;
+		skb = port->tx_bufs[txi].skb;
+		port->tx_bufs[txi].skb = NULL;
 		dev->stats.tx_carrier_errors++;
 		goto out_dropped;
 	}
-- 
1.7.1
