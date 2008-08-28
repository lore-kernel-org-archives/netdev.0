From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 16/37] dccp: API to query the current TX/RX CCID
Date: Thu, 28 Aug 2008 19:44:51 +0200
Message-ID: <1219945512-7723-17-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_featneg_last_call_for_comments>
 <1219945512-7723-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-6-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-11-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-12-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-13-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-16-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55122 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753784AbYH1Rpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 13:45:34 -0400
In-Reply-To: <1219945512-7723-16-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides function to query the current TX/RX CCID dynamically, without
reliance on the minisock value, using dynamic information available in the
currently loaded CCID module.

This query function is then used to
 (a) provide the getsockopt part for getting/setting CCIDs via sockopts;
 (b) replace the current test for "which CCID is in use" in probe.c.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccid.h  |    9 +++++++++
 net/dccp/probe.c |    7 ++-----
 net/dccp/proto.c |    6 ++++++
 3 files changed, 17 insertions(+), 5 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -116,6 +116,15 @@ extern struct ccid *ccid_hc_rx_new(unsigned char id, struct sock *sk,
 extern struct ccid *ccid_hc_tx_new(unsigned char id, struct sock *sk,
 				   gfp_t gfp);
 
+static inline int ccid_get_current_id(struct dccp_sock *dp, bool rx)
+{
+	struct ccid *ccid = rx ? dp->dccps_hc_rx_ccid : dp->dccps_hc_tx_ccid;
+
+	if (ccid == NULL || ccid->ccid_ops == NULL)
+		return -1;
+	return ccid->ccid_ops->ccid_id;
+}
+
 extern void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk);
 extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
 
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -74,14 +74,11 @@ static void printl(const char *fmt, ...)
 static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			 struct msghdr *msg, size_t size)
 {
-	const struct dccp_minisock *dmsk = dccp_msk(sk);
 	const struct inet_sock *inet = inet_sk(sk);
-	const struct ccid3_hc_tx_sock *hctx;
+	struct ccid3_hc_tx_sock *hctx = NULL;
 
-	if (dmsk->dccpms_tx_ccid == DCCPC_CCID3)
+	if (ccid_get_current_id(dccp_sk(sk), false) == DCCPC_CCID3)
 		hctx = ccid3_hc_tx_sk(sk);
-	else
-		hctx = NULL;
 
 	if (port == 0 || ntohs(inet->dport) == port ||
 	    ntohs(inet->sport) == port) {
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -664,6 +664,12 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 		break;
 	case DCCP_SOCKOPT_AVAILABLE_CCIDS:
 		return ccid_getsockopt_builtin_ccids(sk, len, optval, optlen);
+	case DCCP_SOCKOPT_TX_CCID:
+	case DCCP_SOCKOPT_RX_CCID:
+		val = ccid_get_current_id(dp, optname == DCCP_SOCKOPT_RX_CCID);
+		if (val < 0)
+			return -ENOPROTOOPT;
+		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		val = dp->dccps_server_timewait;
 		break;
-- 
1.6.0.rc2

