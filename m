From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] [SCTP] Fix potential null pointer dereference while
	handling an icmp error
Date: Wed, 13 Jul 2005 17:54:45 -0700
Message-ID: <1121302485.5841.30.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@oss.sgi.com,
        cdeboys@stevens.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please apply the following patch which fixes a potential null pointer
dereference while handling an icmp error in sctp_icmp_* routines. These
routines assume that we are passing a valid asoc.

Reported by Charles-Henri de Boysson <cdeboys@stevens.edu>

Thanks
Sridhar

---------------------------------------------------------------------
[SCTP] Fix potential null pointer dereference while handling an icmp
error

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -167,15 +167,12 @@ void sctp_unhash_established(struct sctp
 void sctp_hash_endpoint(struct sctp_endpoint *);
 void sctp_unhash_endpoint(struct sctp_endpoint *);
 struct sock *sctp_err_lookup(int family, struct sk_buff *,
-			     struct sctphdr *, struct sctp_endpoint **,
-			     struct sctp_association **,
+			     struct sctphdr *, struct sctp_association **,
 			     struct sctp_transport **);
-void sctp_err_finish(struct sock *, struct sctp_endpoint *,
-			    struct sctp_association *);
+void sctp_err_finish(struct sock *, struct sctp_association *);
 void sctp_icmp_frag_needed(struct sock *, struct sctp_association *,
 			   struct sctp_transport *t, __u32 pmtu);
 void sctp_icmp_proto_unreachable(struct sock *sk,
-				 struct sctp_endpoint *ep,
 				 struct sctp_association *asoc,
 				 struct sctp_transport *t);
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -351,7 +351,6 @@ void sctp_icmp_frag_needed(struct sock *
  *
  */
 void sctp_icmp_proto_unreachable(struct sock *sk,
-                           struct sctp_endpoint *ep,
                            struct sctp_association *asoc,
                            struct sctp_transport *t)
 {
@@ -367,7 +366,6 @@ void sctp_icmp_proto_unreachable(struct 
 /* Common lookup code for icmp/icmpv6 error handler. */
 struct sock *sctp_err_lookup(int family, struct sk_buff *skb,
 			     struct sctphdr *sctphdr,
-			     struct sctp_endpoint **epp,
 			     struct sctp_association **app,
 			     struct sctp_transport **tpp)
 {
@@ -375,11 +373,10 @@ struct sock *sctp_err_lookup(int family,
 	union sctp_addr daddr;
 	struct sctp_af *af;
 	struct sock *sk = NULL;
-	struct sctp_endpoint *ep = NULL;
 	struct sctp_association *asoc = NULL;
 	struct sctp_transport *transport = NULL;
 
-	*app = NULL; *epp = NULL; *tpp = NULL;
+	*app = NULL; *tpp = NULL;
 
 	af = sctp_get_af_specific(family);
 	if (unlikely(!af)) {
@@ -394,26 +391,15 @@ struct sock *sctp_err_lookup(int family,
 	 * packet.
 	 */
 	asoc = __sctp_lookup_association(&saddr, &daddr, &transport);
-	if (!asoc) {
-		/* If there is no matching association, see if it matches any
-		 * endpoint. This may happen for an ICMP error generated in
-		 * response to an INIT_ACK.
-		 */
-		ep = __sctp_rcv_lookup_endpoint(&daddr);
-		if (!ep) {
-			return NULL;
-		}
-	}
+	if (!asoc)
+		return NULL;
 
-	if (asoc) {
-		sk = asoc->base.sk;
+	sk = asoc->base.sk;
 
-		if (ntohl(sctphdr->vtag) != asoc->c.peer_vtag) {
-			ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
-			goto out;
-		}
-	} else
-		sk = ep->base.sk;
+	if (ntohl(sctphdr->vtag) != asoc->c.peer_vtag) {
+		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+		goto out;
+	}
 
 	sctp_bh_lock_sock(sk);
 
@@ -423,7 +409,6 @@ struct sock *sctp_err_lookup(int family,
 	if (sock_owned_by_user(sk))
 		NET_INC_STATS_BH(LINUX_MIB_LOCKDROPPEDICMPS);
 
-	*epp = ep;
 	*app = asoc;
 	*tpp = transport;
 	return sk;
@@ -432,21 +417,16 @@ out:
 	sock_put(sk);
 	if (asoc)
 		sctp_association_put(asoc);
-	if (ep)
-		sctp_endpoint_put(ep);
 	return NULL;
 }
 
 /* Common cleanup code for icmp/icmpv6 error handler. */
-void sctp_err_finish(struct sock *sk, struct sctp_endpoint *ep,
-		     struct sctp_association *asoc)
+void sctp_err_finish(struct sock *sk, struct sctp_association *asoc)
 {
 	sctp_bh_unlock_sock(sk);
 	sock_put(sk);
 	if (asoc)
 		sctp_association_put(asoc);
-	if (ep)
-		sctp_endpoint_put(ep);
 }
 
 /*
@@ -471,7 +451,6 @@ void sctp_v4_err(struct sk_buff *skb, __
 	int type = skb->h.icmph->type;
 	int code = skb->h.icmph->code;
 	struct sock *sk;
-	struct sctp_endpoint *ep;
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
 	struct inet_sock *inet;
@@ -488,7 +467,7 @@ void sctp_v4_err(struct sk_buff *skb, __
 	savesctp  = skb->h.raw;
 	skb->nh.iph = iph;
 	skb->h.raw = (char *)sh;
-	sk = sctp_err_lookup(AF_INET, skb, sh, &ep, &asoc, &transport);
+	sk = sctp_err_lookup(AF_INET, skb, sh, &asoc, &transport);
 	/* Put back, the original pointers. */
 	skb->nh.raw = saveip;
 	skb->h.raw = savesctp;
@@ -515,7 +494,7 @@ void sctp_v4_err(struct sk_buff *skb, __
 		}
 		else {
 			if (ICMP_PROT_UNREACH == code) {
-				sctp_icmp_proto_unreachable(sk, ep, asoc,
+				sctp_icmp_proto_unreachable(sk, asoc,
 							    transport);
 				goto out_unlock;
 			}
@@ -544,7 +523,7 @@ void sctp_v4_err(struct sk_buff *skb, __
 	}
 
 out_unlock:
-	sctp_err_finish(sk, ep, asoc);
+	sctp_err_finish(sk, asoc);
 }
 
 /*
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -91,7 +91,6 @@ SCTP_STATIC void sctp_v6_err(struct sk_b
 	struct ipv6hdr *iph = (struct ipv6hdr *)skb->data;
 	struct sctphdr *sh = (struct sctphdr *)(skb->data + offset);
 	struct sock *sk;
-	struct sctp_endpoint *ep;
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
 	struct ipv6_pinfo *np;
@@ -105,7 +104,7 @@ SCTP_STATIC void sctp_v6_err(struct sk_b
 	savesctp  = skb->h.raw;
 	skb->nh.ipv6h = iph;
 	skb->h.raw = (char *)sh;
-	sk = sctp_err_lookup(AF_INET6, skb, sh, &ep, &asoc, &transport);
+	sk = sctp_err_lookup(AF_INET6, skb, sh, &asoc, &transport);
 	/* Put back, the original pointers. */
 	skb->nh.raw = saveip;
 	skb->h.raw = savesctp;
@@ -124,7 +123,7 @@ SCTP_STATIC void sctp_v6_err(struct sk_b
 		goto out_unlock;
 	case ICMPV6_PARAMPROB:
 		if (ICMPV6_UNK_NEXTHDR == code) {
-			sctp_icmp_proto_unreachable(sk, ep, asoc, transport);
+			sctp_icmp_proto_unreachable(sk, asoc, transport);
 			goto out_unlock;
 		}
 		break;
@@ -142,7 +141,7 @@ SCTP_STATIC void sctp_v6_err(struct sk_b
 	}
 
 out_unlock:
-	sctp_err_finish(sk, ep, asoc);
+	sctp_err_finish(sk, asoc);
 out:
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
