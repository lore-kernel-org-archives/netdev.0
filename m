From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 06/11] ip6tnl: move route updating for redirect to ndisc layer
Date: Thu, 12 Sep 2013 18:49:24 +0800
Message-ID: <52319C34.8000902@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62552 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab3ILKuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:50:18 -0400
In-Reply-To: <52319A6E.6090503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

In rfc2473, we can know that the tunnel ICMP redirect
message should not be reported to the source of the
original packet, so after calling ip6_tnl_err(), the
rel_msg is set to 0 in function ip4ip6_err(), and the
redirect will never be handled.

In order to deal with this, we move route updating for
redirect to ndisc layer.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ip6_tunnel.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 61355f7..3ea834b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -576,9 +576,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		rel_type = ICMP_DEST_UNREACH;
 		rel_code = ICMP_FRAG_NEEDED;
 		break;
-	case NDISC_REDIRECT:
-		rel_type = ICMP_REDIRECT;
-		rel_code = ICMP_REDIR_HOST;
 	default:
 		return 0;
 	}
@@ -637,8 +634,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), NULL, skb2, rel_info);
 	}
-	if (rel_type == ICMP_REDIRECT)
-		skb_dst(skb2)->ops->redirect(skb_dst(skb2), NULL, skb2);
 
 	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
 
-- 
1.8.3.1
