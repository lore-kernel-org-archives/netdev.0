From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v6 1/3] sctp: check the rto_min and rto_max in setsockopt
Date: Tue, 10 Dec 2013 10:46:35 +0800
Message-ID: <1386643597-22156-2-git-send-email-wangweidong1@huawei.com>
References: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:18175 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab3LJCrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:47:24 -0500
In-Reply-To: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we set 0 to rto_min or rto_max, just not change the value. Also
we should check the rto_min > rto_max.

Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/socket.c | 32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 72046b9..da09e59 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2811,6 +2811,8 @@ static int sctp_setsockopt_rtoinfo(struct sock *sk, char __user *optval, unsigne
 {
 	struct sctp_rtoinfo rtoinfo;
 	struct sctp_association *asoc;
+	unsigned long rto_min, rto_max;
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	if (optlen != sizeof (struct sctp_rtoinfo))
 		return -EINVAL;
@@ -2824,26 +2826,36 @@ static int sctp_setsockopt_rtoinfo(struct sock *sk, char __user *optval, unsigne
 	if (!asoc && rtoinfo.srto_assoc_id && sctp_style(sk, UDP))
 		return -EINVAL;
 
+	rto_max = rtoinfo.srto_max;
+	rto_min = rtoinfo.srto_min;
+
+	if (rto_max)
+		rto_max = asoc ? msecs_to_jiffies(rto_max) : rto_max;
+	else
+		rto_max = asoc ? asoc->rto_max : sp->rtoinfo.srto_max;
+
+	if (rto_min)
+		rto_min = asoc ? msecs_to_jiffies(rto_min) : rto_min;
+	else
+		rto_min = asoc ? asoc->rto_min : sp->rtoinfo.srto_min;
+
+	if (rto_min > rto_max)
+		return -EINVAL;
+
 	if (asoc) {
 		if (rtoinfo.srto_initial != 0)
 			asoc->rto_initial =
 				msecs_to_jiffies(rtoinfo.srto_initial);
-		if (rtoinfo.srto_max != 0)
-			asoc->rto_max = msecs_to_jiffies(rtoinfo.srto_max);
-		if (rtoinfo.srto_min != 0)
-			asoc->rto_min = msecs_to_jiffies(rtoinfo.srto_min);
+		asoc->rto_max = rto_max;
+		asoc->rto_min = rto_min;
 	} else {
 		/* If there is no association or the association-id = 0
 		 * set the values to the endpoint.
 		 */
-		struct sctp_sock *sp = sctp_sk(sk);
-
 		if (rtoinfo.srto_initial != 0)
 			sp->rtoinfo.srto_initial = rtoinfo.srto_initial;
-		if (rtoinfo.srto_max != 0)
-			sp->rtoinfo.srto_max = rtoinfo.srto_max;
-		if (rtoinfo.srto_min != 0)
-			sp->rtoinfo.srto_min = rtoinfo.srto_min;
+		sp->rtoinfo.srto_max = rto_max;
+		sp->rtoinfo.srto_min = rto_min;
 	}
 
 	return 0;
-- 
1.7.12
