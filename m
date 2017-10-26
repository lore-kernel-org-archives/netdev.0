From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ip6_gre: only increase err_count for some certain type icmpv6 in ip6gre_err
Date: Thu, 26 Oct 2017 19:23:27 +0800
Message-ID: <70a53e892e143549ea989dc286eba117113d6101.1509017007.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
        "xeb@mail.ru" <xeb@mail.ru>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:50482 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdJZLXg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 07:23:36 -0400
Received: by mail-pf0-f195.google.com with SMTP id b6so2280309pfh.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 04:23:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The similar fix in patch 'ipip: only increase err_count for some
certain type icmp in ipip_err' is needed for ip6gre_err.

In Jianlin's case, udp netperf broke even when receiving a TooBig
icmpv6 packet.

Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/ip6_gre.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 1602b49..fb595e8 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -408,13 +408,16 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	case ICMPV6_DEST_UNREACH:
 		net_dbg_ratelimited("%s: Path to destination invalid or inactive!\n",
 				    t->parms.name);
-		break;
+		if (code != ICMPV6_PORT_UNREACH)
+			break;
+		return;
 	case ICMPV6_TIME_EXCEED:
 		if (code == ICMPV6_EXC_HOPLIMIT) {
 			net_dbg_ratelimited("%s: Too small hop limit or routing loop in tunnel!\n",
 					    t->parms.name);
+			break;
 		}
-		break;
+		return;
 	case ICMPV6_PARAMPROB:
 		teli = 0;
 		if (code == ICMPV6_HDR_FIELD)
@@ -430,7 +433,7 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			net_dbg_ratelimited("%s: Recipient unable to parse tunneled packet!\n",
 					    t->parms.name);
 		}
-		break;
+		return;
 	case ICMPV6_PKT_TOOBIG:
 		mtu = be32_to_cpu(info) - offset - t->tun_hlen;
 		if (t->dev->type == ARPHRD_ETHER)
@@ -438,7 +441,7 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if (mtu < IPV6_MIN_MTU)
 			mtu = IPV6_MIN_MTU;
 		t->dev->mtu = mtu;
-		break;
+		return;
 	}
 
 	if (time_before(jiffies, t->err_time + IP6TUNNEL_ERR_TIMEO))
-- 
2.1.0
