From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH ] ip6tnl: do route updating for redirect in ip6_tnl_err()
Date: Wed, 18 Sep 2013 20:05:35 +0800
Message-ID: <5239970F.8000105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55773 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752048Ab3IRMGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 08:06:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

After the ip6_tnl_err() is called, the rel_msg is assigned
to 0, and the ip4ip6_err()will return directly, the instruction
below will not be executed.

In rfc2473, we can know that the tunnel ICMP redirect
message should not be reported to the source of the
original packet, so we can handle it in ip4ip6_err().

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ip6_tunnel.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2d8f482..35c4b70 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -529,6 +529,9 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 			rel_msg = 1;
 		}
 		break;
+	case NDISC_REDIRECT:
+		ip6_redirect(skb, net, 0, 0);
+		break;
 	}
 
 	*type = rel_type;
@@ -576,9 +579,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		rel_type = ICMP_DEST_UNREACH;
 		rel_code = ICMP_FRAG_NEEDED;
 		break;
-	case NDISC_REDIRECT:
-		rel_type = ICMP_REDIRECT;
-		rel_code = ICMP_REDIR_HOST;
 	default:
 		return 0;
 	}
@@ -637,8 +637,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), NULL, skb2, rel_info);
 	}
-	if (rel_type == ICMP_REDIRECT)
-		skb_dst(skb2)->ops->redirect(skb_dst(skb2), NULL, skb2);
 
 	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
 
-- 
1.8.3.1
