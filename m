From: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Subject: [PATCH net,v2] ipv4: use new_gw for redirect neigh lookup
Date: Thu, 10 Nov 2016 11:16:15 -0500
Message-ID: <1478794575-28748-1-git-send-email-ssurya@ieee.org>
Cc: Stephen Suryaputra Lin <ssurya@ieee.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34893 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934058AbcKJQQZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 11:16:25 -0500
Received: by mail-qt0-f195.google.com with SMTP id m48so10532621qta.2
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 08:16:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In v2.6, ip_rt_redirect() calls arp_bind_neighbour() which returns 0
and then the state of the neigh for the new_gw is checked. If the state
isn't valid then the redirected route is deleted. This behavior is
maintained up to v3.5.7 by check_peer_redirect() because rt->rt_gateway
is assigned to peer->redirect_learned.a4 before calling
ipv4_neigh_lookup().

After commit 5943634fc559 ("ipv4: Maintain redirect and PMTU info in
struct rtable again."), ipv4_neigh_lookup() is performed without the
rt_gateway assigned to the new_gw. In the case when rt_gateway (old_gw)
isn't zero, the function uses it as the key. The neigh is most likely
valid since the old_gw is the one that sends the ICMP redirect message.
Then the new_gw is assigned to fib_nh_exception. The problem is: the
new_gw ARP may never gets resolved and the traffic is blackholed.

So, use the new_gw for neigh lookup.

Changes from v1:
 - use __ipv4_neigh_lookup instead (per Eric Dumazet).

Fixes: 5943634fc559 ("ipv4: Maintain redirect and PMTU info in struct rtable again.")
Signed-off-by: Stephen Suryaputra Lin <ssurya@ieee.org>
---
 net/ipv4/route.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 62d4d90c1389..2a57566e6e91 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -753,7 +753,9 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 			goto reject_redirect;
 	}
 
-	n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
+	n = __ipv4_neigh_lookup(rt->dst.dev, new_gw);
+	if (!n)
+		n = neigh_create(&arp_tbl, &new_gw, rt->dst.dev);
 	if (!IS_ERR(n)) {
 		if (!(n->nud_state & NUD_VALID)) {
 			neigh_event_send(n, NULL);
-- 
2.7.4
