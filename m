From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 05/14] SCTP: Correctly disable ADD-IP when AUTH is not supported.
Date: Mon, 12 Nov 2007 11:38:20 -0500
Message-ID: <11948855131587-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56243 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045AbXKLQif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:35 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    1 -
 net/sctp/associola.c       |    2 +-
 net/sctp/sm_make_chunk.c   |    5 +++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index a177017..41f1039 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1540,7 +1540,6 @@ struct sctp_association {
 		__u8    asconf_capable;  /* Does peer support ADDIP? */
 		__u8    prsctp_capable;  /* Can peer do PR-SCTP? */
 		__u8	auth_capable;	 /* Is peer doing SCTP-AUTH? */
-		__u8	addip_capable;	 /* Can peer do ADD-IP */
 
 		__u32   adaptation_ind;	 /* Adaptation Code point. */
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 03158e3..eaad5c5 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -265,7 +265,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	/* Assume that the peer recongizes ASCONF until reported otherwise
 	 * via an ERROR chunk.
 	 */
-	asoc->peer.asconf_capable = 1;
+	asoc->peer.asconf_capable = 0;
 
 	/* Create an input queue.  */
 	sctp_inq_init(&asoc->base.inqueue);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index c60564d..2ff3a3d 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1847,7 +1847,7 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 			    break;
 		    case SCTP_CID_ASCONF:
 		    case SCTP_CID_ASCONF_ACK:
-			    asoc->peer.addip_capable = 1;
+			    asoc->peer.asconf_capable = 1;
 			    break;
 		    default:
 			    break;
@@ -2138,10 +2138,11 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 	/* If the peer claims support for ADD-IP without support
 	 * for AUTH, disable support for ADD-IP.
 	 */
-	if (asoc->peer.addip_capable && !asoc->peer.auth_capable) {
+	if (asoc->peer.asconf_capable && !asoc->peer.auth_capable) {
 		asoc->peer.addip_disabled_mask |= (SCTP_PARAM_ADD_IP |
 						  SCTP_PARAM_DEL_IP |
 						  SCTP_PARAM_SET_PRIMARY);
+		asoc->peer.asconf_capable = 0;
 	}
 
 	/* Walk list of transports, removing transports in the UNKNOWN state. */
-- 
1.5.2.4

