From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3.6 13/19] media: dvb_core: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:54:06 +0800
Message-ID: <52CCBDCE.8030503@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Mauro Carvalho Chehab <m.chehab@samsung.com>,
	<linux-media@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:40481 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110AbaAHCyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 21:54:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use possibly more efficient ether_addr_equal
instead of memcmp.

Cc: Mauro Carvalho Chehab <m.chehab@samsung.com>
Cc: linux-media@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Acked-by: Mauro Carvalho Chehab <m.chehab@samsung.com>
---
 drivers/media/dvb-core/dvb_net.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index f91c80c..8a86b30 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -179,7 +179,7 @@ static __be16 dvb_net_eth_type_trans(struct sk_buff *skb,
 	eth = eth_hdr(skb);
 
 	if (*eth->h_dest & 1) {
-		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
+		if (ether_addr_equal(eth->h_dest,dev->broadcast))
 			skb->pkt_type=PACKET_BROADCAST;
 		else
 			skb->pkt_type=PACKET_MULTICAST;
@@ -674,11 +674,13 @@ static void dvb_net_ule( struct net_device *dev, const u8 *buf, size_t buf_len )
 					if (priv->rx_mode != RX_MODE_PROMISC) {
 						if (priv->ule_skb->data[0] & 0x01) {
 							/* multicast or broadcast */
-							if (memcmp(priv->ule_skb->data, bc_addr, ETH_ALEN)) {
+							if (!ether_addr_equal(priv->ule_skb->data, bc_addr)) {
 								/* multicast */
 								if (priv->rx_mode == RX_MODE_MULTI) {
 									int i;
-									for(i = 0; i < priv->multi_num && memcmp(priv->ule_skb->data, priv->multi_macs[i], ETH_ALEN); i++)
+									for (i = 0; i < priv->multi_num &&
+									    !ether_addr_equal(priv->ule_skb->data,
+											      priv->multi_macs[i]); i++)
 										;
 									if (i == priv->multi_num)
 										drop = 1;
@@ -688,7 +690,7 @@ static void dvb_net_ule( struct net_device *dev, const u8 *buf, size_t buf_len )
 							}
 							/* else: broadcast */
 						}
-						else if (memcmp(priv->ule_skb->data, dev->dev_addr, ETH_ALEN))
+						else if (!ether_addr_equal(priv->ule_skb->data, dev->dev_addr))
 							drop = 1;
 						/* else: destination address matches the MAC address of our receiver device */
 					}
-- 
1.8.0
