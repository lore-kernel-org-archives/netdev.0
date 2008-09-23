From: David Miller <davem@davemloft.net>
Subject: [PATCH]: tcp: Fix queue traversal in tcp_use_frto().
Date: Tue, 23 Sep 2008 02:55:42 -0700 (PDT)
Message-ID: <20080923.025542.193703353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751007AbYIWJzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 05:55:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 14AFEC8C185
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 02:55:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


One more skb_queue_next() BUG trigger.  I double audited the
remaining tcp_write_queue_next() cases and they should all
be good.

tcp: Fix queue traversal in tcp_use_frto().

We must check tcp_skb_is_last() before doing a tcp_write_queue_next().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_input.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cbfe13d..3b76bce 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1746,6 +1746,8 @@ int tcp_use_frto(struct sock *sk)
 		return 0;
 
 	skb = tcp_write_queue_head(sk);
+	if (tcp_skb_is_last(sk, skb))
+		return 1;
 	skb = tcp_write_queue_next(sk, skb);	/* Skips head */
 	tcp_for_write_queue_from(skb, sk) {
 		if (skb == tcp_send_head(sk))
-- 
1.5.6.5

