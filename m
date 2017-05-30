From: Flavio Leitner <fbl@sysclose.org>
Subject: [PATCH net-next] netlink: include netnsid only when netns differs.
Date: Tue, 30 May 2017 18:33:25 -0300
Message-ID: <20170530213325.21652-1-fbl@sysclose.org>
Cc: Flavio Leitner <fbl@sysclose.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o51.zoho.com ([135.84.80.216]:21136 "EHLO
        sender-of-o51.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdE3VtD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 17:49:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't include netns id for notifications broadcasts when the
socket and the skb are in the same netns because it will be
an error which can't be distinguished from a peer netns failing
to allocate an id.

Signed-off-by: Flavio Leitner <fbl@sysclose.org>
---
 net/netlink/af_netlink.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ee841f0..b9f1392 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1414,8 +1414,10 @@ static void do_one_broadcast(struct sock *sk,
 		p->skb2 = NULL;
 		goto out;
 	}
-	NETLINK_CB(p->skb2).nsid = peernet2id(sock_net(sk), p->net);
-	NETLINK_CB(p->skb2).nsid_is_set = true;
+	if (!net_eq(sock_net(sk), p->net)) {
+		NETLINK_CB(p->skb2).nsid = peernet2id(sock_net(sk), p->net);
+		NETLINK_CB(p->skb2).nsid_is_set = true;
+	}
 	val = netlink_broadcast_deliver(sk, p->skb2);
 	if (val < 0) {
 		netlink_overrun(sk);
-- 
2.9.4
