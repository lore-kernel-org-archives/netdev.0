From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 4/5] ibmveth: Add support for Large Receive Offload
Date: Tue, 14 Apr 2015 15:35:03 -0500
Message-ID: <1429043704-22552-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org,
	Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:42041 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754570AbbDNUfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 16:35:13 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Tue, 14 Apr 2015 14:35:12 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id AB17C1FF0028
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:26:19 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3EKZ8DM31260726
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 13:35:08 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3EKZ83Z014651
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:35:08 -0600
In-Reply-To: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enables receiving large packets from other LPARs. These packets
have a -1 IP header checksum, so we must recalculate to have
a valid checksum.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 08970c7..05eaca6a 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1092,6 +1092,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 	struct net_device *netdev = adapter->netdev;
 	int frames_processed = 0;
 	unsigned long lpar_rc;
+	struct iphdr *iph;
 
 restart_poll:
 	while (frames_processed < budget) {
@@ -1134,8 +1135,20 @@ restart_poll:
 			skb_put(skb, length);
 			skb->protocol = eth_type_trans(skb, netdev);
 
-			if (csum_good)
+			if (csum_good) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				if (be16_to_cpu(skb->protocol) == ETH_P_IP) {
+					skb_set_network_header(skb, 0);
+					skb_set_transport_header(skb, sizeof(struct iphdr));
+					iph = ip_hdr(skb);
+
+					/* If the IP checksum is not offloaded and if the packet
+					 *  is large send, the checksum must be rebuilt.
+					 */
+					if (iph->check == 0xffff)
+						iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+				}
+			}
 
 			napi_gro_receive(napi, skb);	/* send it up */
 
-- 
1.8.3.1
