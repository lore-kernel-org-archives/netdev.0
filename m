From: Chunbo Luo <chunbo.luo@windriver.com>
Subject: [PATCH v3] sctp: fix the check for path failure detection
Date: Tue, 25 Aug 2009 17:07:59 +0800
Message-ID: <1251191279-1764-1-git-send-email-chunbo.luo@windriver.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux-kernel@vger.kernel.org, chunbo.luo@windriver.com,
	yjwei@cn.fujitsu.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51229 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbZHYJIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 05:08:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The transport error count should be incremented when the the T3-rtx
timer expires or an outstanding HB is not acknowledged. In order to
avoid sending out an extra HB before marking the transport DOWN, the
path failure detection should be done before sending out HB.

Signed-off-by: Chunbo Luo <chunbo.luo@windriver.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/sm_sideeffect.c |    3 ++-
 net/sctp/sm_statefuns.c  |    8 ++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 86426aa..fb723dd 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -447,7 +447,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
 		asoc->overall_error_count++;
 
 	if (transport->state != SCTP_INACTIVE &&
-	    (transport->error_count++ >= transport->pathmaxrxt)) {
+	    (transport->error_count >= transport->pathmaxrxt)) {
 		SCTP_DEBUG_PRINTK_IPADDR("transport_strike:association %p",
 					 " transport IP: port:%d failed.\n",
 					 asoc,
@@ -468,6 +468,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
 	 * that indicates that we have an outstanding HB.
 	 */
 	if (!is_hb || transport->hb_sent) {
+		transport->error_count++;
 		transport->last_rto = transport->rto;
 		transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
 	}
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7288192..7f77099 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -981,10 +981,6 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(const struct sctp_endpoint *ep,
 	 */
 
 	if (transport->param_flags & SPP_HB_ENABLE) {
-		if (SCTP_DISPOSITION_NOMEM ==
-				sctp_sf_heartbeat(ep, asoc, type, arg,
-						  commands))
-			return SCTP_DISPOSITION_NOMEM;
 		/* Set transport error counter and association error counter
 		 * when sending heartbeat.
 		 */
@@ -992,6 +988,10 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(const struct sctp_endpoint *ep,
 				SCTP_TRANSPORT(transport));
 		sctp_add_cmd_sf(commands, SCTP_CMD_TRANSPORT_HB_SENT,
 				SCTP_TRANSPORT(transport));
+		if (SCTP_DISPOSITION_NOMEM ==
+				sctp_sf_heartbeat(ep, asoc, type, arg,
+						  commands))
+			return SCTP_DISPOSITION_NOMEM;
 	}
 	sctp_add_cmd_sf(commands, SCTP_CMD_HB_TIMER_UPDATE,
 			SCTP_TRANSPORT(transport));
-- 
1.6.4

