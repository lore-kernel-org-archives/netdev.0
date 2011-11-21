From: kaber@trash.net
Subject: [PATCH 04/17] netfilter: nf_nat: remove obsolete code from nf_nat_icmp_reply_translation()
Date: Mon, 21 Nov 2011 06:45:56 +0100
Message-ID: <1321854369-3432-5-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61050 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab1KUFqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:46:14 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The inner tuple that is extracted from the packet is unused. The code also
doesn't have any useful side-effects like verifying the packet does contain
enough data to extract the inner tuple since conntrack already does the
same, so remove it.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_core.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index e9cab93..413c9de 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -30,7 +30,6 @@
 #include <net/netfilter/nf_nat_helper.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
-#include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
 static DEFINE_SPINLOCK(nf_nat_lock);
@@ -414,8 +413,7 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 		struct icmphdr icmp;
 		struct iphdr ip;
 	} *inside;
-	const struct nf_conntrack_l4proto *l4proto;
-	struct nf_conntrack_tuple inner, target;
+	struct nf_conntrack_tuple target;
 	int hdrlen = ip_hdrlen(skb);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	unsigned long statusbit;
@@ -463,16 +461,6 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 		 "dir %s\n", skb, manip,
 		 dir == IP_CT_DIR_ORIGINAL ? "ORIG" : "REPLY");
 
-	/* rcu_read_lock()ed by nf_hook_slow */
-	l4proto = __nf_ct_l4proto_find(PF_INET, inside->ip.protocol);
-
-	if (!nf_ct_get_tuple(skb, hdrlen + sizeof(struct icmphdr),
-			     (hdrlen +
-			      sizeof(struct icmphdr) + inside->ip.ihl * 4),
-			     (u_int16_t)AF_INET, inside->ip.protocol,
-			     &inner, l3proto, l4proto))
-		return 0;
-
 	/* Change inner back to look like incoming packet.  We do the
 	   opposite manip on this hook to normal, because it might not
 	   pass all hooks (locally-generated ICMP).  Consider incoming
-- 
1.7.1
