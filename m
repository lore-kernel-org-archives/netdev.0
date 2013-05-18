From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: possible bug in IPv6 MLD retransmissions
Date: Sat, 18 May 2013 19:31:05 +0200
Message-ID: <20130518173105.GD29528@order.stressinduktion.org>
References: <20130517032449.GA3595@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47975 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab3ERRbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 13:31:08 -0400
Content-Disposition: inline
In-Reply-To: <20130517032449.GA3595@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 12:24:49AM -0300, Flavio Leitner wrote:
> A tcpdump captured while adding an IPv6 link-local address shows
> two MLD reports. One with source ``::'' and another with the permanent
> address.
> 
> Well, if you increase dad_retransmits from 1 to 10, for instance,
> then both MLD reports are sent with source address ``::'' which
> according with specs should be ignored by the routers.
>
> [...]
>
> Therefore, I believe this is a bug in IPv6 MLD because it should
> sent at least 2 MLD reports after DAD is completed.
> The specs says:
>
> [..]
>
> Does that make any sense?

Yes, this is unfortunate. RFC3590 clarifies this also for MLDv1 messages.

Could you try following patch I just came up with?

[PATCH RFC] ipv6: resend MLD report if a link-local address completes DAD

RFC3590/RFC3810 specifies we should resend MLD reports as soon as a
valid link-local address is available. This patch always resends MLD
reports if a link-local address completes dad (even a valid one was
already available).

Reported-by: Flavio Leitner <fleitner@redhat.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/addrconf.h |  2 ++
 net/ipv6/addrconf.c    |  9 ++++++++-
 net/ipv6/mcast.c       | 16 ++++++++++++++++
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 84a6440..0ec342c 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -155,6 +155,8 @@ extern bool ipv6_chk_mcast_addr(struct net_device *dev,
 				const struct in6_addr *group,
 				const struct in6_addr *src_addr);
 
+extern void ipv6_mc_resend_report(struct inet6_dev *idev);
+
 /*
  * identify MLD packets for MLD filter exceptions
  */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1ab6ab..c292723 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3272,6 +3272,7 @@ out:
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
 	struct net_device *dev = ifp->idev->dev;
+	int type = ipv6_addr_type(&ifp->addr);
 
 	/*
 	 *	Configure the address for reception. Now it is valid.
@@ -3279,6 +3280,12 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 
 	ipv6_ifa_notify(RTM_NEWADDR, ifp);
 
+	/* While dad is in progress mld report's source address is in6_addrany.
+	 * Resend with proper ll now.
+	 */
+	if (type & IPV6_ADDR_LINKLOCAL)
+		ipv6_mc_resend_report(ifp->idev);
+
 	/* If added prefix is link local and we are prepared to process
 	   router advertisements, start sending router solicitations.
 	 */
@@ -3286,7 +3293,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	if (ipv6_accept_ra(ifp->idev) &&
 	    ifp->idev->cnf.rtr_solicits > 0 &&
 	    (dev->flags&IFF_LOOPBACK) == 0 &&
-	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
+	    (type & IPV6_ADDR_LINKLOCAL)) {
 		/*
 		 *	If a host as already performed a random delay
 		 *	[...] as part of DAD [...] there is no need
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bfa6cc3..5e3b62f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1814,6 +1814,22 @@ err_out:
 	goto out;
 }
 
+void ipv6_mc_resend_report(struct inet6_dev *idev)
+{
+	if (MLD_V1_SEEN(idev)) {
+		struct ifmcaddr6 *mcaddr;
+		read_lock_bh(&idev->lock);
+		for (mcaddr = idev->mc_list; mcaddr; mcaddr = mcaddr->next) {
+			if (!(mcaddr->mca_flags & MAF_NOREPORT))
+				igmp6_send(&mcaddr->mca_addr, idev->dev,
+					   ICMPV6_MGM_REPORT);
+		}
+		read_unlock_bh(&idev->lock);
+	} else {
+		mld_send_report(idev, NULL);
+	}
+}
+
 static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 	const struct in6_addr *psfsrc)
 {
-- 
1.8.1.4
