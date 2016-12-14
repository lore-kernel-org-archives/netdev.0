From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmveth: calculate gso_segs for large packets
Date: Tue, 13 Dec 2016 18:15:09 -0600
Message-ID: <1481674509-14256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: brking@linux.vnet.ibm.com, marcelo.leitner@gmail.com,
        pradeeps@linux.vnet.ibm.com, jmaxwell37@gmail.com, zdai@us.ibm.com,
        eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49556 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752703AbcLNAPR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 19:15:17 -0500
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBE0Dio3003628
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 19:15:14 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27ap1bt5bq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 19:15:14 -0500
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 13 Dec 2016 19:15:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include calculations to compute the number of segments
that comprise an aggregated large packet.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index fbece63..a831f94 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1181,7 +1181,9 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
 
 static void ibmveth_rx_mss_helper(struct sk_buff *skb, u16 mss, int lrg_pkt)
 {
+	struct tcphdr *tcph;
 	int offset = 0;
+	int hdr_len;
 
 	/* only TCP packets will be aggregated */
 	if (skb->protocol == htons(ETH_P_IP)) {
@@ -1208,14 +1210,20 @@ static void ibmveth_rx_mss_helper(struct sk_buff *skb, u16 mss, int lrg_pkt)
 	/* if mss is not set through Large Packet bit/mss in rx buffer,
 	 * expect that the mss will be written to the tcp header checksum.
 	 */
+	tcph = (struct tcphdr *)(skb->data + offset);
 	if (lrg_pkt) {
 		skb_shinfo(skb)->gso_size = mss;
 	} else if (offset) {
-		struct tcphdr *tcph = (struct tcphdr *)(skb->data + offset);
-
 		skb_shinfo(skb)->gso_size = ntohs(tcph->check);
 		tcph->check = 0;
 	}
+
+	if (skb_shinfo(skb)->gso_size) {
+		hdr_len = offset + tcph->doff * 4;
+		skb_shinfo(skb)->gso_segs =
+				DIV_ROUND_UP(skb->len - hdr_len,
+					     skb_shinfo(skb)->gso_size);
+	}
 }
 
 static int ibmveth_poll(struct napi_struct *napi, int budget)
-- 
1.8.3.1
