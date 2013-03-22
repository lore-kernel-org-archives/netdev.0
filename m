From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: increase inner ip id during
 encapsulated tso
Date: Fri, 22 Mar 2013 03:38:24 +0200
Message-ID: <1363916305-15690-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Maciej Zenczykowski" <maze@google.com>,
	"Jesse Gross" <jesse@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4146 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773Ab3CVBia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 21:38:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

57712/578xx devices during handling of encapsulated TSO can
properly increase ip id for only one ip header.
The patch selects inner header to be increased.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
CC: Eilon Greenstein <eilong@broadcom.com>
CC: Ariel Elior <ariele@broadcom.com>
CC: Maciej Zenczykowski <maze@google.com>
CC: Jesse Gross <jesse@nicira.com>
---
tested over 1bc277f79
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   22 ++++++++++------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c   |    2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h   |    3 ++-
 4 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 3f5cd7c..352e58e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3464,30 +3464,28 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 				      u16 *global_data,
 				      u32 xmit_type)
 {
-	u16 inner_hlen_w = 0;
+	u16 hlen_w = 0;
 	u8 outerip_off, outerip_len = 0;
-
-	/* IP len */
-	inner_hlen_w = (skb_inner_transport_header(skb) -
-			skb_inner_network_header(skb)) >> 1;
+	/* from outer IP to transport */
+	hlen_w = (skb_inner_transport_header(skb) -
+		  skb_network_header(skb)) >> 1;
 
 	/* transport len */
 	if (xmit_type & XMIT_CSUM_TCP)
-		inner_hlen_w += inner_tcp_hdrlen(skb) >> 1;
+		hlen_w += inner_tcp_hdrlen(skb) >> 1;
 	else
-		inner_hlen_w += sizeof(struct udphdr) >> 1;
+		hlen_w += sizeof(struct udphdr) >> 1;
 
-	pbd2->fw_ip_hdr_to_payload_w = inner_hlen_w;
+	pbd2->fw_ip_hdr_to_payload_w = hlen_w;
 
 	if (xmit_type & XMIT_CSUM_ENC_V4) {
-		struct iphdr *iph = inner_ip_hdr(skb);
-
+		struct iphdr *iph = ip_hdr(skb);
 		pbd2->fw_ip_csum_wo_len_flags_frag =
 			bswab16(csum_fold((~iph->check) -
 					  iph->tot_len - iph->frag_off));
 	} else {
 		pbd2->fw_ip_hdr_to_payload_w =
-			inner_hlen_w - ((sizeof(struct ipv6hdr)) >> 1);
+			hlen_w - ((sizeof(struct ipv6hdr)) >> 1);
 	}
 
 	pbd2->tcp_send_seq = bswab32(inner_tcp_hdr(skb)->seq);
@@ -3495,7 +3493,7 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 	pbd2->tcp_flags = pbd_tcp_flags(inner_tcp_hdr(skb));
 
 	if (xmit_type & XMIT_GSO_V4) {
-		pbd2->hw_ip_id = bswab16(ip_hdr(skb)->id);
+		pbd2->hw_ip_id = bswab16(inner_ip_hdr(skb)->id);
 
 		pbd_e2->data.tunnel_data.pseudo_csum =
 			bswab16(~csum_tcpudp_magic(
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 10b0748..2c6a2a6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2962,6 +2962,7 @@ static unsigned long bnx2x_get_common_flags(struct bnx2x *bp,
 		__set_bit(BNX2X_Q_FLG_ZERO_STATS, &flags);
 
 	__set_bit(BNX2X_Q_FLG_PCSUM_ON_PKT, &flags);
+	__set_bit(BNX2X_Q_FLG_TUN_INC_INNER_IP_ID, &flags);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	__set_bit(BNX2X_Q_FLG_TX_SEC, &flags);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 5bdc1d6..32a9609 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4432,6 +4432,8 @@ static void bnx2x_q_fill_init_tx_data(struct bnx2x_queue_sp_obj *o,
 	tx_data->force_default_pri_flg =
 		test_bit(BNX2X_Q_FLG_FORCE_DEFAULT_PRI, flags);
 
+	tx_data->tunnel_lso_inc_ip_id =
+		test_bit(BNX2X_Q_FLG_TUN_INC_INNER_IP_ID, flags);
 	tx_data->tunnel_non_lso_pcsum_location =
 		test_bit(BNX2X_Q_FLG_PCSUM_ON_PKT, flags) ? PCSUM_ON_PKT :
 								  PCSUM_ON_BD;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 35479da..43c00bc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -828,7 +828,8 @@ enum {
 	BNX2X_Q_FLG_ANTI_SPOOF,
 	BNX2X_Q_FLG_SILENT_VLAN_REM,
 	BNX2X_Q_FLG_FORCE_DEFAULT_PRI,
-	BNX2X_Q_FLG_PCSUM_ON_PKT
+	BNX2X_Q_FLG_PCSUM_ON_PKT,
+	BNX2X_Q_FLG_TUN_INC_INNER_IP_ID
 };
 
 /* Queue type options: queue type may be a compination of below. */
-- 
1.7.7.2
