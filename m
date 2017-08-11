From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 02/14] sctp: remove the typedef sctp_sender_hb_info_t
Date: Fri, 11 Aug 2017 10:23:46 +0800
Message-ID: <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36784 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdHKCYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:24:21 -0400
In-Reply-To: <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_sender_hb_info_t, and
replace with struct sctp_sender_hb_info in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  4 ++--
 net/sctp/sm_make_chunk.c   |  6 +++---
 net/sctp/sm_sideeffect.c   |  4 ++--
 net/sctp/sm_statefuns.c    | 12 +++++-------
 4 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 73e9509..60033a2 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -371,12 +371,12 @@ union sctp_params {
  *    chunk is sent and the destination transport address to which this
  *    HEARTBEAT is sent (see Section 8.3).
  */
-typedef struct sctp_sender_hb_info {
+struct sctp_sender_hb_info {
 	struct sctp_paramhdr param_hdr;
 	union sctp_addr daddr;
 	unsigned long sent_at;
 	__u64 hb_nonce;
-} sctp_sender_hb_info_t;
+};
 
 int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
 		     gfp_t gfp);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 3a8fb1d..51de638 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1142,10 +1142,10 @@ struct sctp_chunk *sctp_make_violation_max_retrans(
 
 /* Make a HEARTBEAT chunk.  */
 struct sctp_chunk *sctp_make_heartbeat(const struct sctp_association *asoc,
-				  const struct sctp_transport *transport)
+				       const struct sctp_transport *transport)
 {
+	struct sctp_sender_hb_info hbinfo;
 	struct sctp_chunk *retval;
-	sctp_sender_hb_info_t hbinfo;
 
 	retval = sctp_make_control(asoc, SCTP_CID_HEARTBEAT, 0,
 				   sizeof(hbinfo), GFP_ATOMIC);
@@ -1154,7 +1154,7 @@ struct sctp_chunk *sctp_make_heartbeat(const struct sctp_association *asoc,
 		goto nodata;
 
 	hbinfo.param_hdr.type = SCTP_PARAM_HEARTBEAT_INFO;
-	hbinfo.param_hdr.length = htons(sizeof(sctp_sender_hb_info_t));
+	hbinfo.param_hdr.length = htons(sizeof(hbinfo));
 	hbinfo.daddr = transport->ipaddr;
 	hbinfo.sent_at = jiffies;
 	hbinfo.hb_nonce = transport->hb_nonce;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 4a12d29..5e8e418 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -714,7 +714,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 				  struct sctp_transport *t,
 				  struct sctp_chunk *chunk)
 {
-	sctp_sender_hb_info_t *hbinfo;
+	struct sctp_sender_hb_info *hbinfo;
 	int was_unconfirmed = 0;
 
 	/* 8.3 Upon the receipt of the HEARTBEAT ACK, the sender of the
@@ -768,7 +768,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 	if (t->rto_pending == 0)
 		t->rto_pending = 1;
 
-	hbinfo = (sctp_sender_hb_info_t *) chunk->skb->data;
+	hbinfo = (struct sctp_sender_hb_info *)chunk->skb->data;
 	sctp_transport_update_rto(t, (jiffies - hbinfo->sent_at));
 
 	/* Update the heartbeat timer.  */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ac6aaa0..af93419 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1155,27 +1155,25 @@ sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
+	struct sctp_sender_hb_info *hbinfo;
 	struct sctp_chunk *chunk = arg;
-	union sctp_addr from_addr;
 	struct sctp_transport *link;
-	sctp_sender_hb_info_t *hbinfo;
 	unsigned long max_interval;
+	union sctp_addr from_addr;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the HEARTBEAT-ACK chunk has a valid length.  */
 	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr) +
-					    sizeof(sctp_sender_hb_info_t)))
+					    sizeof(*hbinfo)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-	hbinfo = (sctp_sender_hb_info_t *) chunk->skb->data;
+	hbinfo = (struct sctp_sender_hb_info *)chunk->skb->data;
 	/* Make sure that the length of the parameter is what we expect */
-	if (ntohs(hbinfo->param_hdr.length) !=
-				    sizeof(sctp_sender_hb_info_t)) {
+	if (ntohs(hbinfo->param_hdr.length) != sizeof(*hbinfo))
 		return SCTP_DISPOSITION_DISCARD;
-	}
 
 	from_addr = hbinfo->daddr;
 	link = sctp_assoc_lookup_paddr(asoc, &from_addr);
-- 
2.1.0
