From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC PATCH] tg3: use netif_carrier_off to prevent tx timeout
Date: Wed, 12 May 2010 13:16:57 +0200
Message-ID: <20100512131657.76582f10@dhcp-lab-109.englab.brq.redhat.com>
References: <20100512110921.0e3f45fc@dhcp-lab-109.englab.brq.redhat.com>
	<1273656458.2621.22.camel@edumazet-laptop>
	<20100512125815.0dad8ad0@dhcp-lab-109.englab.brq.redhat.com>
	<20100512130628.69bc3890@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15627 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928Ab0ELLOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 07:14:53 -0400
In-Reply-To: <20100512130628.69bc3890@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Touching ->trans_start make netdev watchdog timeouts only less probable.
Use netif_carrier_off to prevent timeout, lately we take care of turning
carrier on.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
Patch was not tested!

 drivers/net/tg3.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 573054a..d745038 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -753,7 +753,7 @@ static void tg3_napi_enable(struct tg3 *tp)
 
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
-	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
+	netif_carrier_off(tp->dev);	/* prevent tx timeout */
 	tg3_napi_disable(tp);
 	netif_tx_disable(tp->dev);
 }
@@ -10964,12 +10964,14 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static void tg3_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
 	struct tg3 *tp = netdev_priv(dev);
+	int link_up;
 
 	if (!netif_running(dev)) {
 		tp->vlgrp = grp;
 		return;
 	}
 
+	link_up = netif_carrier_ok(dev);
 	tg3_netif_stop(tp);
 
 	tg3_full_lock(tp, 0);
@@ -10979,6 +10981,8 @@ static void tg3_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	/* Update RX_MODE_KEEP_VLAN_TAG bit in RX_MODE register. */
 	__tg3_set_rx_mode(dev);
 
+	if (link_up)
+		netif_carrier_on(dev);
 	tg3_netif_start(tp);
 
 	tg3_full_unlock(tp);
-- 
1.5.5.6

