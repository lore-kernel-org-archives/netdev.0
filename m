From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] bridge: Do not compile options in br_parse_ip_options
Date: Mon, 27 Oct 2014 22:38:03 +0100
Message-ID: <1414445887-5108-5-git-send-email-pablo@netfilter.org>
References: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35981 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbaJ0Vgl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 17:36:41 -0400
In-Reply-To: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

Commit 462fb2af9788a82a534f8184abfde31574e1cfa0

	bridge : Sanitize skb before it enters the IP stack

broke when IP options are actually used because it mangles the
skb as if it entered the IP stack which is wrong because the
bridge is supposed to operate below the IP stack.

Since nobody has actually requested for parsing of IP options
this patch fixes it by simply reverting to the previous approach
of ignoring all IP options, i.e., zeroing the IPCB.

If and when somebody who uses IP options and actually needs them
to be parsed by the bridge complains then we can revisit this.

Reported-by: David Newall <davidn@davidnewall.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Tested-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |   24 +++++-------------------
 1 file changed, 5 insertions(+), 19 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 1bada53..1a4f32c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -192,7 +192,6 @@ static inline void nf_bridge_save_header(struct sk_buff *skb)
 
 static int br_parse_ip_options(struct sk_buff *skb)
 {
-	struct ip_options *opt;
 	const struct iphdr *iph;
 	struct net_device *dev = skb->dev;
 	u32 len;
@@ -201,7 +200,6 @@ static int br_parse_ip_options(struct sk_buff *skb)
 		goto inhdr_error;
 
 	iph = ip_hdr(skb);
-	opt = &(IPCB(skb)->opt);
 
 	/* Basic sanity checks */
 	if (iph->ihl < 5 || iph->version != 4)
@@ -227,23 +225,11 @@ static int br_parse_ip_options(struct sk_buff *skb)
 	}
 
 	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-	if (iph->ihl == 5)
-		return 0;
-
-	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
-	if (ip_options_compile(dev_net(dev), opt, skb))
-		goto inhdr_error;
-
-	/* Check correct handling of SRR option */
-	if (unlikely(opt->srr)) {
-		struct in_device *in_dev = __in_dev_get_rcu(dev);
-		if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
-			goto drop;
-
-		if (ip_options_rcv_srr(skb))
-			goto drop;
-	}
-
+	/* We should really parse IP options here but until
+	 * somebody who actually uses IP options complains to
+	 * us we'll just silently ignore the options because
+	 * we're lazy!
+	 */
 	return 0;
 
 inhdr_error:
-- 
1.7.10.4
