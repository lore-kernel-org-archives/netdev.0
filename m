From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e/i40evf: Handle IPv6 extension headers in checksum offload
Date: Thu, 18 Feb 2016 16:31:12 -0800
Message-ID: <1455841881-128892-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36360 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965678AbcBSAbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:34 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch adds support for IPv6 extension headers in setting up the Tx
checksum.  Without this patch extension headers would cause IPv6 traffic to
fail as the transport protocol could not be identified.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 14 +++++++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 14 +++++++++++++-
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1404cae..e49fe8f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2402,7 +2402,9 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		struct udphdr *udp;
 		unsigned char *hdr;
 	} l4;
+	unsigned char *exthdr;
 	u32 l4_tunnel = 0;
+	__be16 frag_off;
 	u8 l4_proto = 0;
 
 	ip.hdr = skb_network_header(skb);
@@ -2419,7 +2421,12 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			l4_proto = ip.v4->protocol;
 		} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
 			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
+
+			exthdr = ip.hdr + sizeof(*ip.v6);
 			l4_proto = ip.v6->nexthdr;
+			if (l4.hdr != exthdr)
+				ipv6_skip_exthdr(skb, exthdr - skb->data,
+						 &l4_proto, &frag_off);
 		}
 
 		/* define outer transport */
@@ -2469,8 +2476,13 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV4;
 		}
 	} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-		l4_proto = ip.v6->nexthdr;
 		*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV6;
+
+		exthdr = ip.hdr + sizeof(*ip.v6);
+		l4_proto = ip.v6->nexthdr;
+		if (l4.hdr != exthdr)
+			ipv6_skip_exthdr(skb, exthdr - skb->data,
+					 &l4_proto, &frag_off);
 	}
 
 	/* Now set the td_offset for IP header length */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 39d5f80..48ec763 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1619,7 +1619,9 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		struct udphdr *udp;
 		unsigned char *hdr;
 	} l4;
+	unsigned char *exthdr;
 	u32 l4_tunnel = 0;
+	__be16 frag_off;
 	u8 l4_proto = 0;
 
 	ip.hdr = skb_network_header(skb);
@@ -1636,7 +1638,12 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			l4_proto = ip.v4->protocol;
 		} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
 			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
+
+			exthdr = ip.hdr + sizeof(*ip.v6);
 			l4_proto = ip.v6->nexthdr;
+			if (l4.hdr != exthdr)
+				ipv6_skip_exthdr(skb, exthdr - skb->data,
+						 &l4_proto, &frag_off);
 		}
 
 		/* define outer transport */
@@ -1686,8 +1693,13 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV4;
 		}
 	} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-		l4_proto = ip.v6->nexthdr;
 		*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV6;
+
+		exthdr = ip.hdr + sizeof(*ip.v6);
+		l4_proto = ip.v6->nexthdr;
+		if (l4.hdr != exthdr)
+			ipv6_skip_exthdr(skb, exthdr - skb->data,
+					 &l4_proto, &frag_off);
 	}
 
 	/* Now set the td_offset for IP header length */
-- 
2.5.0
