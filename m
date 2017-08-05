From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 07/14] sctp: remove the typedef sctp_xmit_t
Date: Sat,  5 Aug 2017 19:59:57 +0800
Message-ID: <a26ddefe25442293b3e1020ce56f859125a93412.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
 <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
 <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
 <f8669af1f44d19322287665b8f7d97e0e2a4dc46.1501934087.git.lucien.xin@gmail.com>
 <9049d5fd9299328397722053f090a66d97de8451.1501934087.git.lucien.xin@gmail.com>
 <e92ab93f0d646a935384c74848671fc56956c754.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34701 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdHEMBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:01:10 -0400
In-Reply-To: <e92ab93f0d646a935384c74848671fc56956c754.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_xmit_t, and
replace with enum sctp_xmit in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  4 +--
 include/net/sctp/structs.h   |  9 ++++---
 net/sctp/output.c            | 60 ++++++++++++++++++++++----------------------
 net/sctp/outqueue.c          |  8 +++---
 4 files changed, 41 insertions(+), 40 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 049868e..311b2e3 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -312,12 +312,12 @@ enum { SCTP_MAX_GABS = 16 };
 /* These return values describe the success or failure of a number of
  * routines which form the lower interface to SCTP_outqueue.
  */
-typedef enum {
+enum sctp_xmit {
 	SCTP_XMIT_OK,
 	SCTP_XMIT_PMTU_FULL,
 	SCTP_XMIT_RWND_FULL,
 	SCTP_XMIT_DELAY,
-} sctp_xmit_t;
+};
 
 /* These are the commands for manipulating transports.  */
 enum sctp_transport_cmd {
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index d098d1c..6fab67e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -697,10 +697,11 @@ struct sctp_packet {
 void sctp_packet_init(struct sctp_packet *, struct sctp_transport *,
 		      __u16 sport, __u16 dport);
 void sctp_packet_config(struct sctp_packet *, __u32 vtag, int);
-sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *,
-				       struct sctp_chunk *, int, gfp_t);
-sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *,
-                                     struct sctp_chunk *);
+enum sctp_xmit sctp_packet_transmit_chunk(struct sctp_packet *packet,
+					  struct sctp_chunk *chunk,
+					  int one_packet, gfp_t gfp);
+enum sctp_xmit sctp_packet_append_chunk(struct sctp_packet *packet,
+					struct sctp_chunk *chunk);
 int sctp_packet_transmit(struct sctp_packet *, gfp_t);
 void sctp_packet_free(struct sctp_packet *);
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 9d85049..4a865cd 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -57,15 +57,15 @@
 #include <net/sctp/checksum.h>
 
 /* Forward declarations for private helpers. */
-static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
-					      struct sctp_chunk *chunk);
-static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
-					   struct sctp_chunk *chunk);
+static enum sctp_xmit __sctp_packet_append_chunk(struct sctp_packet *packet,
+						 struct sctp_chunk *chunk);
+static enum sctp_xmit sctp_packet_can_append_data(struct sctp_packet *packet,
+						  struct sctp_chunk *chunk);
 static void sctp_packet_append_data(struct sctp_packet *packet,
-					   struct sctp_chunk *chunk);
-static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
-					struct sctp_chunk *chunk,
-					u16 chunk_len);
+				    struct sctp_chunk *chunk);
+static enum sctp_xmit sctp_packet_will_fit(struct sctp_packet *packet,
+					   struct sctp_chunk *chunk,
+					   u16 chunk_len);
 
 static void sctp_packet_reset(struct sctp_packet *packet)
 {
@@ -181,11 +181,11 @@ void sctp_packet_free(struct sctp_packet *packet)
  * as it can fit in the packet, but any more data that does not fit in this
  * packet can be sent only after receiving the COOKIE_ACK.
  */
-sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
-				       struct sctp_chunk *chunk,
-				       int one_packet, gfp_t gfp)
+enum sctp_xmit sctp_packet_transmit_chunk(struct sctp_packet *packet,
+					  struct sctp_chunk *chunk,
+					  int one_packet, gfp_t gfp)
 {
-	sctp_xmit_t retval;
+	enum sctp_xmit retval;
 
 	pr_debug("%s: packet:%p size:%zu chunk:%p size:%d\n", __func__,
 		 packet, packet->size, chunk, chunk->skb ? chunk->skb->len : -1);
@@ -218,12 +218,12 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 }
 
 /* Try to bundle an auth chunk into the packet. */
-static sctp_xmit_t sctp_packet_bundle_auth(struct sctp_packet *pkt,
-					   struct sctp_chunk *chunk)
+static enum sctp_xmit sctp_packet_bundle_auth(struct sctp_packet *pkt,
+					      struct sctp_chunk *chunk)
 {
 	struct sctp_association *asoc = pkt->transport->asoc;
+	enum sctp_xmit retval = SCTP_XMIT_OK;
 	struct sctp_chunk *auth;
-	sctp_xmit_t retval = SCTP_XMIT_OK;
 
 	/* if we don't have an association, we can't do authentication */
 	if (!asoc)
@@ -254,10 +254,10 @@ static sctp_xmit_t sctp_packet_bundle_auth(struct sctp_packet *pkt,
 }
 
 /* Try to bundle a SACK with the packet. */
-static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
-					   struct sctp_chunk *chunk)
+static enum sctp_xmit sctp_packet_bundle_sack(struct sctp_packet *pkt,
+					      struct sctp_chunk *chunk)
 {
-	sctp_xmit_t retval = SCTP_XMIT_OK;
+	enum sctp_xmit retval = SCTP_XMIT_OK;
 
 	/* If sending DATA and haven't aleady bundled a SACK, try to
 	 * bundle one in to the packet.
@@ -299,11 +299,11 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
 /* Append a chunk to the offered packet reporting back any inability to do
  * so.
  */
-static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
-					      struct sctp_chunk *chunk)
+static enum sctp_xmit __sctp_packet_append_chunk(struct sctp_packet *packet,
+						 struct sctp_chunk *chunk)
 {
-	sctp_xmit_t retval = SCTP_XMIT_OK;
 	__u16 chunk_len = SCTP_PAD4(ntohs(chunk->chunk_hdr->length));
+	enum sctp_xmit retval = SCTP_XMIT_OK;
 
 	/* Check to see if this chunk will fit into the packet */
 	retval = sctp_packet_will_fit(packet, chunk, chunk_len);
@@ -353,10 +353,10 @@ static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
 /* Append a chunk to the offered packet reporting back any inability to do
  * so.
  */
-sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *packet,
-				     struct sctp_chunk *chunk)
+enum sctp_xmit sctp_packet_append_chunk(struct sctp_packet *packet,
+					struct sctp_chunk *chunk)
 {
-	sctp_xmit_t retval = SCTP_XMIT_OK;
+	enum sctp_xmit retval = SCTP_XMIT_OK;
 
 	pr_debug("%s: packet:%p chunk:%p\n", __func__, packet, chunk);
 
@@ -653,8 +653,8 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
  ********************************************************************/
 
 /* This private function check to see if a chunk can be added */
-static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
-					   struct sctp_chunk *chunk)
+static enum sctp_xmit sctp_packet_can_append_data(struct sctp_packet *packet,
+						  struct sctp_chunk *chunk)
 {
 	size_t datasize, rwnd, inflight, flight_size;
 	struct sctp_transport *transport = packet->transport;
@@ -762,12 +762,12 @@ static void sctp_packet_append_data(struct sctp_packet *packet,
 	sctp_chunk_assign_ssn(chunk);
 }
 
-static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
-					struct sctp_chunk *chunk,
-					u16 chunk_len)
+static enum sctp_xmit sctp_packet_will_fit(struct sctp_packet *packet,
+					   struct sctp_chunk *chunk,
+					   u16 chunk_len)
 {
+	enum sctp_xmit retval = SCTP_XMIT_OK;
 	size_t psize, pmtu, maxsize;
-	sctp_xmit_t retval = SCTP_XMIT_OK;
 
 	psize = packet->size;
 	if (packet->transport->asoc)
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 08ee0ed..2966ff4 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -594,14 +594,14 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			       int rtx_timeout, int *start_timer)
 {
-	struct list_head *lqueue;
 	struct sctp_transport *transport = pkt->transport;
-	sctp_xmit_t status;
 	struct sctp_chunk *chunk, *chunk1;
-	int fast_rtx;
+	struct list_head *lqueue;
+	enum sctp_xmit status;
 	int error = 0;
 	int timer = 0;
 	int done = 0;
+	int fast_rtx;
 
 	lqueue = &q->retransmit;
 	fast_rtx = q->fast_rtx;
@@ -781,7 +781,7 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 	struct sctp_transport *transport = NULL;
 	struct sctp_transport *new_transport;
 	struct sctp_chunk *chunk, *tmp;
-	sctp_xmit_t status;
+	enum sctp_xmit status;
 	int error = 0;
 	int start_timer = 0;
 	int one_packet = 0;
-- 
2.1.0
