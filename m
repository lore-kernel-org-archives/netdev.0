From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 4/7] dccp: Clamping RTT values
Date: Tue, 29 Jul 2008 11:05:49 +0100
Message-ID: <1217325952-12337-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_ccid-3_second_set_of_updates>
 <1217325952-12337-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217325952-12337-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217325952-12337-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217325952-12337-4-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52489 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755712AbYG2KF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 06:05:57 -0400
In-Reply-To: <1217325952-12337-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extracts the clamping part of dccp_sample_rtt() and makes it available
to other parts of the code (as e.g. used in the next patch).

Note: The function dccp_sample_rtt() now reduces to subtracting the elapsed
time. This could be eliminated but would require shorter prefixes and thus
is not done by this patch - maybe an idea for later.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h  |    9 ++++++++-
 net/dccp/input.c |   11 +----------
 2 files changed, 9 insertions(+), 11 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -333,7 +333,14 @@ extern struct sk_buff *dccp_ctl_make_reset(struct sock *sk,
 extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
 extern int	   dccp_invalid_packet(struct sk_buff *skb);
-extern u32	   dccp_sample_rtt(struct sock *sk, long delta);
+
+static inline u32  dccp_sane_rtt(long usec_sample)
+{
+	if (unlikely(usec_sample <= 0 || usec_sample > DCCP_SANE_RTT_MAX))
+		DCCP_WARN("RTT sample %ld out of bounds!\n", usec_sample);
+	return clamp_val(usec_sample, DCCP_SANE_RTT_MIN, DCCP_SANE_RTT_MAX);
+}
+extern u32 dccp_sample_rtt(struct sock *sk, long delta);
 
 static inline int dccp_bad_service_code(const struct sock *sk,
 					const __be32 service)
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -707,16 +707,7 @@ u32 dccp_sample_rtt(struct sock *sk, long delta)
 	/* dccpor_elapsed_time is either zeroed out or set and > 0 */
 	delta -= dccp_sk(sk)->dccps_options_received.dccpor_elapsed_time * 10;
 
-	if (unlikely(delta <= 0)) {
-		DCCP_WARN("unusable RTT sample %ld, using min\n", delta);
-		return DCCP_SANE_RTT_MIN;
-	}
-	if (unlikely(delta > DCCP_SANE_RTT_MAX)) {
-		DCCP_WARN("RTT sample %ld too large, using max\n", delta);
-		return DCCP_SANE_RTT_MAX;
-	}
-
-	return delta;
+	return dccp_sane_rtt(delta);
 }
 
 EXPORT_SYMBOL_GPL(dccp_sample_rtt);
