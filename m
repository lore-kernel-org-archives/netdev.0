From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 9/9] SCTP: Follow Add-IP security consideratiosn wrt INIT/INIT-ACK
Date: Mon, 17 Dec 2007 16:32:49 -0500
Message-ID: <1197927169-5106-10-git-send-email-vladislav.yasevich@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:15330 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761680AbXLQVc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:56 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Security Considerations section of RFC 5061 has the following
text:

   If an SCTP endpoint that supports this extension receives an INIT
   that indicates that the peer supports the ASCONF extension but does
   NOT support the [RFC4895] extension, the receiver of such an INIT
   MUST send an ABORT in response.  Note that an implementation is
   allowed to silently discard such an INIT as an option as well, but
   under NO circumstance is an implementation allowed to proceed with
   the association setup by sending an INIT-ACK in response.

   An implementation that receives an INIT-ACK that indicates that the
   peer does not support the [RFC4895] extension MUST NOT send the
   COOKIE-ECHO to establish the association.  Instead, the
   implementation MUST discard the INIT-ACK and report to the upper-
   layer user that an association cannot be established destroying the
   Transmission Control Block (TCB).

Follow the recomendations.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |   47 ++++++++++++++++++++++++++++++++++++++++++---
 net/sctp/sm_statefuns.c  |    7 ++---
 2 files changed, 46 insertions(+), 8 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 68a994c..ae9fc9e 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1830,6 +1830,39 @@ static int sctp_process_hn_param(const struct sctp_association *asoc,
 	return 0;
 }
 
+static int sctp_verify_ext_param(union sctp_params param)
+{
+	__u16 num_ext = ntohs(param.p->length) - sizeof(sctp_paramhdr_t);
+	int have_auth = 0;
+	int have_asconf = 0;
+	int i;
+
+	for (i = 0; i < num_ext; i++) {
+		switch (param.ext->chunks[i]) {
+		    case SCTP_CID_AUTH:
+			    have_auth = 1;
+			    break;
+		    case SCTP_CID_ASCONF:
+		    case SCTP_CID_ASCONF_ACK:
+			    have_asconf = 1;
+			    break;
+		}
+	}
+
+	/* ADD-IP Security: The draft requires us to ABORT or ignore the
+	 * INIT/INIT-ACK if ADD-IP is listed, but AUTH is not.  Do this
+	 * only if ADD-IP is turned on and we are not backward-compatible
+	 * mode.
+	 */
+	if (sctp_addip_noauth)
+		return 1;
+
+	if (sctp_addip_enable && !have_auth && have_asconf)
+		return 0;
+
+	return 1;
+}
+
 static void sctp_process_ext_param(struct sctp_association *asoc,
 				    union sctp_params param)
 {
@@ -1960,7 +1993,11 @@ static sctp_ierror_t sctp_verify_param(const struct sctp_association *asoc,
 	case SCTP_PARAM_UNRECOGNIZED_PARAMETERS:
 	case SCTP_PARAM_ECN_CAPABLE:
 	case SCTP_PARAM_ADAPTATION_LAYER_IND:
+		break;
+
 	case SCTP_PARAM_SUPPORTED_EXT:
+		if (!sctp_verify_ext_param(param))
+			return SCTP_IERROR_ABORT;
 		break;
 
 	case SCTP_PARAM_SET_PRIMARY:
@@ -2133,10 +2170,11 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 					!asoc->peer.peer_hmacs))
 		asoc->peer.auth_capable = 0;
 
-
-	/* If the peer claims support for ADD-IP without support
-	 * for AUTH, disable support for ADD-IP.
-	 * Do this only if backward compatible mode is turned off.
+	/* In a non-backward compatible mode, if the peer claims
+	 * support for ADD-IP but not AUTH,  the ADD-IP spec states
+	 * that we MUST ABORT the association. Section 6.  The section
+	 * also give us an option to silently ignore the packet, which
+	 * is what we'll do here.
 	 */
 	if (!sctp_addip_noauth &&
 	     (asoc->peer.asconf_capable && !asoc->peer.auth_capable)) {
@@ -2144,6 +2182,7 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 						  SCTP_PARAM_DEL_IP |
 						  SCTP_PARAM_SET_PRIMARY);
 		asoc->peer.asconf_capable = 0;
+		goto clean_up;
 	}
 
 	/* Walk list of transports, removing transports in the UNKNOWN state. */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index eed47c6..aadbed1 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -507,7 +507,9 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 			      &err_chunk)) {
 
 		/* This chunk contains fatal error. It is to be discarded.
-		 * Send an ABORT, with causes if there is any.
+		 * Send an ABORT, with causes.  If there are no causes,
+		 * then there wasn't enough memory.  Just terminate
+		 * the association.
 		 */
 		if (err_chunk) {
 			packet = sctp_abort_pkt_new(ep, asoc, arg,
@@ -526,9 +528,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 			} else {
 				error = SCTP_ERROR_NO_RESOURCE;
 			}
-		} else {
-			sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
-			error = SCTP_ERROR_INV_PARAM;
 		}
 
 		/* SCTP-AUTH, Section 6.3:
-- 
1.5.3.5

