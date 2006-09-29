From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/4] [SCTP]: Do not timestamp every SCTP packet.
Date: Fri, 29 Sep 2006 13:00:37 -0700
Message-ID: <1159560037.29637.52.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:19429 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1422699AbWI2UAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 16:00:42 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8TK0eFu018680
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:40 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8TK0d5O174884
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:40 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8TK0caB000560
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 16:00:39 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Do not timestamp every SCTP packet.

We only need the timestamp on COOKIE-ECHO chunks, so instead of always
timestamping every SCTP packet, let common code timestamp if the socket
option is set.  For COOKIE-ECHO, simply get the time of day if we don't
have a timestamp.  This introduces a small possibility that the cookie
may be considered expired, but it will be renegotiated.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/input.c         |    6 ------
 net/sctp/sm_make_chunk.c |   10 +++++++++-
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 4714882..64f6301 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -218,12 +218,6 @@ int sctp_rcv(struct sk_buff *skb)
 		}
 	}
 
-	/* SCTP seems to always need a timestamp right now (FIXME) */
-	if (skb->tstamp.off_sec == 0) {
-		__net_timestamp(skb);
-		sock_enable_timestamp(sk); 
-	}
-
 	if (!xfrm_policy_check(sk, XFRM_POLICY_IN, skb, family))
 		goto discard_release;
 	nf_reset(skb);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 7745bde..507dff7 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1447,8 +1447,16 @@ no_hmac:
 	/* Check to see if the cookie is stale.  If there is already
 	 * an association, there is no need to check cookie's expiration
 	 * for init collision case of lost COOKIE ACK.
+	 * If skb has been timestamped, then use the stamp, otherwise
+	 * use current time.  This introduces a small possibility that
+	 * that a cookie may be considered expired, but his would only slow
+	 * down the new association establishment instead of every packet.
 	 */
-	skb_get_timestamp(skb, &tv);
+	if (sock_flag(ep->base.sk, SOCK_TIMESTAMP))
+		skb_get_timestamp(skb, &tv);
+	else
+		do_gettimeofday(&tv);
+
 	if (!asoc && tv_lt(bear_cookie->expiration, tv)) {
 		__u16 len;
 		/*


