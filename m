From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] sunvnet: Initialize network_header and
 transport_header in vnet_rx_one()
Date: Mon, 18 Jan 2016 16:12:09 -0500
Message-ID: <20160118211209.GB12034@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rashmi.narasimhan@oracle.com, david.stevens@oracle.com,
	davem@davemloft.net
To: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23737 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756529AbcARVMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 16:12:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vnet_fullcsum() accesses ip_hdr() and transport header to compute
the checksum for IPv4 packets, so these need to be initialized in
skb created in vnet_rx_one().

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index cc106d8..23fa298 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -389,17 +389,27 @@ static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 	if (vio_version_after_eq(&port->vio, 1, 8)) {
 		struct vio_net_dext *dext = vio_net_ext(desc);
 
+		skb_reset_network_header(skb);
+
 		if (dext->flags & VNET_PKT_HCK_IPV4_HDRCKSUM) {
 			if (skb->protocol == ETH_P_IP) {
-				struct iphdr *iph = (struct iphdr *)skb->data;
+				struct iphdr *iph = ip_hdr(skb);
 
 				iph->check = 0;
 				ip_send_check(iph);
 			}
 		}
 		if ((dext->flags & VNET_PKT_HCK_FULLCKSUM) &&
-		    skb->ip_summed == CHECKSUM_NONE)
-			vnet_fullcsum(skb);
+		    skb->ip_summed == CHECKSUM_NONE) {
+			if (skb->protocol == htons(ETH_P_IP)) {
+				struct iphdr *iph = ip_hdr(skb);
+				int ihl = iph->ihl * 4;
+
+				skb_reset_transport_header(skb);
+				skb_set_transport_header(skb, ihl);
+				vnet_fullcsum(skb);
+			}
+		}
 		if (dext->flags & VNET_PKT_HCK_IPV4_HDRCKSUM_OK) {
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_level = 0;
-- 
1.7.1
