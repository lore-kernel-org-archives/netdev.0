From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 2/2] ehea: fix promiscuous mode
Date: Wed, 25 Apr 2012 14:32:12 -0300
Message-ID: <1335375132-4591-2-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1335375132-4591-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:58604 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756735Ab2DYRcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 13:32:24 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Wed, 25 Apr 2012 14:32:22 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 76FF5352004A
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 14:32:17 -0300 (BRT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3PHUuLt3108952
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 14:30:56 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3PFW7Qf009324
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 12:32:07 -0300
In-Reply-To: <1335375132-4591-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a4910b744486254cfa61995954c118fb2283c4fd has broken promiscuous
mode, which is never set. port->promisc just reflects the last setting
of PROMISCUOUS mode to avoid doing an extra hypercall when it's already
set.

However, since it may fail because of hypervisor permissions, we should
still respect the multicast settings and not simply exit after setting
promiscuous mode.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 9dcb5fd..c9069a2 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1946,11 +1946,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	int ret;
 
-	if (port->promisc) {
-		ehea_promiscuous(dev, 1);
-		return;
-	}
-	ehea_promiscuous(dev, 0);
+	ehea_promiscuous(dev, !!(dev->flags & IFF_PROMISC));
 
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
-- 
1.7.4.4
