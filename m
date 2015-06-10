From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3 v2] net: track link-status of ipv4 nexthops
Date: Wed, 10 Jun 2015 13:44:59 -0400
Message-ID: <20150610174458.GR588@gospo.home.greyhouse.net>
References: <1433918841-15576-1-git-send-email-gospo@cumulusnetworks.com>
 <1433918841-15576-2-git-send-email-gospo@cumulusnetworks.com>
 <55785E83.3080303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33937 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933568AbbFJRpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 13:45:03 -0400
Received: by qkoo18 with SMTP id o18so29331073qko.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 10:45:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55785E83.3080303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 08:57:55AM -0700, Alexander Duyck wrote:
> On 06/09/2015 11:47 PM, Andy Gospodarek wrote:
> >Add a fib flag called RTNH_F_LINKDOWN to any ipv4 nexthops that are
> >reachable via an interface where carrier is off.  No action is taken,
> >but additional flags are passed to userspace to indicate carrier status.
> >
> >This also includes a cleanup to fib_disable_ip to more clearly indicate
> >what event made the function call to replace the more cryptic force
> >option previously used.
> >
> >v2: Split out kernel functionality into 2 patches, this patch simply sets and
> >clears new nexthop flag RTNH_F_LINKDOWN.
> >
> >Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> >Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> >
> >---
> >  include/net/ip_fib.h           |  4 +--
> >  include/uapi/linux/rtnetlink.h |  1 +
> >  net/ipv4/fib_frontend.c        | 26 +++++++++++---------
> >  net/ipv4/fib_semantics.c       | 56 ++++++++++++++++++++++++++++++++----------
> >  4 files changed, 60 insertions(+), 27 deletions(-)
> >
> >diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> >index 54271ed..d1de1b7 100644
> >--- a/include/net/ip_fib.h
> >+++ b/include/net/ip_fib.h
> >@@ -305,9 +305,9 @@ void fib_flush_external(struct net *net);
> >
> >  /* Exported by fib_semantics.c */
> >  int ip_fib_check_default(__be32 gw, struct net_device *dev);
> >-int fib_sync_down_dev(struct net_device *dev, int force);
> >+int fib_sync_down_dev(struct net_device *dev, int event);
> >  int fib_sync_down_addr(struct net *net, __be32 local);
> >-int fib_sync_up(struct net_device *dev);
> >+int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
> >  void fib_select_multipath(struct fib_result *res);
> >
> >  /* Exported by fib_trie.c */
> >diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> >index 17fb02f..8dde432 100644
> >--- a/include/uapi/linux/rtnetlink.h
> >+++ b/include/uapi/linux/rtnetlink.h
> >@@ -338,6 +338,7 @@ struct rtnexthop {
> >  #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
> >  #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
> >  #define RTNH_F_OFFLOAD		8	/* offloaded route */
> >+#define RTNH_F_LINKDOWN		16	/* carrier-down on nexthop */
> 
> So you could probably use some sort of define here to identify which flags
> are event based and which are configuration based.  Then it makes it easier
> to take care of code below such as the nh_comp call.
So are you saying something at the top to that would reserve a few bits
for whether the kernel can set it, userspace can set it, or both could
set it?  Seems like overkill to me and a waste of bits -- though maybe
there will not be that many nexthop flags. :)

> 
> >  /* Macros to handle hexthops */
> >
> >diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> >index 872494e..1e4c646 100644
> >--- a/net/ipv4/fib_frontend.c
> >+++ b/net/ipv4/fib_frontend.c
> >@@ -1063,9 +1063,9 @@ static void nl_fib_lookup_exit(struct net *net)
> >  	net->ipv4.fibnl = NULL;
> >  }
> >
> >-static void fib_disable_ip(struct net_device *dev, int force)
> >+static void fib_disable_ip(struct net_device *dev, int event)
> 
> Event should be an unsigned long to match fib_inetaddr_event and avoid any
> unnecessary casts or warnings.
Fixed in upcoming v3

> 
> >  {
> >-	if (fib_sync_down_dev(dev, force))
> >+	if (fib_sync_down_dev(dev, event))
> >  		fib_flush(dev_net(dev));
> >  	rt_cache_flush(dev_net(dev));
> >  	arp_ifdown(dev);
> >@@ -1080,9 +1080,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
> >  	switch (event) {
> >  	case NETDEV_UP:
> >  		fib_add_ifaddr(ifa);
> >-#ifdef CONFIG_IP_ROUTE_MULTIPATH
> >-		fib_sync_up(dev);
> >-#endif
> >+		fib_sync_up(dev, RTNH_F_DEAD);
> >  		atomic_inc(&net->ipv4.dev_addr_genid);
> >  		rt_cache_flush(dev_net(dev));
> >  		break;
> 
> Shouldn't this bit be left wrapped in CONFIG_IP_ROUTE_MULTIPATH?  I thought
> RTNH_F_DEAD was only used in that case.
I can double-check this one and the one referenced below in
fib_netdev_event, but I really struggle to understand why one would not
want to be sure that when IFF_UP is set the DEAD flags were definitely
going to be cleared before continuing?

> 
> >@@ -1093,7 +1091,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
> >  			/* Last address was deleted from this interface.
> >  			 * Disable IP.
> >  			 */
> >-			fib_disable_ip(dev, 1);
> >+			fib_disable_ip(dev, event);
> >  		} else {
> >  			rt_cache_flush(dev_net(dev));
> >  		}
> 
> Aren't you losing information here?  The line above this change is a call to
> see if ifa_list is NULL.  I don't see how that data is being communicated
> down to fib_disable_ip.  It seems like you could end up with the wrong
> scope.
Fixed in fib_sync_down_dev in upcoming v3.

[...]
> >diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> >index 28ec3c1..776e029 100644
> >--- a/net/ipv4/fib_semantics.c
> >+++ b/net/ipv4/fib_semantics.c
> >@@ -266,7 +266,7 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
> >  #ifdef CONFIG_IP_ROUTE_CLASSID
> >  		    nh->nh_tclassid != onh->nh_tclassid ||
> >  #endif
> >-		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
> >+		    ((nh->nh_flags ^ onh->nh_flags) & ~(RTNH_F_DEAD|RTNH_F_LINKDOWN)))
> >  			return -1;
> >  		onh++;
> >  	} endfor_nexthops(fi);
> >@@ -318,7 +318,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
> >  		    nfi->fib_type == fi->fib_type &&
> >  		    memcmp(nfi->fib_metrics, fi->fib_metrics,
> >  			   sizeof(u32) * RTAX_MAX) == 0 &&
> >-		    ((nfi->fib_flags ^ fi->fib_flags) & ~RTNH_F_DEAD) == 0 &&
> >+		    ((nfi->fib_flags ^ fi->fib_flags) & ~(RTNH_F_DEAD|RTNH_F_LINKDOWN)) == 0 &&
> >  		    (nfi->fib_nhs == 0 || nh_comp(fi, nfi) == 0))
> >  			return fi;
> >  	}
> 
> Merging the two flags into some sort of define would probably help the
> readability here.
I can create something like RTNH_F_COMP_MASK for upcoming v3.

[...]
> 
> >@@ -604,6 +604,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  				return -ENODEV;
> >  			if (!(dev->flags & IFF_UP))
> >  				return -ENETDOWN;
> >+			if (!netif_carrier_ok(dev))
> >+				nh->nh_flags |= RTNH_F_LINKDOWN;
> >  			nh->nh_dev = dev;
> >  			dev_hold(dev);
> >  			nh->nh_scope = RT_SCOPE_LINK;
> >@@ -636,6 +638,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  		if (!dev)
> >  			goto out;
> >  		dev_hold(dev);
> >+		if (!netif_carrier_ok(dev))
> >+			nh->nh_flags |= RTNH_F_LINKDOWN;
> >  		err = (dev->flags & IFF_UP) ? 0 : -ENETDOWN;
> >  	} else {
> >  		struct in_device *in_dev;
> >@@ -654,6 +658,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >  		nh->nh_dev = in_dev->dev;
> >  		dev_hold(nh->nh_dev);
> >  		nh->nh_scope = RT_SCOPE_HOST;
> >+		if (!netif_carrier_ok(nh->nh_dev))
> >+			nh->nh_flags |= RTNH_F_LINKDOWN;
> >  		err = 0;
> >  	}
> >  out:
> >@@ -920,11 +926,17 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
> >  		if (!nh->nh_dev)
> >  			goto failure;
> >  	} else {
> >+		int linkdown = 0;
> >  		change_nexthops(fi) {
> >  			err = fib_check_nh(cfg, fi, nexthop_nh);
> >  			if (err != 0)
> >  				goto failure;
> >+			if (nexthop_nh->nh_flags & RTNH_F_LINKDOWN)
> >+				linkdown++;
> >  		} endfor_nexthops(fi)
> >+		if (linkdown == fi->fib_nhs) {
> >+			fi->fib_flags |= RTNH_F_LINKDOWN;
> >+		}
> >  	}
> >
> >  	if (fi->fib_prefsrc) {
> >@@ -1103,7 +1115,7 @@ int fib_sync_down_addr(struct net *net, __be32 local)
> >  	return ret;
> >  }
> >
> >-int fib_sync_down_dev(struct net_device *dev, int force)
> >+int fib_sync_down_dev(struct net_device *dev, int event)
> 
> I believe event should be unsigned long to match the original argument from
> fib_inetaddr_event.
Agreed, in upcoming v3.

> >  {
> >  	int ret = 0;
> >  	int scope = RT_SCOPE_NOWHERE;
> >@@ -1112,7 +1124,7 @@ int fib_sync_down_dev(struct net_device *dev, int force)
> >  	struct hlist_head *head = &fib_info_devhash[hash];
> >  	struct fib_nh *nh;
> >
> >-	if (force)
> >+	if (event == NETDEV_UNREGISTER)
> >  		scope = -1;
> >
> 
> So I believe there is still a gap here in relation to fib_inetaddr_event.
> Specifically in the case of that function it is supposed to set the force
> value to 1 which would trigger this bit of code, but that isn't occurring
> with your change.
Agreed.  As mentioned above, I fixed this in my tree and it will be in
upcoming v3.

Thanks for the review, Alex!
