From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH RESEND net-next 4/5] sctp: remove return value from sctp_packet_init/config
Date: Wed, 28 Dec 2016 09:26:34 -0200
Message-ID: <7d9474410d944567be0dc09da373cf3d30713325.1482924092.git.marcelo.leitner@gmail.com>
References: <cover.1482924092.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36196 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751427AbcL1L1X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 06:27:23 -0500
In-Reply-To: <cover.1482924092.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason to use this cascading. It doesn't add anything.
Let's remove it and simplify.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h |  7 +++----
 net/sctp/output.c          | 14 +++++---------
 net/sctp/sm_statefuns.c    |  5 +++--
 3 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 92daabdc007d94a544baa10d278d229e42e40eb3..87d56cc80a3c1d8549b97391245dacc3b6193618 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -722,10 +722,9 @@ struct sctp_packet {
 	    ipfragok:1;		/* So let ip fragment this packet */
 };
 
-struct sctp_packet *sctp_packet_init(struct sctp_packet *,
-				     struct sctp_transport *,
-				     __u16 sport, __u16 dport);
-struct sctp_packet *sctp_packet_config(struct sctp_packet *, __u32 vtag, int);
+void sctp_packet_init(struct sctp_packet *, struct sctp_transport *,
+		      __u16 sport, __u16 dport);
+void sctp_packet_config(struct sctp_packet *, __u32 vtag, int);
 sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *,
 				       struct sctp_chunk *, int, gfp_t);
 sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *,
diff --git a/net/sctp/output.c b/net/sctp/output.c
index f5320a87341e160d46b1160edf4c38b569e7e79b..07ab5062e541dc663b619a278742425a92002945 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -81,8 +81,8 @@ static void sctp_packet_reset(struct sctp_packet *packet)
 /* Config a packet.
  * This appears to be a followup set of initializations.
  */
-struct sctp_packet *sctp_packet_config(struct sctp_packet *packet,
-				       __u32 vtag, int ecn_capable)
+void sctp_packet_config(struct sctp_packet *packet, __u32 vtag,
+			int ecn_capable)
 {
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
@@ -123,14 +123,12 @@ struct sctp_packet *sctp_packet_config(struct sctp_packet *packet,
 		if (chunk)
 			sctp_packet_append_chunk(packet, chunk);
 	}
-
-	return packet;
 }
 
 /* Initialize the packet structure. */
-struct sctp_packet *sctp_packet_init(struct sctp_packet *packet,
-				     struct sctp_transport *transport,
-				     __u16 sport, __u16 dport)
+void sctp_packet_init(struct sctp_packet *packet,
+		      struct sctp_transport *transport,
+		      __u16 sport, __u16 dport)
 {
 	struct sctp_association *asoc = transport->asoc;
 	size_t overhead;
@@ -151,8 +149,6 @@ struct sctp_packet *sctp_packet_init(struct sctp_packet *packet,
 	packet->overhead = overhead;
 	sctp_packet_reset(packet);
 	packet->vtag = 0;
-
-	return packet;
 }
 
 /* Free a packet.  */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index a95915ef9dbabad30f6171f77b26feab61752f36..9a223d5b2314ff166be0446462c33219b7eec1b9 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -6032,8 +6032,9 @@ static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
 	sctp_transport_route(transport, (union sctp_addr *)&chunk->dest,
 			     sctp_sk(net->sctp.ctl_sock));
 
-	packet = sctp_packet_init(&transport->packet, transport, sport, dport);
-	packet = sctp_packet_config(packet, vtag, 0);
+	packet = &transport->packet;
+	sctp_packet_init(packet, transport, sport, dport);
+	sctp_packet_config(packet, vtag, 0);
 
 	return packet;
 
-- 
2.9.3
