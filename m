From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 1/9] SCTP: Discard unauthenticated ASCONF and ASCONF ACK chunks
Date: Mon, 17 Dec 2007 16:32:41 -0500
Message-ID: <1197927169-5106-2-git-send-email-vladislav.yasevich@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:36657 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758178AbXLQVcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:51 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we support AUTH, discard unauthenticated ASCONF and ASCONF ACK
chunks as mandated in the ADD-IP spec.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5fb8477..859be75 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3399,6 +3399,15 @@ sctp_disposition_t sctp_sf_do_asconf(const struct sctp_endpoint *ep,
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 	}
 
+	/* ADD-IP: Section 4.1.1
+	 * This chunk MUST be sent in an authenticated way by using
+	 * the mechanism defined in [I-D.ietf-tsvwg-sctp-auth]. If this chunk
+	 * is received unauthenticated it MUST be silently discarded as
+	 * described in [I-D.ietf-tsvwg-sctp-auth].
+	 */
+	if (!sctp_addip_noauth && !chunk->auth)
+		return sctp_sf_discard_chunk(ep, asoc, type, arg, commands);
+
 	/* Make sure that the ASCONF ADDIP chunk has a valid length.  */
 	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_addip_chunk_t)))
 		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
@@ -3485,6 +3494,15 @@ sctp_disposition_t sctp_sf_do_asconf_ack(const struct sctp_endpoint *ep,
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 	}
 
+	/* ADD-IP, Section 4.1.2:
+	 * This chunk MUST be sent in an authenticated way by using
+	 * the mechanism defined in [I-D.ietf-tsvwg-sctp-auth]. If this chunk
+	 * is received unauthenticated it MUST be silently discarded as
+	 * described in [I-D.ietf-tsvwg-sctp-auth].
+	 */
+	if (!sctp_addip_noauth && !asconf_ack->auth)
+		return sctp_sf_discard_chunk(ep, asoc, type, arg, commands);
+
 	/* Make sure that the ADDIP chunk has a valid length.  */
 	if (!sctp_chunk_length_valid(asconf_ack, sizeof(sctp_addip_chunk_t)))
 		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
-- 
1.5.3.5

