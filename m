From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] SCTP: enable cookie-echo retransmission transport switch
Date: Thu, 12 Jun 2008 12:37:06 +0800
Message-ID: <4850A7F2.6090906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: vladislav <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63388 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbYFLEjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2008 00:39:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad,
This patch enables cookie-echo retransmission transport switch
feature. If COOKIE-ECHO retransmission happens, it will be sent 
to the address other than the one last sent to.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 include/net/sctp/command.h |    1 +
 include/net/sctp/structs.h |    6 ++++++
 net/sctp/associola.c       |   27 +++++++++++++++++++++++++++
 net/sctp/sm_sideeffect.c   |    8 +++++++-
 net/sctp/sm_statefuns.c    |    4 ++++
 5 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 35b1e83..02d4810 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -105,6 +105,7 @@ typedef enum {
 	SCTP_CMD_ASSOC_SHKEY,    /* generate the association shared keys */
 	SCTP_CMD_T1_RETRAN,	 /* Mark for retransmission after T1 timeout  */
 	SCTP_CMD_UPDATE_INITTAG, /* Update peer inittag */
+	SCTP_CMD_COOKIEECHO_CHOOSE_TRANSPORT, /* Choose transport for a COOKIE-ECHO */
 	SCTP_CMD_LAST
 } sctp_verb_t;
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 9c827a7..66baa96 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1664,6 +1664,9 @@ struct sctp_association {
 	/* Transport to which INIT chunk was last sent. */
 	struct sctp_transport *init_last_sent_to;
 
+	/* Transport to which COOKIE-ECHO chunk was last sent. */
+	struct sctp_transport *cookie_echo_last_sent_to;
+
 	/* Next TSN    : The next TSN number to be assigned to a new
 	 *	       : DATA chunk.  This is sent in the INIT or INIT
 	 *	       : ACK chunk to the peer and incremented each
@@ -1962,6 +1965,9 @@ int sctp_cmp_addr_exact(const union sctp_addr *ss1,
 			const union sctp_addr *ss2);
 struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc);
 
+struct sctp_transport *sctp_assoc_choose_cookie_echo_transport(
+	struct sctp_association *);
+
 /* A convenience structure to parse out SCTP specific CMSGs. */
 typedef struct sctp_cmsgs {
 	struct sctp_initmsg *init;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index d29f792..94cbb34 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1539,3 +1539,30 @@ struct sctp_chunk *sctp_assoc_lookup_asconf_ack(
 
 	return NULL;
 }
+
+/* Choose the transport for cookie-echo retransmission.  */
+struct sctp_transport *sctp_assoc_choose_cookie_echo_transport(
+	struct sctp_association *asoc)
+{
+	struct sctp_transport *t;
+
+	if (!asoc->cookie_echo_last_sent_to) {
+		/* This will never happen, because this routine is
+		 * only invoked when cookie-echo retransmission.
+		 */
+		t = asoc->peer.active_path;
+	} else {
+		if (asoc->cookie_echo_last_sent_to == asoc->peer.retran_path)
+			sctp_assoc_update_retran_path(asoc);
+		t = asoc->peer.retran_path;
+	}
+
+	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_update_retran_path:association"
+				 " %p addr: ",
+				 " port: %d\n",
+				 asoc,
+				 (&t->ipaddr),
+				 ntohs(t->ipaddr.v4.sin_port));
+
+	return t;
+}
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index a4763fd..fd2f7aa 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1188,6 +1188,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 					sctp_chunk_free(cmd->obj.ptr);
 				goto nomem;
 			}
+			asoc->cookie_echo_last_sent_to = new_obj->transport;
 			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
 					SCTP_CHUNK(new_obj));
 
@@ -1539,7 +1540,12 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 		case SCTP_CMD_UPDATE_INITTAG:
 			asoc->peer.i.init_tag = cmd->obj.u32;
 			break;
-
+		case SCTP_CMD_COOKIEECHO_CHOOSE_TRANSPORT:
+			chunk = cmd->obj.ptr;
+			t = sctp_assoc_choose_cookie_echo_transport(asoc);
+			asoc->cookie_echo_last_sent_to = t;
+			chunk->transport = t;
+			break;
 		default:
 			printk(KERN_WARNING "Impossible command: %u, %p\n",
 			       cmd->verb, cmd->obj.ptr);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 07194c2..ce40f29 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5291,6 +5291,10 @@ sctp_disposition_t sctp_sf_t1_cookie_timer_expire(const struct sctp_endpoint *ep
 		if (!repl)
 			return SCTP_DISPOSITION_NOMEM;
 
+		/* Choose transport for COOKIE-ECHO */
+		sctp_add_cmd_sf(commands, SCTP_CMD_COOKIEECHO_CHOOSE_TRANSPORT,
+				SCTP_CHUNK(repl));
+
 		/* Issue a sideeffect to do the needed accounting. */
 		sctp_add_cmd_sf(commands, SCTP_CMD_COOKIEECHO_RESTART,
 				SCTP_TO(SCTP_EVENT_TIMEOUT_T1_COOKIE));
-- 
1.5.3



