From: Thomas Klein <tklein@de.ibm.com>
Subject: [PATCH 2/3] ehea: Fix mem allocations which require page alignment
Date: Wed, 21 Jan 2009 15:49:20 +0100
Message-ID: <200901211549.21066.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:43672 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760556AbZAUOxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 09:53:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PAGE_SIZE allocations via slab are not guaranteed to be page-aligned. Fixed
all memory allocations where page alignment is required by firmware.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
Thanks to Nathan Lynch for this hint!

diff -Nurp -X dontdiff linux-2.6.29-rc2/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.29-rc2/drivers/net/ehea/ehea_main.c	2009-01-21 13:24:54.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2009-01-21 13:36:14.000000000 +0100
@@ -308,7 +308,7 @@ static struct net_device_stats *ehea_get
 
 	memset(stats, 0, sizeof(*stats));
 
-	cb2 = kzalloc(PAGE_SIZE, GFP_ATOMIC);
+	cb2 = (void *)get_zeroed_page(GFP_ATOMIC);
 	if (!cb2) {
 		ehea_error("no mem for cb2");
 		goto out;
@@ -341,7 +341,7 @@ static struct net_device_stats *ehea_get
 	stats->rx_packets = rx_packets;
 
 out_herr:
-	kfree(cb2);
+	free_page((unsigned long)cb2);
 out:
 	return stats;
 }
@@ -915,7 +915,7 @@ int ehea_sense_port_attr(struct ehea_por
 	struct hcp_ehea_port_cb0 *cb0;
 
 	/* may be called via ehea_neq_tasklet() */
-	cb0 = kzalloc(PAGE_SIZE, GFP_ATOMIC);
+	cb0 = (void *)get_zeroed_page(GFP_ATOMIC);
 	if (!cb0) {
 		ehea_error("no mem for cb0");
 		ret = -ENOMEM;
@@ -996,7 +996,7 @@ int ehea_sense_port_attr(struct ehea_por
 out_free:
 	if (ret || netif_msg_probe(port))
 		ehea_dump(cb0, sizeof(*cb0), "ehea_sense_port_attr");
-	kfree(cb0);
+	free_page((unsigned long)cb0);
 out:
 	return ret;
 }
@@ -1007,7 +1007,7 @@ int ehea_set_portspeed(struct ehea_port
 	u64 hret;
 	int ret = 0;
 
-	cb4 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb4 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb4) {
 		ehea_error("no mem for cb4");
 		ret = -ENOMEM;
@@ -1075,7 +1075,7 @@ int ehea_set_portspeed(struct ehea_port
 	if (!prop_carrier_state || (port->phy_link == EHEA_PHY_LINK_UP))
 		netif_carrier_on(port->netdev);
 
-	kfree(cb4);
+	free_page((unsigned long)cb4);
 out:
 	return ret;
 }
@@ -1302,7 +1302,7 @@ static int ehea_configure_port(struct eh
 	struct hcp_ehea_port_cb0 *cb0;
 
 	ret = -ENOMEM;
-	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb0 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb0)
 		goto out;
 
@@ -1338,7 +1338,7 @@ static int ehea_configure_port(struct eh
 	ret = 0;
 
 out_free:
-	kfree(cb0);
+	free_page((unsigned long)cb0);
 out:
 	return ret;
 }
@@ -1748,7 +1748,7 @@ static int ehea_set_mac_addr(struct net_
 		goto out;
 	}
 
-	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb0 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb0) {
 		ehea_error("no mem for cb0");
 		ret = -ENOMEM;
@@ -1793,7 +1793,7 @@ out_upregs:
 	ehea_update_bcmc_registrations();
 	spin_unlock(&ehea_bcmc_regs.lock);
 out_free:
-	kfree(cb0);
+	free_page((unsigned long)cb0);
 out:
 	return ret;
 }
@@ -1817,7 +1817,7 @@ static void ehea_promiscuous(struct net_
 	if ((enable && port->promisc) || (!enable && !port->promisc))
 		return;
 
-	cb7 = kzalloc(PAGE_SIZE, GFP_ATOMIC);
+	cb7 = (void *)get_zeroed_page(GFP_ATOMIC);
 	if (!cb7) {
 		ehea_error("no mem for cb7");
 		goto out;
@@ -1836,7 +1836,7 @@ static void ehea_promiscuous(struct net_
 
 	port->promisc = enable;
 out:
-	kfree(cb7);
+	free_page((unsigned long)cb7);
 	return;
 }
 
@@ -2217,7 +2217,7 @@ static void ehea_vlan_rx_register(struct
 
 	port->vgrp = grp;
 
-	cb1 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb1 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb1) {
 		ehea_error("no mem for cb1");
 		goto out;
@@ -2228,7 +2228,7 @@ static void ehea_vlan_rx_register(struct
 	if (hret != H_SUCCESS)
 		ehea_error("modify_ehea_port failed");
 
-	kfree(cb1);
+	free_page((unsigned long)cb1);
 out:
 	return;
 }
@@ -2241,7 +2241,7 @@ static void ehea_vlan_rx_add_vid(struct
 	int index;
 	u64 hret;
 
-	cb1 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb1 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb1) {
 		ehea_error("no mem for cb1");
 		goto out;
@@ -2262,7 +2262,7 @@ static void ehea_vlan_rx_add_vid(struct
 	if (hret != H_SUCCESS)
 		ehea_error("modify_ehea_port failed");
 out:
-	kfree(cb1);
+	free_page((unsigned long)cb1);
 	return;
 }
 
@@ -2276,7 +2276,7 @@ static void ehea_vlan_rx_kill_vid(struct
 
 	vlan_group_set_device(port->vgrp, vid, NULL);
 
-	cb1 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb1 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb1) {
 		ehea_error("no mem for cb1");
 		goto out;
@@ -2297,7 +2297,7 @@ static void ehea_vlan_rx_kill_vid(struct
 	if (hret != H_SUCCESS)
 		ehea_error("modify_ehea_port failed");
 out:
-	kfree(cb1);
+	free_page((unsigned long)cb1);
 	return;
 }
 
@@ -2309,7 +2309,7 @@ int ehea_activate_qp(struct ehea_adapter
 	u64 dummy64 = 0;
 	struct hcp_modify_qp_cb0 *cb0;
 
-	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb0 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb0) {
 		ret = -ENOMEM;
 		goto out;
@@ -2372,7 +2372,7 @@ int ehea_activate_qp(struct ehea_adapter
 
 	ret = 0;
 out:
-	kfree(cb0);
+	free_page((unsigned long)cb0);
 	return ret;
 }
 
@@ -2664,7 +2664,7 @@ int ehea_stop_qps(struct net_device *dev
 	u64 dummy64 = 0;
 	u16 dummy16 = 0;
 
-	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb0 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb0) {
 		ret = -ENOMEM;
 		goto out;
@@ -2716,7 +2716,7 @@ int ehea_stop_qps(struct net_device *dev
 
 	ret = 0;
 out:
-	kfree(cb0);
+	free_page((unsigned long)cb0);
 
 	return ret;
 }
@@ -2766,7 +2766,7 @@ int ehea_restart_qps(struct net_device *
 	u64 dummy64 = 0;
 	u16 dummy16 = 0;
 
-	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb0 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb0) {
 		ret = -ENOMEM;
 		goto out;
@@ -2819,7 +2819,7 @@ int ehea_restart_qps(struct net_device *
 		ehea_refill_rq3(pr, 0);
 	}
 out:
-	kfree(cb0);
+	free_page((unsigned long)cb0);
 
 	return ret;
 }
@@ -2950,7 +2950,7 @@ int ehea_sense_adapter_attr(struct ehea_
 	u64 hret;
 	int ret;
 
-	cb = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb) {
 		ret = -ENOMEM;
 		goto out;
@@ -2967,7 +2967,7 @@ int ehea_sense_adapter_attr(struct ehea_
 	ret = 0;
 
 out_herr:
-	kfree(cb);
+	free_page((unsigned long)cb);
 out:
 	return ret;
 }
@@ -2981,7 +2981,7 @@ int ehea_get_jumboframe_status(struct eh
 	*jumbo = 0;
 
 	/* (Try to) enable *jumbo frames */
-	cb4 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb4 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb4) {
 		ehea_error("no mem for cb4");
 		ret = -ENOMEM;
@@ -3009,7 +3009,7 @@ int ehea_get_jumboframe_status(struct eh
 		} else
 			ret = -EINVAL;
 
-		kfree(cb4);
+		free_page((unsigned long)cb4);
 	}
 out:
 	return ret;
diff -Nurp -X dontdiff linux-2.6.29-rc2/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-2.6.29-rc2/drivers/net/ehea/ehea_qmr.c	2009-01-16 21:43:00.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2009-01-21 13:36:14.000000000 +0100
@@ -1005,7 +1005,7 @@ void ehea_error_data(struct ehea_adapter
 	unsigned long ret;
 	u64 *rblock;
 
-	rblock = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	rblock = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!rblock) {
 		ehea_error("Cannot allocate rblock memory.");
 		return;
@@ -1022,5 +1022,5 @@ void ehea_error_data(struct ehea_adapter
 	else
 		ehea_error("Error data could not be fetched: %llX", res_handle);
 
-	kfree(rblock);
+	free_page((unsigned long)rblock);
 }
