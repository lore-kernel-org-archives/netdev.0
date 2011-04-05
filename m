From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 14/14] ehea: Add GRO support
Date: Tue, 5 Apr 2011 21:45:01 +1000
Message-ID: <20110405214501.111d3638@kryten>
References: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49916 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286Ab1DELpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:45:05 -0400
In-Reply-To: <20110405212825.6eb85677@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add GRO support to the ehea driver.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-04-05 20:47:47.870323182 +1000
+++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-04-05 20:47:50.709998860 +1000
@@ -634,18 +634,6 @@ static int ehea_treat_poll_error(struct
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
@@ -728,7 +716,14 @@ static int ehea_proc_rwqes(struct net_de
 			}
 
 			processed_bytes += skb->len;
-			ehea_proc_skb(pr, cqe, skb);
+
+			if ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
+			    pr->port->vgrp) {
+				vlan_gro_receive(&pr->napi, pr->port->vgrp,
+					cqe->vlan_tag, skb);
+			} else {
+				napi_gro_receive(&pr->napi, skb);
+			}
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
@@ -3045,7 +3040,7 @@ struct ehea_port *ehea_setup_single_port
 	dev->netdev_ops = &ehea_netdev_ops;
 	ehea_set_ethtool_ops(dev);
 
-	dev->features = NETIF_F_SG | NETIF_F_TSO
+	dev->features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_GRO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_HIGHDMA |

