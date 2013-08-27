From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: sctp_verify_init: clean up mandatory checks and add comment
Date: Tue, 27 Aug 2013 15:23:50 +0200
Message-ID: <1377609830-10193-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821Ab3H0NXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 09:23:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a comment related to RFC4960 explaning why we do not check for initial
TSN, and while at it, remove yoda notation checks and clean up code from
checks of mandatory conditions. That's probably just really minor, but makes
reviewing easier.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/sm_make_chunk.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 01e9783..c6ca3c9 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2240,25 +2240,23 @@ int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
 		     struct sctp_chunk **errp)
 {
 	union sctp_params param;
-	int has_cookie = 0;
+	bool has_cookie = false;
 	int result;
 
-	/* Verify stream values are non-zero. */
-	if ((0 == peer_init->init_hdr.num_outbound_streams) ||
-	    (0 == peer_init->init_hdr.num_inbound_streams) ||
-	    (0 == peer_init->init_hdr.init_tag) ||
-	    (SCTP_DEFAULT_MINWINDOW > ntohl(peer_init->init_hdr.a_rwnd))) {
-
+	/* Check for missing mandatory parameters. Note: Initial TSN is also
+	 * mandatory, but not checked here since range is possible from 0 to
+	 * 2**32-1 (4294967295), RFC4960 3.3.3.
+	 */
+	if (peer_init->init_hdr.num_outbound_streams == 0 ||
+	    peer_init->init_hdr.num_inbound_streams == 0 ||
+	    peer_init->init_hdr.init_tag == 0 ||
+	    ntohl(peer_init->init_hdr.a_rwnd) < SCTP_DEFAULT_MINWINDOW)
 		return sctp_process_inv_mandatory(asoc, chunk, errp);
-	}
 
-	/* Check for missing mandatory parameters.  */
 	sctp_walk_params(param, peer_init, init_hdr.params) {
-
-		if (SCTP_PARAM_STATE_COOKIE == param.p->type)
-			has_cookie = 1;
-
-	} /* for (loop through all parameters) */
+		if (param.p->type == SCTP_PARAM_STATE_COOKIE)
+			has_cookie = true;
+	}
 
 	/* There is a possibility that a parameter length was bad and
 	 * in that case we would have stoped walking the parameters.
-- 
1.7.11.7
