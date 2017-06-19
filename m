From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next] net: raw: assign delivered after receive success
Date: Mon, 19 Jun 2017 20:37:38 +0800
Message-ID: <1497875858-22402-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:51657 "EHLO m12-14.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753942AbdFSMiI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 08:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

it's not reasonable to assign delivered if packet match no RAW sock

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ipv4/raw.c | 5 ++---
 net/ipv6/raw.c | 4 ++--
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index bdffad8..fa39894 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -187,15 +187,14 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 			     skb->dev->ifindex);
 
 	while (sk) {
-		delivered = 1;
 		if ((iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) &&
 		    ip_mc_sf_allow(sk, iph->daddr, iph->saddr,
 				   skb->dev->ifindex)) {
 			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
 
 			/* Not releasing hash table! */
-			if (clone)
-				raw_rcv(sk, clone);
+			if (clone && raw_rcv(sk, clone) == NET_RX_SUCCESS)
+				delivered = 1;
 		}
 		sk = __raw_v4_lookup(net, sk_next(sk), iph->protocol,
 				     iph->saddr, iph->daddr,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 60be012..de9483e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -183,7 +183,6 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 	while (sk) {
 		int filtered;
 
-		delivered = true;
 		switch (nexthdr) {
 		case IPPROTO_ICMPV6:
 			filtered = icmpv6_filter(sk, skb);
@@ -218,7 +217,8 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 			/* Not releasing hash table! */
 			if (clone) {
 				nf_reset(clone);
-				rawv6_rcv(sk, clone);
+				if (rawv6_rcv(sk, clone) == NET_RX_SUCCESS)
+					delivered = true;
 			}
 		}
 		sk = __raw_v6_lookup(net, sk_next(sk), nexthdr, daddr, saddr,
-- 
2.7.4
