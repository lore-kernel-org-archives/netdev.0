From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: fix msi-x interrupt handling
Date: Sat,  7 Feb 2009 09:23:30 -0800
Message-ID: <1234027410-658-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:43019 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756377AbZBGRXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Feb 2009 12:23:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Cut down msi-x vectors from 8 to 1 since only one is used for now.
o Use separate handler for msi-x, that doesn't unnecessarily scrub
  msi status register.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 +-
 drivers/net/netxen/netxen_nic_main.c |   13 ++++++++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 9c78c96..f4dd9ac 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1203,7 +1203,7 @@ typedef struct {
 #define NETXEN_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED))
 
-#define MSIX_ENTRIES_PER_ADAPTER	8
+#define MSIX_ENTRIES_PER_ADAPTER	1
 #define NETXEN_MSIX_TBL_SPACE		8192
 #define NETXEN_PCI_REG_MSIX_TBL		0x44
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 645d384..3b17a79 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -76,6 +76,7 @@ static void netxen_nic_poll_controller(struct net_device *netdev);
 #endif
 static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
+static irqreturn_t netxen_msix_intr(int irq, void *data);
 
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
@@ -1084,7 +1085,9 @@ static int netxen_nic_open(struct net_device *netdev)
 			for (ring = 0; ring < adapter->max_rds_rings; ring++)
 				netxen_post_rx_buffers(adapter, ctx, ring);
 		}
-		if (NETXEN_IS_MSI_FAMILY(adapter))
+		if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
+			handler = netxen_msix_intr;
+		else if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
 			handler = netxen_msi_intr;
 		else {
 			flags |= IRQF_SHARED;
@@ -1612,6 +1615,14 @@ static irqreturn_t netxen_msi_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t netxen_msix_intr(int irq, void *data)
+{
+	struct netxen_adapter *adapter = data;
+
+	napi_schedule(&adapter->napi);
+	return IRQ_HANDLED;
+}
+
 static int netxen_nic_poll(struct napi_struct *napi, int budget)
 {
 	struct netxen_adapter *adapter = container_of(napi, struct netxen_adapter, napi);
-- 
1.6.0.2

