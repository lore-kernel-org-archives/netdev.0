From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/12] netfilter: conntrack: avoid zeroing timer
Date: Wed,  3 Dec 2014 13:55:32 +0100
Message-ID: <1417611342-25257-3-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48597 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbaLCMxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:30 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

add a __nfct_init_offset annotation member to struct nf_conn to make
it clear which members are covered by the memset when the conntrack
is allocated.

This avoids zeroing timer_list and ct_net; both are already inited
explicitly.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |   15 +++++++++------
 net/netfilter/nf_conntrack_core.c    |   11 ++++-------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index c8a7db6..f0daed2 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -92,12 +92,18 @@ struct nf_conn {
 	/* Have we seen traffic both ways yet? (bitset) */
 	unsigned long status;
 
-	/* If we were expected by an expectation, this will be it */
-	struct nf_conn *master;
-
 	/* Timer function; drops refcnt when it goes off. */
 	struct timer_list timeout;
 
+#ifdef CONFIG_NET_NS
+	struct net *ct_net;
+#endif
+	/* all members below initialized via memset */
+	u8 __nfct_init_offset[0];
+
+	/* If we were expected by an expectation, this will be it */
+	struct nf_conn *master;
+
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	u_int32_t mark;
 #endif
@@ -108,9 +114,6 @@ struct nf_conn {
 
 	/* Extensions */
 	struct nf_ct_ext *ext;
-#ifdef CONFIG_NET_NS
-	struct net *ct_net;
-#endif
 
 	/* Storage reserved for other modules, must be the last member */
 	union nf_conntrack_proto proto;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 2c69975..9ef88c8 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -826,22 +826,19 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
-	/*
-	 * Let ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
-	 * and ct->tuplehash[IP_CT_DIR_REPLY].hnnode.next unchanged.
-	 */
-	memset(&ct->tuplehash[IP_CT_DIR_MAX], 0,
-	       offsetof(struct nf_conn, proto) -
-	       offsetof(struct nf_conn, tuplehash[IP_CT_DIR_MAX]));
 	spin_lock_init(&ct->lock);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
 	/* save hash for reusing when confirming */
 	*(unsigned long *)(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev) = hash;
+	ct->status = 0;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
 	write_pnet(&ct->ct_net, net);
+	memset(&ct->__nfct_init_offset[0], 0,
+	       offsetof(struct nf_conn, proto) -
+	       offsetof(struct nf_conn, __nfct_init_offset[0]));
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	if (zone) {
 		struct nf_conntrack_zone *nf_ct_zone;
-- 
1.7.10.4
