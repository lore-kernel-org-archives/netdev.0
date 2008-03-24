From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix Protocol violation when receiving a error length
 INIT ACK
Date: Mon, 24 Mar 2008 13:39:15 +0800
Message-ID: <47E73E83.9000301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: vladislav <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63667 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752385AbYCXFjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 01:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,
When kernel receives a INIT ACK which has an invalid length, it replies a 0 VerificationTag ABORT.
This violates sctp protocol apparently, and doesn't comply to RFC requirement. VerificationTag 
is allowed to set to 0 only in INIT Chunk packet.
We need to record the VerificationTag from INIT ACK before sending out the ABORT Chunk.

Here is a patch for fixing this bug.

Signed-off-by: Guijianfeng <guijianfeng@cn.fujitsu.com>
---
 include/net/sctp/command.h |    1 +
 net/sctp/sm_sideeffect.c   |    5 ++++-
 net/sctp/sm_statefuns.c    |    9 +++++++++
 3 files changed, 14 insertions(+), 1 deletions(-)

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
 
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 28eb38e..2dbc7bd 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1536,7 +1536,10 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			error = sctp_auth_asoc_init_active_key(asoc,
 						GFP_ATOMIC);
 			break;
-
+		case SCTP_CMD_UPDATE_INITTAG:
+			asoc->peer.i.init_tag = cmd->obj.u32;
+			break;
+			
 		default:
 			printk(KERN_WARNING "Impossible command: %u, %p\n",
 			       cmd->verb, cmd->obj.ptr);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f2ed647..1bc2c49 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4144,6 +4144,15 @@ static sctp_disposition_t sctp_sf_abort_violation(
 		goto nomem;
 
 	if (asoc) {
+		/* Treat INIT-ACK as a special case. */
+		if (chunk->chunk_hdr->type == SCTP_CID_INIT_ACK) {
+			sctp_initack_chunk_t *initack;
+
+			initack = (sctp_initack_chunk_t *)chunk->chunk_hdr;
+			sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_INITTAG,
+					SCTP_U32(ntohl(initack->init_hdr.init_tag)));
+		}
+
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
 		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
 
-- 
1.5.3

