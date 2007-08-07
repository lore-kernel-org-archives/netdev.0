From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] cubic: backoff after slow start
Date: Tue, 7 Aug 2007 14:37:39 -0400
Message-ID: <20070807143739.7badea0a@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Injong Rhee <rhee@eos.ncsu.edu>, Sangtae Ha <sha2@ncsu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34450 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754567AbXHGShO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 14:37:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CUBIC takes several unnecessary iterations to converge out of slow start. This
is most noticable over a link where the bottleneck queue size is much larger than BDP,
and the sender has to "fill the pipe" in slow start before the first loss. Typical
consumer broadband links seem to have large (up to 2secs) of queue that needs
to get filled before the first loss.

A possible fix is to use a beta of .5 (same as original TCP) when leaving
slow start.  Originally, the Linux version didn't do slow start so it probably
never was observed.

--- a/net/ipv4/tcp_cubic.c	2007-08-02 12:16:22.000000000 +0100
+++ b/net/ipv4/tcp_cubic.c	2007-08-03 15:57:12.000000000 +0100
@@ -289,7 +289,11 @@ static u32 bictcp_recalc_ssthresh(struct
 
 	ca->loss_cwnd = tp->snd_cwnd;
 
-	return max((tp->snd_cwnd * beta) / BICTCP_BETA_SCALE, 2U);
+	/* Initial backoff when leaving slow start */
+	if (tp->snd_ssthresh == 0x7fffffff)
+		return max(tp->snd_cwnd >> 1U, 2U);
+	else
+		return max((tp->snd_cwnd * beta) / BICTCP_BETA_SCALE, 2U);
 }
 
 static u32 bictcp_undo_cwnd(struct sock *sk)
