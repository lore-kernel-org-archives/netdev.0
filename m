From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 1/4] NET: AX.25: Check ioctl arguments to avoid overflows
 further down the road.
Date: Thu, 24 Nov 2011 16:12:59 +0000
Message-ID: <1d2adcd4eadb1f42926734cca5886dfad258aeb6.1322214950.git.ralf@linux-mips.org>
References: <cover.1322214950.git.ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Xi Wang <xi.wang@gmail.com>, Joerg Reuter <jreuter@yaina.de>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Thomas Osterried <thomas@osterried.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:52585 "EHLO linux-mips.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754595Ab1KYLJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 06:09:56 -0500
In-Reply-To: <cover.1322214950.git.ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Very large, nonsenical arguments or use in very extreme conditions could
result in integer overflows.  Check ioctls arguments to avoid such
overflows and return -EINVAL for too large arguments.

To allow the use of AX.25 for even the most extreme setup (think packet
radio to the Phase 5E mars probe) we make no further attempt to clamp the
argument range.

Originally reported by Fan Long <longfancn@gmail.com> and a first patch
was sent by Xi Wang <xi.wang@gmail.com>.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Cc: Xi Wang <xi.wang@gmail.com>
Cc: Joerg Reuter <jreuter@yaina.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Thomas Osterried <thomas@osterried.de>
---
 net/ax25/af_ax25.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index e7c69f4..b863c18 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -402,14 +402,14 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 		break;
 
 	case AX25_T1:
-		if (ax25_ctl.arg < 1)
+		if (ax25_ctl.arg < 1 || ax25_ctl.arg > ULONG_MAX / HZ)
 			goto einval_put;
 		ax25->rtt = (ax25_ctl.arg * HZ) / 2;
 		ax25->t1  = ax25_ctl.arg * HZ;
 		break;
 
 	case AX25_T2:
-		if (ax25_ctl.arg < 1)
+		if (ax25_ctl.arg < 1 || ax25_ctl.arg > ULONG_MAX / HZ)
 			goto einval_put;
 		ax25->t2 = ax25_ctl.arg * HZ;
 		break;
@@ -422,10 +422,15 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 		break;
 
 	case AX25_T3:
+		if (ax25_ctl.arg > ULONG_MAX / HZ)
+			goto einval_put;
 		ax25->t3 = ax25_ctl.arg * HZ;
 		break;
 
 	case AX25_IDLE:
+		if (ax25_ctl.arg > ULONG_MAX / (60 * HZ))
+			goto einval_put;
+
 		ax25->idle = ax25_ctl.arg * 60 * HZ;
 		break;
 
@@ -571,7 +576,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case AX25_T1:
-		if (opt < 1) {
+		if (opt < 1 || opt > ULONG_MAX / HZ) {
 			res = -EINVAL;
 			break;
 		}
@@ -580,7 +585,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case AX25_T2:
-		if (opt < 1) {
+		if (opt < 1 || opt > ULONG_MAX / HZ) {
 			res = -EINVAL;
 			break;
 		}
@@ -596,7 +601,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case AX25_T3:
-		if (opt < 1) {
+		if (opt < 1 || opt > ULONG_MAX / HZ) {
 			res = -EINVAL;
 			break;
 		}
@@ -604,7 +609,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case AX25_IDLE:
-		if (opt < 0) {
+		if (opt < 0 || opt > ULONG_MAX / (60 * HZ)) {
 			res = -EINVAL;
 			break;
 		}
-- 
1.7.4.4
