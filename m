From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 3/9] cxgb4: fix TSO descriptors
Date: Mon,  2 Aug 2010 16:19:18 -0700
Message-ID: <1280791164-14181-4-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
 <1280791164-14181-2-git-send-email-dm@chelsio.com>
 <1280791164-14181-3-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10728 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761Ab0HBXTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:25 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJPeU025626
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:25 -0700
In-Reply-To: <1280791164-14181-3-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1704d74894912b8ecc3e95cecd7bde336a0b1bf2 ("cxgb4vf: small changes
to message processing structures/macros") was incomplete and causes cxgb4
to write bad TSO descriptors.  Fix that up by reverting the offending part
of that commit and adjusting field accesses now that they are one level
deeper.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/sge.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 304302a..5cacfc7 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -931,23 +931,23 @@ out_free:	dev_kfree_skb(skb);
 
 	ssi = skb_shinfo(skb);
 	if (ssi->gso_size) {
-		struct cpl_tx_pkt_lso_core *lso = (void *)(wr + 1);
+		struct cpl_tx_pkt_lso *lso = (void *)wr;
 		bool v6 = (ssi->gso_type & SKB_GSO_TCPV6) != 0;
 		int l3hdr_len = skb_network_header_len(skb);
 		int eth_xtra_len = skb_network_offset(skb) - ETH_HLEN;
 
 		wr->op_immdlen = htonl(FW_WR_OP(FW_ETH_TX_PKT_WR) |
 				       FW_WR_IMMDLEN(sizeof(*lso)));
-		lso->lso_ctrl = htonl(LSO_OPCODE(CPL_TX_PKT_LSO) |
-				      LSO_FIRST_SLICE | LSO_LAST_SLICE |
-				      LSO_IPV6(v6) |
-				      LSO_ETHHDR_LEN(eth_xtra_len / 4) |
-				      LSO_IPHDR_LEN(l3hdr_len / 4) |
-				      LSO_TCPHDR_LEN(tcp_hdr(skb)->doff));
-		lso->ipid_ofst = htons(0);
-		lso->mss = htons(ssi->gso_size);
-		lso->seqno_offset = htonl(0);
-		lso->len = htonl(skb->len);
+		lso->c.lso_ctrl = htonl(LSO_OPCODE(CPL_TX_PKT_LSO) |
+					LSO_FIRST_SLICE | LSO_LAST_SLICE |
+					LSO_IPV6(v6) |
+					LSO_ETHHDR_LEN(eth_xtra_len / 4) |
+					LSO_IPHDR_LEN(l3hdr_len / 4) |
+					LSO_TCPHDR_LEN(tcp_hdr(skb)->doff));
+		lso->c.ipid_ofst = htons(0);
+		lso->c.mss = htons(ssi->gso_size);
+		lso->c.seqno_offset = htonl(0);
+		lso->c.len = htonl(skb->len);
 		cpl = (void *)(lso + 1);
 		cntrl = TXPKT_CSUM_TYPE(v6 ? TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
 			TXPKT_IPHDR_LEN(l3hdr_len) |
-- 
1.5.4

