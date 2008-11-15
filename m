From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 5/5] dccp: Tidy up setsockopt calls
Date: Sat, 15 Nov 2008 13:11:19 +0100
Message-ID: <1226751079-15019-6-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20081112063643.GB6405@gerrit.erg.abdn.ac.uk>
 <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1226751079-15019-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1226751079-15019-5-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:42066 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754999AbYKOMLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 07:11:30 -0500
In-Reply-To: <1226751079-15019-5-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This splits the setsockopt calls into two groups, depending on whether an
integer argument (val) is required and whether routines being called do
their own locking.

Some options (such as setting the CCID) use u8 rather than int, so that for
these the test with regard to integer-sizeof can not be used.

The second switch-case statement now only has those statements which need
locking and which make use of `val'.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Reviewed-by: Eugene Teo <eugeneteo@kernel.sg>
---
 net/dccp/proto.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -512,7 +512,17 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 	struct dccp_sock *dp = dccp_sk(sk);
 	int val, err = 0;
 
-	if (optlen < sizeof(int))
+	switch (optname) {
+	case DCCP_SOCKOPT_PACKET_SIZE:
+		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
+		return 0;
+	case DCCP_SOCKOPT_CHANGE_L:
+	case DCCP_SOCKOPT_CHANGE_R:
+		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
+		return 0;
+	}
+
+	if (optlen < (int)sizeof(int))
 		return -EINVAL;
 
 	if (get_user(val, (int __user *)optval))
@@ -523,15 +533,6 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 
 	lock_sock(sk);
 	switch (optname) {
-	case DCCP_SOCKOPT_PACKET_SIZE:
-		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
-		err = 0;
-		break;
-	case DCCP_SOCKOPT_CHANGE_L:
-	case DCCP_SOCKOPT_CHANGE_R:
-		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
-		err = 0;
-		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		if (dp->dccps_role != DCCP_ROLE_SERVER)
 			err = -EOPNOTSUPP;
@@ -548,8 +549,8 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		err = -ENOPROTOOPT;
 		break;
 	}
-
 	release_sock(sk);
+
 	return err;
 }
 
