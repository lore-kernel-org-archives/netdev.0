From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] net: sctp: let sctp_destroy_sock destroy related members
Date: Fri,  7 Jun 2013 10:35:04 +0200
Message-ID: <1370594106-25745-2-git-send-email-dborkman@redhat.com>
References: <1370594106-25745-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17412 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721Ab3FGIfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 04:35:11 -0400
In-Reply-To: <1370594106-25745-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Release socket related data during sctp_destroy_sock() after we
called sctp_endpoint_free(), but still before we leave the socket
destruction callback. The socket's hmac and bind_hash are only
used in socket.c and actually not in endpointola.c, so also let
it collect the garbage there, no need to go this detour via
endpoints.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/endpointola.c | 7 -------
 net/sctp/socket.c      | 9 +++++++++
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 5fbd7bc..ecfba70 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -248,9 +248,6 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 {
 	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
 
-	/* Free up the HMAC transform. */
-	crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
-
 	/* Free the digest buffer */
 	kfree(ep->digest);
 
@@ -270,10 +267,6 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 
 	memset(ep->secret_key, 0, sizeof(ep->secret_key));
 
-	/* Remove and free the port */
-	if (sctp_sk(ep->base.sk)->bind_hash)
-		sctp_put_port(ep->base.sk);
-
 	/* Give up our hold on the sock. */
 	if (ep->base.sk)
 		sock_put(ep->base.sk);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f631c5f..3267534 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4007,7 +4007,16 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 		sp->do_auto_asconf = 0;
 		list_del(&sp->auto_asconf_list);
 	}
+
 	sctp_endpoint_free(sp->ep);
+
+	/* Free up the HMAC transform. */
+	crypto_free_hash(sp->hmac);
+
+	/* Remove and free the port */
+	if (sp->bind_hash)
+		sctp_put_port(sk);
+
 	local_bh_disable();
 	percpu_counter_dec(&sctp_sockets_allocated);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-- 
1.7.11.7
