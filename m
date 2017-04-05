From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 6/7] s390/ctcm: improve endianness handling
Date: Wed,  5 Apr 2017 10:40:14 +0200
Message-ID: <20170405084015.35772-7-ubraun@linux.vnet.ibm.com>
References: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39405 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754608AbdDEIkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 04:40:36 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v358d800131652
        for <netdev@vger.kernel.org>; Wed, 5 Apr 2017 04:40:35 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29mvr41cxr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 04:40:35 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 5 Apr 2017 09:40:33 +0100
In-Reply-To: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

Use endianness conversions for SKB protocol assignments and usage to
avoid endianness warnings reported by sparse. No functional changes.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/ctcm_fsms.c |  2 +-
 drivers/s390/net/ctcm_main.c | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/s390/net/ctcm_fsms.c b/drivers/s390/net/ctcm_fsms.c
index fd5944b..730d961 100644
--- a/drivers/s390/net/ctcm_fsms.c
+++ b/drivers/s390/net/ctcm_fsms.c
@@ -1283,7 +1283,7 @@ static void ctcmpc_chx_txdone(fsm_instance *fi, int event, void *arg)
 		p_header = (struct pdu *)
 			(skb_tail_pointer(ch->trans_skb) - skb->len);
 		p_header->pdu_flag = 0x00;
-		if (skb->protocol == ntohs(ETH_P_SNAP))
+		if (be16_to_cpu(skb->protocol) == ETH_P_SNAP)
 			p_header->pdu_flag |= 0x60;
 		else
 			p_header->pdu_flag |= 0x20;
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index ac65f12..198842c 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -106,7 +106,7 @@ void ctcm_unpack_skb(struct channel *ch, struct sk_buff *pskb)
 			priv->stats.rx_frame_errors++;
 			return;
 		}
-		pskb->protocol = ntohs(header->type);
+		pskb->protocol = cpu_to_be16(header->type);
 		if ((header->length <= LL_HEADER_LENGTH) ||
 		    (len <= LL_HEADER_LENGTH)) {
 			if (!(ch->logflags & LOG_FLAG_ILLEGALSIZE)) {
@@ -125,7 +125,7 @@ void ctcm_unpack_skb(struct channel *ch, struct sk_buff *pskb)
 		header->length -= LL_HEADER_LENGTH;
 		len -= LL_HEADER_LENGTH;
 		if ((header->length > skb_tailroom(pskb)) ||
-			(header->length > len)) {
+		    (header->length > len)) {
 			if (!(ch->logflags & LOG_FLAG_OVERRUN)) {
 				CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
 					"%s(%s): Packet size %d (overrun)"
@@ -485,7 +485,7 @@ static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
 		} else {
 			atomic_inc(&skb->users);
 			header.length = l;
-			header.type = skb->protocol;
+			header.type = be16_to_cpu(skb->protocol);
 			header.unused = 0;
 			memcpy(skb_push(skb, LL_HEADER_LENGTH), &header,
 			       LL_HEADER_LENGTH);
@@ -503,7 +503,7 @@ static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
 	atomic_inc(&skb->users);
 	ch->prof.txlen += skb->len;
 	header.length = skb->len + LL_HEADER_LENGTH;
-	header.type = skb->protocol;
+	header.type = be16_to_cpu(skb->protocol);
 	header.unused = 0;
 	memcpy(skb_push(skb, LL_HEADER_LENGTH), &header, LL_HEADER_LENGTH);
 	block_len = skb->len + 2;
@@ -690,7 +690,7 @@ static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
 		p_header->pdu_offset = skb->len;
 		p_header->pdu_proto = 0x01;
 		p_header->pdu_flag = 0x00;
-		if (skb->protocol == ntohs(ETH_P_SNAP)) {
+		if (be16_to_cpu(skb->protocol) == ETH_P_SNAP) {
 			p_header->pdu_flag |= PDU_FIRST | PDU_CNTL;
 		} else {
 			p_header->pdu_flag |= PDU_FIRST;
@@ -745,7 +745,7 @@ static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
 	p_header->pdu_proto = 0x01;
 	p_header->pdu_flag = 0x00;
 	p_header->pdu_seq = 0;
-	if (skb->protocol == ntohs(ETH_P_SNAP)) {
+	if (be16_to_cpu(skb->protocol) == ETH_P_SNAP) {
 		p_header->pdu_flag |= PDU_FIRST | PDU_CNTL;
 	} else {
 		p_header->pdu_flag |= PDU_FIRST;
-- 
2.10.2
