From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 6/6] sctp: not return ENOMEM err back in sctp_packet_transmit
Date: Wed, 14 Sep 2016 02:04:23 +0800
Message-ID: <099da3a4fed2e30a29326e9ffb2517858d29e288.1473789537.git.lucien.xin@gmail.com>
References: <cover.1473789537.git.lucien.xin@gmail.com>
 <4f21a8880a3f8e7daed8a53f10649a1d4dfbb12a.1473789537.git.lucien.xin@gmail.com>
 <10622d6256e2c49fa7ec555dec3bd35b47a50b2b.1473789537.git.lucien.xin@gmail.com>
 <6b43f456f94dfcaeabc8071806f0609fed59a595.1473789537.git.lucien.xin@gmail.com>
 <f4f0d53e93368c69f55df9f4aba4da2148fcca7e.1473789537.git.lucien.xin@gmail.com>
 <6599cec72f3ff913d3b99e60d5f2014df26915de.1473789537.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36542 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755296AbcIMSEw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 14:04:52 -0400
In-Reply-To: <6599cec72f3ff913d3b99e60d5f2014df26915de.1473789537.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1473789537.git.lucien.xin@gmail.com>
References: <cover.1473789537.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As David and Marcelo's suggestion, ENOMEM err shouldn't return back to
user in transmit path. Instead, sctp's retransmit would take care of
the chunks that fail to send because of ENOMEM.

This patch is only to do some release job when alloc_skb fails, not to
return ENOMEM back any more.

Besides, it also cleans up sctp_packet_transmit's err path, and fixes
some issues in err path:

 - It didn't free the head skb in nomem: path.
 - No need to check nskb in no_route: path.
 - It should goto err: path if alloc_skb fails for head.
 - Not all the NOMEMs should free nskb.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/output.c | 47 ++++++++++++++++++++++-------------------------
 1 file changed, 22 insertions(+), 25 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index f2597a9..0c605ec 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -442,14 +442,14 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 			 * time. Application may notice this error.
 			 */
 			pr_err_once("Trying to GSO but underlying device doesn't support it.");
-			goto nomem;
+			goto err;
 		}
 	} else {
 		pkt_size = packet->size;
 	}
 	head = alloc_skb(pkt_size + MAX_HEADER, gfp);
 	if (!head)
-		goto nomem;
+		goto err;
 	if (gso) {
 		NAPI_GRO_CB(head)->last = head;
 		skb_shinfo(head)->gso_type = sk->sk_gso_type;
@@ -470,8 +470,12 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 		}
 	}
 	dst = dst_clone(tp->dst);
-	if (!dst)
-		goto no_route;
+	if (!dst) {
+		if (asoc)
+			IP_INC_STATS(sock_net(asoc->base.sk),
+				     IPSTATS_MIB_OUTNOROUTES);
+		goto nodst;
+	}
 	skb_dst_set(head, dst);
 
 	/* Build the SCTP header.  */
@@ -622,8 +626,10 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 		if (!gso)
 			break;
 
-		if (skb_gro_receive(&head, nskb))
+		if (skb_gro_receive(&head, nskb)) {
+			kfree_skb(nskb);
 			goto nomem;
+		}
 		nskb = NULL;
 		if (WARN_ON_ONCE(skb_shinfo(head)->gso_segs >=
 				 sk->sk_gso_max_segs))
@@ -717,18 +723,13 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	}
 	head->ignore_df = packet->ipfragok;
 	tp->af_specific->sctp_xmit(head, tp);
+	goto out;
 
-out:
-	sctp_packet_reset(packet);
-	return err;
-no_route:
-	kfree_skb(head);
-	if (nskb != head)
-		kfree_skb(nskb);
-
-	if (asoc)
-		IP_INC_STATS(sock_net(asoc->base.sk), IPSTATS_MIB_OUTNOROUTES);
+nomem:
+	if (packet->auth && list_empty(&packet->auth->list))
+		sctp_chunk_free(packet->auth);
 
+nodst:
 	/* FIXME: Returning the 'err' will effect all the associations
 	 * associated with a socket, although only one of the paths of the
 	 * association is unreachable.
@@ -737,22 +738,18 @@ no_route:
 	 * required.
 	 */
 	 /* err = -EHOSTUNREACH; */
-err:
-	/* Control chunks are unreliable so just drop them.  DATA chunks
-	 * will get resent or dropped later.
-	 */
+	kfree_skb(head);
 
+err:
 	list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
 		list_del_init(&chunk->list);
 		if (!sctp_chunk_is_data(chunk))
 			sctp_chunk_free(chunk);
 	}
-	goto out;
-nomem:
-	if (packet->auth && list_empty(&packet->auth->list))
-		sctp_chunk_free(packet->auth);
-	err = -ENOMEM;
-	goto err;
+
+out:
+	sctp_packet_reset(packet);
+	return err;
 }
 
 /********************************************************************
-- 
2.1.0
