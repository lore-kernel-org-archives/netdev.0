From: Flavio Leitner <fbl@redhat.com>
Subject: Re: possible bug in IPv6 MLD retransmissions
Date: Tue, 21 May 2013 12:06:16 -0300
Message-ID: <20130521150616.GA8513@obelix.rh>
References: <20130517032449.GA3595@obelix.rh>
 <20130518173105.GD29528@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045Ab3EUPGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 11:06:25 -0400
Content-Disposition: inline
In-Reply-To: <20130518173105.GD29528@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 18, 2013 at 07:31:05PM +0200, Hannes Frederic Sowa wrote:
> On Fri, May 17, 2013 at 12:24:49AM -0300, Flavio Leitner wrote:
> > A tcpdump captured while adding an IPv6 link-local address shows
> > two MLD reports. One with source ``::'' and another with the permanent
> > address.
> > 
> > Well, if you increase dad_retransmits from 1 to 10, for instance,
> > then both MLD reports are sent with source address ``::'' which
> > according with specs should be ignored by the routers.
> >
> > [...]
> >
> > Therefore, I believe this is a bug in IPv6 MLD because it should
> > sent at least 2 MLD reports after DAD is completed.
> > The specs says:
> >
> > [..]
> >
> > Does that make any sense?
> 
> Yes, this is unfortunate. RFC3590 clarifies this also for MLDv1 messages.
> 
> Could you try following patch I just came up with?

It does work, but it would be better to send [Robustness Variable]
times, right?
thanks!

[PATCH] ipv6: resend MLD report if a link-local address completes DAD

RFC3590/RFC3810 specifies we should resend MLD reports as soon as a
valid link-local address is available. This patch always resends MLD
reports if a link-local address completes dad (even a valid one was
already available).

Reported-by: Flavio Leitner <fleitner@redhat.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 include/net/addrconf.h |  1 +
 include/net/if_inet6.h |  2 ++
 net/ipv6/addrconf.c    |  9 ++++++++-
 net/ipv6/mcast.c       | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 58 insertions(+), 1 deletion(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 84a6440..ddd331c 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -155,6 +155,7 @@ extern bool ipv6_chk_mcast_addr(struct net_device *dev,
 				const struct in6_addr *group,
 				const struct in6_addr *src_addr);
 
+extern void ipv6_mc_dad_complete(struct inet6_dev *idev);
 /*
  * identify MLD packets for MLD filter exceptions
  */
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 100fb8c..5c195b1 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -172,10 +172,12 @@ struct inet6_dev {
 	unsigned char		mc_qrv;
 	unsigned char		mc_gq_running;
 	unsigned char		mc_ifc_count;
+	unsigned char		mc_dad_count;
 	unsigned long		mc_v1_seen;
 	unsigned long		mc_maxdelay;
 	struct timer_list	mc_gq_timer;	/* general query timer */
 	struct timer_list	mc_ifc_timer;	/* interface change timer */
+	struct timer_list	mc_dad_timer;	/* dad complete mc timer */
 
 	struct ifacaddr6	*ac_list;
 	rwlock_t		lock;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1ab6ab..800222b 100644
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
+		ipv6_mc_dad_complete(ifp->idev);
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
index bfa6cc3..9941ff7 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -999,6 +999,14 @@ static void mld_ifc_start_timer(struct inet6_dev *idev, int delay)
 		in6_dev_hold(idev);
 }
 
+static void mld_dad_start_timer(struct inet6_dev *idev, int delay)
+{
+	int tv = net_random() % delay;
+
+	if (!mod_timer(&idev->mc_dad_timer, jiffies+tv+2))
+		in6_dev_hold(idev);
+}
+
 /*
  *	IGMP handling (alias multicast ICMPv6 messages)
  */
@@ -1814,6 +1822,41 @@ err_out:
 	goto out;
 }
 
+void ipv6_mc_dad_complete(struct inet6_dev *idev)
+{
+	idev->mc_dad_count = idev->mc_qrv;
+	mld_dad_start_timer(idev, 1);
+}
+
+static void mld_resend_report(struct inet6_dev *idev)
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
+static void mld_dad_timer_expire(unsigned long data)
+{
+	struct inet6_dev *idev = (struct inet6_dev *)data;
+
+	mld_resend_report(idev);
+	if (idev->mc_dad_count) {
+		idev->mc_dad_count--;
+		if (idev->mc_dad_count)
+			mld_dad_start_timer(idev, idev->mc_maxdelay);
+	}
+	__in6_dev_put(idev);
+}
+
 static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 	const struct in6_addr *psfsrc)
 {
@@ -2231,6 +2274,8 @@ void ipv6_mc_down(struct inet6_dev *idev)
 	idev->mc_gq_running = 0;
 	if (del_timer(&idev->mc_gq_timer))
 		__in6_dev_put(idev);
+	if (del_timer(&idev->mc_dad_timer))
+		__in6_dev_put(idev);
 
 	for (i = idev->mc_list; i; i=i->next)
 		igmp6_group_dropped(i);
@@ -2267,6 +2312,8 @@ void ipv6_mc_init_dev(struct inet6_dev *idev)
 	idev->mc_ifc_count = 0;
 	setup_timer(&idev->mc_ifc_timer, mld_ifc_timer_expire,
 			(unsigned long)idev);
+	setup_timer(&idev->mc_dad_timer, mld_dad_timer_expire,
+			(unsigned long)idev);
 	idev->mc_qrv = MLD_QRV_DEFAULT;
 	idev->mc_maxdelay = IGMP6_UNSOLICITED_IVAL;
 	idev->mc_v1_seen = 0;
-- 
1.8.1.4

 
