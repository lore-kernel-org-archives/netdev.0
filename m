From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: Set source addresses on the association before adding transports
Date: Tue, 10 Nov 2009 13:57:34 -0500
Message-ID: <1257879454-31661-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:33045 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757765AbZKJS5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:57:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent commit 8da645e101a8c20c6073efda3c7cc74eec01b87f
	sctp: Get rid of an extra routing lookup when adding a transport
introduced a regression in the connection setup.  The behavior was
different between IPv4 and IPv6.  IPv4 case ended up working because the
route lookup routing returned a NULL route, which triggered another
route lookup later in the output patch that succeeded.  In the IPv6 case,
a valid route was returned for first call, but we could not find a valid
source address at the time since the source addresses were not set on the
association yet.  Thus resulted in a hung connection.

The solution is to set the source addresses on the association prior to
adding peers.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    2 +-
 net/sctp/associola.c       |    4 +---
 net/sctp/sm_statefuns.c    |   15 +++++++++------
 net/sctp/socket.c          |   22 ++++++++++++----------
 4 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6e5f0e0..cd2e187 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1980,7 +1980,7 @@ void sctp_assoc_set_primary(struct sctp_association *,
 void sctp_assoc_del_nonprimary_peers(struct sctp_association *,
 				    struct sctp_transport *);
 int sctp_assoc_set_bind_addr_from_ep(struct sctp_association *,
-				     gfp_t);
+				     sctp_scope_t, gfp_t);
 int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *,
 					 struct sctp_cookie*,
 					 gfp_t gfp);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 8450960..7eed77a 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1485,15 +1485,13 @@ void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned len)
  * local endpoint and the remote peer.
  */
 int sctp_assoc_set_bind_addr_from_ep(struct sctp_association *asoc,
-				     gfp_t gfp)
+				     sctp_scope_t scope, gfp_t gfp)
 {
-	sctp_scope_t scope;
 	int flags;
 
 	/* Use scoping rules to determine the subset of addresses from
 	 * the endpoint.
 	 */
-	scope = sctp_scope(&asoc->peer.active_path->ipaddr);
 	flags = (PF_INET6 == asoc->base.sk->sk_family) ? SCTP_ADDR6_ALLOWED : 0;
 	if (asoc->peer.ipv4_address)
 		flags |= SCTP_ADDR4_PEERSUPP;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index c8fae19..d4df450 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -384,6 +384,11 @@ sctp_disposition_t sctp_sf_do_5_1B_init(const struct sctp_endpoint *ep,
 	if (!new_asoc)
 		goto nomem;
 
+	if (sctp_assoc_set_bind_addr_from_ep(new_asoc,
+					     sctp_scope(sctp_source(chunk)),
+					     GFP_ATOMIC) < 0)
+		goto nomem_init;
+
 	/* The call, sctp_process_init(), can fail on memory allocation.  */
 	if (!sctp_process_init(new_asoc, chunk->chunk_hdr->type,
 			       sctp_source(chunk),
@@ -401,9 +406,6 @@ sctp_disposition_t sctp_sf_do_5_1B_init(const struct sctp_endpoint *ep,
 		len = ntohs(err_chunk->chunk_hdr->length) -
 			sizeof(sctp_chunkhdr_t);
 
-	if (sctp_assoc_set_bind_addr_from_ep(new_asoc, GFP_ATOMIC) < 0)
-		goto nomem_init;
-
 	repl = sctp_make_init_ack(new_asoc, chunk, GFP_ATOMIC, len);
 	if (!repl)
 		goto nomem_init;
@@ -1452,6 +1454,10 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	if (!new_asoc)
 		goto nomem;
 
+	if (sctp_assoc_set_bind_addr_from_ep(new_asoc,
+				sctp_scope(sctp_source(chunk)), GFP_ATOMIC) < 0)
+		goto nomem;
+
 	/* In the outbound INIT ACK the endpoint MUST copy its current
 	 * Verification Tag and Peers Verification tag into a reserved
 	 * place (local tie-tag and per tie-tag) within the state cookie.
@@ -1488,9 +1494,6 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 			sizeof(sctp_chunkhdr_t);
 	}
 
-	if (sctp_assoc_set_bind_addr_from_ep(new_asoc, GFP_ATOMIC) < 0)
-		goto nomem;
-
 	repl = sctp_make_init_ack(new_asoc, chunk, GFP_ATOMIC, len);
 	if (!repl)
 		goto nomem;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c8d0575..bf705ba 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1080,6 +1080,13 @@ static int __sctp_connect(struct sock* sk,
 				err = -ENOMEM;
 				goto out_free;
 			}
+
+			err = sctp_assoc_set_bind_addr_from_ep(asoc, scope,
+							      GFP_KERNEL);
+			if (err < 0) {
+				goto out_free;
+			}
+
 		}
 
 		/* Prime the peer's transport structures.  */
@@ -1095,11 +1102,6 @@ static int __sctp_connect(struct sock* sk,
 		walk_size += af->sockaddr_len;
 	}
 
-	err = sctp_assoc_set_bind_addr_from_ep(asoc, GFP_KERNEL);
-	if (err < 0) {
-		goto out_free;
-	}
-
 	/* In case the user of sctp_connectx() wants an association
 	 * id back, assign one now.
 	 */
@@ -1689,6 +1691,11 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			goto out_unlock;
 		}
 		asoc = new_asoc;
+		err = sctp_assoc_set_bind_addr_from_ep(asoc, scope, GFP_KERNEL);
+		if (err < 0) {
+			err = -ENOMEM;
+			goto out_free;
+		}
 
 		/* If the SCTP_INIT ancillary data is specified, set all
 		 * the association init values accordingly.
@@ -1718,11 +1725,6 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			err = -ENOMEM;
 			goto out_free;
 		}
-		err = sctp_assoc_set_bind_addr_from_ep(asoc, GFP_KERNEL);
-		if (err < 0) {
-			err = -ENOMEM;
-			goto out_free;
-		}
 	}
 
 	/* ASSERT: we have a valid association at this point.  */
-- 
1.6.0.4

