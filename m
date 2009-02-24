From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/2] netxen: fix physical port mapping
Date: Tue, 24 Feb 2009 00:16:58 -0800
Message-ID: <1235463419-25146-2-git-send-email-dhananjay@netxen.com>
References: <1235463419-25146-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48596 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752803AbZBXIRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 03:17:01 -0500
In-Reply-To: <1235463419-25146-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI function to physical port mapping is valid only for
old firmware. New firmware (4.0.0+) abstracts this.
So driver should never try to access phy using invalid
mapping. The behavior is unpredictable when PCI functions
4-7 are enabled on the same NIC.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9f33e44..f425811 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -795,9 +795,12 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
 	adapter->physical_port = adapter->portnum;
-	i = adapter->pci_read_normalize(adapter, CRB_V2P(adapter->portnum));
-	if (i != 0x55555555)
-		adapter->physical_port = i;
+	if (adapter->fw_major < 4) {
+		i = adapter->pci_read_normalize(adapter,
+				CRB_V2P(adapter->portnum));
+		if (i != 0x55555555)
+			adapter->physical_port = i;
+	}
 
 	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
 
-- 
1.6.0.2

