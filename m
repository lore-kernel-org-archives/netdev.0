From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 02/21] ehea: unify vlan and nonvlan rx path
Date: Fri, 15 Jul 2011 23:33:20 +0200
Message-ID: <1310765619-27827-3-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	leitao@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753308Ab1GOVeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:24 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ehea/ehea_main.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 3fd5a24..8dffb80 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -686,21 +686,13 @@ static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
 	int vlan_extracted = ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
 			      pr->port->vgrp);
 
-	if (skb->dev->features & NETIF_F_LRO) {
-		if (vlan_extracted)
-			lro_vlan_hwaccel_receive_skb(&pr->lro_mgr, skb,
-						     pr->port->vgrp,
-						     cqe->vlan_tag,
-						     cqe);
-		else
-			lro_receive_skb(&pr->lro_mgr, skb, cqe);
-	} else {
-		if (vlan_extracted)
-			vlan_hwaccel_receive_skb(skb, pr->port->vgrp,
-						 cqe->vlan_tag);
-		else
-			netif_receive_skb(skb);
-	}
+	if (vlan_extracted)
+		__vlan_hwaccel_put_tag(skb, cqe->vlan_tag);
+
+	if (skb->dev->features & NETIF_F_LRO)
+		lro_receive_skb(&pr->lro_mgr, skb, cqe);
+	else
+		netif_receive_skb(skb);
 }
 
 static int ehea_proc_rwqes(struct net_device *dev,
-- 
1.7.6

