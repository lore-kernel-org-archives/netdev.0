From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a	socket
 attached to the skb
Date: Fri, 03 Oct 2008 10:57:48 +0200
Message-ID: <1223024268.8912.2.camel@este>
References: <20081001142431.4893.69772.stgit@este>
 <20081001.075040.135314845.davem@davemloft.net> <1222875500.7492.6.camel@este>
 <20081001.085104.193726318.davem@davemloft.net>
 <1222962200.14079.19.camel@este> <20081002170935.GE17843@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	KOVACS Krisztian <hidden@sch.bme.hu>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:44250 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbYJCI6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2008 04:58:00 -0400
In-reply-to: <20081002170935.GE17843@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On cs, okt 02, 2008 at 02:09:35 -0300, Arnaldo Carvalho de Melo wrote:
> Em Thu, Oct 02, 2008 at 05:43:20PM +0200, KOVACS Krisztian escreveu:
> > Hi,
> > 
> > On Wed, 2008-10-01 at 08:51 -0700, David Miller wrote:
> > > From: KOVACS Krisztian <hidden@sch.bme.hu>
> > > Date: Wed, 01 Oct 2008 17:38:20 +0200
> > > 
> > > > The problem is that if you include the if() test then you have to
> > > > include the lookup call as well and that's different for TCP/UDP.
> > > 
> > > No, I only mean to make a helper for this construct:
> > > 
> > > 	if (unlikely(skb->sk)) {
> > > 		...
> > > 	}
> > > 
> > > so, something like:
> > > 
> > > static inline struct sock *sock_skb_steal(struct sk_buff *skb)
> > > {
> > > 	if (unlikely(skb->sk)) {
> > > 		struct sock *sk = skb->sk;
> > > 
> > > 		skb->destructor = NULL;
> > > 		skb->sk = NULL;
> > > 		return sk;
> > > 	}
> > > 	return NULL;
> > > }
> > > 
> > > and then also get rid of the ifdefs at the place where
> > > these calls are made (TCP and UDP).
> > 
> > Something like this?
> > 
> > - 8< -
> 
> Why don't you add it to __inet6_lookup, __inet6_lookup and the udp_lib
> lookup routines? And please rename it to skb_steal_sock, as it acts on a
> skb, not on a sock.

Those functions don't have access to the skb so unless we change the
signature they won't be able to steal the reference.

The renaming totally makes sense, the current name is misleading.

- 8< -
Use the socket reference cached in the skb if present. The iptables
TPROXY rule for example does a socket lookup early and attaches the
socket reference to the skb. So in the respective TCP/UDP/DCCP rcv()
routine we don't do a lookup but simply steal the socket reference from
the skb. 

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/sock.h  |   12 ++++++++++++
 net/dccp/ipv4.c     |    7 ++++---
 net/dccp/ipv6.c     |    9 +++++----
 net/ipv4/tcp_ipv4.c |    6 ++++--
 net/ipv4/udp.c      |    5 +++--
 net/ipv6/tcp_ipv6.c |    9 +++++----
 net/ipv6/udp.c      |    5 +++--
 7 files changed, 36 insertions(+), 17 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 75a312d..18f9670 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1324,6 +1324,18 @@ static inline void sk_change_net(struct sock *sk, struct net *net)
 	sock_net_set(sk, hold_net(net));
 }
 
+static inline struct sock *skb_steal_sock(struct sk_buff *skb)
+{
+	if (unlikely(skb->sk)) {
+		struct sock *sk = skb->sk;
+
+		skb->destructor = NULL;
+		skb->sk = NULL;
+		return sk;
+	}
+	return NULL;
+}
+
 extern void sock_enable_timestamp(struct sock *sk);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 882c5c4..bb329e8 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -811,9 +811,10 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 
 	/* Step 2:
 	 *	Look up flow ID in table and get corresponding socket */
-	sk = __inet_lookup(dev_net(skb->dst->dev), &dccp_hashinfo,
-			   iph->saddr, dh->dccph_sport,
-			   iph->daddr, dh->dccph_dport, inet_iif(skb));
+	if (likely((sk = skb_steal_sock(skb)) == NULL))
+		sk = __inet_lookup(dev_net(skb->dst->dev), &dccp_hashinfo,
+				   iph->saddr, dh->dccph_sport,
+				   iph->daddr, dh->dccph_dport, inet_iif(skb));
 	/*
 	 * Step 2:
 	 *	If no socket ...
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5e1ee0d..66de2a9 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -805,10 +805,11 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 
 	/* Step 2:
 	 *	Look up flow ID in table and get corresponding socket */
-	sk = __inet6_lookup(dev_net(skb->dst->dev), &dccp_hashinfo,
-			    &ipv6_hdr(skb)->saddr, dh->dccph_sport,
-			    &ipv6_hdr(skb)->daddr, ntohs(dh->dccph_dport),
-			    inet6_iif(skb));
+	if (likely((sk = skb_steal_sock(skb)) == NULL))
+		sk = __inet6_lookup(dev_net(skb->dst->dev), &dccp_hashinfo,
+				    &ipv6_hdr(skb)->saddr, dh->dccph_sport,
+				    &ipv6_hdr(skb)->daddr, ntohs(dh->dccph_dport),
+				    inet6_iif(skb));
 	/*
 	 * Step 2:
 	 *	If no socket ...
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1ac4d05..397bc1e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1577,8 +1577,10 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __inet_lookup(net, &tcp_hashinfo, iph->saddr,
-			th->source, iph->daddr, th->dest, inet_iif(skb));
+	if (likely((sk = skb_steal_sock(skb)) == NULL))
+		sk = __inet_lookup(net, &tcp_hashinfo, iph->saddr,
+				th->source, iph->daddr, th->dest, inet_iif(skb));
+
 	if (!sk)
 		goto no_tcp_socket;
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 28c3c31..4bdb4f5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1198,8 +1198,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 		return __udp4_lib_mcast_deliver(net, skb, uh,
 				saddr, daddr, udptable);
 
-	sk = __udp4_lib_lookup(net, saddr, uh->source, daddr,
-			uh->dest, inet_iif(skb), udptable);
+	if (likely((sk = skb_steal_sock(skb)) == NULL))
+		sk = __udp4_lib_lookup(net, saddr, uh->source, daddr,
+				uh->dest, inet_iif(skb), udptable);
 
 	if (sk != NULL) {
 		int ret = 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e85f377..f477b1d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1681,10 +1681,11 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(ipv6_hdr(skb));
 	TCP_SKB_CB(skb)->sacked = 0;
 
-	sk = __inet6_lookup(net, &tcp_hashinfo,
-			&ipv6_hdr(skb)->saddr, th->source,
-			&ipv6_hdr(skb)->daddr, ntohs(th->dest),
-			inet6_iif(skb));
+	if (likely((sk = skb_steal_sock(skb)) == NULL))
+		sk = __inet6_lookup(net, &tcp_hashinfo,
+				&ipv6_hdr(skb)->saddr, th->source,
+				&ipv6_hdr(skb)->daddr, ntohs(th->dest),
+				inet6_iif(skb));
 
 	if (!sk)
 		goto no_tcp_socket;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a6aecf7..659c6a4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -488,8 +488,9 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	 * check socket cache ... must talk to Alan about his plans
 	 * for sock caches... i'll skip this for now.
 	 */
-	sk = __udp6_lib_lookup(net, saddr, uh->source,
-			       daddr, uh->dest, inet6_iif(skb), udptable);
+	if (likely((sk = skb_steal_sock(skb)) == NULL))
+		sk = __udp6_lib_lookup(net, saddr, uh->source,
+				       daddr, uh->dest, inet6_iif(skb), udptable);
 
 	if (sk == NULL) {
 		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))



