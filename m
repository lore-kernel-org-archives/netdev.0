From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net] bnx2x: fix TCP offload for tunneling ipv4 over ipv6
Date: Mon, 3 Jun 2013 12:28:41 +0300
Message-ID: <1370251721-24668-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1164 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179Ab3FCJ2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 05:28:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FW was initialized with data from wrong header, this caused TSO packets
have wrong IP csum.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index c80f1d2..37c1495 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3198,11 +3198,11 @@ static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 		rc |= XMIT_CSUM_TCP;
 
 	if (skb_is_gso_v6(skb)) {
-		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
+		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP);
 		if (rc & XMIT_CSUM_ENC)
 			rc |= XMIT_GSO_ENC_V6;
 	} else if (skb_is_gso(skb)) {
-		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
+		rc |= (XMIT_GSO_V4 | XMIT_CSUM_TCP);
 		if (rc & XMIT_CSUM_ENC)
 			rc |= XMIT_GSO_ENC_V4;
 	}
@@ -3489,19 +3489,18 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 {
 	u16 hlen_w = 0;
 	u8 outerip_off, outerip_len = 0;
+
 	/* from outer IP to transport */
 	hlen_w = (skb_inner_transport_header(skb) -
 		  skb_network_header(skb)) >> 1;
 
 	/* transport len */
-	if (xmit_type & XMIT_CSUM_TCP)
-		hlen_w += inner_tcp_hdrlen(skb) >> 1;
-	else
-		hlen_w += sizeof(struct udphdr) >> 1;
+	hlen_w += inner_tcp_hdrlen(skb) >> 1;
 
 	pbd2->fw_ip_hdr_to_payload_w = hlen_w;
 
-	if (xmit_type & XMIT_CSUM_ENC_V4) {
+	/* outer IP header info */
+	if (xmit_type & XMIT_CSUM_V4) {
 		struct iphdr *iph = ip_hdr(skb);
 		pbd2->fw_ip_csum_wo_len_flags_frag =
 			bswab16(csum_fold((~iph->check) -
-- 
1.8.1.4
