From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 5/6] ipv4: namespacify ip fragment max dist sysctl knob
Date: Mon, 15 Feb 2016 12:11:31 +0200
Message-ID: <1455531092-23184-6-git-send-email-kernel@kyup.com>
References: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Cc: netfilter-devel@vger.kernel.org, ebiederm@xmission.com,
	pabeni@redhat.com, jmorris@namei.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35354 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732AbcBOKLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 05:11:42 -0500
Received: by mail-wm0-f50.google.com with SMTP id c200so105167149wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 02:11:41 -0800 (PST)
In-Reply-To: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/inet_frag.h |  1 +
 net/ipv4/ip_fragment.c  | 25 +++++++++++++------------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 12aac0fd6ee7..909972aa3acd 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -13,6 +13,7 @@ struct netns_frags {
 	int			timeout;
 	int			high_thresh;
 	int			low_thresh;
+	int			max_dist;
 };
 
 /**
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 187c6fcc3027..957161413335 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -54,8 +54,6 @@
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
  * as well. Or notify me, at least. --ANK
  */
-
-static int sysctl_ipfrag_max_dist __read_mostly = 64;
 static const char ip_frag_cache_name[] = "ip4-frags";
 
 struct ipfrag_skb_cb
@@ -150,7 +148,7 @@ static void ip4_frag_init(struct inet_frag_queue *q, const void *a)
 	qp->daddr = arg->iph->daddr;
 	qp->vif = arg->vif;
 	qp->user = arg->user;
-	qp->peer = sysctl_ipfrag_max_dist ?
+	qp->peer = q->net->max_dist ?
 		inet_getpeer_v4(net->ipv4.peers, arg->iph->saddr, arg->vif, 1) :
 		NULL;
 }
@@ -275,7 +273,7 @@ static struct ipq *ip_find(struct net *net, struct iphdr *iph,
 static int ip_frag_too_far(struct ipq *qp)
 {
 	struct inet_peer *peer = qp->peer;
-	unsigned int max = sysctl_ipfrag_max_dist;
+	unsigned int max = qp->q.net->max_dist;
 	unsigned int start, end;
 
 	int rc;
@@ -749,6 +747,14 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "ipfrag_max_dist",
+		.data		= &init_net.ipv4.frags.max_dist,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero
+	},
 	{ }
 };
 
@@ -762,14 +768,6 @@ static struct ctl_table ip4_frags_ctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.procname	= "ipfrag_max_dist",
-		.data		= &sysctl_ipfrag_max_dist,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero
-	},
 	{ }
 };
 
@@ -790,6 +788,7 @@ static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 		table[1].data = &net->ipv4.frags.low_thresh;
 		table[1].extra2 = &net->ipv4.frags.high_thresh;
 		table[2].data = &net->ipv4.frags.timeout;
+		table[3].data = &net->ipv4.frags.max_dist;
 
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
@@ -865,6 +864,8 @@ static int __net_init ipv4_frags_init_net(struct net *net)
 	 */
 	net->ipv4.frags.timeout = IP_FRAG_TIME;
 
+	net->ipv4.frags.max_dist = 64;
+
 	res = inet_frags_init_net(&net->ipv4.frags);
 	if (res)
 		return res;
-- 
2.5.0
