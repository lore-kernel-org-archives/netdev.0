From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/6] xfrm: fix crash in XFRM_MSG_GETSA netlink handler
Date: Thu, 8 Sep 2016 08:29:10 +0200
Message-ID: <1473316155-12186-2-git-send-email-steffen.klassert@secunet.com>
References: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35803 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751981AbcIHG31 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:29:27 -0400
In-Reply-To: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@oracle.com>

If we hit any of the error conditions inside xfrm_dump_sa(), then
xfrm_state_walk_init() never gets called. However, we still call
xfrm_state_walk_done() from xfrm_dump_sa_done(), which will crash
because the state walk was never initialized properly.

We can fix this by setting cb->args[0] only after we've processed the
first element and checking this before calling xfrm_state_walk_done().

Fixes: d3623099d3 ("ipsec: add support of limited SA dump")
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d516845..4fb04ce 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -896,7 +896,8 @@ static int xfrm_dump_sa_done(struct netlink_callback *cb)
 	struct sock *sk = cb->skb->sk;
 	struct net *net = sock_net(sk);
 
-	xfrm_state_walk_done(walk, net);
+	if (cb->args[0])
+		xfrm_state_walk_done(walk, net);
 	return 0;
 }
 
@@ -921,8 +922,6 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 		u8 proto = 0;
 		int err;
 
-		cb->args[0] = 1;
-
 		err = nlmsg_parse(cb->nlh, 0, attrs, XFRMA_MAX,
 				  xfrma_policy);
 		if (err < 0)
@@ -939,6 +938,7 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 			proto = nla_get_u8(attrs[XFRMA_PROTO]);
 
 		xfrm_state_walk_init(walk, proto, filter);
+		cb->args[0] = 1;
 	}
 
 	(void) xfrm_state_walk(net, walk, dump_one_state, &info);
-- 
1.9.1
