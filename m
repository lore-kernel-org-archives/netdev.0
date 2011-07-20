From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 05/47] ehea: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:07 +0200
Message-ID: <1311173689-17419-6-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	leitao@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30016 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508Ab1GTOzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:21 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill port->vgrp and ehea_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ehea/ehea.h      |    1 -
 drivers/net/ehea/ehea_main.c |   54 +++++------------------------------------
 2 files changed, 7 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 6c7257b..7dd5e6a 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -457,7 +457,6 @@ struct ehea_port {
 	struct ehea_port_res port_res[EHEA_MAX_PORT_RES];
 	struct platform_device  ofdev; /* Open Firmware Device */
 	struct ehea_mc_list *mc_list;	 /* Multicast MAC addresses */
-	struct vlan_group *vgrp;
 	struct ehea_eq *qp_eq;
 	struct work_struct reset_task;
 	struct mutex port_lock;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 3fd5a24..be2cb4a 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -683,24 +683,13 @@ static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
 			  struct sk_buff *skb)
 {
-	int vlan_extracted = ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
-			      pr->port->vgrp);
-
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
+	if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
+		__vlan_hwaccel_put_tag(skb, cqe->vlan_tag);
+
+	if (skb->dev->features & NETIF_F_LRO)
+		lro_receive_skb(&pr->lro_mgr, skb, cqe);
+	else
+		netif_receive_skb(skb);
 }
 
 static int ehea_proc_rwqes(struct net_device *dev,
@@ -2339,32 +2328,6 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static void ehea_vlan_rx_register(struct net_device *dev,
-				  struct vlan_group *grp)
-{
-	struct ehea_port *port = netdev_priv(dev);
-	struct ehea_adapter *adapter = port->adapter;
-	struct hcp_ehea_port_cb1 *cb1;
-	u64 hret;
-
-	port->vgrp = grp;
-
-	cb1 = (void *)get_zeroed_page(GFP_KERNEL);
-	if (!cb1) {
-		pr_err("no mem for cb1\n");
-		goto out;
-	}
-
-	hret = ehea_h_modify_ehea_port(adapter->handle, port->logical_port_id,
-				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
-	if (hret != H_SUCCESS)
-		pr_err("modify_ehea_port failed\n");
-
-	free_page((unsigned long)cb1);
-out:
-	return;
-}
-
 static void ehea_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct ehea_port *port = netdev_priv(dev);
@@ -2406,8 +2369,6 @@ static void ehea_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	int index;
 	u64 hret;
 
-	vlan_group_set_device(port->vgrp, vid, NULL);
-
 	cb1 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb1) {
 		pr_err("no mem for cb1\n");
@@ -3202,7 +3163,6 @@ static const struct net_device_ops ehea_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= ehea_set_multicast_list,
 	.ndo_change_mtu		= ehea_change_mtu,
-	.ndo_vlan_rx_register	= ehea_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ehea_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ehea_vlan_rx_kill_vid,
 	.ndo_tx_timeout		= ehea_tx_watchdog,
-- 
1.7.6

