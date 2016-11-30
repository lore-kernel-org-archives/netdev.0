From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/11] netfilter: ipv6: nf_defrag: drop mangled skb on ream error
Date: Wed, 30 Nov 2016 22:57:24 +0100
Message-ID: <1480543045-3389-11-git-send-email-pablo@netfilter.org>
References: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42178 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755246AbcK3V5t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 16:57:49 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9255C13C0ED
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 81EE0DA85F
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7C9D4DA86D
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:44 +0100 (CET)
In-Reply-To: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Dmitry Vyukov reported GPF in network stack that Andrey traced down to
negative nh offset in nf_ct_frag6_queue().

Problem is that all network headers before fragment header are pulled.
Normal ipv6 reassembly will drop the skb when errors occur further down
the line.

netfilter doesn't do this, and instead passed the original fragment
along.  That was also fine back when netfilter ipv6 defrag worked with
cloned fragments, as the original, pristine fragment was passed on.

So we either have to undo the pull op, or discard such fragments.
Since they're malformed after all (e.g. overlapping fragment) it seems
preferrable to just drop them.

Same for temporary errors -- it doesn't make sense to accept (and
perhaps forward!) only some fragments of same datagram.

Fixes: 029f7f3b8701cc7ac ("netfilter: ipv6: nf_defrag: avoid/free clone operations")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Debugged-by: Andrey Konovalov <andreyknvl@google.com>
Diagnosed-by: Eric Dumazet <Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c   | 4 ++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index e4347aeb2e65..9948b5ce52da 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -576,11 +576,11 @@ int nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user)
 	/* Jumbo payload inhibits frag. header */
 	if (ipv6_hdr(skb)->payload_len == 0) {
 		pr_debug("payload len = 0\n");
-		return -EINVAL;
+		return 0;
 	}
 
 	if (find_prev_fhdr(skb, &prevhdr, &nhoff, &fhoff) < 0)
-		return -EINVAL;
+		return 0;
 
 	if (!pskb_may_pull(skb, fhoff + sizeof(*fhdr)))
 		return -ENOMEM;
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index f7aab5ab93a5..f06b0471f39f 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -69,7 +69,7 @@ static unsigned int ipv6_defrag(void *priv,
 	if (err == -EINPROGRESS)
 		return NF_STOLEN;
 
-	return NF_ACCEPT;
+	return err == 0 ? NF_ACCEPT : NF_DROP;
 }
 
 static struct nf_hook_ops ipv6_defrag_ops[] = {
-- 
2.1.4
