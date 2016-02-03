From: Nikolay Borisov <kernel@kyup.com>
Subject: [RESEND PATCH 3/9] ipv4: Namespaceify tcp syncookies sysctl knob
Date: Wed,  3 Feb 2016 09:46:51 +0200
Message-ID: <1454485617-16541-4-git-send-email-kernel@kyup.com>
References: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Cc: edumazet@google.com, ebiederm@xmission.com, fan.du@intel.com,
	kaber@trash.net, jmorris@namei.org, alexander.h.duyck@redhat.com,
	kuznet@ms2.inr.ac.ru
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36146 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933516AbcBCHrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 02:47:06 -0500
Received: by mail-wm0-f47.google.com with SMTP id p63so151843647wmp.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 23:47:05 -0800 (PST)
In-Reply-To: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  2 ++
 include/net/tcp.h          |  1 -
 net/ipv4/syncookies.c      |  4 +---
 net/ipv4/sysctl_net_ipv4.c | 18 +++++++++---------
 net/ipv4/tcp_input.c       | 10 ++++++----
 net/ipv4/tcp_ipv4.c        |  3 ++-
 net/ipv4/tcp_minisocks.c   |  3 ---
 net/ipv6/syncookies.c      |  2 +-
 8 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index bca049102441..80da0d095eaf 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -98,6 +98,8 @@ struct netns_ipv4 {
 	int sysctl_tcp_syn_retries;
 	int sysctl_tcp_synack_retries;
 
+	int sysctl_tcp_syncookies;
+
 	struct ping_group_range ping_group_range;
 
 	atomic_t dev_addr_genid;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5a162875e80c..5497cc809601 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -243,7 +243,6 @@ extern int sysctl_tcp_fin_timeout;
 extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
 extern int sysctl_tcp_orphan_retries;
-extern int sysctl_tcp_syncookies;
 extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 4cbe9f0a4281..1c2bfda72c07 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -19,8 +19,6 @@
 #include <net/tcp.h>
 #include <net/route.h>
 
-extern int sysctl_tcp_syncookies;
-
 static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
 
 #define COOKIEBITS 24	/* Upper bits store count */
@@ -307,7 +305,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	__u8 rcv_wscale;
 	struct flowi4 fl4;
 
-	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
+	if (!sock_net(sk)->ipv4.sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
 
 	if (tcp_synq_no_recent_overflow(sk))
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 5dd89de5bf8d..007b9f8f7a2a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -342,15 +342,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-#ifdef CONFIG_SYN_COOKIES
-	{
-		.procname	= "tcp_syncookies",
-		.data		= &sysctl_tcp_syncookies,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-#endif
 	{
 		.procname	= "tcp_fastopen",
 		.data		= &sysctl_tcp_fastopen,
@@ -950,6 +941,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+#ifdef CONFIG_SYN_COOKIES
+	{
+		.procname	= "tcp_syncookies",
+		.data		= &init_net.ipv4.sysctl_tcp_syncookies,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+#endif
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2d656eef7f8e..dc8fe6c8a2e0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6114,9 +6114,10 @@ static bool tcp_syn_flood_action(const struct sock *sk,
 	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
 	const char *msg = "Dropping request";
 	bool want_cookie = false;
+	struct net *net = sock_net(sk);
 
 #ifdef CONFIG_SYN_COOKIES
-	if (sysctl_tcp_syncookies) {
+	if (net->ipv4.sysctl_tcp_syncookies) {
 		msg = "Sending cookies";
 		want_cookie = true;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDOCOOKIES);
@@ -6125,7 +6126,7 @@ static bool tcp_syn_flood_action(const struct sock *sk,
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDROP);
 
 	if (!queue->synflood_warned &&
-	    sysctl_tcp_syncookies != 2 &&
+	    net->ipv4.sysctl_tcp_syncookies != 2 &&
 	    xchg(&queue->synflood_warned, 1) == 0)
 		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
 			proto, ntohs(tcp_hdr(skb)->dest), msg);
@@ -6158,6 +6159,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	__u32 isn = TCP_SKB_CB(skb)->tcp_tw_isn;
 	struct tcp_options_received tmp_opt;
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	struct sock *fastopen_sk = NULL;
 	struct dst_entry *dst = NULL;
 	struct request_sock *req;
@@ -6168,7 +6170,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	 * limitations, they conserve resources and peer is
 	 * evidently real one.
 	 */
-	if ((sysctl_tcp_syncookies == 2 ||
+	if ((net->ipv4.sysctl_tcp_syncookies == 2 ||
 	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
 		want_cookie = tcp_syn_flood_action(sk, skb, rsk_ops->slab_name);
 		if (!want_cookie)
@@ -6234,7 +6236,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			}
 		}
 		/* Kill the following clause, if you dislike this way. */
-		else if (!sysctl_tcp_syncookies &&
+		else if (!net->ipv4.sysctl_tcp_syncookies &&
 			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
 			  (sysctl_max_syn_backlog >> 2)) &&
 			 !tcp_peer_is_proven(req, dst, false,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a5268576021c..ee3566377717 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -855,7 +855,6 @@ static void tcp_v4_reqsk_destructor(struct request_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
 
-
 #ifdef CONFIG_TCP_MD5SIG
 /*
  * RFC2385 MD5 checksumming requires a mapping of
@@ -2385,6 +2384,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_syn_retries = TCP_SYN_RETRIES;
 	net->ipv4.sysctl_tcp_synack_retries = TCP_SYNACK_RETRIES;
 
+	net->ipv4.sysctl_tcp_syncookies = 0;
+
 	return 0;
 fail:
 	tcp_sk_exit(net);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index ac6b1961ffeb..c6555f97c628 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -27,9 +27,6 @@
 #include <net/inet_common.h>
 #include <net/xfrm.h>
 
-int sysctl_tcp_syncookies __read_mostly = 1;
-EXPORT_SYMBOL(sysctl_tcp_syncookies);
-
 int sysctl_tcp_abort_on_overflow __read_mostly;
 
 struct inet_timewait_death_row tcp_death_row = {
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index eaf7ac496d50..0c306adc166e 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -148,7 +148,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
 
-	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
+	if (!sock_net(sk)->ipv4.sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
 
 	if (tcp_synq_no_recent_overflow(sk))
-- 
2.5.0
