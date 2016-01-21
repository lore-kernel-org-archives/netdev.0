From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: diag: support v4mapped sockets in
 inet_diag_find_one_icsk()
Date: Wed, 20 Jan 2016 16:25:01 -0800
Message-ID: <1453335901.1223.337.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34965 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbcAUAZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 19:25:02 -0500
Received: by mail-pf0-f182.google.com with SMTP id 65so13084458pff.2
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 16:25:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Lorenzo reported that we could not properly find v4mapped sockets
in inet_diag_find_one_icsk(). This patch fixes the issue.

Reported-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 8bb8e7ad8548..6029157a19ed 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -361,13 +361,20 @@ struct sock *inet_diag_find_one_icsk(struct net *net,
 				 req->id.idiag_dport, req->id.idiag_src[0],
 				 req->id.idiag_sport, req->id.idiag_if);
 #if IS_ENABLED(CONFIG_IPV6)
-	else if (req->sdiag_family == AF_INET6)
-		sk = inet6_lookup(net, hashinfo,
-				  (struct in6_addr *)req->id.idiag_dst,
-				  req->id.idiag_dport,
-				  (struct in6_addr *)req->id.idiag_src,
-				  req->id.idiag_sport,
-				  req->id.idiag_if);
+	else if (req->sdiag_family == AF_INET6) {
+		if (ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_dst) &&
+		    ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_src))
+			sk = inet_lookup(net, hashinfo, req->id.idiag_dst[3],
+					 req->id.idiag_dport, req->id.idiag_src[3],
+					 req->id.idiag_sport, req->id.idiag_if);
+		else
+			sk = inet6_lookup(net, hashinfo,
+					  (struct in6_addr *)req->id.idiag_dst,
+					  req->id.idiag_dport,
+					  (struct in6_addr *)req->id.idiag_src,
+					  req->id.idiag_sport,
+					  req->id.idiag_if);
+	}
 #endif
 	else
 		return ERR_PTR(-EINVAL);
