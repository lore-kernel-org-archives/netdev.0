From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 3/3] qede: Fix single MTU sized packet from firmware GRO flow
Date: Mon, 18 Apr 2016 13:06:07 -0400
Message-ID: <1460999167-3746-4-git-send-email-manish.chopra@qlogic.com>
References: <1460999167-3746-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41206 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752680AbcDRRrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 13:47:55 -0400
In-Reply-To: <1460999167-3746-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In firmware assisted GRO flow there could be a single MTU sized
segment arriving due to firmware aggregation timeout/last segment
in an aggregation flow, which is not expected to be an actual gro
packet. So If a skb has zero frags from the GRO flow then simply
push it in the stack as non gso skb.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 8208e1f..197ef85 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1096,6 +1096,17 @@ static void qede_gro_receive(struct qede_dev *edev,
 			     struct sk_buff *skb,
 			     u16 vlan_tag)
 {
+	/* FW can send a single MTU sized packet from gro flow
+	 * due to aggregation timeout/last segment etc. which
+	 * is not expected to be a gro packet. If a skb has zero
+	 * frags then simply push it in the stack as non gso skb.
+	 */
+	if (unlikely(!skb->data_len)) {
+		skb_shinfo(skb)->gso_type = 0;
+		skb_shinfo(skb)->gso_size = 0;
+		goto send_skb;
+	}
+
 #ifdef CONFIG_INET
 	if (skb_shinfo(skb)->gso_size) {
 		skb_set_network_header(skb, 0);
@@ -1114,6 +1125,8 @@ static void qede_gro_receive(struct qede_dev *edev,
 		}
 	}
 #endif
+
+send_skb:
 	skb_record_rx_queue(skb, fp->rss_id);
 	qede_skb_receive(edev, fp, skb, vlan_tag);
 }
-- 
2.7.2
