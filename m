From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: support to lookup with ep+paddr in transport rhashtable
Date: Thu, 14 Jan 2016 13:49:34 +0800
Message-ID: <66cb37a6d0c3776e9eb3adf0bf6fc33ff947eb63.1452750574.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36710 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbcANFti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 00:49:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, when we sendmsg, we translate the ep to laddr by selecting the
first element of the list, and then do a lookup for a transport.

But sctp_hash_cmp() will compare it against asoc addr_list, which may
be a subset of ep addr_list, meaning that this chosen laddr may not be
there, and thus making it impossible to find the transport.

So we fix it by using ep + paddr to lookup transports in hashtable. In
sctp_hash_cmp, if .ep is set, we will check if this ep == asoc->ep,
or we will do the laddr check.

Fixes: d6c0256a60e6 ("sctp: add the rhashtable apis for sctp global transport hashtable")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Reported-by: Vlad Yasevich <vyasevich@gmail.com>
---
 net/sctp/input.c | 38 +++++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index d9a6e66..b9a536b 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -784,6 +784,7 @@ hit:
 
 /* rhashtable for transport */
 struct sctp_hash_cmp_arg {
+	const struct sctp_endpoint	*ep;
 	const union sctp_addr		*laddr;
 	const union sctp_addr		*paddr;
 	const struct net		*net;
@@ -797,15 +798,20 @@ static inline int sctp_hash_cmp(struct rhashtable_compare_arg *arg,
 	struct sctp_association *asoc = t->asoc;
 	const struct net *net = x->net;
 
-	if (x->laddr->v4.sin_port != htons(asoc->base.bind_addr.port))
-		return 1;
 	if (!sctp_cmp_addr_exact(&t->ipaddr, x->paddr))
 		return 1;
 	if (!net_eq(sock_net(asoc->base.sk), net))
 		return 1;
-	if (!sctp_bind_addr_match(&asoc->base.bind_addr,
-				  x->laddr, sctp_sk(asoc->base.sk)))
-		return 1;
+	if (x->ep) {
+		if (x->ep != asoc->ep)
+			return 1;
+	} else {
+		if (x->laddr->v4.sin_port != htons(asoc->base.bind_addr.port))
+			return 1;
+		if (!sctp_bind_addr_match(&asoc->base.bind_addr,
+					  x->laddr, sctp_sk(asoc->base.sk)))
+			return 1;
+	}
 
 	return 0;
 }
@@ -832,9 +838,11 @@ static inline u32 sctp_hash_key(const void *data, u32 len, u32 seed)
 	const struct sctp_hash_cmp_arg *x = data;
 	const union sctp_addr *paddr = x->paddr;
 	const struct net *net = x->net;
-	u16 lport = x->laddr->v4.sin_port;
+	u16 lport;
 	u32 addr;
 
+	lport = x->ep ? htons(x->ep->base.bind_addr.port) :
+			x->laddr->v4.sin_port;
 	if (paddr->sa.sa_family == AF_INET6)
 		addr = jhash(&paddr->v6.sin6_addr, 16, seed);
 	else
@@ -864,12 +872,9 @@ void sctp_transport_hashtable_destroy(void)
 
 void sctp_hash_transport(struct sctp_transport *t)
 {
-	struct sctp_sockaddr_entry *addr;
 	struct sctp_hash_cmp_arg arg;
 
-	addr = list_entry(t->asoc->base.bind_addr.address_list.next,
-			  struct sctp_sockaddr_entry, list);
-	arg.laddr = &addr->a;
+	arg.ep = t->asoc->ep;
 	arg.paddr = &t->ipaddr;
 	arg.net   = sock_net(t->asoc->base.sk);
 
@@ -891,6 +896,7 @@ struct sctp_transport *sctp_addrs_lookup_transport(
 				const union sctp_addr *paddr)
 {
 	struct sctp_hash_cmp_arg arg = {
+		.ep    = NULL,
 		.laddr = laddr,
 		.paddr = paddr,
 		.net   = net,
@@ -904,13 +910,15 @@ struct sctp_transport *sctp_epaddr_lookup_transport(
 				const struct sctp_endpoint *ep,
 				const union sctp_addr *paddr)
 {
-	struct sctp_sockaddr_entry *addr;
 	struct net *net = sock_net(ep->base.sk);
+	struct sctp_hash_cmp_arg arg = {
+		.ep    = ep,
+		.paddr = paddr,
+		.net   = net,
+	};
 
-	addr = list_entry(ep->base.bind_addr.address_list.next,
-			  struct sctp_sockaddr_entry, list);
-
-	return sctp_addrs_lookup_transport(net, &addr->a, paddr);
+	return rhashtable_lookup_fast(&sctp_transport_hashtable, &arg,
+				      sctp_hash_params);
 }
 
 /* Look up an association. */
-- 
2.1.0
