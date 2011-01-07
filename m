From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/3] dccp: fix bug in updating the GSR
Date: Fri,  7 Jan 2011 12:35:29 +0100
Message-ID: <1294400130-5604-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <0110107112837.GA5315@gerrit.erg.abdn.ac.uk>
 <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1294400130-5604-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Samuel Jero <sj323707@ohio.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:57451 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751983Ab1AGLfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 06:35:45 -0500
In-Reply-To: <1294400130-5604-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Jero <sj323707@ohio.edu>

Currently dccp_check_seqno allows any valid packet to update the Greatest
Sequence Number Received, even if that packet's sequence number is less than
the current GSR. This patch adds a check to make sure that the new packet's
sequence number is greater than GSR.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -426,7 +426,8 @@ static inline void dccp_update_gsr(struct sock *sk, u64 seq)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
-	dp->dccps_gsr = seq;
+	if (after48(seq, dp->dccps_gsr))
+		dp->dccps_gsr = seq;
 	/* Sequence validity window depends on remote Sequence Window (7.5.1) */
 	dp->dccps_swl = SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_win / 4);
 	/*
