From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net] sctp: fix ICMP processing if skb is non-linear
Date: Fri, 19 May 2017 17:34:46 +0200
Message-ID: <cb2535a6a40a84684f26d7c7d26788cc3f8a2010.1495207495.git.dcaratti@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Xin Long <lucien.xin@gmail.com>
To: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52136 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751667AbdESPe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 11:34:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when the ICMP packet is carried by a paged skb, sctp_err_lookup() may fail
validation even if the payload contents match an open socket: as a
consequence, sometimes ICMPs are wrongly ignored. Use skb_header_pointer()
to retrieve encapsulated SCTP headers, to ensure that ICMP payloads are
validated correctly, also when skbs are non-linear.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/net/sctp/sctp.h |  2 +-
 net/sctp/input.c        | 29 +++++++++++++++++++----------
 net/sctp/ipv6.c         |  2 +-
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 069582e..1b8c16b 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -152,7 +152,7 @@ void sctp_v4_err(struct sk_buff *skb, u32 info);
 void sctp_hash_endpoint(struct sctp_endpoint *);
 void sctp_unhash_endpoint(struct sctp_endpoint *);
 struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *,
-			     struct sctphdr *, struct sctp_association **,
+			     struct sctp_association **,
 			     struct sctp_transport **);
 void sctp_err_finish(struct sock *, struct sctp_transport *);
 void sctp_icmp_frag_needed(struct sock *, struct sctp_association *,
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 0e06a27..7f3f983 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -469,19 +469,19 @@ void sctp_icmp_proto_unreachable(struct sock *sk,
 
 /* Common lookup code for icmp/icmpv6 error handler. */
 struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
-			     struct sctphdr *sctphdr,
 			     struct sctp_association **app,
 			     struct sctp_transport **tpp)
 {
+	struct sctp_init_chunk _chunkhdr, *chunkhdr;
+	struct sctphdr _sctphdr, *sctphdr;
 	union sctp_addr saddr;
 	union sctp_addr daddr;
 	struct sctp_af *af;
 	struct sock *sk = NULL;
 	struct sctp_association *asoc;
 	struct sctp_transport *transport = NULL;
-	struct sctp_init_chunk *chunkhdr;
-	__u32 vtag = ntohl(sctphdr->vtag);
-	int len = skb->len - ((void *)sctphdr - (void *)skb->data);
+	int offset;
+	__u32 vtag;
 
 	*app = NULL; *tpp = NULL;
 
@@ -515,14 +515,23 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
 	 * or the chunk type or the Initiate Tag does not match, silently
 	 * discard the packet.
 	 */
+	offset = skb_transport_offset(skb);
+	sctphdr = skb_header_pointer(skb, offset, sizeof(_sctphdr), &_sctphdr);
+	if (unlikely(!sctphdr))
+		goto out;
+
+	vtag = ntohl(sctphdr->vtag);
 	if (vtag == 0) {
-		chunkhdr = (void *)sctphdr + sizeof(struct sctphdr);
-		if (len < sizeof(struct sctphdr) + sizeof(sctp_chunkhdr_t)
-			  + sizeof(__be32) ||
+		offset += sizeof(_sctphdr);
+		/* chunk header + first 4 octects of init header */
+		chunkhdr = skb_header_pointer(skb, offset,
+					      sizeof(struct sctp_chunkhdr) +
+					      sizeof(__be32), &_chunkhdr);
+		if (!chunkhdr ||
 		    chunkhdr->chunk_hdr.type != SCTP_CID_INIT ||
-		    ntohl(chunkhdr->init_hdr.init_tag) != asoc->c.my_vtag) {
+		    ntohl(chunkhdr->init_hdr.init_tag) != asoc->c.my_vtag)
 			goto out;
-		}
+
 	} else if (vtag != asoc->c.peer_vtag) {
 		goto out;
 	}
@@ -585,7 +594,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	savesctp = skb->transport_header;
 	skb_reset_network_header(skb);
 	skb_set_transport_header(skb, ihlen);
-	sk = sctp_err_lookup(net, AF_INET, skb, sctp_hdr(skb), &asoc, &transport);
+	sk = sctp_err_lookup(net, AF_INET, skb, &asoc, &transport);
 	/* Put back, the original values. */
 	skb->network_header = saveip;
 	skb->transport_header = savesctp;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 142b70e..d72c8d5 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -157,7 +157,7 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	savesctp = skb->transport_header;
 	skb_reset_network_header(skb);
 	skb_set_transport_header(skb, offset);
-	sk = sctp_err_lookup(net, AF_INET6, skb, sctp_hdr(skb), &asoc, &transport);
+	sk = sctp_err_lookup(net, AF_INET6, skb, &asoc, &transport);
 	/* Put back, the original pointers. */
 	skb->network_header   = saveip;
 	skb->transport_header = savesctp;
-- 
2.7.4
