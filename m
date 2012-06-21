From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] ipv4: Add sysctl knob to control early socket demux
Date: Thu, 21 Jun 2012 16:58:31 -0700
Message-ID: <20120621235011.29846.29715.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27773 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758407Ab2FUX6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 19:58:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to add a control for disabling early socket demux.
The main motivation behind this patch is to provide an option to disable
the feature as it adds an additional cost to routing that reduces overall
throughput by up to 5%.  For example one of my systems went from 12.1Mpps
to 11.6 after the early socket demux was added.  It looks like the reason
for the regression is that we are now having to perform two lookups, first
the one for an established socket, and then the one for the routing table.

By adding this patch and toggling the value for ip_early_demux to 0 I am
able to get back to the 12.1Mpps I was previously seeing.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

I am open to any comments or suggestions on this patch.  I had seen the
earlier discussions and saw mention of adding a control for disabling the
early demux feature so I figured I would just code it up real quick once I
ran into the regression.  I am assuming it is okay to disable the early
demux code since I suspect there is other code in place that will still
handle the demux for the TCP sockets later.  Also I wasn't sure about the
sysctl since I haven't set one up before.

 include/linux/sysctl.h     |    1 +
 include/net/ip.h           |    3 +++
 kernel/sysctl_binary.c     |    2 ++
 net/ipv4/ip_input.c        |   19 +++++++++++--------
 net/ipv4/sysctl_net_ipv4.c |    7 +++++++
 5 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index c34b4c8..20825e5 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -425,6 +425,7 @@ enum
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
 	NET_TCP_MAX_SSTHRESH=124,
 	NET_TCP_FRTO_RESPONSE=125,
+	NET_IPV4_EARLY_DEMUX=126,
 };
 
 enum {
diff --git a/include/net/ip.h b/include/net/ip.h
index 83e0619..50841bd 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -210,6 +210,9 @@ extern int inet_peer_threshold;
 extern int inet_peer_minttl;
 extern int inet_peer_maxttl;
 
+/* From ip_input.c */
+extern int sysctl_ip_early_demux;
+
 /* From ip_output.c */
 extern int sysctl_ip_dynaddr;
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index a650694..6a3cf82 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -415,6 +415,8 @@ static const struct bin_table bin_net_ipv4_table[] = {
 	{ CTL_INT,	NET_IPV4_IPFRAG_SECRET_INTERVAL,	"ipfrag_secret_interval" },
 	/* NET_IPV4_IPFRAG_MAX_DIST "ipfrag_max_dist" no longer used */
 
+	{ CTL_INT,	NET_IPV4_EARLY_DEMUX,			"ip_early_demux" },
+
 	{ CTL_INT,	2088 /* NET_IPQ_QMAX */,		"ip_queue_maxlen" },
 
 	/* NET_TCP_DEFAULT_WIN_SCALE unused */
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 93b092c..07de38d 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -313,6 +313,8 @@ drop:
 	return true;
 }
 
+int sysctl_ip_early_demux __read_mostly = 1;
+
 static int ip_rcv_finish(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -325,14 +327,15 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	if (skb_dst(skb) == NULL) {
 		const struct net_protocol *ipprot;
 		int protocol = iph->protocol;
-		int err;
-
-		rcu_read_lock();
-		ipprot = rcu_dereference(inet_protos[protocol]);
-		err = -ENOENT;
-		if (ipprot && ipprot->early_demux)
-			err = ipprot->early_demux(skb);
-		rcu_read_unlock();
+		int err = -ENOENT;
+
+		if (sysctl_ip_early_demux) {
+			rcu_read_lock();
+			ipprot = rcu_dereference(inet_protos[protocol]);
+			if (ipprot && ipprot->early_demux)
+				err = ipprot->early_demux(skb);
+			rcu_read_unlock();
+		}
 
 		if (err) {
 			err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index ef32956..12aa0c5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -301,6 +301,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "ip_early_demux",
+		.data		= &sysctl_ip_early_demux,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "ip_dynaddr",
 		.data		= &sysctl_ip_dynaddr,
 		.maxlen		= sizeof(int),
