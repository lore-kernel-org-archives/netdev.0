From: pablo@netfilter.org
Subject: [PATCH 1/7] netfilter: nf_ct_udp[lite]: convert UDP[lite] timeouts to array
Date: Sun,  4 Mar 2012 12:27:52 +0100
Message-ID: <1330860478-13184-2-git-send-email-pablo@netfilter.org>
References: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49025 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752956Ab2CDL2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 06:28:10 -0500
In-Reply-To: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Use one array to store the UDP timeouts instead of two variables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_udp.c     |   30 ++++++++++++++++++---------
 net/netfilter/nf_conntrack_proto_udplite.c |   25 +++++++++++++++-------
 2 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 5f35757..5b24ff8 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -25,8 +25,16 @@
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 
-static unsigned int nf_ct_udp_timeout __read_mostly = 30*HZ;
-static unsigned int nf_ct_udp_timeout_stream __read_mostly = 180*HZ;
+enum udp_conntrack {
+	UDP_CT_UNREPLIED,
+	UDP_CT_REPLIED,
+	UDP_CT_MAX
+};
+
+static unsigned int udp_timeouts[UDP_CT_MAX] = {
+	[UDP_CT_UNREPLIED]	= 30*HZ,
+	[UDP_CT_REPLIED]	= 180*HZ,
+};
 
 static bool udp_pkt_to_tuple(const struct sk_buff *skb,
 			     unsigned int dataoff,
@@ -74,13 +82,15 @@ static int udp_packet(struct nf_conn *ct,
 	/* If we've seen traffic both ways, this is some kind of UDP
 	   stream.  Extend timeout. */
 	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
-		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udp_timeout_stream);
+		nf_ct_refresh_acct(ct, ctinfo, skb,
+				   udp_timeouts[UDP_CT_REPLIED]);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
 			nf_conntrack_event_cache(IPCT_ASSURED, ct);
-	} else
-		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udp_timeout);
-
+	} else {
+		nf_ct_refresh_acct(ct, ctinfo, skb,
+				   udp_timeouts[UDP_CT_UNREPLIED]);
+	}
 	return NF_ACCEPT;
 }
 
@@ -142,14 +152,14 @@ static struct ctl_table_header *udp_sysctl_header;
 static struct ctl_table udp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_udp_timeout",
-		.data		= &nf_ct_udp_timeout,
+		.data		= &udp_timeouts[UDP_CT_UNREPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_udp_timeout_stream",
-		.data		= &nf_ct_udp_timeout_stream,
+		.data		= &udp_timeouts[UDP_CT_REPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -160,14 +170,14 @@ static struct ctl_table udp_sysctl_table[] = {
 static struct ctl_table udp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_udp_timeout",
-		.data		= &nf_ct_udp_timeout,
+		.data		= &udp_timeouts[UDP_CT_UNREPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_udp_timeout_stream",
-		.data		= &nf_ct_udp_timeout_stream,
+		.data		= &udp_timeouts[UDP_CT_REPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index f52ca11..e730717 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -24,8 +24,16 @@
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_log.h>
 
-static unsigned int nf_ct_udplite_timeout __read_mostly = 30*HZ;
-static unsigned int nf_ct_udplite_timeout_stream __read_mostly = 180*HZ;
+enum udplite_conntrack {
+	UDPLITE_CT_UNREPLIED,
+	UDPLITE_CT_REPLIED,
+	UDPLITE_CT_MAX
+};
+
+static unsigned int udplite_timeouts[UDPLITE_CT_MAX] = {
+	[UDPLITE_CT_UNREPLIED]	= 30*HZ,
+	[UDPLITE_CT_REPLIED]	= 180*HZ,
+};
 
 static bool udplite_pkt_to_tuple(const struct sk_buff *skb,
 				 unsigned int dataoff,
@@ -72,13 +80,14 @@ static int udplite_packet(struct nf_conn *ct,
 	   stream.  Extend timeout. */
 	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
 		nf_ct_refresh_acct(ct, ctinfo, skb,
-				   nf_ct_udplite_timeout_stream);
+				   udplite_timeouts[UDPLITE_CT_REPLIED]);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
 			nf_conntrack_event_cache(IPCT_ASSURED, ct);
-	} else
-		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udplite_timeout);
-
+	} else {
+		nf_ct_refresh_acct(ct, ctinfo, skb,
+				   udplite_timeouts[UDPLITE_CT_UNREPLIED]);
+	}
 	return NF_ACCEPT;
 }
 
@@ -147,14 +156,14 @@ static struct ctl_table_header *udplite_sysctl_header;
 static struct ctl_table udplite_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_udplite_timeout",
-		.data		= &nf_ct_udplite_timeout,
+		.data		= &udplite_timeouts[UDPLITE_CT_UNREPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_udplite_timeout_stream",
-		.data		= &nf_ct_udplite_timeout_stream,
+		.data		= &udplite_timeouts[UDPLITE_CT_REPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-- 
1.7.7.3
