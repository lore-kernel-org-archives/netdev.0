From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/4] [SCTP]: Add check for hmac_algo parameter in sctp_verify_param()
Date: Fri, 28 Mar 2008 10:56:18 -0400
Message-ID: <1206716180-16573-3-git-send-email-vladislav.yasevich@hp.com>
References: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:21049 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399AbYC1O4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 10:56:24 -0400
In-Reply-To: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

RFC 4890 has the following text:

  The HMAC algorithm based on SHA-1 MUST be supported and
  included in the HMAC-ALGO parameter.

As a result, we need to check in sctp_verify_param() that HMAC_SHA1 is
present in the list.  If not, we should probably treat this as a
protocol violation.

It should also be a protocol violation if the HMAC parameter is empty.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |   29 ++++++++++++++++++++++++++---
 1 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index b489f51..63c1490 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1982,7 +1982,10 @@ static sctp_ierror_t sctp_verify_param(const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
 					struct sctp_chunk **err_chunk)
 {
+	struct sctp_hmac_algo_param *hmacs;
 	int retval = SCTP_IERROR_NO_ERROR;
+	__u16 n_elt, id = 0;
+	int i;
 
 	/* FIXME - This routine is not looking at each parameter per the
 	 * chunk type, i.e., unrecognized parameters should be further
@@ -2056,9 +2059,29 @@ static sctp_ierror_t sctp_verify_param(const struct sctp_association *asoc,
 		break;
 
 	case SCTP_PARAM_HMAC_ALGO:
-		if (sctp_auth_enable)
-			break;
-		/* Fall Through */
+		if (!sctp_auth_enable)
+			goto fallthrough;
+
+		hmacs = (struct sctp_hmac_algo_param *)param.p;
+		n_elt = (ntohs(param.p->length) - sizeof(sctp_paramhdr_t)) >> 1;
+
+		/* SCTP-AUTH: Section 6.1
+		 * The HMAC algorithm based on SHA-1 MUST be supported and
+		 * included in the HMAC-ALGO parameter.
+		 */
+		for (i = 0; i < n_elt; i++) {
+			id = ntohs(hmacs->hmac_ids[i]);
+
+			if (id == SCTP_AUTH_HMAC_ID_SHA1)
+				break;
+		}
+
+		if (id != SCTP_AUTH_HMAC_ID_SHA1) {
+			sctp_process_inv_paramlength(asoc, param.p, chunk,
+						     err_chunk);
+			retval = SCTP_IERROR_ABORT;
+		}
+		break;
 fallthrough:
 	default:
 		SCTP_DEBUG_PRINTK("Unrecognized param: %d for chunk %d.\n",
-- 
1.5.3.5

