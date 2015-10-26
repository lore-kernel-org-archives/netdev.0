From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next] bnxt_en: Fix compile warnings when CONFIG_INET is not set.
Date: Sun, 25 Oct 2015 22:27:57 -0400
Message-ID: <1445826477-24881-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:28926 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbbJZC2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 22:28:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnxt_gro_skb() has unused variables when CONFIG_INET is not set.  We
really cannot support hardware GRO if CONFIG_INET is not set, so
compile out bnxt_gro_skb() completely and define BNXT_FLAG_GRO to be 0
if CONFIG_INET is not set.  This will effectively always disable
hardware GRO if CONFIG_INET is not set.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 5 +++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9e36f83..6c2e0c6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -852,6 +852,7 @@ static inline struct sk_buff *bnxt_gro_skb(struct bnxt_tpa_info *tpa_info,
 					   struct rx_tpa_end_cmp_ext *tpa_end1,
 					   struct sk_buff *skb)
 {
+#ifdef CONFIG_INET
 	struct tcphdr *th;
 	int payload_off, tcp_opt_len = 0;
 	int len, nw_off;
@@ -866,7 +867,6 @@ static inline struct sk_buff *bnxt_gro_skb(struct bnxt_tpa_info *tpa_info,
 	if (TPA_END_GRO_TS(tpa_end))
 		tcp_opt_len = 12;
 
-#ifdef CONFIG_INET
 	if (tpa_info->gso_type == SKB_GSO_TCPV4) {
 		struct iphdr *iph;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 5ee3cc2..4f2267c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -855,7 +855,12 @@ struct bnxt {
 	#define BNXT_FLAG_DCB_ENABLED	0x1
 	#define BNXT_FLAG_VF		0x2
 	#define BNXT_FLAG_LRO		0x4
+#ifdef CONFIG_INET
 	#define BNXT_FLAG_GRO		0x8
+#else
+	/* Cannot support hardware GRO if CONFIG_INET is not set */
+	#define BNXT_FLAG_GRO		0x0
+#endif
 	#define BNXT_FLAG_TPA		(BNXT_FLAG_LRO | BNXT_FLAG_GRO)
 	#define BNXT_FLAG_JUMBO		0x10
 	#define BNXT_FLAG_STRIP_VLAN	0x20
-- 
1.8.3.1
