From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 12/15] fm10k: Convert to advertise NETIF_F_HW_CSUM
Date: Thu, 19 Nov 2015 11:55:58 -0800
Message-ID: <1447962961-2106059-13-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49500 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161065AbbKST4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:21 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJJswBu016196
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:20 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y8r6vxd7s-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:20 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 9a0ccc9c8ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:19 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_csum_offload_chk is used to resolve checksums that are unable
to be offloaded to the device.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   | 16 ++++++++++++++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  5 ++---
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index e76a44c..3c78ea6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -827,6 +827,17 @@ err_vxlan:
 	return -1;
 }
 
+static const struct skb_csum_offl_spec csum_offl_spec = {
+	.ipv4_okay = 1,
+	.ip_options_okay = 1,
+	.ipv6_okay = 1,
+	.encap_okay = 1,
+	.no_encapped_ipv6 = 1,
+	.vlan_okay = 1,
+	.tcp_okay = 1,
+	.udp_okay = 1,
+};
+
 static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
 			  struct fm10k_tx_buffer *first)
 {
@@ -839,11 +850,12 @@ static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
 	} network_hdr;
 	__be16 protocol;
 	u8 l4_hdr = 0;
+	bool csum_encapped;
 
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
+	if (!skb_csum_offload_chk(skb, &csum_offl_spec, &csum_encapped, true))
 		goto no_csum;
 
-	if (skb->encapsulation) {
+	if (csum_encapped) {
 		protocol = fm10k_tx_encap_offload(skb);
 		if (!protocol) {
 			if (skb_checksum_help(skb)) {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index a340772..b467e2b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1404,8 +1404,7 @@ struct net_device *fm10k_alloc_netdev(void)
 	interface->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
 
 	/* configure default features */
-	dev->features |= NETIF_F_IP_CSUM |
-			 NETIF_F_IPV6_CSUM |
+	dev->features |= NETIF_F_HW_CSUM |
 			 NETIF_F_SG |
 			 NETIF_F_TSO |
 			 NETIF_F_TSO6 |
@@ -1424,7 +1423,7 @@ struct net_device *fm10k_alloc_netdev(void)
 	dev->vlan_features |= dev->features;
 
 	/* configure tunnel offloads */
-	dev->hw_enc_features |= NETIF_F_IP_CSUM |
+	dev->hw_enc_features |= NETIF_F_HW_CSUM |
 				NETIF_F_TSO |
 				NETIF_F_TSO6 |
 				NETIF_F_TSO_ECN |
-- 
2.4.6
