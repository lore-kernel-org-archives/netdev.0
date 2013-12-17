From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v3 2/2] SCTP: Reduce log spamming for sctp setsockopt
Date: Tue, 17 Dec 2013 11:19:59 -0500
Message-ID: <1387297199-14363-3-git-send-email-nhorman@tuxdriver.com>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
 <1387297199-14363-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53075 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425Ab3LQQUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 11:20:30 -0500
In-Reply-To: <1387297199-14363-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During a recent discussion regarding some sctp socket options, it was noted that
we have several points at which we issue log warnings that can be flooded at an
unbounded rate by any user.  Fix this by converting all the pr_warns in the
sctp_setsockopt path to be pr_warn_ratelimited.

Note there are several debug level messages as well.  I'm leaving those alone,
as, if you turn on pr_debug, you likely want lots of verbosity.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: David Miller <davem@davemloft.net>
CC: netdev@vger.kernel.org

---

Change notes:

V2)
	* Based on suggestions from Daniel Borkman, and Joe Perches I'm creating
and using a new pr_warn_deprecated macro

	* Note from David Laight, The pr_warn statements come in pairs, and if
one is printed through the ratelimit filter, the other should also be printed.
Correct this by merging both calls into a single pr_warn_deprecated call.

v3)
	* Convert to using DEPRECATED macro
---
 net/sctp/socket.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 42b709c..edd261e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2579,8 +2579,9 @@ static int sctp_setsockopt_delayed_ack(struct sock *sk,
 		if (params.sack_delay == 0 && params.sack_freq == 0)
 			return 0;
 	} else if (optlen == sizeof(struct sctp_assoc_value)) {
-		pr_warn("Use of struct sctp_assoc_value in delayed_ack socket option deprecated\n");
-		pr_warn("Use struct sctp_sack_info instead\n");
+		pr_warn_ratelimited(DEPRECATED
+				    "Use of struct sctp_assoc_value in delayed_ack socket option.\n"
+				    "Use struct sctp_sack_info instead\n");
 		if (copy_from_user(&params, optval, optlen))
 			return -EFAULT;
 
@@ -2995,8 +2996,9 @@ static int sctp_setsockopt_maxseg(struct sock *sk, char __user *optval, unsigned
 	int val;
 
 	if (optlen == sizeof(int)) {
-		pr_warn("Use of int in maxseg socket option deprecated\n");
-		pr_warn("Use struct sctp_assoc_value instead\n");
+		pr_warn_ratelimited(DEPRECATED
+				    "Use of int in maxseg socket option.\n"
+				    "Use struct sctp_assoc_value instead\n");
 		if (copy_from_user(&val, optval, optlen))
 			return -EFAULT;
 		params.assoc_id = 0;
@@ -3253,8 +3255,9 @@ static int sctp_setsockopt_maxburst(struct sock *sk,
 	int assoc_id = 0;
 
 	if (optlen == sizeof(int)) {
-		pr_warn("Use of int in max_burst socket option deprecated\n");
-		pr_warn("Use struct sctp_assoc_value instead\n");
+		pr_warn_ratelimited(DEPRECATED
+				    "Use of int in max_burst socket option deprecated.\n"
+				    "Use struct sctp_assoc_value instead\n");
 		if (copy_from_user(&val, optval, optlen))
 			return -EFAULT;
 	} else if (optlen == sizeof(struct sctp_assoc_value)) {
@@ -4574,8 +4577,9 @@ static int sctp_getsockopt_delayed_ack(struct sock *sk, int len,
 		if (copy_from_user(&params, optval, len))
 			return -EFAULT;
 	} else if (len == sizeof(struct sctp_assoc_value)) {
-		pr_warn("Use of struct sctp_assoc_value in delayed_ack socket option deprecated\n");
-		pr_warn("Use struct sctp_sack_info instead\n");
+		pr_warn_ratelimited(DEPRECATED
+				    "Use of struct sctp_assoc_value in delayed_ack socket option.\n"
+				    "Use struct sctp_sack_info instead\n");
 		if (copy_from_user(&params, optval, len))
 			return -EFAULT;
 	} else
@@ -5219,8 +5223,9 @@ static int sctp_getsockopt_maxseg(struct sock *sk, int len,
 	struct sctp_association *asoc;
 
 	if (len == sizeof(int)) {
-		pr_warn("Use of int in maxseg socket option deprecated\n");
-		pr_warn("Use struct sctp_assoc_value instead\n");
+		pr_warn_ratelimited(DEPRECATED
+				    "Use of int in maxseg socket option.\n"
+				    "Use struct sctp_assoc_value instead\n");
 		params.assoc_id = 0;
 	} else if (len >= sizeof(struct sctp_assoc_value)) {
 		len = sizeof(struct sctp_assoc_value);
@@ -5311,8 +5316,9 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 	struct sctp_association *asoc;
 
 	if (len == sizeof(int)) {
-		pr_warn("Use of int in max_burst socket option deprecated\n");
-		pr_warn("Use struct sctp_assoc_value instead\n");
+		pr_warn_ratelimited(DEPRECATED
+				    "Use of int in max_burst socket option.\n"
+				    "Use struct sctp_assoc_value instead\n");
 		params.assoc_id = 0;
 	} else if (len >= sizeof(struct sctp_assoc_value)) {
 		len = sizeof(struct sctp_assoc_value);
-- 
1.8.3.1
