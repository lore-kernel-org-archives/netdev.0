From: Duan Jiong <djduanjiong@gmail.com>
Subject: [PATCH v2] ip6tnl: do route updating for redirect in ip6_tnl_err()
Date: Tue, 17 Sep 2013 20:27:57 -0700
Message-ID: <1379474877-3097-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Duan Jiong <duanj.fnst@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:57748 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab3ISFaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 01:30:10 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so7993516pbb.28
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 22:30:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the ip6_tnl_err() is called, the rel_msg is assigned to
0, and the ip4ip6_err() will return directly, the instruction
below will not be executed.

In rfc2473, we can know that the tunnel ICMP redirect message
should not be reported to the source of the original packet,
so we can handle it in ip6_tnl_err().

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ip6_tunnel.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 61355f7..48034d8 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -529,6 +529,9 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 			rel_msg = 1;
 		}
 		break;
+	case NDISC_REDIRECT:
+		ip6_redirect(skb, dev_net(skb->dev), skb->dev->ifindex, 0);
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
1.7.7.6
