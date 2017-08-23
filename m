From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next] ipv6: Add sysctl for per namespace flow label reflection
Date: Wed, 23 Aug 2017 09:55:41 +0200
Message-ID: <20170823075541.26764-1-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38832 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753386AbdHWHzo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:55:44 -0400
Received: by mail-wm0-f48.google.com with SMTP id l19so9653429wmi.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 00:55:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reflecting IPv6 Flow Label at server nodes is useful in environments
that employ multipath routing to load balance the requests. As "IPv6
Flow Label Reflection" standard draft [1] points out - ICMPv6 PTB error
messages generated in response to a downstream packets from the server
can be routed by a load balancer back to the original server without
looking at transport headers, if the server applies the flow label
reflection. This enables the Path MTU Discovery past the ECMP router in
load-balance or anycast environments where each server node is reachable
by only one path.

Introduce a sysctl to enable flow label reflection per net namespace for
all newly created sockets. Same could be earlier achieved only per
socket by setting the IPV6_FL_F_REFLECT flag for the IPV6_FLOWLABEL_MGR
socket option.

[1] https://tools.ietf.org/html/draft-wang-6man-flow-label-reflection-01

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 Documentation/networking/ip-sysctl.txt | 9 +++++++++
 include/net/netns/ipv6.h               | 1 +
 net/ipv6/af_inet6.c                    | 1 +
 net/ipv6/sysctl_net_ipv6.c             | 8 ++++++++
 4 files changed, 19 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 84c9b8c..6b0bc0f 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1350,6 +1350,15 @@ flowlabel_state_ranges - BOOLEAN
 	FALSE: disabled
 	Default: true
 
+flowlabel_reflect - BOOLEAN
+	Automatically reflect the flow label. Needed for Path MTU
+	Discovery to work with Equal Cost Multipath Routing in anycast
+	environments. See RFC 7690 and:
+	https://tools.ietf.org/html/draft-wang-6man-flow-label-reflection-01
+	TRUE: enabled
+	FALSE: disabled
+	Default: FALSE
+
 anycast_src_echo_reply - BOOLEAN
 	Controls the use of anycast addresses as source addresses for ICMPv6
 	echo reply
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 0e50bf3..2544f97 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -36,6 +36,7 @@ struct netns_sysctl_ipv6 {
 	int idgen_retries;
 	int idgen_delay;
 	int flowlabel_state_ranges;
+	int flowlabel_reflect;
 };
 
 struct netns_ipv6 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3b58ee7..fe5262f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -211,6 +211,7 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 	np->mc_loop	= 1;
 	np->pmtudisc	= IPV6_PMTUDISC_WANT;
 	np->autoflowlabel = ip6_default_np_autolabel(net);
+	np->repflow	= net->ipv6.sysctl.flowlabel_reflect;
 	sk->sk_ipv6only	= net->ipv6.sysctl.bindv6only;
 
 	/* Init the ipv4 part of the socket since we can have sockets
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 69c50e7..6fbf8ae 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -90,6 +90,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "flowlabel_reflect",
+		.data		= &init_net.ipv6.sysctl.flowlabel_reflect,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
@@ -149,6 +156,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[6].data = &net->ipv6.sysctl.idgen_delay;
 	ipv6_table[7].data = &net->ipv6.sysctl.flowlabel_state_ranges;
 	ipv6_table[8].data = &net->ipv6.sysctl.ip_nonlocal_bind;
+	ipv6_table[9].data = &net->ipv6.sysctl.flowlabel_reflect;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
2.9.4
