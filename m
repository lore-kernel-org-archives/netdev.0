From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 8/8] SCTP: Tie ADD-IP and AUTH functionality as required by spec.
Date: Fri, 14 Sep 2007 14:44:59 -0400
Message-ID: <11897955003232-git-send-email-vladislav.yasevich@hp.com>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:49229 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753850AbXINSpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:45:12 -0400
In-Reply-To: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ADD-IP spec requires AUTH. It is, in fact, dangerous without AUTH.
So, disable ADD-IP functionality if the peer claims to support
ADD-IP, but not AUTH.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    1 +
 net/sctp/sm_make_chunk.c   |   13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 3215da4..8e772a9 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1537,6 +1537,7 @@ struct sctp_association {
 		__u8    asconf_capable;  /* Does peer support ADDIP? */
 		__u8    prsctp_capable;  /* Can peer do PR-SCTP? */
 		__u8	auth_capable;	 /* Is peer doing SCTP-AUTH? */
+		__u8	addip_capable;	 /* Can peer do ADD-IP *?
 
 		__u32   adaptation_ind;	 /* Adaptation Code point. */
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 7cd8241..80ca98e 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1851,7 +1851,8 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 			    break;
 		    case SCTP_CID_ASCONF:
 		    case SCTP_CID_ASCONF_ACK:
-			    /* don't need to do anything for ASCONF */
+			    asoc->peer.addip_capable = 1;
+			    break;
 		    default:
 			    break;
 		}
@@ -2137,6 +2138,16 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 					!asoc->peer.peer_hmacs))
 		asoc->peer.auth_capable = 0;
 
+
+	/* If the peer claims support for ADD-IP without support
+	 * for AUTH, disable support for ADD-IP.
+	 */
+	if (asoc->peer.addip_capable && !asoc->peer.auth_capable) {
+		asoc->peer.addip_disable_mask |= (SCTP_PARAM_ADD_IP |
+						  SCTP_PARAM_DEL_IP |
+						  SCTP_PARAM_SET_PRIMARY);
+	}
+
 	/* Walk list of transports, removing transports in the UNKNOWN state. */
 	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
 		transport = list_entry(pos, struct sctp_transport, transports);
-- 
1.5.2.4

