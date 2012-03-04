From: pablo@netfilter.org
Subject: [PATCH 2/7] netfilter: nf_ct_tcp: move retransmission and unacknowledged timeout to array
Date: Sun,  4 Mar 2012 12:27:53 +0100
Message-ID: <1330860478-13184-3-git-send-email-pablo@netfilter.org>
References: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49027 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059Ab2CDL2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 06:28:10 -0500
In-Reply-To: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch moves the retransmission and unacknowledged timeouts
to the tcp_timeouts array. This change is required by follow-up
patches.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_tcp.h |    5 ++++-
 net/netfilter/nf_conntrack_proto_tcp.c     |   27 +++++++++++++--------------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_tcp.h b/include/linux/netfilter/nf_conntrack_tcp.h
index 6e135f9..e59868a 100644
--- a/include/linux/netfilter/nf_conntrack_tcp.h
+++ b/include/linux/netfilter/nf_conntrack_tcp.h
@@ -18,7 +18,10 @@ enum tcp_conntrack {
 	TCP_CONNTRACK_LISTEN,	/* obsolete */
 #define TCP_CONNTRACK_SYN_SENT2	TCP_CONNTRACK_LISTEN
 	TCP_CONNTRACK_MAX,
-	TCP_CONNTRACK_IGNORE
+	TCP_CONNTRACK_IGNORE,
+	TCP_CONNTRACK_RETRANS,
+	TCP_CONNTRACK_UNACK,
+	TCP_CONNTRACK_TIMEOUT_MAX
 };
 
 /* Window scaling is advertised by the sender */
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 97b9f3e..57c7785 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -64,13 +64,7 @@ static const char *const tcp_conntrack_names[] = {
 #define HOURS * 60 MINS
 #define DAYS * 24 HOURS
 
-/* RFC1122 says the R2 limit should be at least 100 seconds.
-   Linux uses 15 packets as limit, which corresponds
-   to ~13-30min depending on RTO. */
-static unsigned int nf_ct_tcp_timeout_max_retrans __read_mostly    =   5 MINS;
-static unsigned int nf_ct_tcp_timeout_unacknowledged __read_mostly =   5 MINS;
-
-static unsigned int tcp_timeouts[TCP_CONNTRACK_MAX] __read_mostly = {
+static unsigned int tcp_timeouts[TCP_CONNTRACK_TIMEOUT_MAX] __read_mostly = {
 	[TCP_CONNTRACK_SYN_SENT]	= 2 MINS,
 	[TCP_CONNTRACK_SYN_RECV]	= 60 SECS,
 	[TCP_CONNTRACK_ESTABLISHED]	= 5 DAYS,
@@ -80,6 +74,11 @@ static unsigned int tcp_timeouts[TCP_CONNTRACK_MAX] __read_mostly = {
 	[TCP_CONNTRACK_TIME_WAIT]	= 2 MINS,
 	[TCP_CONNTRACK_CLOSE]		= 10 SECS,
 	[TCP_CONNTRACK_SYN_SENT2]	= 2 MINS,
+/* RFC1122 says the R2 limit should be at least 100 seconds.
+   Linux uses 15 packets as limit, which corresponds
+   to ~13-30min depending on RTO. */
+	[TCP_CONNTRACK_RETRANS]		= 5 MINS,
+	[TCP_CONNTRACK_UNACK]		= 5 MINS,
 };
 
 #define sNO TCP_CONNTRACK_NONE
@@ -1015,12 +1014,12 @@ static int tcp_packet(struct nf_conn *ct,
 		ct->proto.tcp.seen[dir].flags |= IP_CT_TCP_FLAG_CLOSE_INIT;
 
 	if (ct->proto.tcp.retrans >= nf_ct_tcp_max_retrans &&
-	    tcp_timeouts[new_state] > nf_ct_tcp_timeout_max_retrans)
-		timeout = nf_ct_tcp_timeout_max_retrans;
+	    tcp_timeouts[new_state] > tcp_timeouts[TCP_CONNTRACK_RETRANS])
+		timeout = tcp_timeouts[TCP_CONNTRACK_RETRANS];
 	else if ((ct->proto.tcp.seen[0].flags | ct->proto.tcp.seen[1].flags) &
 		 IP_CT_TCP_FLAG_DATA_UNACKNOWLEDGED &&
-		 tcp_timeouts[new_state] > nf_ct_tcp_timeout_unacknowledged)
-		timeout = nf_ct_tcp_timeout_unacknowledged;
+		 tcp_timeouts[new_state] > tcp_timeouts[TCP_CONNTRACK_UNACK])
+		timeout = tcp_timeouts[TCP_CONNTRACK_UNACK];
 	else
 		timeout = tcp_timeouts[new_state];
 	spin_unlock_bh(&ct->lock);
@@ -1301,14 +1300,14 @@ static struct ctl_table tcp_sysctl_table[] = {
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_max_retrans",
-		.data		= &nf_ct_tcp_timeout_max_retrans,
+		.data		= &tcp_timeouts[TCP_CONNTRACK_RETRANS],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_unacknowledged",
-		.data		= &nf_ct_tcp_timeout_unacknowledged,
+		.data		= &tcp_timeouts[TCP_CONNTRACK_UNACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -1404,7 +1403,7 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
-		.data		= &nf_ct_tcp_timeout_max_retrans,
+		.data		= &tcp_timeouts[TCP_CONNTRACK_RETRANS],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-- 
1.7.7.3
