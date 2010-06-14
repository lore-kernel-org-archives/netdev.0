From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: avoid two atomics in ipv6_rthdr_rcv()
Date: Mon, 14 Jun 2010 16:39:27 +0200
Message-ID: <1276526367.2478.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:58902 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512Ab0FNOjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 10:39:31 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1176391fga.1
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 07:39:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use __in6_dev_get() instead of in6_dev_get()/in6_dev_put()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/exthdrs.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 853a633..262f105 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -312,6 +312,7 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
   Routing header.
  ********************************/
 
+/* called with rcu_read_lock() */
 static int ipv6_rthdr_rcv(struct sk_buff *skb)
 {
 	struct inet6_skb_parm *opt = IP6CB(skb);
@@ -324,12 +325,9 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	int accept_source_route = net->ipv6.devconf_all->accept_source_route;
 
-	idev = in6_dev_get(skb->dev);
-	if (idev) {
-		if (accept_source_route > idev->cnf.accept_source_route)
-			accept_source_route = idev->cnf.accept_source_route;
-		in6_dev_put(idev);
-	}
+	idev = __in6_dev_get(skb->dev);
+	if (idev && accept_source_route > idev->cnf.accept_source_route)
+		accept_source_route = idev->cnf.accept_source_route;
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +


