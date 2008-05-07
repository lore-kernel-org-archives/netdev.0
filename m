From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: mc_loop and multicast traffic with IPv6 over IPv4 tunnels
Date: Wed, 7 May 2008 18:33:21 +0300
Message-ID: <200805071833.21177.opurdila@ixiacom.com>
References: <200805062358.25834.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4140 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755230AbYEGPeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 11:34:10 -0400
In-Reply-To: <200805062358.25834.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 06 May 2008, Octavian Purdila wrote:
> Hi,
>
> We are using a GRE tunnel module developed in house which can tunnel IPv6
> traffic over IPv4. The implementation is similar with what the upstream
> kernel does with GRE, IPIP or SIT tunnels, basically it stuffs the skb with
> the outer header and NF_HOOKs back to the stack.
>
> I've noticed that when using raw6 sockets on these tunnels, the
> IPV6_MULTICAST_LOOP setsockopt does not take effect, i.e. even if I set
> mc_loop to 0, I still get the send packets back when using a multicast
> address.
>
> This problem seems to be caused by the fact that the when the skb is pushed
> through the tunnel it reaches the IPv4 layer which checks the mc_loop flag
> from the IPv4 part of the socket, which was not altered by the IPv6
> setsockopt. Modifying the IPv4's mc_loop as well in the IPv6's setsockopt
> seems to fix the problem.
>
> I've looked over the upstream kernel GRE, IPIP and SIT tunnel code, and it
> seems that this case is not handled. I'll try to reproduce the problem with
> the upstream kernel as well, but in the meanwhile can somebody tell me if
> there is something obvious that I've missed?
>

Hi,

Just to clarify, the problem occurs if the tunnel destination address is a 
multicast address. Our routing people have told me that this is a valid 
configuration used with mVPN tunnels. 

I've tried to reproduce the problem with the upstream kernel, but it looks 
like the sit module explicitly denies routing the encapsulated packet through 
a multicast route. With gre I got "connect: Cannot assign requested address" 
errors when trying to route packets through gre tunnels which had an 
multicast address (with unicast addresses all worked fine).

Anyways, here is the patch that we've used to fix the problems at our end. 
Doesn't seems to have much value for upstream, but just for the record...

Regards,
tavi


When we have L3 tunnels with different inner/outer families (e.g. IPV4/IPV6)
which use an multicast address as the outer tunnel destination address,
multicast packets will be loopbacked back to the sending socket even
if IP*_MULTICAST_LOOP is set to disabled.

The mc_loop flag is present in the family specific part of the socket 
(e.g. the IPv4 or IPv4 specific part).  setsockopt sets the inner family 
mc_loop flag. When the packet is pushed through the L3 tunnel it will 
eventually be processed by the outer family which if different will 
check the flag in a different part of the socket then it was set.


--- include/linux/ipv6.h.orig	2008-05-07 01:54:27.000000000 +0300
+++ include/linux/ipv6.h	2008-05-07 01:54:39.000000000 +0300
@@ -300,6 +300,20 @@
 #define ipv6_only_sock(sk)	0
 #endif
 
+static inline int sk_mc_loop(struct sock *sk)
+{
+	if (!sk)
+		return 1;
+	switch (sk->sk_family) {
+	case AF_INET: 
+		return inet_sk(sk)->mc_loop;
+	case AF_INET6:
+		return inet6_sk(sk)->mc_loop;
+	}
+	WARN_ON(1); /* this should not happen */
+	return 1;
+}
+
 #endif
 
 #endif
--- net/ipv4/ip_output.c.orig	2008-05-07 01:32:43.000000000 +0300
+++ net/ipv4/ip_output.c	2008-05-07 01:53:58.000000000 +0300
@@ -84,6 +84,7 @@
 #include <linux/mroute.h>
 #include <linux/netlink.h>
 #include <net/ifstats.h>
+#include <linux/ipv6.h>
 
 #include <net/mpls.h>
 #include <net/mpls_route.h>
@@ -280,7 +281,7 @@
 	 */
 
 	if (rt->rt_flags&RTCF_MULTICAST) {
-		if ((!sk || inet_sk(sk)->mc_loop)
+		if (sk_mc_loop(sk)
 #ifdef CONFIG_IP_MROUTE
 		/* Small optimization: do not loopback not local frames,
 		   which returned after forwarding; they will be  dropped
--- net/ipv6/ip6_output.c.orig	2008-05-07 01:28:58.000000000 +0300
+++ net/ipv6/ip6_output.c	2008-05-07 01:34:20.000000000 +0300
@@ -166,9 +166,8 @@
 	skb->dev = dev;
 
 	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr)) {
-		struct ipv6_pinfo* np = skb->sk ? inet6_sk(skb->sk) : NULL;
 
-		if (!(dev->flags & IFF_LOOPBACK) && (!np || np->mc_loop) &&
+		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(sk) &&
 		    ipv6_chk_mcast_addr(dev, &skb->nh.ipv6h->daddr,
 				&skb->nh.ipv6h->saddr)) {
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);




