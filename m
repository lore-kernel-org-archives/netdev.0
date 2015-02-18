From: Derrick Pallas <pallas@meraki.com>
Subject: [PATCH] ethernet/ixp4xx: prevent allmulti from clobbering promisc
Date: Wed, 18 Feb 2015 00:50:25 -0800
Message-ID: <1424249425-2438-1-git-send-email-pallas@meraki.com>
Cc: netdev@vger.kernel.org, Derrick Pallas <pallas@meraki.com>
To: Krzysztof Halasa <khalasa@piap.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:34332 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750753AbbBRIx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 03:53:56 -0500
Received: by padbj1 with SMTP id bj1so13115735pad.5
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 00:53:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If both promisc and allmulti are set, promisc should trump allmulti and
disable the MAC filter; otherwise, the interface is not really promisc.

Previously, this code checked IFF_ALLMULTI prior to and without regard for
IFF_PROMISC; if both were set, only multicast and direct unicast traffic
would make it through the filter.

Signed-off-by: Derrick Pallas <pallas@meraki.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index f7e0f0f..9e16a28 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -938,7 +938,7 @@ static void eth_set_mcast_list(struct net_device *dev)
 	int i;
 	static const u8 allmulti[] = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
 
-	if (dev->flags & IFF_ALLMULTI) {
+	if ((dev->flags & IFF_ALLMULTI) && !(dev->flags & IFF_PROMISC)) {
 		for (i = 0; i < ETH_ALEN; i++) {
 			__raw_writel(allmulti[i], &port->regs->mcast_addr[i]);
 			__raw_writel(allmulti[i], &port->regs->mcast_mask[i]);
-- 
2.1.0
