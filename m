From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 5/5] sctp: Add validity check for SCTP_PARTIAL_DELIVERY_POINT socket option
Date: Fri, 19 Dec 2008 20:47:52 -0500
Message-ID: <1229737672-28328-7-git-send-email-vladislav.yasevich@hp.com>
References: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:37888 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275AbYLTBr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 20:47:59 -0500
In-Reply-To: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

The latest ietf socket extensions API draft said:

  8.1.21.  Set or Get the SCTP Partial Delivery Point

    Note also that the call will fail if the user attempts to set
    this value larger than the socket receive buffer size.

This patch add this validity check for SCTP_PARTIAL_DELIVERY_POINT
socket option.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9f5fe23..b14a8f3 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3010,14 +3010,21 @@ static int sctp_setsockopt_fragment_interleave(struct sock *sk,
 }
 
 /*
- * 7.1.25.  Set or Get the sctp partial delivery point
+ * 8.1.21.  Set or Get the SCTP Partial Delivery Point
  *       (SCTP_PARTIAL_DELIVERY_POINT)
+ *
  * This option will set or get the SCTP partial delivery point.  This
  * point is the size of a message where the partial delivery API will be
  * invoked to help free up rwnd space for the peer.  Setting this to a
- * lower value will cause partial delivery's to happen more often.  The
+ * lower value will cause partial deliveries to happen more often.  The
  * calls argument is an integer that sets or gets the partial delivery
- * point.
+ * point.  Note also that the call will fail if the user attempts to set
+ * this value larger than the socket receive buffer size.
+ *
+ * Note that any single message having a length smaller than or equal to
+ * the SCTP partial delivery point will be delivered in one single read
+ * call as long as the user provided buffer is large enough to hold the
+ * message.
  */
 static int sctp_setsockopt_partial_delivery_point(struct sock *sk,
 						  char __user *optval,
@@ -3030,6 +3037,12 @@ static int sctp_setsockopt_partial_delivery_point(struct sock *sk,
 	if (get_user(val, (int __user *)optval))
 		return -EFAULT;
 
+	/* Note: We double the receive buffer from what the user sets
+	 * it to be, also initial rwnd is based on rcvbuf/2.
+	 */
+	if (val > (sk->sk_rcvbuf >> 1))
+		return -EINVAL;
+
 	sctp_sk(sk)->pd_point = val;
 
 	return 0; /* is this the right error code? */
-- 
1.5.3.5

