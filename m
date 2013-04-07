From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH v2] ipv6/tcp: Stop processing ICMPv6 redirect messages
Date: Sun,  7 Apr 2013 16:53:15 +0200
Message-ID: <1365346395-18016-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, djduanjiong@gmail.com,
	steffen.klassert@secunet.com, Neal Cardwell <ncardwell@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:42759 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933839Ab3DGOx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 10:53:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetja Rediske found that if the host receives an ICMPv6 redirect message
after sending a SYN+ACK, the connection will be reset.

He bisected it down to 093d04d (ipv6: Change skb->data before using
icmpv6_notify() to propagate redirect), but the origin of the bug comes
from ec18d9a26 (ipv6: Add redirect support to all protocol icmp error
handlers.). The bug simply did not trigger prior to 093d04d, because
skb->data did not point to the inner IP header and thus icmpv6_notify
did not call the correct err_handler.

This patch adds the missing "goto out;" in tcp_v6_err. After receiving
an ICMPv6 Redirect, we should not continue processing the ICMP in
tcp_v6_err, as this may trigger the removal of request-socks or setting
sk_err(_soft).

Reported-by: Tetja Rediske <tetja@tetja.de>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
v2: Removed code-cleanup from the patch and improved the commit-message upon 
suggestion from Eric Dumazet.

 net/ipv6/tcp_ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1033d2b..e51bd1a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -386,6 +386,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		if (dst)
 			dst->ops->redirect(dst, sk, skb);
+		goto out;
 	}
 
 	if (type == ICMPV6_PKT_TOOBIG) {
-- 
1.8.1.227.g44fe835
