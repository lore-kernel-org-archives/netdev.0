From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: [PATCH] Use inline function dst_metric() instead of direct access to dst->metric[]
Date: Fri, 25 Apr 2008 23:17:00 +0900
Message-ID: <d72b7ace0804250717g40f81ea0o899f43fdc1d08384@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:13687 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444AbYDYORU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 10:17:20 -0400
Received: by yw-out-2324.google.com with SMTP id 5so537389ywh.1
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 07:17:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are functions to refer to the value of dst->metric[THE_METRIC-1] directly
without use of a inline function "dst_metric" defined in net/dst.h.

The following patch changes them to use the inline function consistently.

Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

 net/decnet/dn_route.c |    4 ++--
 net/ipv4/route.c      |    2 +-
 net/ipv4/tcp_input.c  |   15 ++++++++-------
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 2f665a5..9c23160 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -235,14 +235,14 @@ static void dn_dst_update_pmtu(struct dst_entry
*dst, u32 mtu)
 	else
 		min_mtu -= 21;

-	if (dst->metrics[RTAX_MTU-1] > mtu && mtu >= min_mtu) {
+	if (dst_metric(dst, RTAX_MTU) > mtu && mtu >= min_mtu) {
 		if (!(dst_metric_locked(dst, RTAX_MTU))) {
 			dst->metrics[RTAX_MTU-1] = mtu;
 			dst_set_expires(dst, dn_rt_mtu_expires);
 		}
 		if (!(dst_metric_locked(dst, RTAX_ADVMSS))) {
 			u32 mss = mtu - DN_MAX_NSP_DATA_HEADER;
-			if (dst->metrics[RTAX_ADVMSS-1] > mss)
+			if (dst_metric(dst, RTAX_ADVMSS) > mss)
 				dst->metrics[RTAX_ADVMSS-1] = mss;
 		}
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 780e948..1184f5d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1490,7 +1490,7 @@ unsigned short ip_rt_frag_needed(struct net
*net, struct iphdr *iph,

 static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
-	if (dst->metrics[RTAX_MTU-1] > mtu && mtu >= 68 &&
+	if (dst_metric(dst, RTAX_MTU) > mtu && mtu >= 68 &&
 	    !(dst_metric_locked(dst, RTAX_MTU))) {
 		if (mtu < ip_rt_min_pmtu) {
 			mtu = ip_rt_min_pmtu;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cdc051b..deee5ef 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -66,6 +66,7 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/sysctl.h>
+#include <net/dst.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
 #include <linux/ipsec.h>
@@ -605,7 +606,7 @@ static u32 tcp_rto_min(struct sock *sk)
 	u32 rto_min = TCP_RTO_MIN;

 	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
-		rto_min = dst->metrics[RTAX_RTO_MIN - 1];
+		rto_min = dst_metric(dst, RTAX_RTO_MIN);
 	return rto_min;
 }

@@ -769,7 +770,7 @@ void tcp_update_metrics(struct sock *sk)
 				dst->metrics[RTAX_RTTVAR - 1] = m;
 			else
 				dst->metrics[RTAX_RTTVAR-1] -=
-					(dst->metrics[RTAX_RTTVAR-1] - m)>>2;
+					(dst_metric(dst, RTAX_RTTVAR) - m)>>2;
 		}

 		if (tp->snd_ssthresh >= 0xFFFF) {
@@ -788,21 +789,21 @@ void tcp_update_metrics(struct sock *sk)
 				dst->metrics[RTAX_SSTHRESH-1] =
 					max(tp->snd_cwnd >> 1, tp->snd_ssthresh);
 			if (!dst_metric_locked(dst, RTAX_CWND))
-				dst->metrics[RTAX_CWND-1] = (dst->metrics[RTAX_CWND-1] +
tp->snd_cwnd) >> 1;
+				dst->metrics[RTAX_CWND-1] = (dst_metric(dst, RTAX_CWND) +
tp->snd_cwnd) >> 1;
 		} else {
 			/* Else slow start did not finish, cwnd is non-sense,
 			   ssthresh may be also invalid.
 			 */
 			if (!dst_metric_locked(dst, RTAX_CWND))
-				dst->metrics[RTAX_CWND-1] = (dst->metrics[RTAX_CWND-1] +
tp->snd_ssthresh) >> 1;
-			if (dst->metrics[RTAX_SSTHRESH-1] &&
+				dst->metrics[RTAX_CWND-1] = (dst_metric(dst, RTAX_CWND) +
tp->snd_ssthresh) >> 1;
+			if (dst_metric(dst, RTAX_SSTHRESH) &&
 			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
-			    tp->snd_ssthresh > dst->metrics[RTAX_SSTHRESH-1])
+			    tp->snd_ssthresh > dst_metric(dst, RTAX_SSTHRESH))
 				dst->metrics[RTAX_SSTHRESH-1] = tp->snd_ssthresh;
 		}

 		if (!dst_metric_locked(dst, RTAX_REORDERING)) {
-			if (dst->metrics[RTAX_REORDERING-1] < tp->reordering &&
+			if (dst_metric(dst, RTAX_REORDERING) < tp->reordering &&
 			    tp->reordering != sysctl_tcp_reordering)
 				dst->metrics[RTAX_REORDERING-1] = tp->reordering;
 		}
