From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH net] af_iucv: wrong mapping of sent and confirmed skbs
Date: Mon, 12 May 2014 13:01:39 +0200
Message-ID: <20140512110139.GA38070@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:47187 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbaELLBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 07:01:44 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Mon, 12 May 2014 12:01:43 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

When sending data through IUCV a MESSAGE COMPLETE interrupt
signals that sent data memory can be freed or reused again.
With commit f9c41a62bba3f3f7ef3541b2a025e3371bcbba97 the
MESSAGE COMPLETE callback iucv_callback_txdone() identifies
the wrong skb as being confirmed, which leads to data corruption.
This patch fixes the skb mapping logic in iucv_callback_txdone().

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Cc: <stable@vger.kernel.org>
---
 net/iucv/af_iucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1830,7 +1830,7 @@ static void iucv_callback_txdone(struct
 		spin_lock_irqsave(&list->lock, flags);
 
 		while (list_skb != (struct sk_buff *)list) {
-			if (msg->tag != IUCV_SKB_CB(list_skb)->tag) {
+			if (msg->tag == IUCV_SKB_CB(list_skb)->tag) {
 				this = list_skb;
 				break;
 			}
