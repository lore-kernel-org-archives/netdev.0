From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 3/9] SCTP: Add the handling of "Set Primary IP Address" parameter to INIT
Date: Mon, 17 Dec 2007 16:32:43 -0500
Message-ID: <1197927169-5106-4-git-send-email-vladislav.yasevich@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:15306 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932586AbXLQVcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:53 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ADD-IP "Set Primary IP Address" parameter is allowed in the
INIT/INIT-ACK exchange.  Allow processing of this parameter during
the INIT/INIT-ACK.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    1 +
 net/sctp/sm_make_chunk.c   |   27 +++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 55acadc..fb9b7e7 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -451,6 +451,7 @@ union sctp_params {
 	struct sctp_random_param *random;
 	struct sctp_chunks_param *chunks;
 	struct sctp_hmac_algo_param *hmac_algo;
+	struct sctp_addip_param *addip;
 };
 
 /* RFC 2960.  Section 3.3.5 Heartbeat.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 00598ee..62af33d 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1963,6 +1963,11 @@ static sctp_ierror_t sctp_verify_param(const struct sctp_association *asoc,
 	case SCTP_PARAM_SUPPORTED_EXT:
 		break;
 
+	case SCTP_PARAM_SET_PRIMARY:
+		if (sctp_addip_enable)
+			break;
+		goto fallthrough;
+
 	case SCTP_PARAM_HOST_NAME_ADDRESS:
 		/* Tell the peer, we won't support this param.  */
 		sctp_process_hn_param(asoc, param, chunk, err_chunk);
@@ -2280,6 +2285,8 @@ static int sctp_process_param(struct sctp_association *asoc,
 	sctp_scope_t scope;
 	time_t stale;
 	struct sctp_af *af;
+	union sctp_addr_param *addr_param;
+	struct sctp_transport *t;
 
 	/* We maintain all INIT parameters in network byte order all the
 	 * time.  This allows us to not worry about whether the parameters
@@ -2370,6 +2377,26 @@ static int sctp_process_param(struct sctp_association *asoc,
 		asoc->peer.adaptation_ind = param.aind->adaptation_ind;
 		break;
 
+	case SCTP_PARAM_SET_PRIMARY:
+		addr_param = param.v + sizeof(sctp_addip_param_t);
+
+		af = sctp_get_af_specific(param_type2af(param.p->type));
+		af->from_addr_param(&addr, addr_param,
+				    htons(asoc->peer.port), 0);
+
+		/* if the address is invalid, we can't process it.
+		 * XXX: see spec for what to do.
+		 */
+		if (!af->addr_valid(&addr, NULL, NULL))
+			break;
+
+		t = sctp_assoc_lookup_paddr(asoc, &addr);
+		if (!t)
+			break;
+
+		sctp_assoc_set_primary(asoc, t);
+		break;
+
 	case SCTP_PARAM_SUPPORTED_EXT:
 		sctp_process_ext_param(asoc, param);
 		break;
-- 
1.5.3.5

