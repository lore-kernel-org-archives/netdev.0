From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 15/51] nf_conntrack_proto_sctp: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:05 -0400
Message-ID: <1333335521-1348-16-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994Ab2DBC71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:27 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_proto_sctp.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 72b5088..996db2f 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -482,15 +482,12 @@ static int sctp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 	if (!nest_parms)
 		goto nla_put_failure;
 
-	NLA_PUT_U8(skb, CTA_PROTOINFO_SCTP_STATE, ct->proto.sctp.state);
-
-	NLA_PUT_BE32(skb,
-		     CTA_PROTOINFO_SCTP_VTAG_ORIGINAL,
-		     ct->proto.sctp.vtag[IP_CT_DIR_ORIGINAL]);
-
-	NLA_PUT_BE32(skb,
-		     CTA_PROTOINFO_SCTP_VTAG_REPLY,
-		     ct->proto.sctp.vtag[IP_CT_DIR_REPLY]);
+	if (nla_put_u8(skb, CTA_PROTOINFO_SCTP_STATE, ct->proto.sctp.state) ||
+	    nla_put_be32(skb, CTA_PROTOINFO_SCTP_VTAG_ORIGINAL,
+			 ct->proto.sctp.vtag[IP_CT_DIR_ORIGINAL]) ||
+	    nla_put_be32(skb, CTA_PROTOINFO_SCTP_VTAG_REPLY,
+			 ct->proto.sctp.vtag[IP_CT_DIR_REPLY]))
+		goto nla_put_failure;
 
 	spin_unlock_bh(&ct->lock);
 
@@ -578,9 +575,10 @@ sctp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
         const unsigned int *timeouts = data;
 	int i;
 
-	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++)
-	        NLA_PUT_BE32(skb, i, htonl(timeouts[i] / HZ));
-
+	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++) {
+	        if (nla_put_be32(skb, i, htonl(timeouts[i] / HZ)))
+			goto nla_put_failure;
+	}
         return 0;
 
 nla_put_failure:
-- 
1.7.7.6
