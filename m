From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 5/6] dccp: schedule an Ack when receiving timestamps
Date: Tue, 12 Oct 2010 07:15:50 +0200
Message-ID: <1286860551-6809-6-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_misc_fixes_and_helper_functions___a_set_of_six_patches_sent_today>
 <1286860551-6809-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1286860551-6809-5-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43506 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751758Ab0JLFP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 01:15:59 -0400
In-Reply-To: <1286860551-6809-5-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This schedules an Ack when receiving a timestamp, exploiting the
existing inet_csk_schedule_ack() function, saving one case in the
`dccp_ack_pending()' function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h    |    3 +--
 net/dccp/options.c |    2 ++
 2 files changed, 3 insertions(+), 2 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -459,8 +459,7 @@ static inline void dccp_update_gss(struct sock *sk, u64 seq)
 static inline int dccp_ack_pending(const struct sock *sk)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
-	return dp->dccps_timestamp_echo != 0 ||
-	       (dp->dccps_hc_rx_ackvec != NULL &&
+	return (dp->dccps_hc_rx_ackvec != NULL &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
 	       inet_csk_ack_scheduled(sk);
 }
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -163,6 +163,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 				      dccp_role(sk), ntohl(opt_val),
 				      (unsigned long long)
 				      DCCP_SKB_CB(skb)->dccpd_ack_seq);
+			/* schedule an Ack in case this sender is quiescent */
+			inet_csk_schedule_ack(sk);
 			break;
 		case DCCPO_TIMESTAMP_ECHO:
 			if (len != 4 && len != 6 && len != 8)
