From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH] ip: fix mc_loop checks for tunnels with multicast outer addresses
Date: Mon, 4 Jan 2010 12:48:25 +0200
Message-ID: <201001041248.26095.opurdila@ixiacom.com>
References: <200912302201.37735.opurdila@ixiacom.com> <20100103.215855.267134875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:15986 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753286Ab0ADKvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 05:51:51 -0500
In-Reply-To: <20100103.215855.267134875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 04 January 2010 07:58:55 you wrote:

> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Wed, 30 Dec 2009 22:01:37 +0200
> 
> > +	switch (sk->sk_family) {
> > +	case AF_INET:
> > +		return inet_sk(sk)->mc_loop;
> > +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> > +	case AF_INET6:
> > +		return inet6_sk(sk)->mc_loop;
> > +	}
> > +#endif
> > +	__WARN();
> > +	return 1;
> > +}
> > +
> 
> This won't compile with IPV6 disabled.  Switch closing brace is
> erroneously inside of the ifdef test.
> 

Oops... Here is a new version:

[PATCH] ip: fix mc_loop checks for tunnels with multicast outer addresses

When we have L3 tunnels with different inner/outer families
(i.e. IPV4/IPV6) which use a multicast address as the outer tunnel
destination address, multicast packets will be loopbacked back to the
sending socket even if IP*_MULTICAST_LOOP is set to disabled.

The mc_loop flag is present in the family specific part of the socket
(e.g. the IPv4 or IPv4 specific part).  setsockopt sets the inner
family mc_loop flag. When the packet is pushed through the L3 tunnel
it will eventually be processed by the outer family which if different
will check the flag in a different part of the socket then it was set.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/ip.h      |   16 ++++++++++++++++
 net/ipv4/ip_output.c  |    2 +-
 net/ipv6/ip6_output.c |    3 +--
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 85108cf..d9a0e74 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -326,6 +326,22 @@ static __inline__ void inet_reset_saddr(struct sock *sk)
 
 #endif
 
+static inline int sk_mc_loop(struct sock *sk)
+{
+	if (!sk)
+		return 1;
+	switch (sk->sk_family) {
+	case AF_INET:
+		return inet_sk(sk)->mc_loop;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		return inet6_sk(sk)->mc_loop;
+#endif
+	}
+	__WARN();
+	return 1;
+}
+
 extern int	ip_call_ra_chain(struct sk_buff *skb);
 
 /*
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e34013a..3451799 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -254,7 +254,7 @@ int ip_mc_output(struct sk_buff *skb)
 	 */
 
 	if (rt->rt_flags&RTCF_MULTICAST) {
-		if ((!sk || inet_sk(sk)->mc_loop)
+		if (sk_mc_loop(sk)
 #ifdef CONFIG_IP_MROUTE
 		/* Small optimization: do not loopback not local frames,
 		   which returned after forwarding; they will be  dropped
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cd48801..eb6d097 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -121,10 +121,9 @@ static int ip6_output2(struct sk_buff *skb)
 	skb->dev = dev;
 
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr)) {
-		struct ipv6_pinfo* np = skb->sk ? inet6_sk(skb->sk) : NULL;
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
-		if (!(dev->flags & IFF_LOOPBACK) && (!np || np->mc_loop) &&
+		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(skb->sk) &&
 		    ((mroute6_socket(dev_net(dev)) &&
 		     !(IP6CB(skb)->flags & IP6SKB_FORWARDED)) ||
 		     ipv6_chk_mcast_addr(dev, &ipv6_hdr(skb)->daddr,
-- 
1.5.6.5

