From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 7/8] qeth: repair SBAL elements calculation
Date: Fri, 11 Dec 2015 12:27:56 +0100
Message-ID: <1449833277-69012-8-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1449833277-69012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:45303 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036AbbLKL2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 06:28:07 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 11 Dec 2015 11:28:05 -0000
In-Reply-To: <1449833277-69012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending skbs, qeth determines the number of qdio SBAL elements
required. If qeth sends a fragmented skb, the SBAL element number
calculation is wrong, because the fragmented data part is added
twice in qeth_l3_tso_elements(). This patch makes sure fragmented
data is handled in qeth_elements_for_frags() only, while
qeth_l3_tso_elements() starts calculation of qdio SBAL elements just
with the linear data part of the skb.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 10d9d3e..7c8c68c 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2797,7 +2797,7 @@ static inline int qeth_l3_tso_elements(struct sk_buff *skb)
 {
 	unsigned long tcpd = (unsigned long)tcp_hdr(skb) +
 		tcp_hdr(skb)->doff * 4;
-	int tcpd_len = skb->len - (tcpd - (unsigned long)skb->data);
+	int tcpd_len = skb_headlen(skb) - (tcpd - (unsigned long)skb->data);
 	int elements = PFN_UP(tcpd + tcpd_len - 1) - PFN_DOWN(tcpd);
 
 	elements += qeth_get_elements_for_frags(skb);
-- 
2.3.9
