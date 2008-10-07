From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a	socket
 attached to the skb
Date: Tue, 07 Oct 2008 09:36:24 +0200
Message-ID: <1223364984.35518.3.camel@nessa.odu>
References: <20081001142431.4893.69772.stgit@este>
 <20081001.075040.135314845.davem@davemloft.net> <1222875500.7492.6.camel@este>
 <20081001.085104.193726318.davem@davemloft.net>
 <1222962200.14079.19.camel@este> <20081002170935.GE17843@ghostprotocols.net>
 <1223024268.8912.2.camel@este> <20081003134747.GH17843@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:57863 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbYJGHga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 03:36:30 -0400
In-reply-to: <20081003134747.GH17843@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2008-10-03 at 10:47 -0300, Arnaldo Carvalho de Melo wrote:
> [...] 
> > > Why don't you add it to __inet6_lookup, __inet6_lookup and the udp_lib
> > > lookup routines? And please rename it to skb_steal_sock, as it acts on a
> > > skb, not on a sock.
> > 
> > Those functions don't have access to the skb so unless we change the
> > signature they won't be able to steal the reference.
> 
> Indeed, but we should try to have the main TCP code flow clean, ditto for
> DCCP, free of such details, so after this activitity settles down I'll
> submit something like the patch below.
> 
> If Dave agrees and you feel like merging it on your current patchset,
> feel free to do it.

Ok, I'll pick this up. Didn't compile because of missing includes in
inet_hashtables.h but I've fixed it.

-- 
KOVACS Krisztian 


inet_hashtables: Add inet_lookup_skb helpers

To be able to use the cached socket reference in the skb during input
processing we add a new set of lookup functions that receive the skb on
their argument list.

From: Arnaldo Carvalho de Melo <acme@redhat.com>

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/inet6_hashtables.h |   11 +++++++++++
 include/net/inet_hashtables.h  |   14 ++++++++++++++
 net/dccp/ipv4.c                |    5 ++---
 net/dccp/ipv6.c                |    6 ++----
 net/ipv4/tcp_ipv4.c            |    3 +--
 net/ipv6/tcp_ipv6.c            |    6 +-----
 6 files changed, 31 insertions(+), 14 deletions(-)


diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index e48989f..995efbb 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -91,6 +91,17 @@ static inline struct sock *__inet6_lookup(struct net *net,
 	return inet6_lookup_listener(net, hashinfo, daddr, hnum, dif);
 }
 
+static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
+					      struct sk_buff *skb,
+					      const __be16 sport,
+					      const __be16 dport)
+{
+	return __inet6_lookup(dev_net(skb->dst->dev), hashinfo,
+			      &ipv6_hdr(skb)->saddr, sport,
+			      &ipv6_hdr(skb)->daddr, ntohs(dport),
+			      inet6_iif(skb));
+}
+
 extern struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 				 const struct in6_addr *saddr, const __be16 sport,
 				 const struct in6_addr *daddr, const __be16 dport,
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index bb619d8..3522bbc 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -16,6 +16,7 @@
 
 
 #include <linux/interrupt.h>
+#include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/list.h>
 #include <linux/slab.h>
@@ -28,6 +29,7 @@
 #include <net/inet_connection_sock.h>
 #include <net/inet_sock.h>
 #include <net/sock.h>
+#include <net/route.h>
 #include <net/tcp_states.h>
 #include <net/netns/hash.h>
 
@@ -371,6 +373,18 @@ static inline struct sock *inet_lookup(struct net *net,
 	return sk;
 }
 
+static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
+					     struct sk_buff *skb,
+					     const __be16 sport,
+					     const __be16 dport)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+
+	return __inet_lookup(dev_net(skb->dst->dev), hashinfo,
+			     iph->saddr, sport,
+			     iph->daddr, dport, inet_iif(skb));
+}
+
 extern int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		struct sock *sk, u32 port_offset,
 		int (*check_established)(struct inet_timewait_death_row *,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 882c5c4..e3dfdda 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -811,9 +811,8 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 
 	/* Step 2:
 	 *	Look up flow ID in table and get corresponding socket */
-	sk = __inet_lookup(dev_net(skb->dst->dev), &dccp_hashinfo,
-			   iph->saddr, dh->dccph_sport,
-			   iph->daddr, dh->dccph_dport, inet_iif(skb));
+	sk = __inet_lookup_skb(&dccp_hashinfo, skb,
+			       dh->dccph_sport, dh->dccph_dport);
 	/*
 	 * Step 2:
 	 *	If no socket ...
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5e1ee0d..caa7f34 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -805,10 +805,8 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 
 	/* Step 2:
 	 *	Look up flow ID in table and get corresponding socket */
-	sk = __inet6_lookup(dev_net(skb->dst->dev), &dccp_hashinfo,
-			    &ipv6_hdr(skb)->saddr, dh->dccph_sport,
-			    &ipv6_hdr(skb)->daddr, ntohs(dh->dccph_dport),
-			    inet6_iif(skb));
+	sk = __inet6_lookup_skb(&dccp_hashinfo, skb,
+			        dh->dccph_sport, dh->dccph_dport);
 	/*
 	 * Step 2:
 	 *	If no socket ...
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1ac4d05..5215369 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1577,8 +1577,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __inet_lookup(net, &tcp_hashinfo, iph->saddr,
-			th->source, iph->daddr, th->dest, inet_iif(skb));
+	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
 	if (!sk)
 		goto no_tcp_socket;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e85f377..37b189f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1681,11 +1681,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(ipv6_hdr(skb));
 	TCP_SKB_CB(skb)->sacked = 0;
 
-	sk = __inet6_lookup(net, &tcp_hashinfo,
-			&ipv6_hdr(skb)->saddr, th->source,
-			&ipv6_hdr(skb)->daddr, ntohs(th->dest),
-			inet6_iif(skb));
-
+	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
 	if (!sk)
 		goto no_tcp_socket;
 

