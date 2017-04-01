From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: check for dst and pathmtu update in sctp_packet_config
Date: Sat,  1 Apr 2017 17:15:59 +0800
Message-ID: <7d69e45b3cc8f84658e04ab07288a9fe09254e12.1491038159.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36297 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdDAJQJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 05:16:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to move sctp_transport_dst_check into sctp_packet_config
from sctp_packet_transmit and add pathmtu check in sctp_packet_config.

With this fix, sctp can update dst or pathmtu before appending chunks,
which can void dropping packets in sctp_packet_transmit when dst is
obsolete or dst's mtu is changed.

This patch is also to improve some other codes in sctp_packet_config.
It updates packet max_size with gso_max_size, checks for dst and
pathmtu, and appends ecne chunk only when packet is empty and asoc
is not NULL.

It makes sctp flush work better, as we only need to set up them once
for one flush schedule. It's also safe, since asoc is NULL only when
the packet is created by sctp_ootb_pkt_new in which it just gets the
new dst, no need to do more things for it other than set packet with
transport's pathmtu.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h | 17 ++++++++++---
 net/sctp/output.c       | 67 ++++++++++++++++++++++++++-----------------------
 2 files changed, 50 insertions(+), 34 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 1f71ee5..d75caa7 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -596,12 +596,23 @@ static inline void sctp_v4_map_v6(union sctp_addr *addr)
  */
 static inline struct dst_entry *sctp_transport_dst_check(struct sctp_transport *t)
 {
-	if (t->dst && (!dst_check(t->dst, t->dst_cookie) ||
-		       t->pathmtu != max_t(size_t, SCTP_TRUNC4(dst_mtu(t->dst)),
-					   SCTP_DEFAULT_MINSEGMENT)))
+	if (t->dst && !dst_check(t->dst, t->dst_cookie))
 		sctp_transport_dst_release(t);
 
 	return t->dst;
 }
 
+static inline bool sctp_transport_pmtu_check(struct sctp_transport *t)
+{
+	__u32 pmtu = max_t(size_t, SCTP_TRUNC4(dst_mtu(t->dst)),
+			   SCTP_DEFAULT_MINSEGMENT);
+
+	if (t->pathmtu == pmtu)
+		return true;
+
+	t->pathmtu = pmtu;
+
+	return false;
+}
+
 #endif /* __net_sctp_h__ */
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 73fd178..ec4d50a 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -86,43 +86,53 @@ void sctp_packet_config(struct sctp_packet *packet, __u32 vtag,
 {
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
+	struct sock *sk;
 
 	pr_debug("%s: packet:%p vtag:0x%x\n", __func__, packet, vtag);
-
 	packet->vtag = vtag;
 
-	if (asoc && tp->dst) {
-		struct sock *sk = asoc->base.sk;
-
-		rcu_read_lock();
-		if (__sk_dst_get(sk) != tp->dst) {
-			dst_hold(tp->dst);
-			sk_setup_caps(sk, tp->dst);
-		}
-
-		if (sk_can_gso(sk)) {
-			struct net_device *dev = tp->dst->dev;
+	/* do the following jobs only once for a flush schedule */
+	if (!sctp_packet_empty(packet))
+		return;
 
-			packet->max_size = dev->gso_max_size;
-		} else {
-			packet->max_size = asoc->pathmtu;
-		}
-		rcu_read_unlock();
+	/* set packet max_size with pathmtu */
+	packet->max_size = tp->pathmtu;
+	if (!asoc)
+		return;
 
-	} else {
-		packet->max_size = tp->pathmtu;
+	/* update dst or transport pathmtu if in need */
+	sk = asoc->base.sk;
+	if (!sctp_transport_dst_check(tp)) {
+		sctp_transport_route(tp, NULL, sctp_sk(sk));
+		if (asoc->param_flags & SPP_PMTUD_ENABLE)
+			sctp_assoc_sync_pmtu(sk, asoc);
+	} else if (!sctp_transport_pmtu_check(tp)) {
+		if (asoc->param_flags & SPP_PMTUD_ENABLE)
+			sctp_assoc_sync_pmtu(sk, asoc);
 	}
 
-	if (ecn_capable && sctp_packet_empty(packet)) {
-		struct sctp_chunk *chunk;
+	/* If there a is a prepend chunk stick it on the list before
+	 * any other chunks get appended.
+	 */
+	if (ecn_capable) {
+		struct sctp_chunk *chunk = sctp_get_ecne_prepend(asoc);
 
-		/* If there a is a prepend chunk stick it on the list before
-		 * any other chunks get appended.
-		 */
-		chunk = sctp_get_ecne_prepend(asoc);
 		if (chunk)
 			sctp_packet_append_chunk(packet, chunk);
 	}
+
+	if (!tp->dst)
+		return;
+
+	/* set packet max_size with gso_max_size if gso is enabled*/
+	rcu_read_lock();
+	if (__sk_dst_get(sk) != tp->dst) {
+		dst_hold(tp->dst);
+		sk_setup_caps(sk, tp->dst);
+	}
+	packet->max_size = sk_can_gso(sk) ? tp->dst->dev->gso_max_size
+					  : asoc->pathmtu;
+	rcu_read_unlock();
 }
 
 /* Initialize the packet structure. */
@@ -582,12 +592,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	sh->vtag = htonl(packet->vtag);
 	sh->checksum = 0;
 
-	/* update dst if in need */
-	if (!sctp_transport_dst_check(tp)) {
-		sctp_transport_route(tp, NULL, sctp_sk(sk));
-		if (asoc && asoc->param_flags & SPP_PMTUD_ENABLE)
-			sctp_assoc_sync_pmtu(sk, asoc);
-	}
+	/* drop packet if no dst */
 	dst = dst_clone(tp->dst);
 	if (!dst) {
 		IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
-- 
2.1.0
