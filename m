From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/4] [SCTP]: Fix protocol violation when receiving an error lenght INIT-ACK
Date: Fri, 28 Mar 2008 10:56:19 -0400
Message-ID: <1206716180-16573-4-git-send-email-vladislav.yasevich@hp.com>
References: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:21938 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755774AbYC1O43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 10:56:29 -0400
In-Reply-To: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

When receiving an error length INIT-ACK during COOKIE-WAIT,
a 0-vtag ABORT will be responsed. This action violates the
protocol apparently. This patch achieves the following things.
1 If the INIT-ACK contains all the fixed parameters, use init-tag
  recorded from INIT-ACK as vtag.
2 If the INIT-ACK doesn't contain all the fixed parameters,
  just reflect its vtag.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/command.h |    1 +
 net/sctp/outqueue.c        |    3 +++
 net/sctp/sm_sideeffect.c   |    3 +++
 net/sctp/sm_statefuns.c    |   18 ++++++++++++++++++
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 10ae2da..35b1e83 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -104,6 +104,7 @@ typedef enum {
 	SCTP_CMD_ADAPTATION_IND, /* generate and send adaptation event */
 	SCTP_CMD_ASSOC_SHKEY,    /* generate the association shared keys */
 	SCTP_CMD_T1_RETRAN,	 /* Mark for retransmission after T1 timeout  */
+	SCTP_CMD_UPDATE_INITTAG, /* Update peer inittag */
 	SCTP_CMD_LAST
 } sctp_verb_t;
 
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index b66da52..a9a550b 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -791,6 +791,9 @@ int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			break;
 
 		case SCTP_CID_ABORT:
+			if (sctp_test_T_bit(chunk)) {
+				packet->vtag = asoc->c.my_vtag;
+			}
 		case SCTP_CID_SACK:
 		case SCTP_CID_HEARTBEAT:
 		case SCTP_CID_HEARTBEAT_ACK:
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index e5d6025..38de7bd 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1530,6 +1530,9 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			error = sctp_auth_asoc_init_active_key(asoc,
 						GFP_ATOMIC);
 			break;
+		case SCTP_CMD_UPDATE_INITTAG:
+			asoc->peer.i.init_tag = cmd->obj.u32;
+			break;
 
 		default:
 			printk(KERN_WARNING "Impossible command: %u, %p\n",
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 461377c..c2f72cd 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4142,6 +4142,24 @@ static sctp_disposition_t sctp_sf_abort_violation(
 		goto nomem;
 
 	if (asoc) {
+		/* Treat INIT-ACK as a special case during COOKIE-WAIT. */
+		if (chunk->chunk_hdr->type == SCTP_CID_INIT_ACK &&
+		    !asoc->peer.i.init_tag) {
+			sctp_initack_chunk_t *initack;
+
+			initack = (sctp_initack_chunk_t *)chunk->chunk_hdr;
+			if (!sctp_chunk_length_valid(chunk,
+						     sizeof(sctp_initack_chunk_t)))
+				abort->chunk_hdr->flags |= SCTP_CHUNK_FLAG_T;
+			else {
+				unsigned int inittag;
+
+				inittag = ntohl(initack->init_hdr.init_tag);
+				sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_INITTAG,
+						SCTP_U32(inittag));
+			}
+		}
+
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
 		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
 
-- 
1.5.3.5

