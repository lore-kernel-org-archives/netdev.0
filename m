From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] ixgbe/ixgbevf: Enables TSO for MPLS encapsulated packets
Date: Wed, 31 May 2017 14:19:22 -0700
Message-ID: <20170531211936.63417-2-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Scott Peterson <scott.d.peterson@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38747 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751062AbdEaVTq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:46 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Peterson <scott.d.peterson@intel.com>

This patch advertises TSO & GSO features in netdev->mpls_features.
In ixgbe(vf)_tso() where we set up segmentation offload, the IP
header will be the inner network header when eth_p_mpls() indicates
the Ethernet protocol is MPLS (UC or MC).

Suggested-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Scott Peterson <scott.d.peterson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 12 ++++++++++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 12 ++++++++++--
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d39cba214320..c263e2293661 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -58,6 +58,7 @@
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_mirred.h>
 #include <net/vxlan.h>
+#include <net/mpls.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -7667,7 +7668,10 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	if (err < 0)
 		return err;
 
-	ip.hdr = skb_network_header(skb);
+	if (eth_p_mpls(first->protocol))
+		ip.hdr = skb_inner_network_header(skb);
+	else
+		ip.hdr = skb_network_header(skb);
 	l4.hdr = skb_checksum_start(skb);
 
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
@@ -10191,7 +10195,11 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->vlan_features |= netdev->features | NETIF_F_TSO_MANGLEID;
 	netdev->hw_enc_features |= netdev->vlan_features;
-	netdev->mpls_features |= NETIF_F_HW_CSUM;
+	netdev->mpls_features |= NETIF_F_SG |
+				 NETIF_F_TSO |
+				 NETIF_F_TSO6 |
+				 NETIF_F_HW_CSUM;
+	netdev->mpls_features |= IXGBE_GSO_PARTIAL_FEATURES;
 
 	/* set this bit last since it cannot be part of vlan_features */
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER |
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index eee29bddddc1..706d868a778d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -49,6 +49,7 @@
 #include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
+#include <net/mpls.h>
 
 #include "ixgbevf.h"
 
@@ -3321,7 +3322,10 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 	if (err < 0)
 		return err;
 
-	ip.hdr = skb_network_header(skb);
+	if (eth_p_mpls(first->protocol))
+		ip.hdr = skb_inner_network_header(skb);
+	else
+		ip.hdr = skb_network_header(skb);
 	l4.hdr = skb_checksum_start(skb);
 
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
@@ -4075,7 +4079,11 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	netdev->vlan_features |= netdev->features | NETIF_F_TSO_MANGLEID;
-	netdev->mpls_features |= NETIF_F_HW_CSUM;
+	netdev->mpls_features |= NETIF_F_SG |
+				 NETIF_F_TSO |
+				 NETIF_F_TSO6 |
+				 NETIF_F_HW_CSUM;
+	netdev->mpls_features |= IXGBEVF_GSO_PARTIAL_FEATURES;
 	netdev->hw_enc_features |= netdev->vlan_features;
 
 	/* set this bit last since it cannot be part of vlan_features */
-- 
2.12.2
