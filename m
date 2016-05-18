From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 2/2] intel: Add support for IPv6 IP-in-IP offload
Date: Wed, 18 May 2016 10:44:53 -0700
Message-ID: <20160518174453.2608.59296.stgit@localhost.localdomain>
References: <20160518173605.2608.42484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: tom@herbertland.com, alexander.duyck@gmail.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kernel-team@fb.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35154 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932340AbcERRoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:44:55 -0400
Received: by mail-pf0-f181.google.com with SMTP id b66so4590pfb.2
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 10:44:55 -0700 (PDT)
In-Reply-To: <20160518173605.2608.42484.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for offloading IPXIP6 type packets that represent
either IPv4 or IPv6 encapsulated inside of an IPv6 outer IP header.  In
addition with this change we should also be able to support FOU
encapsulated traffic with outer IPv6 headers.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c       |    1 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |    1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |    1 +
 drivers/net/ethernet/intel/igb/igb_main.c         |    1 +
 drivers/net/ethernet/intel/igbvf/netdev.c         |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    1 +
 8 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 14e9c99e9d36..c059d09f3257 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9113,6 +9113,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 				   NETIF_F_GSO_GRE		|
 				   NETIF_F_GSO_GRE_CSUM		|
 				   NETIF_F_GSO_IPXIP4		|
+				   NETIF_F_GSO_IPXIP6		|
 				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
 				   NETIF_F_GSO_PARTIAL		|
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 0a8122c00ae2..55f151fca1dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2285,6 +2285,7 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
 					 SKB_GSO_GRE_CSUM |
 					 SKB_GSO_IPXIP4 |
+					 SKB_GSO_IPXIP6 |
 					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
 		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 2bbbbd0f9f15..be99189da925 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1560,6 +1560,7 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
 					 SKB_GSO_GRE_CSUM |
 					 SKB_GSO_IPXIP4 |
+					 SKB_GSO_IPXIP6 |
 					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
 		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 520c5b3b6cb4..eac057b88055 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2231,6 +2231,7 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 				   NETIF_F_GSO_GRE		|
 				   NETIF_F_GSO_GRE_CSUM		|
 				   NETIF_F_GSO_IPXIP4		|
+				   NETIF_F_GSO_IPXIP6		|
 				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
 				   NETIF_F_GSO_PARTIAL		|
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b1a5cdb77088..ef3d642f5ff2 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2419,6 +2419,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 #define IGB_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
 				  NETIF_F_GSO_GRE_CSUM | \
 				  NETIF_F_GSO_IPXIP4 | \
+				  NETIF_F_GSO_IPXIP6 | \
 				  NETIF_F_GSO_UDP_TUNNEL | \
 				  NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 79b907f1a520..b0778ba65083 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2764,6 +2764,7 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 #define IGBVF_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
 				    NETIF_F_GSO_GRE_CSUM | \
 				    NETIF_F_GSO_IPXIP4 | \
+				    NETIF_F_GSO_IPXIP6 | \
 				    NETIF_F_GSO_UDP_TUNNEL | \
 				    NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 427084e7fbf4..e98affdb14b7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9544,6 +9544,7 @@ skip_sriov:
 #define IXGBE_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
 				    NETIF_F_GSO_GRE_CSUM | \
 				    NETIF_F_GSO_IPXIP4 | \
+				    NETIF_F_GSO_IPXIP6 | \
 				    NETIF_F_GSO_UDP_TUNNEL | \
 				    NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index d86e51116384..acc24010cfe0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -4063,6 +4063,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 #define IXGBEVF_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
 				      NETIF_F_GSO_GRE_CSUM | \
 				      NETIF_F_GSO_IPXIP4 | \
+				      NETIF_F_GSO_IPXIP6 | \
 				      NETIF_F_GSO_UDP_TUNNEL | \
 				      NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
