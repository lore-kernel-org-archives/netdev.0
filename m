From: kaber@trash.net
Subject: [PATCH 1/1] netfilter: nf_conntrack: set conntrack templates again if we return NF_REPEAT
Date: Wed,  9 Feb 2011 15:39:29 +0100
Message-ID: <1297262369-26393-2-git-send-email-kaber@trash.net>
References: <1297262369-26393-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52924 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609Ab1BIOju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 09:39:50 -0500
In-Reply-To: <1297262369-26393-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

The TCP tracking code has a special case that allows to return
NF_REPEAT if we receive a new SYN packet while in TIME_WAIT state.

In this situation, the TCP tracking code destroys the existing
conntrack to start a new clean session.

[DESTROY] tcp      6 src=192.168.0.2 dst=192.168.1.2 sport=38925 dport=8000 src=192.168.1.2 dst=192.168.1.100 sport=8000 dport=38925 [ASSURED]
    [NEW] tcp      6 120 SYN_SENT src=192.168.0.2 dst=192.168.1.2 sport=38925 dport=8000 [UNREPLIED] src=192.168.1.2 dst=192.168.1.100 sport=8000 dport=38925

However, this is a problem for the iptables' CT target event filtering
which will not work in this case since the conntrack template will not
be there for the new session. To fix this, we reassign the conntrack
template to the packet if we return NF_REPEAT.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_core.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e615119..84f4fcc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -942,8 +942,15 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
 		nf_conntrack_event_cache(IPCT_REPLY, ct);
 out:
-	if (tmpl)
-		nf_ct_put(tmpl);
+	if (tmpl) {
+		/* Special case: we have to repeat this hook, assign the
+		 * template again to this packet. We assume that this packet
+		 * has no conntrack assigned. This is used by nf_ct_tcp. */
+		if (ret == NF_REPEAT)
+			skb->nfct = (struct nf_conntrack *)tmpl;
+		else
+			nf_ct_put(tmpl);
+	}
 
 	return ret;
 }
-- 
1.7.2.3

