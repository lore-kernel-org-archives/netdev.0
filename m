From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/5] sctp: Adjust PMTU updates to accomodate route
 invalidation.
Date: Tue, 17 Jul 2012 06:14:28 -0700 (PDT)
Message-ID: <20120717.061428.520315266334224994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab2GQNO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:14:28 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id A1C2E5837B7
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 06:14:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This adjusts the call to dst_ops->update_pmtu() so that we can
transparently handle the fact that, in the future, the dst itself can
be invalidated by the PMTU update (when we have non-host routes cached
in sockets).

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sctp/sctp.h    |    4 ++--
 include/net/sctp/structs.h |    4 ++--
 net/sctp/associola.c       |    4 ++--
 net/sctp/input.c           |    4 ++--
 net/sctp/output.c          |    2 +-
 net/sctp/socket.c          |    6 +++---
 net/sctp/transport.c       |   12 ++++++++++--
 7 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 1f2735d..ff49964 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -519,10 +519,10 @@ static inline int sctp_frag_point(const struct sctp_association *asoc, int pmtu)
 	return frag;
 }
 
-static inline void sctp_assoc_pending_pmtu(struct sctp_association *asoc)
+static inline void sctp_assoc_pending_pmtu(struct sock *sk, struct sctp_association *asoc)
 {
 
-	sctp_assoc_sync_pmtu(asoc);
+	sctp_assoc_sync_pmtu(sk, asoc);
 	asoc->pmtu_pending = 0;
 }
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index fecdf31..536e439 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1091,7 +1091,7 @@ void sctp_transport_burst_limited(struct sctp_transport *);
 void sctp_transport_burst_reset(struct sctp_transport *);
 unsigned long sctp_transport_timeout(struct sctp_transport *);
 void sctp_transport_reset(struct sctp_transport *);
-void sctp_transport_update_pmtu(struct sctp_transport *, u32);
+void sctp_transport_update_pmtu(struct sock *, struct sctp_transport *, u32);
 void sctp_transport_immediate_rtx(struct sctp_transport *);
 
 
@@ -2003,7 +2003,7 @@ void sctp_assoc_update(struct sctp_association *old,
 
 __u32 sctp_association_get_next_tsn(struct sctp_association *);
 
-void sctp_assoc_sync_pmtu(struct sctp_association *);
+void sctp_assoc_sync_pmtu(struct sock *, struct sctp_association *);
 void sctp_assoc_rwnd_increase(struct sctp_association *, unsigned int);
 void sctp_assoc_rwnd_decrease(struct sctp_association *, unsigned int);
 void sctp_assoc_set_primary(struct sctp_association *,
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b16517e..8cf348e 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1360,7 +1360,7 @@ struct sctp_transport *sctp_assoc_choose_alter_transport(
 /* Update the association's pmtu and frag_point by going through all the
  * transports. This routine is called when a transport's PMTU has changed.
  */
-void sctp_assoc_sync_pmtu(struct sctp_association *asoc)
+void sctp_assoc_sync_pmtu(struct sock *sk, struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
 	__u32 pmtu = 0;
@@ -1372,7 +1372,7 @@ void sctp_assoc_sync_pmtu(struct sctp_association *asoc)
 	list_for_each_entry(t, &asoc->peer.transport_addr_list,
 				transports) {
 		if (t->pmtu_pending && t->dst) {
-			sctp_transport_update_pmtu(t, dst_mtu(t->dst));
+			sctp_transport_update_pmtu(sk, t, dst_mtu(t->dst));
 			t->pmtu_pending = 0;
 		}
 		if (!pmtu || (t->pathmtu < pmtu))
diff --git a/net/sctp/input.c b/net/sctp/input.c
index f050d45..a67bc31 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -408,10 +408,10 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 
 	if (t->param_flags & SPP_PMTUD_ENABLE) {
 		/* Update transports view of the MTU */
-		sctp_transport_update_pmtu(t, pmtu);
+		sctp_transport_update_pmtu(sk, t, pmtu);
 
 		/* Update association pmtu. */
-		sctp_assoc_sync_pmtu(asoc);
+		sctp_assoc_sync_pmtu(sk, asoc);
 	}
 
 	/* Retransmit with the new pmtu setting.
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 539f35d..838e18b 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -410,7 +410,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	if (!sctp_transport_dst_check(tp)) {
 		sctp_transport_route(tp, NULL, sctp_sk(sk));
 		if (asoc && (asoc->param_flags & SPP_PMTUD_ENABLE)) {
-			sctp_assoc_sync_pmtu(asoc);
+			sctp_assoc_sync_pmtu(sk, asoc);
 		}
 	}
 	dst = dst_clone(tp->dst);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index b3b8a8d..74bd3c4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1853,7 +1853,7 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	if (asoc->pmtu_pending)
-		sctp_assoc_pending_pmtu(asoc);
+		sctp_assoc_pending_pmtu(sk, asoc);
 
 	/* If fragmentation is disabled and the message length exceeds the
 	 * association fragmentation point, return EMSGSIZE.  The I-D
@@ -2365,7 +2365,7 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
 	if ((params->spp_flags & SPP_PMTUD_DISABLE) && params->spp_pathmtu) {
 		if (trans) {
 			trans->pathmtu = params->spp_pathmtu;
-			sctp_assoc_sync_pmtu(asoc);
+			sctp_assoc_sync_pmtu(sctp_opt2sk(sp), asoc);
 		} else if (asoc) {
 			asoc->pathmtu = params->spp_pathmtu;
 			sctp_frag_point(asoc, params->spp_pathmtu);
@@ -2382,7 +2382,7 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
 				(trans->param_flags & ~SPP_PMTUD) | pmtud_change;
 			if (update) {
 				sctp_transport_pmtu(trans, sctp_opt2sk(sp));
-				sctp_assoc_sync_pmtu(asoc);
+				sctp_assoc_sync_pmtu(sctp_opt2sk(sp), asoc);
 			}
 		} else if (asoc) {
 			asoc->param_flags =
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 1dcceb6..e69e1a2 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -228,7 +228,7 @@ void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 		transport->pathmtu = SCTP_DEFAULT_MAXSEGMENT;
 }
 
-void sctp_transport_update_pmtu(struct sctp_transport *t, u32 pmtu)
+void sctp_transport_update_pmtu(struct sock *sk, struct sctp_transport *t, u32 pmtu)
 {
 	struct dst_entry *dst;
 
@@ -245,8 +245,16 @@ void sctp_transport_update_pmtu(struct sctp_transport *t, u32 pmtu)
 	}
 
 	dst = sctp_transport_dst_check(t);
-	if (dst)
+	if (!dst)
+		t->af_specific->get_dst(t, &t->saddr, &t->fl, sk);
+
+	if (dst) {
 		dst->ops->update_pmtu(dst, pmtu);
+
+		dst = sctp_transport_dst_check(t);
+		if (!dst)
+			t->af_specific->get_dst(t, &t->saddr, &t->fl, sk);
+	}
 }
 
 /* Caches the dst entry and source address for a transport's destination
-- 
1.7.10.4
