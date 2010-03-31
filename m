From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH 2/5] net: ipv6: add IPSKB_REROUTED exclusion to NF_HOOK/POSTROUTING invocation
Date: Wed, 31 Mar 2010 12:38:50 +0200
Message-ID: <1270031934-15940-3-git-send-email-jengelh@medozas.de>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:55973 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003Ab0CaKjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 06:39:02 -0400
In-Reply-To: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to how IPv4's ip_output.c works, have ip6_output also check
the IPSKB_REROUTED flag. It will be set from xt_TEE for cloned packets
since Xtables can currently only deal with a single packet in flight
at a time.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv6/ip6_output.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f314ba4..7e10f62 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -172,8 +172,9 @@ int ip6_output(struct sk_buff *skb)
 		return 0;
 	}
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, dev,
-		       ip6_finish_output);
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, dev,
+			    ip6_finish_output,
+			    !(IP6CB(skb)->flags & IPSKB_REROUTED));
 }
 
 /*
-- 
1.7.0.2

