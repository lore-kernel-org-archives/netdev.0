From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: Fix multicast registration on semi-promiscuous mode
Date: Mon, 23 May 2011 10:36:35 -0300
Message-ID: <1306157795-13377-1-git-send-email-leitao@linux.vnet.ibm.com>
References: <20110520.162801.1310159491178676084.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:46516 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab1EWNg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 09:36:57 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p4NEcUJW027115
	for <netdev@vger.kernel.org>; Mon, 23 May 2011 11:38:30 -0300
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4NDXkxc4173860
	for <netdev@vger.kernel.org>; Mon, 23 May 2011 10:33:47 -0300
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4NDaoUH027408
	for <netdev@vger.kernel.org>; Mon, 23 May 2011 10:36:50 -0300
In-Reply-To: <20110520.162801.1310159491178676084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ehea will not register multicast groups in phyp if the physical
interface is in promiscuous mode. But it should register if the
logical port is in promiscuous mode, but the physical port is not.

Ehea physical promiscuous mode is defined by ehea_port->promisc,
while logical port is defined by IFF_PROMISC.

So currently, if the user set the interface in promiscuous mode,
IGMP will not be registred in PHYP, and PHYP will never pass
the multicast packet to the logical port, which is bad

So, this patch just fixes it, assuring that we register in phyp
if the physical port is not on promiscuous mode.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_main.c |    2 +-
 drivers/tty/serial/8250.c    |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index cf79cf7..80027be 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2082,7 +2082,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	int ret;
 
-	if (dev->flags & IFF_PROMISC) {
+	if (port->promisc) {
 		ehea_promiscuous(dev, 1);
 		return;
 	}
 
-- 
1.7.1

