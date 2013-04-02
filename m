From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] af_iucv: recvmsg: use correct skb_pull() function
Date: Tue, 02 Apr 2013 12:56:51 +0200
Message-ID: <20130402105707.116460653@de.ibm.com>
References: <20130402105650.056630101@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:38710 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760918Ab3DBK5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 06:57:12 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 2 Apr 2013 11:55:44 +0100
Content-Disposition: inline; filename=601-af-iucv-skb-pull.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

When receiving data messages, the "BUG_ON(skb->len < skb->data_len)" in
the skb_pull() function triggers a kernel panic.

Check if the skb uses paged data (is non-linear) and use the pskb_pull()
function.  Use skb_pull() for linear skbs' only.

Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1382,7 +1382,10 @@ static int iucv_sock_recvmsg(struct kioc
 
 		/* SOCK_STREAM: re-queue skb if it contains unreceived data */
 		if (sk->sk_type == SOCK_STREAM) {
-			skb_pull(skb, copied);
+			if (skb_is_nonlinear(skb))
+				pskb_pull(skb, copied);
+			else
+				skb_pull(skb, copied);
 			if (skb->len) {
 				skb_queue_head(&sk->sk_receive_queue, skb);
 				goto done;
