From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH net-next v2 2/5] net: l2tp: only set L2TP_ATTR_UDP_CSUM if AF_INET
Date: Mon,  7 Nov 2016 20:39:25 +0000
Message-ID: <20161107203928.30111-2-asbjorn@asbjorn.st>
References: <20161107203928.30111-1-asbjorn@asbjorn.st>
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:55318 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752163AbcKGVFN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 16:05:13 -0500
In-Reply-To: <20161107203928.30111-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only set L2TP_ATTR_UDP_CSUM in l2tp_nl_tunnel_send()
when it's running over IPv4.

This prepares the code to also have IPv6 specific attributes.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 net/l2tp/l2tp_netlink.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 59aa2d2..2abd100 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -379,9 +379,14 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 
 	switch (tunnel->encap) {
 	case L2TP_ENCAPTYPE_UDP:
+		switch (sk->sk_family) {
+		case AF_INET:
+			if (nla_put_u8(skb, L2TP_ATTR_UDP_CSUM, !sk->sk_no_check_tx))
+				goto nla_put_failure;
+			break;
+		}
 		if (nla_put_u16(skb, L2TP_ATTR_UDP_SPORT, ntohs(inet->inet_sport)) ||
-		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)) ||
-		    nla_put_u8(skb, L2TP_ATTR_UDP_CSUM, !sk->sk_no_check_tx))
+		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)))
 			goto nla_put_failure;
 		/* NOBREAK */
 	case L2TP_ENCAPTYPE_IP:
-- 
2.10.1
