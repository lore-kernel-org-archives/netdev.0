From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: [PATCH 1/4] pch_gbe: Fix the checksum fill to the error location
Date: Mon, 16 Jul 2012 13:03:14 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:59302 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870Ab2GPUDT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 16:03:19 -0400
Received: from ka-exchange-1.kontronamerica.local ([10.100.2.39]) by mail.us.kontron.com with ESMTP id Gd3dqCOenDxeoWjU for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 13:03:18 -0700 (PDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Author: Zhong Hongbo <hongbo.zhong@windriver.com>

Due to some unknown hardware limitations the pch_gbe hardware cannot
calculate checksums when the length of network package is less
than 64 bytes, where we will surprisingly encounter a problem of
the destination IP incorrectly changed.

When forwarding network packages at the network layer the IP packages
won't be relayed to the upper transport layer and analyzed there,
consequently, skb->transport_header pointer will be mistakenly remained
the same as that of skb->network_header, resulting in TCP checksum
wrongly
filled into the field of destination IP in IP header.

We can fix this issue by manually calculate the offset of the TCP
checksum
 and update it accordingly.

We would normally use the skb_checksum_start_offset(skb) here, but in
this
case it is sometimes -2 (csum_start=0 - skb_headroom=2 => -2), hence the
manual calculation.

Signed-off-by: Zhong Hongbo <hongbo.zhong@windriver.com>
Merged-by: Andy Cress <andy.cress@us.kontron.com>

---
 drivers/net/pch_gbe/pch_gbe_main.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3787c64..1642bff 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1178,32 +1178,35 @@ static void pch_gbe_tx_queue(struct
pch_gbe_adapter *adapter,
 	/*
 	 * It is because the hardware accelerator does not support a
checksum,
 	 * when the received data size is less than 64 bytes.
+	 * Note: skb_checksum_start_offset(skb) is sometimes -2 here.
 	 */
 	if (skb->len < PCH_GBE_SHORT_PKT && skb->ip_summed !=
CHECKSUM_NONE) {
+		struct iphdr *iph = ip_hdr(skb);
 		frame_ctrl |= PCH_GBE_TXD_CTRL_APAD |
 			      PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
 		if (skb->protocol == htons(ETH_P_IP)) {
-			struct iphdr *iph = ip_hdr(skb);
 			unsigned int offset;
-			offset = skb_transport_offset(skb);
+			offset = (unsigned char *)((u8 *)iph + iph->ihl
* 4) - skb->data;
 			if (iph->protocol == IPPROTO_TCP) {
+				struct tcphdr *tcphdr_point = (struct
tcphdr *)((u8 *)iph + iph->ihl * 4);
 				skb->csum = 0;
-				tcp_hdr(skb)->check = 0;
+				tcphdr_point->check = 0;
 				skb->csum = skb_checksum(skb, offset,
 							 skb->len -
offset, 0);
-				tcp_hdr(skb)->check =
+				tcphdr_point->check = 
 					csum_tcpudp_magic(iph->saddr,
 							  iph->daddr,
 							  skb->len -
offset,
 							  IPPROTO_TCP,
 							  skb->csum);
 			} else if (iph->protocol == IPPROTO_UDP) {
+				struct udphdr *udphdr_point = (struct
udphdr *)((u8 *)iph + iph->ihl * 4);
 				skb->csum = 0;
-				udp_hdr(skb)->check = 0;
+				udphdr_point->check = 0;
 				skb->csum =
 					skb_checksum(skb, offset,
 						     skb->len - offset,
0);
-				udp_hdr(skb)->check =
+				udphdr_point->check = 
 					csum_tcpudp_magic(iph->saddr,
 							  iph->daddr,
 							  skb->len -
offset,
