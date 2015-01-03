From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 4/4] geneve: Check family when reusing sockets.
Date: Fri,  2 Jan 2015 18:26:05 -0800
Message-ID: <1420251965-44794-5-git-send-email-jesse@nicira.com>
References: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:46574 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752048AbbACC0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 21:26:13 -0500
Received: by mail-qa0-f47.google.com with SMTP id n4so12983230qaq.20
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 18:26:12 -0800 (PST)
In-Reply-To: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When searching for an existing socket to reuse, the address family
is not taken into account - only port number. This means that an
IPv4 socket could be used for IPv6 traffic and vice versa, which
is sure to cause problems when passing packets.

It is not possible to trigger this problem currently because the
only user of Geneve creates just IPv4 sockets. However, that is
likely to change in the near future.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/ipv4/geneve.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 4fe5a59..5b52046 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -65,14 +65,15 @@ static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
 	return (struct genevehdr *)(udp_hdr(skb) + 1);
 }
 
-/* Find geneve socket based on network namespace and UDP port */
-static struct geneve_sock *geneve_find_sock(struct net *net, __be16 port)
+static struct geneve_sock *geneve_find_sock(struct net *net,
+					    sa_family_t family, __be16 port)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 
 	list_for_each_entry(gs, &gn->sock_list, list) {
-		if (inet_sk(gs->sock->sk)->inet_sport == port)
+		if (inet_sk(gs->sock->sk)->inet_sport == port &&
+		    inet_sk(gs->sock->sk)->sk.sk_family == family)
 			return gs;
 	}
 
@@ -375,7 +376,7 @@ struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
 
 	mutex_lock(&geneve_mutex);
 
-	gs = geneve_find_sock(net, port);
+	gs = geneve_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port);
 	if (gs) {
 		if (!no_share && gs->rcv == rcv)
 			gs->refcnt++;
-- 
1.9.1
