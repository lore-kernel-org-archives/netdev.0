From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] sctp: stop pending timers and purge queues when peer restart
 asoc
Date: Mon, 30 May 2011 17:23:36 +0800
Message-ID: <4DE36218.2090400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: lksctp <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56928 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752654Ab1E3JYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 05:24:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the peer restart the asoc, we should not only fail any unsent/unacked
data, but also stop the T3-rtx, SACK, T4-rto timers, and teardown ASCONF
queues.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/command.h |    1 +
 include/net/sctp/structs.h |    2 +-
 net/sctp/associola.c       |   23 ++++++++++++++---------
 net/sctp/sm_sideeffect.c   |    3 +++
 net/sctp/sm_statefuns.c    |   14 ++++++++++++--
 5 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 2b44764..c1baee9 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -107,6 +107,7 @@ typedef enum {
 	SCTP_CMD_UPDATE_INITTAG, /* Update peer inittag */
 	SCTP_CMD_SEND_MSG,	 /* Send the whole use message */
 	SCTP_CMD_SEND_NEXT_ASCONF, /* Send the next ASCONF after ACK */
+	SCTP_CMD_PURGE_ASCONF_QUEUE, /* Purge all asconf queues.*/
 	SCTP_CMD_LAST
 } sctp_verb_t;
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 795f488..7df327a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1993,7 +1993,7 @@ void sctp_assoc_clean_asconf_ack_cache(const struct sctp_association *asoc);
 struct sctp_chunk *sctp_assoc_lookup_asconf_ack(
 					const struct sctp_association *asoc,
 					__be32 serial);
-
+void sctp_asconf_queue_teardown(struct sctp_association *asoc);
 
 int sctp_cmp_addr_exact(const union sctp_addr *ss1,
 			const union sctp_addr *ss2);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 525f97c..4a62888 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -444,15 +444,7 @@ void sctp_association_free(struct sctp_association *asoc)
 
 	asoc->peer.transport_count = 0;
 
-	/* Free any cached ASCONF_ACK chunk. */
-	sctp_assoc_free_asconf_acks(asoc);
-
-	/* Free the ASCONF queue. */
-	sctp_assoc_free_asconf_queue(asoc);
-
-	/* Free any cached ASCONF chunk. */
-	if (asoc->addip_last_asconf)
-		sctp_chunk_free(asoc->addip_last_asconf);
+	sctp_asconf_queue_teardown(asoc);
 
 	/* AUTH - Free the endpoint shared keys */
 	sctp_auth_destroy_keys(&asoc->endpoint_shared_keys);
@@ -1646,3 +1638,16 @@ struct sctp_chunk *sctp_assoc_lookup_asconf_ack(
 
 	return NULL;
 }
+
+void sctp_asconf_queue_teardown(struct sctp_association *asoc)
+{
+	/* Free any cached ASCONF_ACK chunk. */
+	sctp_assoc_free_asconf_acks(asoc);
+
+	/* Free the ASCONF queue. */
+	sctp_assoc_free_asconf_queue(asoc);
+
+	/* Free any cached ASCONF chunk. */
+	if (asoc->addip_last_asconf)
+		sctp_chunk_free(asoc->addip_last_asconf);
+}
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index d612ca1..534c2e5 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1670,6 +1670,9 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 		case SCTP_CMD_SEND_NEXT_ASCONF:
 			sctp_cmd_send_asconf(asoc);
 			break;
+		case SCTP_CMD_PURGE_ASCONF_QUEUE:
+			sctp_asconf_queue_teardown(asoc);
+			break;
 		default:
 			pr_warn("Impossible command: %u, %p\n",
 				cmd->verb, cmd->obj.ptr);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7f4a4f8..a297283 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1718,11 +1718,21 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(const struct sctp_endpoint *ep,
 		return SCTP_DISPOSITION_CONSUME;
 	}
 
-	/* For now, fail any unsent/unacked data.  Consider the optional
-	 * choice of resending of this data.
+	/* For now, stop pending T3-rtx and SACK timers, fail any unsent/unacked
+	 * data. Consider the optional choice of resending of this data.
 	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_T3_RTX_TIMERS_STOP, SCTP_NULL());
+	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
+			SCTP_TO(SCTP_EVENT_TIMEOUT_SACK));
 	sctp_add_cmd_sf(commands, SCTP_CMD_PURGE_OUTQUEUE, SCTP_NULL());
 
+	/* Stop pending T4-rto timer, teardown ASCONF queue, ASCONF-ACK queue
+	 * and ASCONF-ACK cache.
+	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
+			SCTP_TO(SCTP_EVENT_TIMEOUT_T4_RTO));
+	sctp_add_cmd_sf(commands, SCTP_CMD_PURGE_ASCONF_QUEUE, SCTP_NULL());
+
 	repl = sctp_make_cookie_ack(new_asoc, chunk);
 	if (!repl)
 		goto nomem;
-- 
1.6.5.2


