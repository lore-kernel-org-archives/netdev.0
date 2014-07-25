From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net] tcp: Fix integer-overflows in TCP vegas
Date: Fri, 25 Jul 2014 11:14:48 -0700
Message-ID: <20140725111448.53df867a@haswell.linuxnetplumber.net>
References: <1406289159-30498-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Doug Leith <doug.leith@nuim.ie>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:43771 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaGYSOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 14:14:46 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so5907849pde.18
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 11:14:46 -0700 (PDT)
In-Reply-To: <1406289159-30498-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jul 2014 13:52:39 +0200
Christoph Paasch <christoph.paasch@uclouvain.be> wrote:

> In vegas we do a multiplication of the cwnd and the rtt. This
> may overflow and thus their result is stored in a u64. The current code
> however does not cast the cwnd to a u64 and thus 32-bit arithmetic will
> be done. This means, that in case of an integer overflow, the result is
> completly wrong.
> 
> This patch fixes it, by splitting the calculation of target_cwnd in two:
> 
> 1. The non-overflow case: We just do a regular division here.
> 2. The overflow-case: In this case we also want to avoid doing a costly do_div.
>    So, we calculate the upper 32 bits (that are overflowing) and the
>    error and add everything up. More details are in the comment in
>    tcp_vegas.c
> 
> For the accuracy, I tested this with a python script that does the
> same 32-bit arithmetic and compared the difference of this one with
> the result of floating-point arithmetic with the following ranges in
> a space-filling design across this 3-dimensional space:
> 
> snd_cwnd : [1, 2^31 / 1500] (that's the maximum congestion-window size,
>                              assuming a send-buffer of 2^31 and a MSS of 1500)
> rtt: [1, 2^28]
> baseRTT: [1, rtt]
> 
> The error is never bigger than 10% in this simulation.
> 
> If I set the rtt bigger than 2^28 the error may grow up to 50%.
> 
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: David Laight <David.Laight@ACULAB.COM>
> Cc: Doug Leith <doug.leith@nuim.ie>
> Fixes: 8d3a564da34e (tcp: tcp_vegas cong avoid fix)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Wouldnt the simple, dumb approach used by other places doing 64 bit by 32 divide
in the kernel be sufficient?

--- a/net/ipv4/tcp_vegas.c	2014-05-16 20:27:32.499419952 -0700
+++ b/net/ipv4/tcp_vegas.c	2014-07-25 11:14:18.161465900 -0700
@@ -218,7 +218,9 @@ static void tcp_vegas_cong_avoid(struct
 			 * This is:
 			 *     (actual rate in segments) * baseRTT
 			 */
-			target_cwnd = tp->snd_cwnd * vegas->baseRTT / rtt;
+			target_cwnd = tp->snd_cwnd;
+			target_cwnd *= vegas->baseRTT;
+			do_div(target_cwnd, rtt);
 
 			/* Calculate the difference between the window we had,
 			 * and the window we would like to have. This quantity
@@ -238,7 +240,7 @@ static void tcp_vegas_cong_avoid(struct
 				 * truncation robs us of full link
 				 * utilization.
 				 */
-				tp->snd_cwnd = min(tp->snd_cwnd, (u32)target_cwnd+1);
+				tp->snd_cwnd = min_t(u64, tp->snd_cwnd, target_cwnd+1);
 				tp->snd_ssthresh = tcp_vegas_ssthresh(tp);
 
 			} else if (tp->snd_cwnd <= tp->snd_ssthresh) {
