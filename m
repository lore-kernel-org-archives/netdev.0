From: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
Subject: [PATCH][TCP] tcp_vegas.c: (tcp_vegas_cong_avoid) fix a bug in disabling slow start by gamma parameter
Date: Tue, 9 Oct 2007 00:10:51 -0700
Message-ID: <7335583a0710090010w4ec27015h33d5f058e0f1a3ab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:61580 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbXJIHKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 03:10:53 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1466312nfb
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2007 00:10:52 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TCP Vegas implementation has a bug in the process of disabling
slow-start with gamma parameter. The bug may lead to extreme
unfairness in the presence of early packet loss. See details in:
http://www.cs.caltech.edu/~weixl/technical/ns2linux/known_linux/index.html#vegas


Switch the order of "if (tp->snd_cwnd <= tp->snd_ssthresh)" statement
and "if (diff > gamma)" statement to eliminate the problem.

Signed-off-by: Xiaoliang (David) Wei  <http://www.davidwei.org>
---
 linux-2.6.22.9-fixedvegas/net/ipv4/tcp_vegas.c |   35 ++++++++++++-------------
 1 files changed, 17 insertions(+), 18 deletions(-)

diff -uprN linux-2.6.22.9/net/ipv4/tcp_vegas.c
linux-2.6.22.9-fixedvegas/net/ipv4/tcp_vegas.c
--- linux-2.6.22.9/net/ipv4/tcp_vegas.c	2007-09-26 11:03:01.000000000 -0700
+++ linux-2.6.22.9-fixedvegas/net/ipv4/tcp_vegas.c	2007-10-08
22:44:46.000000000 -0700
@@ -266,26 +266,25 @@ static void tcp_vegas_cong_avoid(struct
 			 */
 			diff = (old_wnd << V_PARAM_SHIFT) - target_cwnd;

-			if (tp->snd_cwnd <= tp->snd_ssthresh) {
-				/* Slow start.  */
-				if (diff > gamma) {
-					/* Going too fast. Time to slow down
-					 * and switch to congestion avoidance.
-					 */
-					tp->snd_ssthresh = 2;
+			if (diff > gamma && tp->snd_ssthresh > 2 ) {
+				/* Going too fast. Time to slow down
+				 * and switch to congestion avoidance.
+				 */
+				tp->snd_ssthresh = 2;

-					/* Set cwnd to match the actual rate
-					 * exactly:
-					 *   cwnd = (actual rate) * baseRTT
-					 * Then we add 1 because the integer
-					 * truncation robs us of full link
-					 * utilization.
-					 */
-					tp->snd_cwnd = min(tp->snd_cwnd,
-							   (target_cwnd >>
-							    V_PARAM_SHIFT)+1);
+				/* Set cwnd to match the actual rate
+				 * exactly:
+				 *   cwnd = (actual rate) * baseRTT
+				 * Then we add 1 because the integer
+				 * truncation robs us of full link
+				 * utilization.
+				 */
+				tp->snd_cwnd = min(tp->snd_cwnd,
+						   (target_cwnd >>
+						    V_PARAM_SHIFT)+1);

-				}
+			} else if (tp->snd_cwnd <= tp->snd_ssthresh) {
+				/* Slow start.  */
 				tcp_slow_start(tp);
 			} else {
 				/* Congestion avoidance. */
