From: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
Subject: A potential bug in tcp_vegas.c
Date: Thu, 1 Feb 2007 13:03:49 -0800
Message-ID: <7335583a0702011303y5f3565d1r70a79eae94db6348@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:29517 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422948AbXBAVDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 16:03:51 -0500
Received: by ug-out-1314.google.com with SMTP id 44so580378uga
        for <netdev@vger.kernel.org>; Thu, 01 Feb 2007 13:03:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi gurus,

I am testing tcp_vegas.c in Linux with the NS-2 TCP-Linux.
It seems that the ssthresh is not correctly reset to 2 in the
"tcp_vegas_cong_avoid" function.
The problem might lead to very unfair behavior among Vegas flows, when
some flows exit slow start due to loss, not delay.

Please see the detailed effect at:
http://www.cs.caltech.edu/%7Eweixl/technical/ns2linux/known_linux/#vegas
(the section of "Setting of Slow-Start-Threshold")

A patch I wrote (for Linux 2.6.19-2) is attached.
Basically, the branch that sets ssthresh to be 2 should be outside the
condition of (cwnd<=ssthresh).

--- tcp_vegas.c.old     2007-02-01 00:33:55.000000000 -0800
+++ tcp_vegas.c 2007-02-01 00:39:49.000000000 -0800
@@ -265,26 +265,25 @@
                        */
                       diff = (old_wnd << V_PARAM_SHIFT) - target_cwnd;

-                       if (tp->snd_cwnd <= tp->snd_ssthresh) {
-                               /* Slow start.  */
-                               if (diff > gamma) {
-                                       /* Going too fast. Time to slow down
-                                        * and switch to congestion avoidance.
-                                        */
-                                       tp->snd_ssthresh = 2;
+                       if (diff > gamma && tp->snd_ssthresh > 2 ) {
+                               /* Going too fast. Time to slow down
+                                * and switch to congestion avoidance.
+                                */
+                               tp->snd_ssthresh = 2;

-                                       /* Set cwnd to match the actual rate
-                                        * exactly:
-                                        *   cwnd = (actual rate) * baseRTT
-                                        * Then we add 1 because the integer
-                                        * truncation robs us of full link
-                                        * utilization.
-                                        */
-                                       tp->snd_cwnd = min(tp->snd_cwnd,
-                                                          (target_cwnd >>
-                                                           V_PARAM_SHIFT)+1);
+                               /* Set cwnd to match the actual rate
+                                * exactly:
+                                *   cwnd = (actual rate) * baseRTT
+                                * Then we add 1 because the integer
+                                * truncation robs us of full link
+                                * utilization.
+                                */
+                               tp->snd_cwnd = min(tp->snd_cwnd,
+                                                  (target_cwnd >>
+                                                   V_PARAM_SHIFT)+1);

-                               }
+                       } else if (tp->snd_cwnd <= tp->snd_ssthresh) {
+                               /* Slow start.  */
                               tcp_slow_start(tp);
                       } else {
                               /* Congestion avoidance. */



Thanks.

-David

--
Xiaoliang (David) Wei      Graduate Student, CS@Caltech
http://davidwei.org
***********************************************
