From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] tcp: don't allow syn packets without timestamps to pass tcp_tw_recycle logic
Date: Thu, 14 Aug 2014 22:06:12 +0200
Message-ID: <6c91df2ee8f92c4687c98342d5dde52bbc3c5fe8.1408046709.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55809 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753350AbaHNUGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 16:06:24 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway1.nyi.internal (Postfix) with ESMTP id BB41824640
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 16:06:19 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_tw_recycle heavily relies on tcp timestamps to build a per-host
ordering of incoming connections and teardowns without the need to
hold state on a specific quadruple for TCP_TIMEWAIT_LEN, but only for
the last measured RTO. To do so, we keep the last seen timestamp in a
per-host indexed data structure and verify if the incoming timestamp
in a connection request is strictly greater than the saved one during
last connection teardown. Thus we can verify later on that no old data
packets will be accepted by the new connection.

During moving a socket to time-wait state we already verify if timestamps
where seen on a connection. Only if that was the case we let the
time-wait socket expire after the RTO, otherwise normal TCP_TIMEWAIT_LEN
will be used. But we don't verify this on incoming SYN packets. If a
connection teardown was less than TCP_PAWS_MSL seconds in the past we
cannot guarantee to not accept data packets from an old connection if
no timestamps are present. We should drop this SYN packet. This patch
closes this loophole.

Please note, this patch does not make tcp_tw_recycle in any way more
usable but only adds another safety check:
Sporadic drops of SYN packets because of reordering in the network or
in the socket backlog queues can happen. Users behing NAT trying to
connect to a tcp_tw_recycle enabled server can get caught in blackholes
and their connection requests may regullary get dropped because hosts
behind an address translator don't have synchronized tcp timestamp clocks.
tcp_tw_recycle cannot work if peers don't have tcp timestamps enabled.

In general, use of tcp_tw_recycle is disadvised.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2:
- updated changelog to disadvise people from ever using tcp_tw_recycle

 include/net/tcp.h      | 2 +-
 net/ipv4/tcp_input.c   | 9 ++++++---
 net/ipv4/tcp_metrics.c | 6 ++++--
 3 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index dafa1cb..68425af 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -417,7 +417,7 @@ void tcp_update_metrics(struct sock *sk);
 void tcp_init_metrics(struct sock *sk);
 void tcp_metrics_init(void);
 bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst,
-			bool paws_check);
+			bool paws_check, bool timestamps);
 bool tcp_remember_stamp(struct sock *sk);
 bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw);
 void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a3d47af..a0eb435 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5979,12 +5979,14 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		 * timewait bucket, so that all the necessary checks
 		 * are made in the function processing timewait state.
 		 */
-		if (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_recycle) {
+		if (tcp_death_row.sysctl_tw_recycle) {
 			bool strict;
 
 			dst = af_ops->route_req(sk, &fl, req, &strict);
+
 			if (dst && strict &&
-			    !tcp_peer_is_proven(req, dst, true)) {
+			    !tcp_peer_is_proven(req, dst, true,
+						tmp_opt.saw_tstamp)) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
 				goto drop_and_release;
 			}
@@ -5993,7 +5995,8 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		else if (!sysctl_tcp_syncookies &&
 			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
 			  (sysctl_max_syn_backlog >> 2)) &&
-			 !tcp_peer_is_proven(req, dst, false)) {
+			 !tcp_peer_is_proven(req, dst, false,
+					     tmp_opt.saw_tstamp)) {
 			/* Without syncookies last quarter of
 			 * backlog is filled with destinations,
 			 * proven to be alive.
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 0d54e59..ed9c9a9 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -576,7 +576,8 @@ reset:
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst, bool paws_check)
+bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst,
+			bool paws_check, bool timestamps)
 {
 	struct tcp_metrics_block *tm;
 	bool ret;
@@ -589,7 +590,8 @@ bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst, bool pa
 	if (paws_check) {
 		if (tm &&
 		    (u32)get_seconds() - tm->tcpm_ts_stamp < TCP_PAWS_MSL &&
-		    (s32)(tm->tcpm_ts - req->ts_recent) > TCP_PAWS_WINDOW)
+		    ((s32)(tm->tcpm_ts - req->ts_recent) > TCP_PAWS_WINDOW ||
+		     !timestamps))
 			ret = false;
 		else
 			ret = true;
-- 
1.9.3
