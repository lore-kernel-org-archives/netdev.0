From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next 2/2] tcp: remove tcp_tw_recycle
Date: Wed, 15 Mar 2017 16:30:46 -0400
Message-ID: <20170315203046.158791-2-soheil.kdev@gmail.com>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>, Lutz Vieweg <lvml@5t9.de>,
        Florian Westphal <fw@strlen.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35199 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbdCOUaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:30:52 -0400
Received: by mail-qt0-f195.google.com with SMTP id r5so3365322qtb.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:30:51 -0700 (PDT)
In-Reply-To: <20170315203046.158791-1-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

The tcp_tw_recycle was already broken for connections
behind NAT, since the per-destination timestamp is not
monotonically increasing for multiple machines behind
a single destination address.

After the randomization of TCP timestamp offsets
in commit 8a5bd45f6616 (tcp: randomize tcp timestamp offsets
for each connection), the tcp_tw_recycle is broken for all
types of connections for the same reason: the timestamps
received from a single machine is not monotonically increasing,
anymore.

Remove tcp_tw_recycle, since it is not functional. Also, remove
the PAWSPassive SNMP counter since it is only used for
tcp_tw_recycle, and simplify tcp_v4_route_req and tcp_v6_route_req
since the strict argument is only set when tcp_tw_recycle is
enabled.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Cc: Lutz Vieweg <lvml@5t9.de>
Cc: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/ip-sysctl.txt |  5 -----
 include/net/netns/ipv4.h               |  1 -
 include/net/tcp.h                      |  3 +--
 include/uapi/linux/snmp.h              |  1 -
 net/ipv4/proc.c                        |  1 -
 net/ipv4/sysctl_net_ipv4.c             |  7 -------
 net/ipv4/tcp_input.c                   | 30 +++++-------------------------
 net/ipv4/tcp_ipv4.c                    | 15 ++-------------
 net/ipv6/tcp_ipv6.c                    |  5 +----
 9 files changed, 9 insertions(+), 59 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ab0230461377..ed3d0791eb27 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -640,11 +640,6 @@ tcp_tso_win_divisor - INTEGER
 	building larger TSO frames.
 	Default: 3
 
-tcp_tw_recycle - BOOLEAN
-	Enable fast recycling TIME-WAIT sockets. Default value is 0.
-	It should not be changed without advice/request of technical
-	experts.
-
 tcp_tw_reuse - BOOLEAN
 	Allow to reuse TIME-WAIT sockets for new connections when it is
 	safe from protocol viewpoint. Default value is 0.
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 622d2da27135..2e9d649ba169 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -33,7 +33,6 @@ struct inet_timewait_death_row {
 	atomic_t		tw_count;
 
 	struct inet_hashinfo 	*hashinfo ____cacheline_aligned_in_smp;
-	int			sysctl_tw_recycle;
 	int			sysctl_max_tw_buckets;
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c81f3b958d44..e614ad4d613e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1810,8 +1810,7 @@ struct tcp_request_sock_ops {
 				 __u16 *mss);
 #endif
 	struct dst_entry *(*route_req)(const struct sock *sk, struct flowi *fl,
-				       const struct request_sock *req,
-				       bool *strict);
+				       const struct request_sock *req);
 	__u32 (*init_seq_tsoff)(const struct sk_buff *skb, u32 *tsoff);
 	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 3b2bed7ca9a4..cec0e171d20c 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -177,7 +177,6 @@ enum
 	LINUX_MIB_TIMEWAITED,			/* TimeWaited */
 	LINUX_MIB_TIMEWAITRECYCLED,		/* TimeWaitRecycled */
 	LINUX_MIB_TIMEWAITKILLED,		/* TimeWaitKilled */
-	LINUX_MIB_PAWSPASSIVEREJECTED,		/* PAWSPassiveRejected */
 	LINUX_MIB_PAWSACTIVEREJECTED,		/* PAWSActiveRejected */
 	LINUX_MIB_PAWSESTABREJECTED,		/* PAWSEstabRejected */
 	LINUX_MIB_DELAYEDACKS,			/* DelayedACKs */
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 69cf49e8356d..4ccbf464d1ac 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -199,7 +199,6 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TW", LINUX_MIB_TIMEWAITED),
 	SNMP_MIB_ITEM("TWRecycled", LINUX_MIB_TIMEWAITRECYCLED),
 	SNMP_MIB_ITEM("TWKilled", LINUX_MIB_TIMEWAITKILLED),
-	SNMP_MIB_ITEM("PAWSPassive", LINUX_MIB_PAWSPASSIVEREJECTED),
 	SNMP_MIB_ITEM("PAWSActive", LINUX_MIB_PAWSACTIVEREJECTED),
 	SNMP_MIB_ITEM("PAWSEstab", LINUX_MIB_PAWSESTABREJECTED),
 	SNMP_MIB_ITEM("DelayedACKs", LINUX_MIB_DELAYEDACKS),
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d6880a6149ee..11aaef0939b2 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -981,13 +981,6 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_tw_recycle",
-		.data		= &init_net.ipv4.tcp_death_row.sysctl_tw_recycle,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_max_syn_backlog",
 		.data		= &init_net.ipv4.sysctl_max_syn_backlog,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index aafec0676d3e..bb09c7095988 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6327,31 +6327,11 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		af_ops->init_seq_tsoff(skb, &tcp_rsk(req)->ts_off);
 
 	if (!want_cookie && !isn) {
-		/* VJ's idea. We save last timestamp seen
-		 * from the destination in peer table, when entering
-		 * state TIME-WAIT, and check against it before
-		 * accepting new connection request.
-		 *
-		 * If "isn" is not zero, this request hit alive
-		 * timewait bucket, so that all the necessary checks
-		 * are made in the function processing timewait state.
-		 */
-		if (net->ipv4.tcp_death_row.sysctl_tw_recycle) {
-			bool strict;
-
-			dst = af_ops->route_req(sk, &fl, req, &strict);
-
-			if (dst && strict &&
-			    !tcp_peer_is_proven(req, dst)) {
-				NET_INC_STATS(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
-				goto drop_and_release;
-			}
-		}
 		/* Kill the following clause, if you dislike this way. */
-		else if (!net->ipv4.sysctl_tcp_syncookies &&
-			 (net->ipv4.sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
-			  (net->ipv4.sysctl_max_syn_backlog >> 2)) &&
-			 !tcp_peer_is_proven(req, dst)) {
+		if (!net->ipv4.sysctl_tcp_syncookies &&
+		    (net->ipv4.sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
+		     (net->ipv4.sysctl_max_syn_backlog >> 2)) &&
+		    !tcp_peer_is_proven(req, dst)) {
 			/* Without syncookies last quarter of
 			 * backlog is filled with destinations,
 			 * proven to be alive.
@@ -6367,7 +6347,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		isn = af_ops->init_seq_tsoff(skb, &tcp_rsk(req)->ts_off);
 	}
 	if (!dst) {
-		dst = af_ops->route_req(sk, &fl, req, NULL);
+		dst = af_ops->route_req(sk, &fl, req);
 		if (!dst)
 			goto drop_and_free;
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d8b401fff9fe..7482b5d11861 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1213,19 +1213,9 @@ static void tcp_v4_init_req(struct request_sock *req,
 
 static struct dst_entry *tcp_v4_route_req(const struct sock *sk,
 					  struct flowi *fl,
-					  const struct request_sock *req,
-					  bool *strict)
+					  const struct request_sock *req)
 {
-	struct dst_entry *dst = inet_csk_route_req(sk, &fl->u.ip4, req);
-
-	if (strict) {
-		if (fl->u.ip4.daddr == inet_rsk(req)->ir_rmt_addr)
-			*strict = true;
-		else
-			*strict = false;
-	}
-
-	return dst;
+	return inet_csk_route_req(sk, &fl->u.ip4, req);
 }
 
 struct request_sock_ops tcp_request_sock_ops __read_mostly = {
@@ -2462,7 +2452,6 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_tw_reuse = 0;
 
 	cnt = tcp_hashinfo.ehash_mask + 1;
-	net->ipv4.tcp_death_row.sysctl_tw_recycle = 0;
 	net->ipv4.tcp_death_row.sysctl_max_tw_buckets = (cnt + 1) / 2;
 	net->ipv4.tcp_death_row.hashinfo = &tcp_hashinfo;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 853cb43e3e3c..0f08d718a002 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -722,11 +722,8 @@ static void tcp_v6_init_req(struct request_sock *req,
 
 static struct dst_entry *tcp_v6_route_req(const struct sock *sk,
 					  struct flowi *fl,
-					  const struct request_sock *req,
-					  bool *strict)
+					  const struct request_sock *req)
 {
-	if (strict)
-		*strict = true;
 	return inet6_csk_route_req(sk, &fl->u.ip6, req, IPPROTO_TCP);
 }
 
-- 
2.12.0.367.g23dc2f6d3c-goog
