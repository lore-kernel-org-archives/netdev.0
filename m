From: pablo@netfilter.org
Subject: [PATCH 14/19] netfilter: nf_nat: remove obsolete code from nf_nat_icmp_reply_translation()
Date: Sun, 25 Dec 2011 02:57:30 +0100
Message-ID: <1324778255-2830-15-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The inner tuple that is extracted from the packet is unused. The code also
doesn't have any useful side-effects like verifying the packet does contain
enough data to extract the inner tuple since conntrack already does the
same, so remove it.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_core.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 5e1bd85..acdd002 100644
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
1.7.2.5

