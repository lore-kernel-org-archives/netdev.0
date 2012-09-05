From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] tcp: fix possible socket refcount problem for ipv6
Date: Wed,  5 Sep 2012 23:53:18 +0300
Message-ID: <1346878398-4782-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39498 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916Ab2IEUuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 16:50:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	commit 144d56e91044181ec0ef67aeca91e9a8b5718348
("tcp: fix possible socket refcount problem") is missing
the IPv6 part. As tcp_release_cb is shared by both protocols
we should hold sock reference for the TCP_MTU_REDUCED_DEFERRED
bit.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv6/tcp_ipv6.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 09078b9..f3bfb8b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -403,8 +403,9 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		tp->mtu_info = ntohl(info);
 		if (!sock_owned_by_user(sk))
 			tcp_v6_mtu_reduced(sk);
-		else
-			set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags);
+		else if (!test_and_set_bit(TCP_MTU_REDUCED_DEFERRED,
+					   &tp->tsq_flags))
+			sock_hold(sk);
 		goto out;
 	}
 
-- 
1.7.3.4
