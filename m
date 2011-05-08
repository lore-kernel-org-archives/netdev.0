From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/15] sctp: Store a flowi in transports to provide
 persistent keying.
Date: Sun, 08 May 2011 15:37:44 -0700 (PDT)
Message-ID: <20110508.153744.48524428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42653
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755717Ab1EHWiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6C58824C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several future simplifications are possible now because of this.

For example, the sctp_addr unions can simply refer directly to
the flowi information.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sctp/structs.h |    1 +
 net/sctp/transport.c       |    9 +++------
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index ff3e8cc..795f488 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -894,6 +894,7 @@ struct sctp_transport {
 		/* Is this structure kfree()able? */
 		malloced:1;
 
+	struct flowi fl;
 
 	/* This is the peer's IP address and port. */
 	union sctp_addr ipaddr;
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index d8595dd..394c57c 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -213,13 +213,11 @@ void sctp_transport_set_owner(struct sctp_transport *transport,
 /* Initialize the pmtu of a transport. */
 void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 {
-	struct flowi fl;
-
 	/* If we don't have a fresh route, look one up */
 	if (!transport->dst || transport->dst->obsolete > 1) {
 		dst_release(transport->dst);
 		transport->af_specific->get_dst(transport, &transport->saddr,
-					      &fl, sk);
+						&transport->fl, sk);
 	}
 
 	if (transport->dst) {
@@ -274,14 +272,13 @@ void sctp_transport_route(struct sctp_transport *transport,
 {
 	struct sctp_association *asoc = transport->asoc;
 	struct sctp_af *af = transport->af_specific;
-	struct flowi fl;
 
-	af->get_dst(transport, saddr, &fl, sctp_opt2sk(opt));
+	af->get_dst(transport, saddr, &transport->fl, sctp_opt2sk(opt));
 
 	if (saddr)
 		memcpy(&transport->saddr, saddr, sizeof(union sctp_addr));
 	else
-		af->get_saddr(opt, transport, &fl);
+		af->get_saddr(opt, transport, &transport->fl);
 
 	if ((transport->param_flags & SPP_PMTUD_DISABLE) && transport->pathmtu) {
 		return;
-- 
1.7.5.1

