From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/6] fddi: slight optimization of addr compare
Date: Mon, 16 Dec 2013 15:15:33 +0800
Message-ID: <52AEA895.2050001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:8822 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874Ab3LPHPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 02:15:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches add ether_addr_equal_unaligned to test if
possibly unaligned to u16 Ethernet addresses are equal.

If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set, this uses
the slightly faster generic routine ether_addr_equal,
otherwise this uses memcmp, and FDDI_K_ALEN is same with
ETH_ALEN.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/802/fddi.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/802/fddi.c b/net/802/fddi.c
index 9cda406..d536a81 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -41,6 +41,7 @@
 #include <linux/errno.h>
 #include <net/arp.h>
 #include <net/sock.h>
+#include <linux/etherdevice.h>
 
 /*
  * Create the FDDI MAC header for an arbitrary protocol layer
@@ -147,7 +148,7 @@ __be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	if (*fddi->daddr & 0x01)
 	{
-		if (memcmp(fddi->daddr, dev->broadcast, FDDI_K_ALEN) == 0)
+		if (ether_addr_equal_unaligned(fddi->daddr, dev->broadcast))
 			skb->pkt_type = PACKET_BROADCAST;
 		else
 			skb->pkt_type = PACKET_MULTICAST;
@@ -155,7 +156,7 @@ __be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	else if (dev->flags & IFF_PROMISC)
 	{
-		if (memcmp(fddi->daddr, dev->dev_addr, FDDI_K_ALEN))
+		if (!ether_addr_equal_unaligned(fddi->daddr, dev->dev_addr))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
 
-- 
1.8.0
