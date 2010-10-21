From: kaber@trash.net
Subject: [PATCH 58/72] nf_nat: restrict ICMP translation for embedded header
Date: Thu, 21 Oct 2010 17:19:45 +0200
Message-ID: <1287674399-31455-59-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

 	Skip ICMP translation of embedded protocol header
if NAT bits are not set. Needed for IPVS to see the original
embedded addresses because for IPVS traffic the IPS_SRC_NAT_BIT
and IPS_DST_NAT_BIT bits are not set. It happens when IPVS performs
DNAT for client packets after using nf_conntrack_alter_reply
to expect replies from real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/ipv4/netfilter/nf_nat_core.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index e2e00c4..0047923 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -462,6 +462,18 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 			return 0;
 	}
 
+	if (manip == IP_NAT_MANIP_SRC)
+		statusbit = IPS_SRC_NAT;
+	else
+		statusbit = IPS_DST_NAT;
+
+	/* Invert if this is reply dir. */
+	if (dir == IP_CT_DIR_REPLY)
+		statusbit ^= IPS_NAT_MASK;
+
+	if (!(ct->status & statusbit))
+		return 1;
+
 	pr_debug("icmp_reply_translation: translating error %p manip %u "
 		 "dir %s\n", skb, manip,
 		 dir == IP_CT_DIR_ORIGINAL ? "ORIG" : "REPLY");
@@ -496,20 +508,9 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 
 	/* Change outer to look the reply to an incoming packet
 	 * (proto 0 means don't invert per-proto part). */
-	if (manip == IP_NAT_MANIP_SRC)
-		statusbit = IPS_SRC_NAT;
-	else
-		statusbit = IPS_DST_NAT;
-
-	/* Invert if this is reply dir. */
-	if (dir == IP_CT_DIR_REPLY)
-		statusbit ^= IPS_NAT_MASK;
-
-	if (ct->status & statusbit) {
-		nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
-		if (!manip_pkt(0, skb, 0, &target, manip))
-			return 0;
-	}
+	nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
+	if (!manip_pkt(0, skb, 0, &target, manip))
+		return 0;
 
 	return 1;
 }
-- 
1.7.1

