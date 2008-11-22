From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/5] dccp: API to query the current TX/RX CCID
Date: Sat, 22 Nov 2008 11:30:38 +0100
Message-ID: <1227349841-9440-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1227349841-9440-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1227349841-9440-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54502 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754684AbYKVKax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 05:30:53 -0500
In-Reply-To: <1227349841-9440-2-git-send-email-gerrit@erg.abdn.ac.uk>
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
 net/dccp/ccid.h  |   18 ++++++++++++++++++
 net/dccp/probe.c |    7 ++-----
 net/dccp/proto.c |   10 ++++++++++
 3 files changed, 30 insertions(+), 5 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -116,6 +116,24 @@ extern struct ccid *ccid_hc_rx_new(unsigned char id, struct sock *sk,
 extern struct ccid *ccid_hc_tx_new(unsigned char id, struct sock *sk,
 				   gfp_t gfp);
 
+static inline int ccid_get_current_rx_ccid(struct dccp_sock *dp)
+{
+	struct ccid *ccid = dp->dccps_hc_rx_ccid;
+
+	if (ccid == NULL || ccid->ccid_ops == NULL)
+		return -1;
+	return ccid->ccid_ops->ccid_id;
+}
+
+static inline int ccid_get_current_tx_ccid(struct dccp_sock *dp)
+{
+	struct ccid *ccid = dp->dccps_hc_tx_ccid;
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
+	if (ccid_get_current_tx_ccid(dccp_sk(sk)) == DCCPC_CCID3)
 		hctx = ccid3_hc_tx_sk(sk);
-	else
-		hctx = NULL;
 
 	if (port == 0 || ntohs(inet->dport) == port ||
 	    ntohs(inet->sport) == port) {
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -667,6 +667,16 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 		break;
 	case DCCP_SOCKOPT_AVAILABLE_CCIDS:
 		return ccid_getsockopt_builtin_ccids(sk, len, optval, optlen);
+	case DCCP_SOCKOPT_TX_CCID:
+		val = ccid_get_current_tx_ccid(dp);
+		if (val < 0)
+			return -ENOPROTOOPT;
+		break;
+	case DCCP_SOCKOPT_RX_CCID:
+		val = ccid_get_current_rx_ccid(dp);
+		if (val < 0)
+			return -ENOPROTOOPT;
+		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		val = dp->dccps_server_timewait;
 		break;
