From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next] net: Use consume_skb() to free gso segmented skb
Date: Mon, 29 Apr 2013 16:02:42 -0700
Message-ID: <1367276562.23068.7.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:47008 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758424Ab3D2XDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 19:03:10 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Mon, 29 Apr 2013 17:03:10 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6920F19D8036
	for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 17:03:00 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3TN2hmf095924
	for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 17:02:47 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3TN5bkP026108
	for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 17:05:37 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use consume_skb() to free the original skb that is successfully transmitted 
as gso segmented skbs so that it is not treated as a drop due to an error.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
---

diff --git a/net/core/dev.c b/net/core/dev.c
index 7c30dce..4040673 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2565,8 +2565,11 @@ gso:
 	} while (skb->next);
 
 out_kfree_gso_skb:
-	if (likely(skb->next == NULL))
+	if (likely(skb->next == NULL)) {
 		skb->destructor = DEV_GSO_CB(skb)->destructor;
+		consume_skb(skb);
+		return rc;
+	}
 out_kfree_skb:
 	kfree_skb(skb);
 out:
