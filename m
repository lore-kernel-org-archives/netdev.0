From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/5] bnx2x: prevent GRO false checksum claims
Date: Wed, 24 Apr 2013 14:44:58 +0300
Message-ID: <1366803902-17870-2-git-send-email-yuvalmin@broadcom.com>
References: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1103 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab3DXMqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 08:46:24 -0400
In-Reply-To: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a more robust error handling flow in case of incorrect
behaviour by the FW when passing on GRO aggregations.

Although this should never happen (i.e., this is merely a theoretical fix),
if the bnx2x driver was to receive a GRO from FW with protocol other than
IPv4/IPv6, the driver would falsely claim to have performed partial
checksum and set various incorrect fields in the skb header.

Current behaviour of the bnx2x driver (i.e., print an error) is insufficient.
This patch remedies this by simply preventing the false claims.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index d72bd8c..5a815ce 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -642,6 +642,14 @@ static void bnx2x_gro_ipv6_csum(struct bnx2x *bp, struct sk_buff *skb)
 	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
 				  &iph->saddr, &iph->daddr, 0);
 }
+
+static void bnx2x_gro_csum(struct bnx2x *bp, struct sk_buff *skb,
+			    void (*gro_func)(struct bnx2x*, struct sk_buff*))
+{
+	skb_set_network_header(skb, 0);
+	gro_func(bp, skb);
+	tcp_gro_complete(skb);
+}
 #endif
 
 static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
@@ -649,19 +657,17 @@ static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 {
 #ifdef CONFIG_INET
 	if (skb_shinfo(skb)->gso_size) {
-		skb_set_network_header(skb, 0);
 		switch (be16_to_cpu(skb->protocol)) {
 		case ETH_P_IP:
-			bnx2x_gro_ip_csum(bp, skb);
+			bnx2x_gro_csum(bp, skb, bnx2x_gro_ip_csum);
 			break;
 		case ETH_P_IPV6:
-			bnx2x_gro_ipv6_csum(bp, skb);
+			bnx2x_gro_csum(bp, skb, bnx2x_gro_ipv6_csum);
 			break;
 		default:
-			BNX2X_ERR("FW GRO supports only IPv4/IPv6, not 0x%04x\n",
+			BNX2X_ERR("Error: FW GRO supports only IPv4/IPv6, not 0x%04x\n",
 				  be16_to_cpu(skb->protocol));
 		}
-		tcp_gro_complete(skb);
 	}
 #endif
 	napi_gro_receive(&fp->napi, skb);
-- 
1.8.1.227.g44fe835
