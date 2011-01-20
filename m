From: kaber@trash.net
Subject: [PATCH 2/7] netfilter: do not omit re-route check on NF_QUEUE verdict
Date: Thu, 20 Jan 2011 21:22:41 +0100
Message-ID: <1295554966-5263-3-git-send-email-kaber@trash.net>
References: <1295554966-5263-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44058 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513Ab1ATUX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 15:23:58 -0500
In-Reply-To: <1295554966-5263-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

ret != NF_QUEUE only works in the "--queue-num 0" case; for
queues > 0 the test should be '(ret & NF_VERDICT_MASK) != NF_QUEUE'.

However, NF_QUEUE no longer DROPs the skb unconditionally if queueing
fails (due to NF_VERDICT_FLAG_QUEUE_BYPASS verdict flag), so the
re-route test should also be performed if this flag is set in the
verdict.

The full test would then look something like

&& ((ret & NF_VERDICT_MASK) == NF_QUEUE && (ret & NF_VERDICT_FLAG_QUEUE_BYPASS))

This is rather ugly, so just remove the NF_QUEUE test altogether.

The only effect is that we might perform an unnecessary route lookup
in the NF_QUEUE case.

ip6table_mangle did not have such a check.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/iptable_mangle.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 294a2a3..aef5d1f 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -60,7 +60,7 @@ ipt_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	ret = ipt_do_table(skb, NF_INET_LOCAL_OUT, NULL, out,
 			   dev_net(out)->ipv4.iptable_mangle);
 	/* Reroute for ANY change. */
-	if (ret != NF_DROP && ret != NF_STOLEN && ret != NF_QUEUE) {
+	if (ret != NF_DROP && ret != NF_STOLEN) {
 		iph = ip_hdr(skb);
 
 		if (iph->saddr != saddr ||
-- 
1.7.3.4

