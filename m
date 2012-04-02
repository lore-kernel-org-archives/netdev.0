From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 18/51] nf_conntrack_proto_dccp: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:08 -0400
Message-ID: <1333335521-1348-19-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288Ab2DBC7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:40 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_proto_dccp.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 24fdce2..a58998d 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -643,11 +643,12 @@ static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 	nest_parms = nla_nest_start(skb, CTA_PROTOINFO_DCCP | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
-	NLA_PUT_U8(skb, CTA_PROTOINFO_DCCP_STATE, ct->proto.dccp.state);
-	NLA_PUT_U8(skb, CTA_PROTOINFO_DCCP_ROLE,
-		   ct->proto.dccp.role[IP_CT_DIR_ORIGINAL]);
-	NLA_PUT_BE64(skb, CTA_PROTOINFO_DCCP_HANDSHAKE_SEQ,
-		     cpu_to_be64(ct->proto.dccp.handshake_seq));
+	if (nla_put_u8(skb, CTA_PROTOINFO_DCCP_STATE, ct->proto.dccp.state) ||
+	    nla_put_u8(skb, CTA_PROTOINFO_DCCP_ROLE,
+		       ct->proto.dccp.role[IP_CT_DIR_ORIGINAL]) ||
+	    nla_put_be64(skb, CTA_PROTOINFO_DCCP_HANDSHAKE_SEQ,
+			 cpu_to_be64(ct->proto.dccp.handshake_seq)))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 	spin_unlock_bh(&ct->lock);
 	return 0;
@@ -739,9 +740,10 @@ dccp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
         const unsigned int *timeouts = data;
 	int i;
 
-	for (i=CTA_TIMEOUT_DCCP_UNSPEC+1; i<CTA_TIMEOUT_DCCP_MAX+1; i++)
-		NLA_PUT_BE32(skb, i, htonl(timeouts[i] / HZ));
-
+	for (i=CTA_TIMEOUT_DCCP_UNSPEC+1; i<CTA_TIMEOUT_DCCP_MAX+1; i++) {
+		if (nla_put_be32(skb, i, htonl(timeouts[i] / HZ)))
+			goto nla_put_failure;
+	}
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
