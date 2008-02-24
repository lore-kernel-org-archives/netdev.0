From: Jim Westfall <jwestfall@surrealistic.net>
Subject: [PATCH] llc: fix skb size for test responses
Date: Sun, 24 Feb 2008 11:07:58 -0800
Message-ID: <20080224190758.GW84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from snapper.surrealistic.net ([67.40.222.186]:54713 "EHLO
	snapper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbYBXTIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 14:08:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

The llc test command is used for a layer2 ping and contains a variable 
length payload that we must include in the response.  Use the size of the 
received skb as the size of the skb we must allocate to hold the payload. 

This resolved an skb_over_panic(), when trying to copy the payload into 
what was a hard coded skb of size 128.

Signed-off-by: Jim Westfall <jwestfall@surrealistic.net>

diff -urp linux-2.6.24.2.org/net/llc/llc_s_ac.c linux-2.6.24.2/net/llc/llc_s_ac.c
--- linux-2.6.24.2.org/net/llc/llc_s_ac.c	2008-02-10 21:51:11.000000000 -0800
+++ linux-2.6.24.2/net/llc/llc_s_ac.c	2008-02-24 10:15:02.000000000 -0800
@@ -148,9 +148,18 @@ int llc_sap_action_send_test_r(struct ll
 	llc_pdu_decode_sa(skb, mac_da);
 	llc_pdu_decode_da(skb, mac_sa);
 	llc_pdu_decode_ssap(skb, &dsap);
-	nskb = llc_alloc_frame(NULL, skb->dev);
+	nskb = alloc_skb(skb->end - skb->head, GFP_ATOMIC);
+
 	if (!nskb)
 		goto out;
+
+	skb_reset_mac_header(nskb);
+	skb_reserve(nskb, 50);
+	skb_reset_network_header(nskb);
+	skb_reset_transport_header(nskb);
+	nskb->protocol = htons(ETH_P_802_2);
+	nskb->dev = skb->dev;
+
 	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, sap->laddr.lsap, dsap,
 			    LLC_PDU_RSP);
 	llc_pdu_init_as_test_rsp(nskb, skb);
diff -urp linux-2.6.24.2.org/net/llc/llc_station.c linux-2.6.24.2/net/llc/llc_station.c
--- linux-2.6.24.2.org/net/llc/llc_station.c	2008-02-10 21:51:11.000000000 -0800
+++ linux-2.6.24.2/net/llc/llc_station.c	2008-02-24 10:10:01.000000000 -0800
@@ -298,10 +298,18 @@ static int llc_station_ac_send_test_r(st
 {
 	u8 mac_da[ETH_ALEN], dsap;
 	int rc = 1;
-	struct sk_buff *nskb = llc_alloc_frame(NULL, skb->dev);
+	struct sk_buff *nskb = alloc_skb(skb->end - skb->head, GFP_ATOMIC);
 
 	if (!nskb)
 		goto out;
+
+	skb_reset_mac_header(nskb);
+	skb_reserve(nskb, 50);
+	skb_reset_network_header(nskb);
+	skb_reset_transport_header(nskb);
+	nskb->protocol = htons(ETH_P_802_2);
+	nskb->dev = skb->dev;
+
 	rc = 0;
 	llc_pdu_decode_sa(skb, mac_da);
 	llc_pdu_decode_ssap(skb, &dsap);

