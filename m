From: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Subject: [PATCH net,v2] Fixes: 5943634fc559 ("ipv4: Maintain redirect and PMTU info in struct rtable again.")
Date: Mon,  7 Nov 2016 17:48:39 -0500
Message-ID: <1478558919-12014-1-git-send-email-ssurya@ieee.org>
Cc: Stephen Suryaputra Lin <ssurya@ieee.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34880 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcKGWtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 17:49:06 -0500
Received: by mail-qk0-f196.google.com with SMTP id n204so12879405qke.2
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 14:49:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP redirects behavior is different after the commit above. An email
requesting the explanation on why the behavior needs to be different
was sent earlier to netdev (https://patchwork.ozlabs.org/patch/687728/).
Since there isn't a reply yet, I decided to prepare this formal patch.

In v2.6 kernel, it used to be that ip_rt_redirect() calls
arp_bind_neighbour() which returns 0 and then the state of the neigh for
the new_gw is checked. If the state isn't valid then the redirected
route is deleted. This behavior is maintained up to v3.5.7 by
check_peer_redirect() because rt->rt_gateway is assigned to
peer->redirect_learned.a4 before calling ipv4_neigh_lookup().

After the commit, ipv4_neigh_lookup() is performed without the
rt_gateway assigned to the new_gw. In the case when rt_gateway (old_gw)
isn't zero, the function uses it as the key. The neigh is most likely valid
since the old_gw is the one that sends the ICMP redirect message. Then the
new_gw is assigned to fib_nh_exception. The problem is: the new_gw ARP may
never gets resolved and the traffic is blackholed.

Changes from v1:
 - use __ipv4_neigh_lookup instead (per Eric Dumazet).

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
