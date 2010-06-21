From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: 2.6.34 + IPv6: Oops?
Date: Mon, 21 Jun 2010 10:25:08 -0700
Message-ID: <20100621102508.2075d677@nehalam>
References: <20100619175352.GA8482@EIS>
	<20100621153018.GA2433@EIS>
	<20100621162518.GA5972@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andreas Klauer <Andreas.Klauer@metamorpher.de>,
	netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38266 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758016Ab0FURZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 13:25:13 -0400
In-Reply-To: <20100621162518.GA5972@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The OOPS is here
static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
			  const struct in6_addr *daddr,
			  const struct in6_addr *solicited_addr,
			  int router, int solicited, int override, int inc_opt)
{
...
	/* for anycast or proxy, solicited_addr != src_addr */
	ifp = ipv6_get_ifaddr(dev_net(dev), solicited_addr, dev, 1);
	if (ifp) {
		src_addr = solicited_addr;
		if (ifp->flags & IFA_F_OPTIMISTIC)
			override = 0;
		in6_ifa_put(ifp);
	} else {
		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
				       &tmpaddr))
			return;
		src_addr = &tmpaddr;
	}

	icmp6h.icmp6_router = router;
	icmp6h.icmp6_solicited = solicited;
	icmp6h.icmp6_override = override;

	inc_opt |= ifp->idev->cnf.force_tllao;

And it caused by this recent commit.

Author: Octavian Purdila <opurdila@ixiacom.com>  2009-10-02 04:39:15
Committer: David S. Miller <davem@davemloft.net>  2009-10-07 01:10:45
Parent: d1f8297a96b0d70f17704296a6666468f2087ce6 (Revert "sit: stateless autoconf for isatap")
Child:  d7fc02c7bae7b1cf69269992cf880a43a350cdaa (Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6)
Branches: addrconf, master, remotes/origin/master
Follows: v2.6.32-rc3
Precedes: v2.6.33-rc1

    make TLLAO option for NA packets configurable
    
    On Friday 02 October 2009 20:53:51 you wrote:
    
    > This is good although I would have shortened the name.
    
    Ah, I knew I forgot something :) Here is v4.
    
    tavi
    
    >From 24d96d825b9fa832b22878cc6c990d5711968734 Mon Sep 17 00:00:00 2001
    From: Octavian Purdila <opurdila@ixiacom.com>
    Date: Fri, 2 Oct 2009 00:51:15 +0300
    Subject: [PATCH] ipv6: new sysctl for sending TLLAO with unicast NAs
    
    Neighbor advertisements responding to unicast neighbor solicitations
    did not include the target link-layer address option. This patch adds
    a new sysctl option (disabled by default) which controls whether this
    option should be sent even with unicast NAs.
    
    The need for this arose because certain routers expect the TLLAO in
    some situations even as a response to unicast NS packets.
    
    Moreover, RFC 2461 recommends sending this to avoid a race condition
    (section 4.4, Target link-layer address)
    
    Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
    Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

It is not handling the case of ifp == NULL.

Maybe the following (move the assignment into the if block).

--- a/net/ipv6/ndisc.c	2010-06-21 10:22:20.825637690 -0700
+++ b/net/ipv6/ndisc.c	2010-06-21 10:24:31.573011996 -0700
@@ -586,6 +586,7 @@ static void ndisc_send_na(struct net_dev
 		src_addr = solicited_addr;
 		if (ifp->flags & IFA_F_OPTIMISTIC)
 			override = 0;
+		inc_opt |= ifp->idev->cnf.force_tllao;
 		in6_ifa_put(ifp);
 	} else {
 		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
@@ -599,7 +600,6 @@ static void ndisc_send_na(struct net_dev
 	icmp6h.icmp6_solicited = solicited;
 	icmp6h.icmp6_override = override;
 
-	inc_opt |= ifp->idev->cnf.force_tllao;
 	__ndisc_send(dev, neigh, daddr, src_addr,
 		     &icmp6h, solicited_addr,
 		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);



