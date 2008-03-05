From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] [SCTP]: Bring MAX_BURST socket option into ietf API extension
 compliance
Date: Tue, 04 Mar 2008 22:46:33 -0500
Message-ID: <47CE1799.5040706@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	lksctp-developers <lksctp-developers@lists.sourceforge.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:31542 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbYCEDqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 22:46:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

Brings max_burst socket option set/get into line with the latest ietf socket
extensions api draft, while maintaining backwards compatibility.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   73 +++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 60 insertions(+), 13 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9398926..d994d82 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2933,17 +2933,39 @@ static int sctp_setsockopt_maxburst(struct sock *sk,
 				    char __user *optval,
 				    int optlen)
 {
+	struct sctp_assoc_value params;
+	struct sctp_sock *sp;
+	struct sctp_association *asoc;
 	int val;
+	int assoc_id = 0;
 
-	if (optlen != sizeof(int))
+	if (optlen < sizeof(int))
 		return -EINVAL;
-	if (get_user(val, (int __user *)optval))
-		return -EFAULT;
 
-	if (val < 0)
+	if (optlen == sizeof(int)) {
+		printk(KERN_WARNING
+		   "SCTP: Use of int in max_burst socket option deprecated\n");
+		printk(KERN_WARNING
+		   "SCTP: Use struct sctp_assoc_value instead\n");
+		if (copy_from_user(&val, optval, optlen))
+			return -EFAULT;
+	} else if (optlen == sizeof(struct sctp_assoc_value)) {
+		if (copy_from_user(&params, optval, optlen))
+			return -EFAULT;
+		val = params.assoc_value;
+		assoc_id = params.assoc_id;
+	} else
 		return -EINVAL;
 
-	sctp_sk(sk)->max_burst = val;
+	sp = sctp_sk(sk);
+
+	if (assoc_id != 0) {
+		asoc = sctp_id2assoc(sk, assoc_id);
+		if (!asoc)
+			return -EINVAL;
+		asoc->max_burst = val;
+	} else
+		sp->max_burst = val;
 
 	return 0;
 }
@@ -5005,20 +5027,45 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 				    char __user *optval,
 				    int __user *optlen)
 {
-	int val;
+	struct sctp_assoc_value params;
+	struct sctp_sock *sp;
+	struct sctp_association *asoc;
 
 	if (len < sizeof(int))
 		return -EINVAL;
 
-	len = sizeof(int);
+	if (len == sizeof(int)) {
+		printk(KERN_WARNING
+		   "SCTP: Use of int in max_burst socket option deprecated\n");
+		printk(KERN_WARNING
+		   "SCTP: Use struct sctp_assoc_value instead\n");
+		params.assoc_id = 0;
+	} else if (len == sizeof (struct sctp_assoc_value)) {
+		if (copy_from_user(&params, optval, len))
+			return -EFAULT;
+	} else
+		return -EINVAL;
 
-	val = sctp_sk(sk)->max_burst;
-	if (put_user(len, optlen))
-		return -EFAULT;
-	if (copy_to_user(optval, &val, len))
-		return -EFAULT;
+	sp = sctp_sk(sk);
+
+	if (params.assoc_id != 0) {
+		asoc = sctp_id2assoc(sk, params.assoc_id);
+		if (!asoc)
+			return -EINVAL;
+		params.assoc_value = asoc->max_burst;
+	} else
+		params.assoc_value = sp->max_burst;
+
+	if (len == sizeof(int)) {
+		if (copy_to_user(optval, &params.assoc_value, len))
+			return -EFAULT;
+	} else {
+		if (copy_to_user(optval, &params, len))
+			return -EFAULT;
+	}
+
+	return 0;
 
-	return -ENOTSUPP;
 }
 
 static int sctp_getsockopt_hmac_ident(struct sock *sk, int len,
-- 
1.5.2.5

