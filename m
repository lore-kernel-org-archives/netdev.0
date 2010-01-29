From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 1/3][v2] tcp: fix ICMP-RTO war: Check lower bound
Date: Fri, 29 Jan 2010 23:15:54 +0100
Message-ID: <4B635E1A.7040100@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54475 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755763Ab0A2WPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 17:15:55 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KX100C4V4IFDL00@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 29 Jan 2010 23:15:54 +0100 (CET)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id o0TMFsPB019788	for
 <netdev@vger.kernel.org>; Fri, 29 Jan 2010 23:15:54 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure, that the returned RTO value does not under-run the valid
minimum RTO as given by tcp_rto_min().
Under some circumstances, TCPs srtt and rttvar are zero,
yielding a calculated RTO of zero.
This is particularly unfortunate for ICMP based RTO recalculation
as introduced in f1ecd5d9e736660 (Revert Backoff [v3]: Revert RTO
on ICMP destination unreachable).
Given an initial RTO of zero, the calculation yields zero independent
of icsk_backoff, which results in RTO retransmission flooding.

Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 34f5cc2..ff6cbaa 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -528,9 +528,12 @@ static inline void tcp_bound_rto(const struct sock *sk)
 		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
 }
 
+static inline u32 tcp_rto_min(struct sock *sk);
 static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 {
-	return (tp->srtt >> 3) + tp->rttvar;
+	u32 rto = (tp->srtt >> 3) + tp->rttvar;
+	u32 min = tcp_rto_min((struct sock *)tp);
+	return unlikely(rto < min) ? min : rto;
 }
 
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
-- 
1.6.4.4
