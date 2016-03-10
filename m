From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 18:09:20 +0300
Message-ID: <20160310150920.GC21154@uranus.lan>
References: <20160309204158.GO2207@uranus.lan>
 <20160309.154725.1921352291794389965.davem@davemloft.net>
 <20160309205746.GQ2207@uranus.lan>
 <20160309.161038.283281065293712589.davem@davemloft.net>
 <20160309211629.GR2207@uranus.lan>
 <20160310102018.GA21154@uranus.lan>
 <20160310110324.GB21154@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:35202 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452AbcCJPJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 10:09:28 -0500
Content-Disposition: inline
In-Reply-To: <20160310110324.GB21154@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 02:03:24PM +0300, Cyrill Gorcunov wrote:
> On Thu, Mar 10, 2016 at 01:20:18PM +0300, Cyrill Gorcunov wrote:
> > On Thu, Mar 10, 2016 at 12:16:29AM +0300, Cyrill Gorcunov wrote:
> > > 
> > > Thanks for explanation, Dave! I'll continue on this task tomorrow
> > > tryin to implement optimization you proposed.
> > 
> > OK, here are the results for the preliminary patch with conntrack running
> ...
> >  net/ipv4/devinet.c |   13 ++++++++++++-
> >  1 file changed, 12 insertions(+), 1 deletion(-)
> > 
> > Index: linux-ml.git/net/ipv4/devinet.c
> > ===================================================================
> > --- linux-ml.git.orig/net/ipv4/devinet.c
> > +++ linux-ml.git/net/ipv4/devinet.c
> > @@ -403,7 +403,18 @@ no_promotions:
> >  	   So that, this order is correct.
> >  	 */
> 
> This patch is wrong, so drop it please. I'll do another.

Here I think is a better variant. The resulst are good
enough -- 1 sec for cleanup. Does the patch look sane?
---
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

Index: linux-ml.git/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
===================================================================
--- linux-ml.git.orig/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
+++ linux-ml.git/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
@@ -108,9 +108,22 @@ static int masq_inet_event(struct notifi
 			   unsigned long event,
 			   void *ptr)
 {
-	struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
+	struct in_ifaddr *ifa = ptr;
+	struct net_device *dev = ifa->ifa_dev->dev;
 	struct netdev_notifier_info info;
 
+	if (event == NETDEV_DOWN) {
+		/*
+		 * When we meet dead device which is
+		 * being released with dozeon of addresses
+		 * assigned -- we can optimize calls
+		 * to conntrack cleanups and do it only
+		 * once.
+		 */
+		if (ifa->ifa_dev->dead && ifa->ifa_next)
+			return NOTIFY_DONE;
+	}
+
 	netdev_notifier_info_init(&info, dev);
 	return masq_device_event(this, event, &info);
 }
