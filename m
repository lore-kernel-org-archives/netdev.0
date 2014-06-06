From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH] ipip, sit: fix ipv4_{update_pmtu,redirect} calls
Date: Fri, 6 Jun 2014 23:19:21 +0400
Message-ID: <20140606231921.2ff39106ac54216fd9170fae@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:52128 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbaFFTTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 15:19:25 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so1802098lbi.1
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 12:19:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4_{update_pmtu,redirect} were called with tunnel's ifindex (t->dev is a 
tunnel netdevice). It caused wrong route lookup and failure of pmtu update or 
redirect. We should use the same ifindex that we use in ip_route_output_* in 
*tunnel_xmit code. It is t->parms.link .

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 net/ipv4/ipip.c | 4 ++--
 net/ipv6/sit.c  | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 812b183..09680dd 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -149,13 +149,13 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
 		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->dev->ifindex, 0, IPPROTO_IPIP, 0);
+				 t->parms.link, 0, IPPROTO_IPIP, 0);
 		err = 0;
 		goto out;
 	}
 
 	if (type == ICMP_REDIRECT) {
-		ipv4_redirect(skb, dev_net(skb->dev), t->dev->ifindex, 0,
+		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
 			      IPPROTO_IPIP, 0);
 		err = 0;
 		goto out;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e5a453c..45397b2 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -560,12 +560,12 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
 		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->dev->ifindex, 0, IPPROTO_IPV6, 0);
+				 t->parms.link, 0, IPPROTO_IPV6, 0);
 		err = 0;
 		goto out;
 	}
 	if (type == ICMP_REDIRECT) {
-		ipv4_redirect(skb, dev_net(skb->dev), t->dev->ifindex, 0,
+		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
 			      IPPROTO_IPV6, 0);
 		err = 0;
 		goto out;
