From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 8/8] bnxt: Add support for segmentation of
 tunnels with outer checksums
Date: Mon, 02 May 2016 09:38:55 -0700
Message-ID: <20160502163855.11809.43075.stgit@ahduyck-xeon-server>
References: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, alexander.duyck@gmail.com,
	davem@davemloft.net, galp@mellanox.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34164 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbcEBQi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:38:57 -0400
Received: by mail-pf0-f179.google.com with SMTP id y69so80608873pfb.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:38:57 -0700 (PDT)
In-Reply-To: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch assumes that the bnxt hardware will ignore existing IPv4/v6
header fields for length and checksum as well as the length and checksum
fields for outer UDP and GRE headers.

I have been told by Michael Chan that this is working.  Though this might
be somewhat redundant for IPv6 as they are forcing the checksum to be
computed for all IPv6 frames that are offloaded.  A follow-up patch may be
necessary in order to fix this as it is essentially mangling the outer IPv6
headers to add a checksum where none was requested.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4645c44e7c15..ae668476fff0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6194,14 +6194,19 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_TSO | NETIF_F_TSO6 |
 			   NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
 			   NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
-			   NETIF_F_RXHASH |
+			   NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
+			   NETIF_F_GSO_PARTIAL | NETIF_F_RXHASH |
 			   NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO;
 
 	dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO6 |
 			NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
-			NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
+			NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
+			NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
+			NETIF_F_GSO_PARTIAL;
+	dev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM |
+				    NETIF_F_GSO_GRE_CSUM;
 	dev->vlan_features = dev->hw_features | NETIF_F_HIGHDMA;
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_TX |
 			    NETIF_F_HW_VLAN_STAG_RX | NETIF_F_HW_VLAN_STAG_TX;
