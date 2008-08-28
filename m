From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 05/37] dccp: Cleanup routines for feature negotiation
Date: Thu, 28 Aug 2008 19:44:40 +0200
Message-ID: <1219945512-7723-6-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_featneg_last_call_for_comments>
 <1219945512-7723-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55122 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753823AbYH1RpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 13:45:18 -0400
In-Reply-To: <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This inserts the required de-allocation routines for memory allocated by
feature negotiation in the socket destructors, replacing dccp_feat_clean()
in one instance.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h  |    2 ++
 net/dccp/ipv4.c  |    1 +
 net/dccp/ipv6.c  |    1 +
 net/dccp/proto.c |    2 +-
 4 files changed, 5 insertions(+), 1 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -442,6 +442,8 @@ static inline int dccp_ack_pending(const struct sock *sk)
 	       inet_csk_ack_scheduled(sk);
 }
 
+extern void dccp_feat_list_purge(struct list_head *fn_list);
+
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
 extern int dccp_insert_options_rsk(struct dccp_request_sock*, struct sk_buff*);
 extern int dccp_insert_option_elapsed_time(struct sock *sk,
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -545,6 +545,7 @@ out:
 
 static void dccp_v4_reqsk_destructor(struct request_sock *req)
 {
+	dccp_feat_list_purge(&dccp_rsk(req)->dreq_featneg);
 	kfree(inet_rsk(req)->opt);
 }
 
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -302,6 +302,7 @@ done:
 
 static void dccp_v6_reqsk_destructor(struct request_sock *req)
 {
+	dccp_feat_list_purge(&dccp_rsk(req)->dreq_featneg);
 	if (inet6_rsk(req)->pktopts != NULL)
 		kfree_skb(inet6_rsk(req)->pktopts);
 }
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -268,7 +268,7 @@ void dccp_destroy_sock(struct sock *sk)
 	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
 
 	/* clean up feature negotiation state */
-	dccp_feat_clean(dmsk);
+	dccp_feat_list_purge(&dp->dccps_featneg);
 }
 
 EXPORT_SYMBOL_GPL(dccp_destroy_sock);
-- 
1.6.0.rc2

