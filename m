From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 10/51] nfnetlink_log: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:00 -0400
Message-ID: <1333335521-1348-11-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177Ab2DBC7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:20 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nfnetlink_log.c |  100 ++++++++++++++++++++++++-----------------
 1 files changed, 58 insertions(+), 42 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 66b2c54..3c3cfc0 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -391,67 +391,78 @@ __build_packet_message(struct nfulnl_instance *inst,
 	pmsg.hw_protocol	= skb->protocol;
 	pmsg.hook		= hooknum;
 
-	NLA_PUT(inst->skb, NFULA_PACKET_HDR, sizeof(pmsg), &pmsg);
+	if (nla_put(inst->skb, NFULA_PACKET_HDR, sizeof(pmsg), &pmsg))
+		goto nla_put_failure;
 
-	if (prefix)
-		NLA_PUT(inst->skb, NFULA_PREFIX, plen, prefix);
+	if (prefix &&
+	    nla_put(inst->skb, NFULA_PREFIX, plen, prefix))
+		goto nla_put_failure;
 
 	if (indev) {
 #ifndef CONFIG_BRIDGE_NETFILTER
-		NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_INDEV,
-			     htonl(indev->ifindex));
+		if (nla_put_be32(inst->skb, NFULA_IFINDEX_INDEV,
+				 htonl(indev->ifindex)))
+			goto nla_put_failure;
 #else
 		if (pf == PF_BRIDGE) {
 			/* Case 1: outdev is physical input device, we need to
 			 * look for bridge group (when called from
 			 * netfilter_bridge) */
-			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
-				     htonl(indev->ifindex));
+			if (nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
+					 htonl(indev->ifindex)) ||
 			/* this is the bridge group "brX" */
 			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
-			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_INDEV,
-				     htonl(br_port_get_rcu(indev)->br->dev->ifindex));
+			    nla_put_be32(inst->skb, NFULA_IFINDEX_INDEV,
+					 htonl(br_port_get_rcu(indev)->br->dev->ifindex)))
+				goto nla_put_failure;
 		} else {
 			/* Case 2: indev is bridge group, we need to look for
 			 * physical device (when called from ipv4) */
-			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_INDEV,
-				     htonl(indev->ifindex));
-			if (skb->nf_bridge && skb->nf_bridge->physindev)
-				NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
-					     htonl(skb->nf_bridge->physindev->ifindex));
+			if (nla_put_be32(inst->skb, NFULA_IFINDEX_INDEV,
+					 htonl(indev->ifindex)))
+				goto nla_put_failure;
+			if (skb->nf_bridge && skb->nf_bridge->physindev &&
+			    nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
+					 htonl(skb->nf_bridge->physindev->ifindex)))
+				goto nla_put_failure;
 		}
 #endif
 	}
 
 	if (outdev) {
 #ifndef CONFIG_BRIDGE_NETFILTER
-		NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_OUTDEV,
-			     htonl(outdev->ifindex));
+		if (nla_put_be32(inst->skb, NFULA_IFINDEX_OUTDEV,
+				 htonl(outdev->ifindex)))
+			goto nla_put_failure;
 #else
 		if (pf == PF_BRIDGE) {
 			/* Case 1: outdev is physical output device, we need to
 			 * look for bridge group (when called from
 			 * netfilter_bridge) */
-			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
-				     htonl(outdev->ifindex));
+			if (nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
+					 htonl(outdev->ifindex)) ||
 			/* this is the bridge group "brX" */
 			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
-			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_OUTDEV,
-				     htonl(br_port_get_rcu(outdev)->br->dev->ifindex));
+			    nla_put_be32(inst->skb, NFULA_IFINDEX_OUTDEV,
+					 htonl(br_port_get_rcu(outdev)->br->dev->ifindex)))
+				goto nla_put_failure;
 		} else {
 			/* Case 2: indev is a bridge group, we need to look
 			 * for physical device (when called from ipv4) */
-			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_OUTDEV,
-				     htonl(outdev->ifindex));
-			if (skb->nf_bridge && skb->nf_bridge->physoutdev)
-				NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
-					     htonl(skb->nf_bridge->physoutdev->ifindex));
+			if (nla_put_be32(inst->skb, NFULA_IFINDEX_OUTDEV,
+					 htonl(outdev->ifindex)))
+				goto nla_put_failure;
+			if (skb->nf_bridge && skb->nf_bridge->physoutdev &&
+			    nla_put_be32(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
+					 htonl(skb->nf_bridge->physoutdev->ifindex)))
+				goto nla_put_failure;
 		}
 #endif
 	}
 
-	if (skb->mark)
-		NLA_PUT_BE32(inst->skb, NFULA_MARK, htonl(skb->mark));
+	if (skb->mark &&
+	    nla_put_be32(inst->skb, NFULA_MARK, htonl(skb->mark)))
+		goto nla_put_failure;
 
 	if (indev && skb->dev &&
 	    skb->mac_header != skb->network_header) {
@@ -459,16 +470,18 @@ __build_packet_message(struct nfulnl_instance *inst,
 		int len = dev_parse_header(skb, phw.hw_addr);
 		if (len > 0) {
 			phw.hw_addrlen = htons(len);
-			NLA_PUT(inst->skb, NFULA_HWADDR, sizeof(phw), &phw);
+			if (nla_put(inst->skb, NFULA_HWADDR, sizeof(phw), &phw))
+				goto nla_put_failure;
 		}
 	}
 
 	if (indev && skb_mac_header_was_set(skb)) {
-		NLA_PUT_BE16(inst->skb, NFULA_HWTYPE, htons(skb->dev->type));
-		NLA_PUT_BE16(inst->skb, NFULA_HWLEN,
-			     htons(skb->dev->hard_header_len));
-		NLA_PUT(inst->skb, NFULA_HWHEADER, skb->dev->hard_header_len,
-			skb_mac_header(skb));
+		if (nla_put_be32(inst->skb, NFULA_HWTYPE, htons(skb->dev->type)) ||
+		    nla_put_be16(inst->skb, NFULA_HWLEN,
+				 htons(skb->dev->hard_header_len)) ||
+		    nla_put(inst->skb, NFULA_HWHEADER, skb->dev->hard_header_len,
+			    skb_mac_header(skb)))
+			goto nla_put_failure;
 	}
 
 	if (skb->tstamp.tv64) {
@@ -477,7 +490,8 @@ __build_packet_message(struct nfulnl_instance *inst,
 		ts.sec = cpu_to_be64(tv.tv_sec);
 		ts.usec = cpu_to_be64(tv.tv_usec);
 
-		NLA_PUT(inst->skb, NFULA_TIMESTAMP, sizeof(ts), &ts);
+		if (nla_put(inst->skb, NFULA_TIMESTAMP, sizeof(ts), &ts))
+			goto nla_put_failure;
 	}
 
 	/* UID */
@@ -487,22 +501,24 @@ __build_packet_message(struct nfulnl_instance *inst,
 			struct file *file = skb->sk->sk_socket->file;
 			__be32 uid = htonl(file->f_cred->fsuid);
 			__be32 gid = htonl(file->f_cred->fsgid);
-			/* need to unlock here since NLA_PUT may goto */
 			read_unlock_bh(&skb->sk->sk_callback_lock);
-			NLA_PUT_BE32(inst->skb, NFULA_UID, uid);
-			NLA_PUT_BE32(inst->skb, NFULA_GID, gid);
+			if (nla_put_be32(inst->skb, NFULA_UID, uid) ||
+			    nla_put_be32(inst->skb, NFULA_GID, gid))
+				goto nla_put_failure;
 		} else
 			read_unlock_bh(&skb->sk->sk_callback_lock);
 	}
 
 	/* local sequence number */
-	if (inst->flags & NFULNL_CFG_F_SEQ)
-		NLA_PUT_BE32(inst->skb, NFULA_SEQ, htonl(inst->seq++));
+	if ((inst->flags & NFULNL_CFG_F_SEQ) &&
+	    nla_put_be32(inst->skb, NFULA_SEQ, htonl(inst->seq++)))
+		goto nla_put_failure;
 
 	/* global sequence number */
-	if (inst->flags & NFULNL_CFG_F_SEQ_GLOBAL)
-		NLA_PUT_BE32(inst->skb, NFULA_SEQ_GLOBAL,
-			     htonl(atomic_inc_return(&global_seq)));
+	if ((inst->flags & NFULNL_CFG_F_SEQ_GLOBAL) &&
+	    nla_put_be32(inst->skb, NFULA_SEQ_GLOBAL,
+			 htonl(atomic_inc_return(&global_seq))))
+		goto nla_put_failure;
 
 	if (data_len) {
 		struct nlattr *nla;
-- 
1.7.7.6
