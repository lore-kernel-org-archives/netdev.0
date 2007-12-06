From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] SCTP: Fix the bind_addr info during migration.
Date: Thu,  6 Dec 2007 12:48:24 -0500
Message-ID: <1196963304-32494-3-git-send-email-vladislav.yasevich@hp.com>
References: <1196963304-32494-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:6623 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbXLFRs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 12:48:27 -0500
In-Reply-To: <1196963304-32494-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During accept/migrate the code attempts to copy the addresses from
the parent endpoint to the new endpoint.   However, if the parent
was bound to a wildcard address, then we end up pointlessly copying
all of the current addresses on the system.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    3 +++
 net/sctp/bind_addr.c       |   26 ++++++++++++++++++++++++++
 net/sctp/socket.c          |   12 ++----------
 3 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index eb3113c..002a00a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1184,6 +1184,9 @@ int sctp_bind_addr_copy(struct sctp_bind_addr *dest,
 			const struct sctp_bind_addr *src,
 			sctp_scope_t scope, gfp_t gfp,
 			int flags);
+int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
+			const struct sctp_bind_addr *src,
+			gfp_t gfp);
 int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
 		       __u8 use_as_src, gfp_t gfp);
 int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index cae95af..6a7d010 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -105,6 +105,32 @@ out:
 	return error;
 }
 
+/* Exactly duplicate the address lists.  This is necessary when doing
+ * peer-offs and accepts.  We don't want to put all the current system
+ * addresses into the endpoint.  That's useless.  But we do want duplicat
+ * the list of bound addresses that the older endpoint used.
+ */
+int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
+			const struct sctp_bind_addr *src,
+			gfp_t gfp)
+{
+	struct sctp_sockaddr_entry *addr;
+	struct list_head *pos;
+	int error = 0;
+
+	/* All addresses share the same port.  */
+	dest->port = src->port;
+
+	list_for_each(pos, &src->address_list) {
+		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
+		error = sctp_add_bind_addr(dest, &addr->a, 1, gfp);
+		if (error < 0)
+			break;
+	}
+
+	return error;
+}
+
 /* Initialize the SCTP_bind_addr structure for either an endpoint or
  * an association.
  */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9f5d793..ea9649c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6326,7 +6326,6 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	struct sk_buff *skb, *tmp;
 	struct sctp_ulpevent *event;
 	struct sctp_bind_hashbucket *head;
-	int flags = 0;
 
 	/* Migrate socket buffer sizes and all the socket level options to the
 	 * new socket.
@@ -6356,15 +6355,8 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	/* Copy the bind_addr list from the original endpoint to the new
 	 * endpoint so that we can handle restarts properly
 	 */
-	if (PF_INET6 == assoc->base.sk->sk_family)
-		flags = SCTP_ADDR6_ALLOWED;
-	if (assoc->peer.ipv4_address)
-		flags |= SCTP_ADDR4_PEERSUPP;
-	if (assoc->peer.ipv6_address)
-		flags |= SCTP_ADDR6_PEERSUPP;
-	sctp_bind_addr_copy(&newsp->ep->base.bind_addr,
-			     &oldsp->ep->base.bind_addr,
-			     SCTP_SCOPE_GLOBAL, GFP_KERNEL, flags);
+	sctp_bind_addr_dup(&newsp->ep->base.bind_addr,
+				&oldsp->ep->base.bind_addr, GFP_KERNEL);
 
 	/* Move any messages in the old socket's receive queue that are for the
 	 * peeled off association to the new socket's receive queue.
-- 
1.5.3.5

