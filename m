From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 11/26] igb: update feature flags supported in ethtool
Date: Sat, 07 Feb 2009 01:18:27 -0800
Message-ID: <20090207091827.15697.42208.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:50304
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752250AbZBGJSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:18:47 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This driver is currently using HW_CSUM which is not correct.  Update this
to use the IP_CSUM and IPV6_CSUM flags.  In addition consolidate the TSO
flag setting.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |   16 +++++++---------
 drivers/net/igb/igb_main.c    |    5 +++--
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 84be46c..d7bdc6c 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -287,15 +287,15 @@ static int igb_set_rx_csum(struct net_device *netdev, u32 data)
 
 static u32 igb_get_tx_csum(struct net_device *netdev)
 {
-	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+	return (netdev->features & NETIF_F_IP_CSUM) != 0;
 }
 
 static int igb_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	if (data)
-		netdev->features |= NETIF_F_HW_CSUM;
+		netdev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 	else
-		netdev->features &= ~NETIF_F_HW_CSUM;
+		netdev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 
 	return 0;
 }
@@ -304,15 +304,13 @@ static int igb_set_tso(struct net_device *netdev, u32 data)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-	if (data)
+	if (data) {
 		netdev->features |= NETIF_F_TSO;
-	else
-		netdev->features &= ~NETIF_F_TSO;
-
-	if (data)
 		netdev->features |= NETIF_F_TSO6;
-	else
+	} else {
+		netdev->features &= ~NETIF_F_TSO;
 		netdev->features &= ~NETIF_F_TSO6;
+	}
 
 	dev_info(&adapter->pdev->dev, "TSO is %s\n",
 		 data ? "Enabled" : "Disabled");
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e3a3582..8c27e0a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1158,11 +1158,12 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 			"PHY reset is blocked due to SOL/IDER session.\n");
 
 	netdev->features = NETIF_F_SG |
-			   NETIF_F_HW_CSUM |
+			   NETIF_F_IP_CSUM |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
 
+	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
 
@@ -1172,7 +1173,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
-	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_IP_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
 	if (pci_using_dac)

