From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 14/15] ehea: Add GRO support
Date: Thu, 12 May 2011 10:52:27 +1000
Message-ID: <20110512005623.766530798@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54425 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418Ab1ELB16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:27:58 -0400
Content-Disposition: inline; filename=ehea_21.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add GRO support to the ehea driver.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

v2:
- Removed use of vlan_gro_receive as suggested by Jesse Gross

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:48:03.810341336 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:48:05.100361788 +1000
@@ -637,18 +637,6 @@ static int ehea_treat_poll_error(struct
 	return 0;
 }
 
-static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
-			  struct sk_buff *skb)
-{
-	int vlan_extracted = ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
-			      pr->port->vgrp);
-
-	if (vlan_extracted)
-		vlan_hwaccel_receive_skb(skb, pr->port->vgrp, cqe->vlan_tag);
-	else
-		netif_receive_skb(skb);
-}
-
 static int ehea_proc_rwqes(struct net_device *dev,
 			   struct ehea_port_res *pr,
 			   int budget)
@@ -725,7 +713,12 @@ static int ehea_proc_rwqes(struct net_de
 			}
 
 			processed_bytes += skb->len;
-			ehea_proc_skb(pr, cqe, skb);
+
+			if ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
+			    pr->port->vgrp)
+				__vlan_hwaccel_put_tag(skb, cqe->vlan_tag);
+
+			napi_gro_receive(&pr->napi, skb);
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
@@ -3041,7 +3034,7 @@ struct ehea_port *ehea_setup_single_port
 	dev->netdev_ops = &ehea_netdev_ops;
 	ehea_set_ethtool_ops(dev);
 
-	dev->hw_features = NETIF_F_SG | NETIF_F_TSO
+	dev->hw_features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_GRO
 		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX | NETIF_F_LRO;
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX


