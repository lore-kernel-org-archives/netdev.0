From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH][RFC] sctp: fix reporting of unknown parameters
Date: Fri, 18 Feb 2011 00:12:08 +0100
Message-ID: <20110217231208.GA28281@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46360 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756113Ab1BRQZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 11:25:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

commit 5fa782c2f5ef6c2e4f04d3e228412c9b4a4c8809 re-worked the 
handling of unknown parameters. sctp_init_cause_fixed() can now
return -ENOSPC if there is not enough tailroom in the error
chunk skb. When this happens, the error header is not appended to
the error chunk. In that case, the payload of the unknown parameter
should not be appended either.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>


diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 2cc46f0..b23428f 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2029,11 +2029,11 @@ static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
 			*errp = sctp_make_op_error_fixed(asoc, chunk);
 
 		if (*errp) {
-			sctp_init_cause_fixed(*errp, SCTP_ERROR_UNKNOWN_PARAM,
-					WORD_ROUND(ntohs(param.p->length)));
-			sctp_addto_chunk_fixed(*errp,
-					WORD_ROUND(ntohs(param.p->length)),
-					param.v);
+			if (!sctp_init_cause_fixed(*errp, SCTP_ERROR_UNKNOWN_PARAM,
+					WORD_ROUND(ntohs(param.p->length))))
+				sctp_addto_chunk_fixed(*errp,
+						WORD_ROUND(ntohs(param.p->length)),
+						param.v);
 		} else {
 			/* If there is no memory for generating the ERROR
 			 * report as specified, an ABORT will be triggered


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

