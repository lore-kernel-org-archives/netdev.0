From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/8] ipvs: correct usage/allocation of seqadj ext in ipvs
Date: Sat, 28 Dec 2013 23:03:04 +0100
Message-ID: <1388268187-11569-6-git-send-email-pablo@netfilter.org>
References: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43865 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443Ab3L1WD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Dec 2013 17:03:27 -0500
In-Reply-To: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>

The IPVS FTP helper ip_vs_ftp could trigger an OOPS in nf_ct_seqadj_set,
after commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence number
adjustments usuable without NAT).

This is because, the seqadj ext is now allocated dynamically, and the
IPVS code didn't handle this situation.  Fix this in the IPVS nfct
code by invoking the alloc function nfct_seqadj_ext_add().

Fixes: 41d73ec053d2 (netfilter: nf_conntrack: make sequence number adjustments usuable without NAT)
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_nfct.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index c8beafd..5a355a4 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -63,6 +63,7 @@
 #include <net/ip_vs.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
@@ -97,6 +98,11 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
 		return;
 
+	/* Applications may adjust TCP seqs */
+	if (cp->app && nf_ct_protonum(ct) == IPPROTO_TCP &&
+	    !nfct_seqadj(ct) && !nfct_seqadj_ext_add(ct))
+		return;
+
 	/*
 	 * The connection is not yet in the hashtable, so we update it.
 	 * CIP->VIP will remain the same, so leave the tuple in
-- 
1.7.10.4
