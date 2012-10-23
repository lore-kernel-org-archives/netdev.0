From: Duan Jiong <djduanjiong@gmail.com>
Subject: [PATCH]ipv6: Add an ICMP error handler icmpv6_err
Date: Tue, 23 Oct 2012 23:24:29 +0800
Message-ID: <5086B6AD.8060306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46333 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755495Ab2JWPYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 11:24:34 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so507107pbb.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 08:24:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add an ICMP error handler icmpv6_err to deal with ICMPV6 Error
Messages and Redirect Message, when we do not have a socket
context.

Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
---
 net/ipv6/icmp.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 24d69db..d3cb61d 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -82,9 +82,12 @@ static inline struct sock *icmpv6_sk(struct net *net)
 }
 
 static int icmpv6_rcv(struct sk_buff *skb);
+static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+			u8 type, u8 code, int offset, __be32 info);
 
 static const struct inet6_protocol icmpv6_protocol = {
 	.handler	=	icmpv6_rcv,
+	.err_handler	=	icmpv6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
@@ -782,6 +785,26 @@ drop_no_count:
 	return 0;
 }
 
+static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+			u8 type, u8 code, int offset, __be32 info)
+{
+	struct net *net = dev_net(skb->dev);
+	struct icmp6hdr *hdr = icmp6_hdr(skb);
+
+	switch (hdr->icmp6_type) {
+	case ICMPV6_PKT_TOOBIG:
+		ip6_update_pmtu(skb, net, info, 0, 0);
+		break;
+
+	case NDISC_REDIRECT:
+		ip6_redirect(skb, net, 0, 0);
+		break;
+
+	default:
+		break;
+	}
+}
+
 void icmpv6_flow_init(struct sock *sk, struct flowi6 *fl6,
 		      u8 type,
 		      const struct in6_addr *saddr,
-- 
1.7.11.4
