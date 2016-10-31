From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 3/3] sctp: hold transport instead of assoc when lookup assoc in rx path
Date: Mon, 31 Oct 2016 20:32:33 +0800
Message-ID: <c9aed45c28a86d9983447c856f912416fb801426.1477916928.git.lucien.xin@gmail.com>
References: <cover.1477916928.git.lucien.xin@gmail.com>
 <a58ed3a60643e38876a12ed9193e60f7b38cba4d.1477916928.git.lucien.xin@gmail.com>
 <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477916928.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33320 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938778AbcJaMcx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:32:53 -0400
In-Reply-To: <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477916928.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1477916928.git.lucien.xin@gmail.com>
References: <cover.1477916928.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch, in rx path, before calling lock_sock, it needed to
hold assoc when got it by __sctp_lookup_association, in case other place
would free/put assoc.

But in __sctp_lookup_association, it lookup and hold transport, then got
assoc by transport->assoc, then hold assoc and put transport. It means
it didn't hold transport, yet it was returned and later on directly
assigned to chunk->transport.

Without the protection of sock lock, the transport may be freed/put by
other places, which would cause a use-after-free issue.

This patch is to fix this issue by holding transport instead of assoc.
As holding transport can make sure to access assoc is also safe, and
actually it looks up assoc by searching transport rhashtable, to hold
transport here makes more sense.

Note that the function will be renamed later on on another patch.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h |  2 +-
 net/sctp/input.c        | 32 ++++++++++++++++----------------
 net/sctp/ipv6.c         |  2 +-
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 87a7f42..31acc3f 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -152,7 +152,7 @@ void sctp_unhash_endpoint(struct sctp_endpoint *);
 struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *,
 			     struct sctphdr *, struct sctp_association **,
 			     struct sctp_transport **);
-void sctp_err_finish(struct sock *, struct sctp_association *);
+void sctp_err_finish(struct sock *, struct sctp_transport *);
 void sctp_icmp_frag_needed(struct sock *, struct sctp_association *,
 			   struct sctp_transport *t, __u32 pmtu);
 void sctp_icmp_redirect(struct sock *, struct sctp_transport *,
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 8e0bc58..a01a56e 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -181,9 +181,10 @@ int sctp_rcv(struct sk_buff *skb)
 	 * bound to another interface, via SO_BINDTODEVICE, treat it as OOTB
 	 */
 	if (sk->sk_bound_dev_if && (sk->sk_bound_dev_if != af->skb_iif(skb))) {
-		if (asoc) {
-			sctp_association_put(asoc);
+		if (transport) {
+			sctp_transport_put(transport);
 			asoc = NULL;
+			transport = NULL;
 		} else {
 			sctp_endpoint_put(ep);
 			ep = NULL;
@@ -269,8 +270,8 @@ int sctp_rcv(struct sk_buff *skb)
 	bh_unlock_sock(sk);
 
 	/* Release the asoc/ep ref we took in the lookup calls. */
-	if (asoc)
-		sctp_association_put(asoc);
+	if (transport)
+		sctp_transport_put(transport);
 	else
 		sctp_endpoint_put(ep);
 
@@ -283,8 +284,8 @@ int sctp_rcv(struct sk_buff *skb)
 
 discard_release:
 	/* Release the asoc/ep ref we took in the lookup calls. */
-	if (asoc)
-		sctp_association_put(asoc);
+	if (transport)
+		sctp_transport_put(transport);
 	else
 		sctp_endpoint_put(ep);
 
@@ -300,6 +301,7 @@ int sctp_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct sctp_chunk *chunk = SCTP_INPUT_CB(skb)->chunk;
 	struct sctp_inq *inqueue = &chunk->rcvr->inqueue;
+	struct sctp_transport *t = chunk->transport;
 	struct sctp_ep_common *rcvr = NULL;
 	int backloged = 0;
 
@@ -351,7 +353,7 @@ int sctp_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 done:
 	/* Release the refs we took in sctp_add_backlog */
 	if (SCTP_EP_TYPE_ASSOCIATION == rcvr->type)
-		sctp_association_put(sctp_assoc(rcvr));
+		sctp_transport_put(t);
 	else if (SCTP_EP_TYPE_SOCKET == rcvr->type)
 		sctp_endpoint_put(sctp_ep(rcvr));
 	else
@@ -363,6 +365,7 @@ int sctp_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	struct sctp_chunk *chunk = SCTP_INPUT_CB(skb)->chunk;
+	struct sctp_transport *t = chunk->transport;
 	struct sctp_ep_common *rcvr = chunk->rcvr;
 	int ret;
 
@@ -373,7 +376,7 @@ static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
 		 * from us
 		 */
 		if (SCTP_EP_TYPE_ASSOCIATION == rcvr->type)
-			sctp_association_hold(sctp_assoc(rcvr));
+			sctp_transport_hold(t);
 		else if (SCTP_EP_TYPE_SOCKET == rcvr->type)
 			sctp_endpoint_hold(sctp_ep(rcvr));
 		else
@@ -537,15 +540,15 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
 	return sk;
 
 out:
-	sctp_association_put(asoc);
+	sctp_transport_put(transport);
 	return NULL;
 }
 
 /* Common cleanup code for icmp/icmpv6 error handler. */
-void sctp_err_finish(struct sock *sk, struct sctp_association *asoc)
+void sctp_err_finish(struct sock *sk, struct sctp_transport *t)
 {
 	bh_unlock_sock(sk);
-	sctp_association_put(asoc);
+	sctp_transport_put(t);
 }
 
 /*
@@ -641,7 +644,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	}
 
 out_unlock:
-	sctp_err_finish(sk, asoc);
+	sctp_err_finish(sk, transport);
 }
 
 /*
@@ -952,11 +955,8 @@ static struct sctp_association *__sctp_lookup_association(
 		goto out;
 
 	asoc = t->asoc;
-	sctp_association_hold(asoc);
 	*pt = t;
 
-	sctp_transport_put(t);
-
 out:
 	return asoc;
 }
@@ -986,7 +986,7 @@ int sctp_has_association(struct net *net,
 	struct sctp_transport *transport;
 
 	if ((asoc = sctp_lookup_association(net, laddr, paddr, &transport))) {
-		sctp_association_put(asoc);
+		sctp_transport_put(transport);
 		return 1;
 	}
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index f473779..176af30 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -198,7 +198,7 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	}
 
 out_unlock:
-	sctp_err_finish(sk, asoc);
+	sctp_err_finish(sk, transport);
 out:
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
-- 
2.1.0
