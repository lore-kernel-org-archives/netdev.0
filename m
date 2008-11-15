From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/5] dccp: Feature negotiation for minimum-checksum-coverage
Date: Sat, 15 Nov 2008 13:11:17 +0100
Message-ID: <1226751079-15019-4-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20081112063643.GB6405@gerrit.erg.abdn.ac.uk>
 <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:42066 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755207AbYKOMLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 07:11:33 -0500
In-Reply-To: <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides feature negotiation for server minimum checksum coverage
which so far has been missing.

Since sender/receiver coverage values range only from 0...15, their
type has also been reduced in size from u16 to u4.

Feature-negotiation options are now generated for both sender and receiver
coverage, i.e. when the peer has `forgotten' to enable partial coverage
then feature negotiation will automatically enable (negotiate) the partial
coverage value for this connection.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 include/linux/dccp.h |    4 +-
 net/dccp/proto.c     |   53 +++++++++++++++++++++++++++++++++++++------------
 2 files changed, 42 insertions(+), 15 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -527,8 +527,8 @@ struct dccp_sock {
 	__u32				dccps_timestamp_time;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
-	__u16				dccps_pcslen;
-	__u16				dccps_pcrlen;
+	__u8				dccps_pcslen:4;
+	__u8				dccps_pcrlen:4;
 	__u64				dccps_ndp_count:48;
 	unsigned long			dccps_rate_last;
 	struct dccp_minisock		dccps_minisock;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -470,6 +470,42 @@ static int dccp_setsockopt_service(struct sock *sk, const __be32 service,
 	return 0;
 }
 
+static int dccp_setsockopt_cscov(struct sock *sk, int cscov, bool rx)
+{
+	u8 *list, len;
+	int i, rc;
+
+	if (cscov < 0 || cscov > 15)
+		return -EINVAL;
+	/*
+	 * Populate a list of permissible values, in the range cscov...15. This
+	 * is necessary since feature negotiation of single values only works if
+	 * both sides incidentally choose the same value. Since the list starts
+	 * lowest-value first, negotiation will pick the smallest shared value.
+	 */
+	if (cscov == 0)
+		return 0;
+	len = 16 - cscov;
+
+	list = kmalloc(len, GFP_KERNEL);
+	if (list == NULL)
+		return -ENOBUFS;
+
+	for (i = 0; i < len; i++)
+		list[i] = cscov++;
+
+	rc = dccp_feat_register_sp(sk, DCCPF_MIN_CSUM_COVER, rx, list, len);
+
+	if (rc == 0) {
+		if (rx)
+			dccp_sk(sk)->dccps_pcrlen = cscov;
+		else
+			dccp_sk(sk)->dccps_pcslen = cscov;
+	}
+	kfree(list);
+	return rc;
+}
+
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		char __user *optval, int optlen)
 {
@@ -502,20 +538,11 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		else
 			dp->dccps_server_timewait = (val != 0);
 		break;
-	case DCCP_SOCKOPT_SEND_CSCOV:	/* sender side, RFC 4340, sec. 9.2 */
-		if (val < 0 || val > 15)
-			err = -EINVAL;
-		else
-			dp->dccps_pcslen = val;
+	case DCCP_SOCKOPT_SEND_CSCOV:
+		err = dccp_setsockopt_cscov(sk, val, false);
 		break;
-	case DCCP_SOCKOPT_RECV_CSCOV:	/* receiver side, RFC 4340 sec. 9.2.1 */
-		if (val < 0 || val > 15)
-			err = -EINVAL;
-		else {
-			dp->dccps_pcrlen = val;
-			/* FIXME: add feature negotiation,
-			 * ChangeL(MinimumChecksumCoverage, val) */
-		}
+	case DCCP_SOCKOPT_RECV_CSCOV:
+		err = dccp_setsockopt_cscov(sk, val, true);
 		break;
 	default:
 		err = -ENOPROTOOPT;
