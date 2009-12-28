From: "Hwang Jae-Hyun" <jhhwang@os.korea.ac.kr>
Subject: [PATCH] tcp: for tcp westwood implementation
Date: Mon, 28 Dec 2009 14:18:33 +0900
Message-ID: <021101ca877d$337f4140$9a7dc3c0$@korea.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from os.korea.ac.kr ([163.152.39.64]:53547 "EHLO os.korea.ac.kr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750913AbZL1FSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 00:18:42 -0500
Received: from jhhwang ([163.152.41.60])
	by os.korea.ac.kr (8.13.8/8.13.8) with ESMTP id nBS5IeUf029242
	for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 14:18:40 +0900
Content-Language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>

Current net/ipv4/tcp_westwood.c seems to be unnatural when compared with
Westwood papers.
Since Linux TCP calls '.ssthresh' interface whenever packet loss is
detected,
it is more natural that the interface points to 'tcp_westwood_bw_rttmin'
function, not Reno's function.
This patch also enables Westwood to perform its algorithm when CA_EVENT_LOSS
event is generated as explained in the papers.

Signed-off-by: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
---

--- linux-2.6.32.2/net/ipv4/tcp_westwood.c.orig 2009-12-28
13:35:42.000000000 +0900
+++ linux-2.6.32.2/net/ipv4/tcp_westwood.c      2009-12-28
13:36:54.000000000 +0900
@@ -232,12 +232,7 @@ static void tcp_westwood_event(struct so
                westwood_fast_bw(sk);
                break;
 
-       case CA_EVENT_COMPLETE_CWR:
-               tp->snd_cwnd = tp->snd_ssthresh =
tcp_westwood_bw_rttmin(sk);
-               break;
-
        case CA_EVENT_FRTO:
-               tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
                /* Update RTT_min when next ack arrives */
                w->reset_rtt_min = 1;
                break;
@@ -274,9 +269,8 @@ static void tcp_westwood_info(struct soc
 
 static struct tcp_congestion_ops tcp_westwood = {
        .init           = tcp_westwood_init,
-       .ssthresh       = tcp_reno_ssthresh,
+       .ssthresh       = tcp_westwood_bw_rttmin,
        .cong_avoid     = tcp_reno_cong_avoid,
-       .min_cwnd       = tcp_westwood_bw_rttmin,
        .cwnd_event     = tcp_westwood_event,
        .get_info       = tcp_westwood_info,
        .pkts_acked     = tcp_westwood_pkts_acked,
--

