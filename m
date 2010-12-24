From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 08/10] bna: Restore VLAN filter table
Date: Thu, 23 Dec 2010 23:45:08 -0800
Message-ID: <1293176710-21335-9-git-send-email-rmody@brocade.com>
References: <1293176710-21335-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangj@brocade.com>, Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:33851 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752188Ab0LXHqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Dec 2010 02:46:21 -0500
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBO7jrIh012818
	for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 23:46:21 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.140.11])
	by mx0a-000f0801.pphosted.com with ESMTP id tcax1099m-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 23:46:20 -0800
In-Reply-To: <1293176710-21335-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Details:
	- Retrieve the VLAN configuration from the networking stack
	and apply it to the base interface during ifconfig up

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |   29 +++++++++++++++++++++++++++--
 1 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index f775936..140ea95 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -566,7 +566,8 @@ bnad_enable_rx_irq(struct bnad *bnad, struct bna_ccb *ccb)
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(&bnad->bna_lock, flags); /* Because of polling context */
+	/* Because of polling context */
+	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bnad_enable_rx_irq_unsafe(ccb);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
@@ -1962,6 +1963,27 @@ bnad_enable_default_bcast(struct bnad *bnad)
 	return 0;
 }
 
+/* Called with bnad_conf_lock() held */
+static void
+bnad_restore_vlans(struct bnad *bnad, u32 rx_id)
+{
+	u16 vlan_id;
+	unsigned long flags;
+
+	if (!bnad->vlan_grp)
+		return;
+
+	BUG_ON(!(VLAN_N_VID == (BFI_MAX_VLAN + 1)));
+
+	for (vlan_id = 0; vlan_id < VLAN_N_VID; vlan_id++) {
+		if (!vlan_group_get_device(bnad->vlan_grp, vlan_id))
+			continue;
+		spin_lock_irqsave(&bnad->bna_lock, flags);
+		bna_rx_vlan_add(bnad->rx_info[rx_id].rx, vlan_id);
+		spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	}
+}
+
 /* Statistics utilities */
 void
 bnad_netdev_qstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats)
@@ -2337,6 +2359,9 @@ bnad_open(struct net_device *netdev)
 	/* Enable broadcast */
 	bnad_enable_default_bcast(bnad);
 
+	/* Restore VLANs, if any */
+	bnad_restore_vlans(bnad, 0);
+
 	/* Set the UCAST address */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bnad_mac_addr_set_locked(bnad, netdev->dev_addr);
@@ -3021,7 +3046,7 @@ static int __devinit
 bnad_pci_probe(struct pci_dev *pdev,
 		const struct pci_device_id *pcidev_id)
 {
-	bool 	using_dac;
+	bool 	using_dac = false;
 	int 	err;
 	struct bnad *bnad;
 	struct bna *bna;
-- 
1.7.1

