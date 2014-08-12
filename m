From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] tcp: don't allow syn packets without timestamps to pass tcp_tw_recycle logic
Date: Tue, 12 Aug 2014 02:21:36 +0200
Message-ID: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:50297 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750991AbaHLAVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 20:21:44 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway1.nyi.internal (Postfix) with ESMTP id 8E9A522CD2
	for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 20:21:43 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If tw_recycle is enabled, non-timestamped SYN packets could get past
the tw_recycle check and create a new connection. This is dangerous
as we cannot verify that segments from an old connection won't be
accepted by the new one in tcp_validate_incoming because of the missing
timestamps. Note that Windows seems to have timestamps disabled by
default. Thus this broken situation could easily arise by a Linux and
Windows box sharing one IP address and talking to a tcp_tw_recycle
enabled server.

We don't change the behavior regarding how many SYNs we queue up from
non timestamping hosts (the second tcp_peer_is_proven check), because the
second call to tcp_peer_is_proven does not use the new boolean timestamp
argument at all because PAWS check is disabled.

Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
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
