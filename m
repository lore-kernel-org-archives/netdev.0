From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] ipv6: Add an error handler for icmp6
Date: Thu, 17 Jan 2013 09:09:49 +0100
Message-ID: <20130117080949.GA24987@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Duan Jiong <djduanjiong@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54751 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759234Ab3AQIJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 03:09:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pmtu and redirect events are now handled in the protocols error handler,
so add an error handler for icmp6 to do this. It is needed in the case
when we have no socket context. Based on a patch by Duan Jiong.

Reported-by: Duan Jiong <djduanjiong@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/icmp.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index b4a9fd5..fff5bdd 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -81,10 +81,22 @@ static inline struct sock *icmpv6_sk(struct net *net)
 	return net->ipv6.icmp_sk[smp_processor_id()];
 }
 
+static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+		       u8 type, u8 code, int offset, __be32 info)
+{
+	struct net *net = dev_net(skb->dev);
+
+	if (type == ICMPV6_PKT_TOOBIG)
+		ip6_update_pmtu(skb, net, info, 0, 0);
+	else if (type == NDISC_REDIRECT)
+		ip6_redirect(skb, net, 0, 0);
+}
+
 static int icmpv6_rcv(struct sk_buff *skb);
 
 static const struct inet6_protocol icmpv6_protocol = {
 	.handler	=	icmpv6_rcv,
+	.err_handler	=	icmpv6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-- 
1.7.9.5
