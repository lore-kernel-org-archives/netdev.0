From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 4/4] sctp: add Adaptation Layer Indication parameter only when it's set
Date: Thu, 12 Mar 2009 15:49:20 -0400
Message-ID: <1236887360-1904-5-git-send-email-vladislav.yasevich@hp.com>
References: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	malc <mlashley@gmail.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:30953 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900AbZCLTta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:49:30 -0400
In-Reply-To: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: malc <mlashley@gmail.com>

RFC5061 states:

        Each adaptation layer that is defined that wishes
        to use this parameter MUST specify an adaptation code point in an
        appropriate RFC defining its use and meaning.

If the user has not set one - assume they don't want to sent the param
with a zero Adaptation Code Point.

Rationale - Currently the IANA defines zero as reserved - and
1 as the only valid value - so we consider zero to be unset - to save
adding a boolean to the socket structure.

Including this parameter unconditionally causes endpoints that do not
understand it to report errors unnecessarily.

Signed-off-by: Malcolm Lashley <mlashley@gmail.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |   29 +++++++++++++++++++----------
 1 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 9484f33..6851ee9 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -224,7 +224,9 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 		num_ext += 2;
 	}
 
-	chunksize += sizeof(aiparam);
+	if (sp->adaptation_ind)
+		chunksize += sizeof(aiparam);
+
 	chunksize += vparam_len;
 
 	/* Account for AUTH related parameters */
@@ -304,10 +306,12 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	if (sctp_prsctp_enable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);
 
-	aiparam.param_hdr.type = SCTP_PARAM_ADAPTATION_LAYER_IND;
-	aiparam.param_hdr.length = htons(sizeof(aiparam));
-	aiparam.adaptation_ind = htonl(sp->adaptation_ind);
-	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
+	if (sp->adaptation_ind) {
+		aiparam.param_hdr.type = SCTP_PARAM_ADAPTATION_LAYER_IND;
+		aiparam.param_hdr.length = htons(sizeof(aiparam));
+		aiparam.adaptation_ind = htonl(sp->adaptation_ind);
+		sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
+	}
 
 	/* Add SCTP-AUTH chunks to the parameter list */
 	if (sctp_auth_enable) {
@@ -332,6 +336,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	sctp_inithdr_t initack;
 	struct sctp_chunk *retval;
 	union sctp_params addrs;
+	struct sctp_sock *sp;
 	int addrs_len;
 	sctp_cookie_param_t *cookie;
 	int cookie_len;
@@ -366,6 +371,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	/* Calculate the total size of allocation, include the reserved
 	 * space for reporting unknown parameters if it is specified.
 	 */
+	sp = sctp_sk(asoc->base.sk);
 	chunksize = sizeof(initack) + addrs_len + cookie_len + unkparam_len;
 
 	/* Tell peer that we'll do ECN only if peer advertised such cap.  */
@@ -381,7 +387,8 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 		num_ext += 2;
 	}
 
-	chunksize += sizeof(aiparam);
+	if (sp->adaptation_ind)
+		chunksize += sizeof(aiparam);
 
 	if (asoc->peer.auth_capable) {
 		auth_random = (sctp_paramhdr_t *)asoc->c.auth_random;
@@ -432,10 +439,12 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	if (asoc->peer.prsctp_capable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);
 
-	aiparam.param_hdr.type = SCTP_PARAM_ADAPTATION_LAYER_IND;
-	aiparam.param_hdr.length = htons(sizeof(aiparam));
-	aiparam.adaptation_ind = htonl(sctp_sk(asoc->base.sk)->adaptation_ind);
-	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
+	if (sp->adaptation_ind) {
+		aiparam.param_hdr.type = SCTP_PARAM_ADAPTATION_LAYER_IND;
+		aiparam.param_hdr.length = htons(sizeof(aiparam));
+		aiparam.adaptation_ind = htonl(sp->adaptation_ind);
+		sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
+	}
 
 	if (asoc->peer.auth_capable) {
 		sctp_addto_chunk(retval, ntohs(auth_random->length),
-- 
1.5.4.3

