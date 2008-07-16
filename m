From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/20] ipv4: prepare net initialization for IP accounting
Date: Wed, 16 Jul 2008 12:08:22 +0400
Message-ID: <487DAC76.20708@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38298 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706AbYGPII3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:08:29 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some places, that deal with IP statistics already have where to
get a struct net from, but use it directly, without declaring
a separate variable on the stack.

So, save this net on the stack for future IP_XXX_STATS macros.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/inet_connection_sock.c |    3 ++-
 net/ipv4/ip_fragment.c          |    6 +++---
 net/ipv4/udp.c                  |    4 +++-
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 5bbf000..8338e10 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -338,9 +338,10 @@ struct dst_entry* inet_csk_route_req(struct sock *sk,
 			    .uli_u = { .ports =
 				       { .sport = inet_sk(sk)->sport,
 					 .dport = ireq->rmt_port } } };
+	struct net *net = sock_net(sk);
 
 	security_req_classify_flow(req, &fl);
-	if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 0)) {
+	if (ip_route_output_flow(net, &rt, &fl, sk, 0)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index fbd5804..e23be5b 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -187,8 +187,10 @@ static void ip_evictor(struct net *net)
 static void ip_expire(unsigned long arg)
 {
 	struct ipq *qp;
+	struct net *net;
 
 	qp = container_of((struct inet_frag_queue *) arg, struct ipq, q);
+	net = container_of(qp->q.net, struct net, ipv4.frags);
 
 	spin_lock(&qp->q.lock);
 
@@ -202,9 +204,7 @@ static void ip_expire(unsigned long arg)
 
 	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
 		struct sk_buff *head = qp->q.fragments;
-		struct net *net;
 
-		net = container_of(qp->q.net, struct net, ipv4.frags);
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		if ((head->dev = dev_get_by_index(net, qp->iif)) != NULL) {
 			icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
@@ -570,9 +570,9 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	struct ipq *qp;
 	struct net *net;
 
+	net = skb->dev ? dev_net(skb->dev) : dev_net(skb->dst->dev);
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMREQDS);
 
-	net = skb->dev ? dev_net(skb->dev) : dev_net(skb->dst->dev);
 	/* Start by cleaning up the memory. */
 	if (atomic_read(&net->ipv4.frags.mem) > net->ipv4.frags.high_thresh)
 		ip_evictor(net);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fdd4faa..048ef57 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -656,8 +656,10 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				    .uli_u = { .ports =
 					       { .sport = inet->sport,
 						 .dport = dport } } };
+		struct net *net = sock_net(sk);
+
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 1);
+		err = ip_route_output_flow(net, &rt, &fl, sk, 1);
 		if (err) {
 			if (err == -ENETUNREACH)
 				IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
-- 
1.5.5.1


