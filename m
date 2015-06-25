From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 9/9] bnx2x: Fix linearization for encapsulated packets
Date: Thu, 25 Jun 2015 15:19:29 +0300
Message-ID: <1435234769-5625-10-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46661 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751964AbbFYMUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:20:21 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to FW constraints, driver must make sure that transmitted SKBs will
not be too fragmented, or in the case that they are - that each 'window'
of fragments passed to the FW would contain at least an mss worth of data.

For encapsultaed packets the calculation is wrong, since it ignores the
inner headers in the calculation of the headers' length.
This could lead to a FW assertion in case of a too-fragmented encapsulated
packet.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ec56a9b..d336356 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3400,8 +3400,13 @@ static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
 			u32 wnd_sum = 0;
 
 			/* Headers length */
-			hlen = (int)(skb_transport_header(skb) - skb->data) +
-				tcp_hdrlen(skb);
+			if (xmit_type & XMIT_GSO_ENC)
+				hlen = (int)(skb_inner_transport_header(skb) -
+					     skb->data) +
+					     inner_tcp_hdrlen(skb);
+			else
+				hlen = (int)(skb_transport_header(skb) -
+					     skb->data) + tcp_hdrlen(skb);
 
 			/* Amount of data (w/o headers) on linear part of SKB*/
 			first_bd_sz = skb_headlen(skb) - hlen;
-- 
1.9.3
