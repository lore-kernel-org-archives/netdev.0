From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH] Add udplib_lookup_skb() helpers (was: [net-next	PATCH
 10/16] Don't lookup the socket if there's a socket attached to the	skb)
Date: Tue, 07 Oct 2008 09:42:12 +0200
Message-ID: <1223365332.35518.9.camel@nessa.odu>
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
Received: from balu.sch.bme.hu ([152.66.208.40]:59876 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbYJGHmO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 03:42:14 -0400
In-reply-to: <20081003134747.GH17843@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2008-10-03 at 10:47 -0300, Arnaldo Carvalho de Melo wrote:
> > Those functions don't have access to the skb so unless we change the
> > signature they won't be able to steal the reference.
> 
> Indeed, but we should try to have the main TCP code flow clean, ditto
> for
> DCCP, free of such details, so after this activitity settles down I'll
> submit something like the patch below.
> 
> If Dave agrees and you feel like merging it on your current patchset,
> feel free to do it.

And here are the skb lookup helpers for UDP.

-- 
KOVACS Krisztian


Add udplib_lookup_skb() helpers

To be able to use the cached socket reference in the skb during input
processing we add a new set of lookup functions that receive the skb on
their argument list.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 net/ipv4/udp.c |   14 ++++++++++++--
 net/ipv6/udp.c |   14 ++++++++++++--
 2 files changed, 24 insertions(+), 4 deletions(-)


diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 28c3c31..8369f4d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -302,6 +302,17 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	return result;
 }
 
+static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
+						 __be16 sport, __be16 dport,
+						 struct hlist_head udptable[])
+{
+	const struct iphdr *iph = ip_hdr(skb);
+
+	return __udp4_lib_lookup(dev_net(skb->dst->dev), iph->saddr, sport,
+				 iph->daddr, dport, inet_iif(skb),
+				 udptable);
+}
+
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif)
 {
@@ -1198,8 +1209,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 		return __udp4_lib_mcast_deliver(net, skb, uh,
 				saddr, daddr, udptable);
 
-	sk = __udp4_lib_lookup(net, saddr, uh->source, daddr,
-			uh->dest, inet_iif(skb), udptable);
+	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 
 	if (sk != NULL) {
 		int ret = 0;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a6aecf7..ce26c41 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -107,6 +107,17 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 	return result;
 }
 
+static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
+					  __be16 sport, __be16 dport,
+					  struct hlist_head udptable[])
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
+	return __udp6_lib_lookup(dev_net(skb->dst->dev), &iph->saddr, sport,
+				 &iph->daddr, dport, inet6_iif(skb),
+				 udptable);
+}
+
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
@@ -488,8 +499,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	 * check socket cache ... must talk to Alan about his plans
 	 * for sock caches... i'll skip this for now.
 	 */
-	sk = __udp6_lib_lookup(net, saddr, uh->source,
-			       daddr, uh->dest, inet6_iif(skb), udptable);
+	sk = __udp6_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 
 	if (sk == NULL) {
 		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))


