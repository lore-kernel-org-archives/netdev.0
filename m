From: Pavel Fedin <p.fedin@samsung.com>
Subject: [PATCH] net: Cavium: Bug fix: MAC address setting in shutdown state
Date: Wed, 17 Jun 2015 10:35:14 +0300
Message-ID: <00a401d0a8d0$271e3760$755aa620$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ks_c_5601-1987
Content-Transfer-Encoding: 7bit
Cc: Aleksey.Makarov@caviumnetworks.com,
	'Sunil Goutham' <sgoutham@cavium.com>,
	=?ks_c_5601-1987?B?J7HoxcLHzyc=?= <thlab.kim@samsung.com>,
	'Dyasly Sergey' <s.dyasly@samsung.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:37342 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204AbbFQHfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 03:35:18 -0400
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQ200HVAVQSJN70@mailout1.w1.samsung.com> for
 netdev@vger.kernel.org; Wed, 17 Jun 2015 08:35:16 +0100 (BST)
Content-language: ru
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug pops up with NetworkManager on Fedora 21. NetworkManager tends to
stop the interface (nicvf_stop() is called) before changing settings. In
stopped state MAC cannot be sent to a PF. However, when the interface is
restarted (nicvf_open() is called), we ping the PF using NIC_MBOX_MSG_READY
message, and the PF replies back with old MAC address, overriding what we had
after MAC setting from userspace. As a result, we cannot set MAC address using
NetworkManager.

This patch introduces special tracking of MAC change in stopped state so that
the correct new MAC address is sent to a PF when interface is reopen.

Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h        |  1 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 12 ++++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h
b/drivers/net/ethernet/cavium/thunder/nic.h
index a3b43e5..dda8a02 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -263,6 +263,7 @@ struct nicvf {
 	bool			pf_acked;
 	bool			pf_nacked;
 	bool			bgx_stats_acked;
+	bool			set_mac_pending;
 } ____cacheline_aligned_in_smp;
 
 /* PF <--> VF Mailbox communication
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 02da802..49d7bcf 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -201,7 +201,8 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 		nic->vf_id = mbx.nic_cfg.vf_id & 0x7F;
 		nic->tns_mode = mbx.nic_cfg.tns_mode & 0x7F;
 		nic->node = mbx.nic_cfg.node_id;
-		ether_addr_copy(nic->netdev->dev_addr, mbx.nic_cfg.mac_addr);
+		if (!nic->set_mac_pending)
+			ether_addr_copy(nic->netdev->dev_addr, mbx.nic_cfg.mac_addr);
 		nic->link_up = false;
 		nic->duplex = 0;
 		nic->speed = 0;
@@ -941,6 +942,11 @@ int nicvf_open(struct net_device *netdev)
 		nicvf_hw_set_mac_addr(nic, netdev);
 	}
 
+	if (nic->set_mac_pending) {
+		nic->set_mac_pending = false;
+		nicvf_hw_set_mac_addr(nic, netdev);
+	}
+
 	/* Init tasklet for handling Qset err interrupt */
 	tasklet_init(&nic->qs_err_task, nicvf_handle_qs_err,
 		     (unsigned long)nic);
@@ -1040,9 +1046,11 @@ static int nicvf_set_mac_address(struct net_device *netdev, void
*p)
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
-	if (nic->msix_enabled)
+	if (nic->msix_enabled) {
 		if (nicvf_hw_set_mac_addr(nic, netdev))
 			return -EBUSY;
+	} else
+		nic->set_mac_pending = true;
 
 	return 0;
 }
-- 
1.9.5.msysgit.0
