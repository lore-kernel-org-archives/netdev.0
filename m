From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/3] qla3xxx: cleanup checksum offload code
Date: Wed, 30 May 2007 14:23:18 -0700
Message-ID: <20070530212512.178720251@linux-foundation.org>
References: <20070530212316.407169588@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:50808 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758719AbXE3ViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 17:38:08 -0400
Content-Disposition: inline; filename=qla-csum.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code for checksum is more complex than needed when dealing with VLAN's;
the higher layers already pass down the location of the IP header.

Compile tested only, no hardware available.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/qla3xxx.c |   37 +++++++++++--------------------------
 1 file changed, 11 insertions(+), 26 deletions(-)

--- a/drivers/net/qla3xxx.c	2007-05-30 14:09:25.000000000 -0700
+++ b/drivers/net/qla3xxx.c	2007-05-30 14:09:31.000000000 -0700
@@ -2433,37 +2433,22 @@ static int ql_get_seg_count(struct ql3_a
 	return -1;
 }
 
-static void ql_hw_csum_setup(struct sk_buff *skb,
+static void ql_hw_csum_setup(const struct sk_buff *skb,
 			     struct ob_mac_iocb_req *mac_iocb_ptr)
 {
-	struct ethhdr *eth;
-	struct iphdr *ip = NULL;
-	u8 offset = ETH_HLEN;
-
-	eth = (struct ethhdr *)(skb->data);
-
-	if (eth->h_proto == __constant_htons(ETH_P_IP)) {
-		ip = (struct iphdr *)&skb->data[ETH_HLEN];
-	} else if (eth->h_proto == htons(ETH_P_8021Q) &&
-		   ((struct vlan_ethhdr *)skb->data)->
-		   h_vlan_encapsulated_proto == __constant_htons(ETH_P_IP)) {
-		ip = (struct iphdr *)&skb->data[VLAN_ETH_HLEN];
-		offset = VLAN_ETH_HLEN;
-	}
-
-	if (ip) {
-		if (ip->protocol == IPPROTO_TCP) {
-			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_TC | 
+	const struct iphdr *ip = ip_hdr(skb);
+
+	mac_iocb_ptr->ip_hdr_off = skb_network_offset(skb);
+	mac_iocb_ptr->ip_hdr_len = ip->ihl;
+
+	if (ip->protocol == IPPROTO_TCP) {
+		mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_TC |
 			OB_3032MAC_IOCB_REQ_IC;
-			mac_iocb_ptr->ip_hdr_off = offset;
-			mac_iocb_ptr->ip_hdr_len = ip->ihl;
-		} else if (ip->protocol == IPPROTO_UDP) {
-			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_UC | 
+	} else {
+		mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_UC |
 			OB_3032MAC_IOCB_REQ_IC;
-			mac_iocb_ptr->ip_hdr_off = offset;
-			mac_iocb_ptr->ip_hdr_len = ip->ihl;
-		}
 	}
+
 }
 
 /*

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

