From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 4/4] netxen: disable rss for GbE ports
Date: Tue,  5 May 2009 22:05:09 -0700
Message-ID: <1241586309-12112-5-git-send-email-dhananjay@netxen.com>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:59284 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751660AbZEFFFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 01:05:13 -0400
In-Reply-To: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no advantage of receive side scaling on GbE ports, so
restrict rss support to 10GbE ports.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 83dadfd..1349cf8 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -292,12 +292,12 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	adapter->msix_supported = 0;
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		adapter->msix_supported = !!use_msi_x;
-		adapter->rss_supported = !!use_msi_x;
+		adapter->rss_supported = !!use_msi_x &&
+			(adapter->ahw.port_type == NETXEN_NIC_XGBE);
 	} else if (adapter->fw_version >= NETXEN_VERSION_CODE(3, 4, 336)) {
 		switch (adapter->ahw.board_type) {
 		case NETXEN_BRDTYPE_P2_SB31_10G:
 		case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
-		case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
 			adapter->msix_supported = !!use_msi_x;
 			adapter->rss_supported = !!use_msi_x;
 			break;
@@ -496,6 +496,7 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 {
 	struct netxen_legacy_intr_set *legacy_intrp;
 	struct pci_dev *pdev = adapter->pdev;
+	int num_msix = adapter->rss_supported ? MSIX_ENTRIES_PER_ADAPTER : 1;
 
 	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
 
@@ -513,8 +514,7 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 	if (adapter->msix_supported) {
 
 		netxen_init_msix_entries(adapter);
-		if (pci_enable_msix(pdev, adapter->msix_entries,
-					MSIX_ENTRIES_PER_ADAPTER))
+		if (pci_enable_msix(pdev, adapter->msix_entries, num_msix))
 			goto request_msi;
 
 		adapter->flags |= NETXEN_NIC_MSIX_ENABLED;
-- 
1.6.0.2

