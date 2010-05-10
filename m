From: kaber@trash.net
Subject: [PATCH 67/84] netfilter: ipv6: add IPSKB_REROUTED exclusion to NF_HOOK/POSTROUTING invocation
Date: Mon, 10 May 2010 22:18:38 +0200
Message-ID: <1273522735-24672-68-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Similar to how IPv4's ip_output.c works, have ip6_output also check
the IPSKB_REROUTED flag. It will be set from xt_TEE for cloned packets
since Xtables can currently only deal with a single packet in flight
at a time.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Acked-by: David S. Miller <davem@davemloft.net>
[Patrick: changed to use an IP6SKB value instead of IPSKB]
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/ipv6.h  |    1 +
 net/ipv6/ip6_output.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e0cc9a7..7bdf6ff 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -250,6 +250,7 @@ struct inet6_skb_parm {
 
 #define IP6SKB_XFRM_TRANSFORMED	1
 #define IP6SKB_FORWARDED	2
+#define IP6SKB_REROUTED		4
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 236ac78..c10a38a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -172,8 +172,9 @@ int ip6_output(struct sk_buff *skb)
 		return 0;
 	}
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, dev,
-		       ip6_finish_output);
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, dev,
+			    ip6_finish_output,
+			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
 
 /*
-- 
1.7.0.4

