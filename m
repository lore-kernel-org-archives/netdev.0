From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: ctnetlink: send event when conntrack label was modified
Date: Mon, 24 Jun 2013 17:16:25 +0200
Message-ID: <1372086986-4080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51597 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245Ab3FXPQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 11:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

commit 0ceabd83875b72a29f33db4ab703d6ba40ea4c58
(netfilter: ctnetlink: deliver labels to userspace) sets the event bit
when we raced with another packet, instead of raising the event bit
when the label bit is set for the first time.

commit 9b21f6a90924dfe8e5e686c314ddb441fb06501e
(netfilter: ctnetlink: allow userspace to modify labels) forgot to update
the event mask in the "conntrack already exists" case.

Both issues result in CTA_LABELS attribute not getting included in the
conntrack event.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_labels.c  |    2 +-
 net/netfilter/nf_conntrack_netlink.c |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index 8fe2e99..355d2ef 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -45,7 +45,7 @@ int nf_connlabel_set(struct nf_conn *ct, u16 bit)
 	if (test_bit(bit, labels->bits))
 		return 0;
 
-	if (test_and_set_bit(bit, labels->bits))
+	if (!test_and_set_bit(bit, labels->bits))
 		nf_conntrack_event_cache(IPCT_LABEL, ct);
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6d0f8a1..ecf065f 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1825,6 +1825,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			nf_conntrack_eventmask_report((1 << IPCT_REPLY) |
 						      (1 << IPCT_ASSURED) |
 						      (1 << IPCT_HELPER) |
+						      (1 << IPCT_LABEL) |
 						      (1 << IPCT_PROTOINFO) |
 						      (1 << IPCT_NATSEQADJ) |
 						      (1 << IPCT_MARK),
-- 
1.7.10.4
