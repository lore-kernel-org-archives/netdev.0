From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] xfrm: Fix local error reporting crash with interfamily tunnels
Date: Mon, 16 Mar 2015 07:52:23 +0100
Message-ID: <1426488744-17104-3-git-send-email-steffen.klassert@secunet.com>
References: <1426488744-17104-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57385 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbbCPGxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 02:53:17 -0400
In-Reply-To: <1426488744-17104-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We set the outer mode protocol too early. As a result, the
local error handler might dispatch to the wrong address family
and report the error to a wrong socket type. We fix this by
setting the outer protocol to the skb after we accessed the
inner mode for the last time, right before we do the atcual
encapsulation where we switch finally to the outer mode.

Reported-by: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Tested-by: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_output.c | 2 +-
 net/ipv6/xfrm6_output.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index d5f6bd9..dab7381 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -63,6 +63,7 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 		return err;
 
 	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
+	skb->protocol = htons(ETH_P_IP);
 
 	return x->outer_mode->output2(x, skb);
 }
@@ -71,7 +72,6 @@ EXPORT_SYMBOL(xfrm4_prepare_output);
 int xfrm4_output_finish(struct sk_buff *skb)
 {
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
-	skb->protocol = htons(ETH_P_IP);
 
 #ifdef CONFIG_NETFILTER
 	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index ca3f29b..010f8bd 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -114,6 +114,7 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 		return err;
 
 	skb->ignore_df = 1;
+	skb->protocol = htons(ETH_P_IPV6);
 
 	return x->outer_mode->output2(x, skb);
 }
@@ -122,7 +123,6 @@ EXPORT_SYMBOL(xfrm6_prepare_output);
 int xfrm6_output_finish(struct sk_buff *skb)
 {
 	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
-	skb->protocol = htons(ETH_P_IPV6);
 
 #ifdef CONFIG_NETFILTER
 	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
-- 
1.9.1
