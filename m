From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 14/51] nf_conntrack_proto_tcp: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:04 -0400
Message-ID: <1333335521-1348-15-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220Ab2DBC70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:26 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_proto_tcp.c |   68 ++++++++++++++++---------------
 1 files changed, 35 insertions(+), 33 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 361eade..cc55816 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1147,21 +1147,22 @@ static int tcp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 	if (!nest_parms)
 		goto nla_put_failure;
 
-	NLA_PUT_U8(skb, CTA_PROTOINFO_TCP_STATE, ct->proto.tcp.state);
-
-	NLA_PUT_U8(skb, CTA_PROTOINFO_TCP_WSCALE_ORIGINAL,
-		   ct->proto.tcp.seen[0].td_scale);
-
-	NLA_PUT_U8(skb, CTA_PROTOINFO_TCP_WSCALE_REPLY,
-		   ct->proto.tcp.seen[1].td_scale);
+	if (nla_put_u8(skb, CTA_PROTOINFO_TCP_STATE, ct->proto.tcp.state) ||
+	    nla_put_u8(skb, CTA_PROTOINFO_TCP_WSCALE_ORIGINAL,
+		       ct->proto.tcp.seen[0].td_scale) ||
+	    nla_put_u8(skb, CTA_PROTOINFO_TCP_WSCALE_REPLY,
+		       ct->proto.tcp.seen[1].td_scale))
+		goto nla_put_failure;
 
 	tmp.flags = ct->proto.tcp.seen[0].flags;
-	NLA_PUT(skb, CTA_PROTOINFO_TCP_FLAGS_ORIGINAL,
-		sizeof(struct nf_ct_tcp_flags), &tmp);
+	if (nla_put(skb, CTA_PROTOINFO_TCP_FLAGS_ORIGINAL,
+		    sizeof(struct nf_ct_tcp_flags), &tmp))
+		goto nla_put_failure;
 
 	tmp.flags = ct->proto.tcp.seen[1].flags;
-	NLA_PUT(skb, CTA_PROTOINFO_TCP_FLAGS_REPLY,
-		sizeof(struct nf_ct_tcp_flags), &tmp);
+	if (nla_put(skb, CTA_PROTOINFO_TCP_FLAGS_REPLY,
+		    sizeof(struct nf_ct_tcp_flags), &tmp))
+		goto nla_put_failure;
 	spin_unlock_bh(&ct->lock);
 
 	nla_nest_end(skb, nest_parms);
@@ -1310,28 +1311,29 @@ tcp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeouts = data;
 
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_SYN_SENT,
-			htonl(timeouts[TCP_CONNTRACK_SYN_SENT] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_SYN_RECV,
-			htonl(timeouts[TCP_CONNTRACK_SYN_RECV] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_ESTABLISHED,
-			htonl(timeouts[TCP_CONNTRACK_ESTABLISHED] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_FIN_WAIT,
-			htonl(timeouts[TCP_CONNTRACK_FIN_WAIT] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_CLOSE_WAIT,
-			htonl(timeouts[TCP_CONNTRACK_CLOSE_WAIT] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_LAST_ACK,
-			htonl(timeouts[TCP_CONNTRACK_LAST_ACK] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_TIME_WAIT,
-			htonl(timeouts[TCP_CONNTRACK_TIME_WAIT] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_CLOSE,
-			htonl(timeouts[TCP_CONNTRACK_CLOSE] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_SYN_SENT2,
-			htonl(timeouts[TCP_CONNTRACK_SYN_SENT2] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_RETRANS,
-			htonl(timeouts[TCP_CONNTRACK_RETRANS] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_UNACK,
-			htonl(timeouts[TCP_CONNTRACK_UNACK] / HZ));
+	if (nla_put_be32(skb, CTA_TIMEOUT_TCP_SYN_SENT,
+			htonl(timeouts[TCP_CONNTRACK_SYN_SENT] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_SYN_RECV,
+			 htonl(timeouts[TCP_CONNTRACK_SYN_RECV] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_ESTABLISHED,
+			 htonl(timeouts[TCP_CONNTRACK_ESTABLISHED] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_FIN_WAIT,
+			 htonl(timeouts[TCP_CONNTRACK_FIN_WAIT] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_CLOSE_WAIT,
+			 htonl(timeouts[TCP_CONNTRACK_CLOSE_WAIT] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_LAST_ACK,
+			 htonl(timeouts[TCP_CONNTRACK_LAST_ACK] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_TIME_WAIT,
+			 htonl(timeouts[TCP_CONNTRACK_TIME_WAIT] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_CLOSE,
+			 htonl(timeouts[TCP_CONNTRACK_CLOSE] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_SYN_SENT2,
+			 htonl(timeouts[TCP_CONNTRACK_SYN_SENT2] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_RETRANS,
+			 htonl(timeouts[TCP_CONNTRACK_RETRANS] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_TCP_UNACK,
+			 htonl(timeouts[TCP_CONNTRACK_UNACK] / HZ)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
