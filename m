From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 4/6] [SCTP] Honor flags when setting peer address parameters
Date: Fri, 23 Mar 2007 09:52:50 -0400
Message-ID: <1174657973332-git-send-email-vladislav.yasevich@hp.com>
References: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:49226 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422908AbXCWNw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 09:52:56 -0400
In-Reply-To: <1174657972645-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Parameters only take effect when a corresponding flag bit is set
and a value is specified. This means we need to check the flags
in addition to checking for non-zero value.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/user.h |   15 +++++++------
 net/sctp/socket.c       |   54 ++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 4ed7521..80b7afe 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -513,16 +513,17 @@ struct sctp_setadaptation {
  *   address's parameters:
  */
 enum  sctp_spp_flags {
-	SPP_HB_ENABLE = 1,		/*Enable heartbeats*/
-	SPP_HB_DISABLE = 2,		/*Disable heartbeats*/
+	SPP_HB_ENABLE = 1<<0,		/*Enable heartbeats*/
+	SPP_HB_DISABLE = 1<<1,		/*Disable heartbeats*/
 	SPP_HB = SPP_HB_ENABLE | SPP_HB_DISABLE,
-	SPP_HB_DEMAND = 4,		/*Send heartbeat immediately*/
-	SPP_PMTUD_ENABLE = 8,		/*Enable PMTU discovery*/
-	SPP_PMTUD_DISABLE = 16,		/*Disable PMTU discovery*/
+	SPP_HB_DEMAND = 1<<2,		/*Send heartbeat immediately*/
+	SPP_PMTUD_ENABLE = 1<<3,	/*Enable PMTU discovery*/
+	SPP_PMTUD_DISABLE = 1<<4,	/*Disable PMTU discovery*/
 	SPP_PMTUD = SPP_PMTUD_ENABLE | SPP_PMTUD_DISABLE,
-	SPP_SACKDELAY_ENABLE = 32,	/*Enable SACK*/
-	SPP_SACKDELAY_DISABLE = 64,	/*Disable SACK*/
+	SPP_SACKDELAY_ENABLE = 1<<5,	/*Enable SACK*/
+	SPP_SACKDELAY_DISABLE = 1<<6,	/*Disable SACK*/
 	SPP_SACKDELAY = SPP_SACKDELAY_ENABLE | SPP_SACKDELAY_DISABLE,
+	SPP_HB_TIME_IS_ZERO = 1<<7,	/* Set HB delay to 0 */
 };
 
 struct sctp_paddrparams {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2d0c2ee..8939536 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2033,6 +2033,10 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
  *                     SPP_HB_DEMAND - Request a user initiated heartbeat
  *                     to be made immediately.
  *
+ *                     SPP_HB_TIME_IS_ZERO - Specify's that the time for
+ *                     heartbeat delayis to be set to the value of 0
+ *                     milliseconds.
+ *
  *                     SPP_PMTUD_ENABLE - This field will enable PMTU
  *                     discovery upon the specified address. Note that
  *                     if the address feild is empty then all addresses
@@ -2075,13 +2079,30 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
 			return error;
 	}
 
-	if (params->spp_hbinterval) {
-		if (trans) {
-			trans->hbinterval = msecs_to_jiffies(params->spp_hbinterval);
-		} else if (asoc) {
-			asoc->hbinterval = msecs_to_jiffies(params->spp_hbinterval);
-		} else {
-			sp->hbinterval = params->spp_hbinterval;
+	/* Note that unless the spp_flag is set to SPP_HB_ENABLE the value of
+	 * this field is ignored.  Note also that a value of zero indicates
+	 * the current setting should be left unchanged.
+	 */
+	if (params->spp_flags & SPP_HB_ENABLE) { 
+
+		/* Re-zero the interval if the SPP_HB_TIME_IS_ZERO is
+		 * set.  This lets us use 0 value when this flag
+		 * is set.
+		 */
+		if (params->spp_flags & SPP_HB_TIME_IS_ZERO)
+			params->spp_hbinterval = 0;
+
+		if (params->spp_hbinterval ||
+		    (params->spp_flags & SPP_HB_TIME_IS_ZERO)) {
+			if (trans) {
+				trans->hbinterval =
+				    msecs_to_jiffies(params->spp_hbinterval);
+			} else if (asoc) {
+				asoc->hbinterval =
+				    msecs_to_jiffies(params->spp_hbinterval);
+			} else {
+				sp->hbinterval = params->spp_hbinterval;
+			}
 		}
 	}
 
@@ -2098,7 +2119,12 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
 		}
 	}
 
-	if (params->spp_pathmtu) {
+	/* When Path MTU discovery is disabled the value specified here will
+	 * be the "fixed" path mtu (i.e. the value of the spp_flags field must
+	 * include the flag SPP_PMTUD_DISABLE for this field to have any
+	 * effect).
+	 */
+	if ((params->spp_flags & SPP_PMTUD_DISABLE) && params->spp_pathmtu) {
 		if (trans) {
 			trans->pathmtu = params->spp_pathmtu;
 			sctp_assoc_sync_pmtu(asoc);
@@ -2129,7 +2155,11 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
 		}
 	}
 
-	if (params->spp_sackdelay) {
+	/* Note that unless the spp_flag is set to SPP_SACKDELAY_ENABLE the
+	 * value of this field is ignored.  Note also that a value of zero
+	 * indicates the current setting should be left unchanged.
+	 */
+	if ((params->spp_flags & SPP_SACKDELAY_ENABLE) && params->spp_sackdelay) {
 		if (trans) {
 			trans->sackdelay =
 				msecs_to_jiffies(params->spp_sackdelay);
@@ -2157,7 +2187,11 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
 		}
 	}
 
-	if (params->spp_pathmaxrxt) {
+	/* Note that unless the spp_flag is set to SPP_PMTUD_ENABLE the value
+	 * of this field is ignored.  Note also that a value of zero
+	 * indicates the current setting should be left unchanged.
+	 */
+	if ((params->spp_flags & SPP_PMTUD_ENABLE) && params->spp_pathmaxrxt) {
 		if (trans) {
 			trans->pathmaxrxt = params->spp_pathmaxrxt;
 		} else if (asoc) {
-- 
1.5.0.3.438.gc49b2

