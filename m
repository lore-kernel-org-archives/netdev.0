From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 1/2] net: spider_net: do not read mac address again after setting it
Date: Fri,  3 Oct 2014 17:01:55 +0200
Message-ID: <1412348517-20352-3-git-send-email-antoine.tenart@free-electrons.com>
References: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dan.carpenter@oracle.com, kou.ishizaki@toshiba.co.jp,
	jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:46677 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752586AbaJCPCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:02:00 -0400
In-Reply-To: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the spider_net_get_mac_address() call at the end of
the spider_net_set_mac() function. The dev->dev_addr is instead updated
with a memcpy() from sa->sa_data.

Since spider_net_get_mac_address() is not used anywhere else, this patch
also removes the function.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/toshiba/spider_net.c | 36 ++-----------------------------
 1 file changed, 2 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 3e38f67c6011..713313e15c68 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -267,34 +267,6 @@ spider_net_set_promisc(struct spider_net_card *card)
 }
 
 /**
- * spider_net_get_mac_address - read mac address from spider card
- * @card: device structure
- *
- * reads MAC address from GMACUNIMACU and GMACUNIMACL registers
- */
-static int
-spider_net_get_mac_address(struct net_device *netdev)
-{
-	struct spider_net_card *card = netdev_priv(netdev);
-	u32 macl, macu;
-
-	macl = spider_net_read_reg(card, SPIDER_NET_GMACUNIMACL);
-	macu = spider_net_read_reg(card, SPIDER_NET_GMACUNIMACU);
-
-	netdev->dev_addr[0] = (macu >> 24) & 0xff;
-	netdev->dev_addr[1] = (macu >> 16) & 0xff;
-	netdev->dev_addr[2] = (macu >> 8) & 0xff;
-	netdev->dev_addr[3] = macu & 0xff;
-	netdev->dev_addr[4] = (macl >> 8) & 0xff;
-	netdev->dev_addr[5] = macl & 0xff;
-
-	if (!is_valid_ether_addr(&netdev->dev_addr[0]))
-		return -EINVAL;
-
-	return 0;
-}
-
-/**
  * spider_net_get_descr_status -- returns the status of a descriptor
  * @descr: descriptor to look at
  *
@@ -1345,6 +1317,8 @@ spider_net_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	memcpy(netdev->dev_addr, addr->sa_data, ETH_ALEN);
+
 	/* switch off GMACTPE and GMACRPE */
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GMACOPEMD);
 	regvalue &= ~((1 << 5) | (1 << 6));
@@ -1364,12 +1338,6 @@ spider_net_set_mac(struct net_device *netdev, void *p)
 
 	spider_net_set_promisc(card);
 
-	/* look up, whether we have been successful */
-	if (spider_net_get_mac_address(netdev))
-		return -EADDRNOTAVAIL;
-	if (memcmp(netdev->dev_addr,addr->sa_data,netdev->addr_len))
-		return -EADDRNOTAVAIL;
-
 	return 0;
 }
 
-- 
1.9.1
