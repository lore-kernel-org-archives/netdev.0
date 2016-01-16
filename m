From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: the temp asoc's transports should not be hashed/unhashed
Date: Sat, 16 Jan 2016 20:17:17 +0800
Message-ID: <488453d4e06805934290a1ef3cf633ee4b26bdc6.1452946637.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35509 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbcAPMRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2016 07:17:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-establish the previous behavior and avoid hashing temporary asocs by
checking t->asoc->temp in sctp_(un)hash_transport. Also, remove the
check of t->asoc->temp in __sctp_lookup_association, since they are
never hashed now.

Fixes: 4f0087812648 ("sctp: apply rhashtable api to send/recv path")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Reported-by: Vlad Yasevich <vyasevich@gmail.com>
---
 net/sctp/endpointola.c | 2 +-
 net/sctp/input.c       | 8 +++++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 52838ea..2522a61 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -333,7 +333,7 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
 	if (!ep->base.bind_addr.port)
 		goto out;
 	t = sctp_epaddr_lookup_transport(ep, paddr);
-	if (!t || t->asoc->temp)
+	if (!t)
 		goto out;
 
 	*transport = t;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index b9a536b..bf61dfb 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -874,6 +874,9 @@ void sctp_hash_transport(struct sctp_transport *t)
 {
 	struct sctp_hash_cmp_arg arg;
 
+	if (t->asoc->temp)
+		return;
+
 	arg.ep = t->asoc->ep;
 	arg.paddr = &t->ipaddr;
 	arg.net   = sock_net(t->asoc->base.sk);
@@ -886,6 +889,9 @@ reinsert:
 
 void sctp_unhash_transport(struct sctp_transport *t)
 {
+	if (t->asoc->temp)
+		return;
+
 	rhashtable_remove_fast(&sctp_transport_hashtable, &t->node,
 			       sctp_hash_params);
 }
@@ -931,7 +937,7 @@ static struct sctp_association *__sctp_lookup_association(
 	struct sctp_transport *t;
 
 	t = sctp_addrs_lookup_transport(net, local, peer);
-	if (!t || t->dead || t->asoc->temp)
+	if (!t || t->dead)
 		return NULL;
 
 	sctp_association_hold(t->asoc);
-- 
2.1.0
