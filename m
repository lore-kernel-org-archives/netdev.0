From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bonding: make global bonding stats more reliable
Date: Fri, 26 Sep 2014 09:52:08 -0400
Message-ID: <20140926135208.GB18564@gospo.home.greyhouse.net>
References: <1411650996-2087-1-git-send-email-gospo@cumulusnetworks.com>
 <54252940.6070100@redhat.com>
 <20140926132631.GA18564@gospo.home.greyhouse.net>
 <54256BA5.9080803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:47086 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbaIZNwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 09:52:04 -0400
Content-Disposition: inline
In-Reply-To: <54256BA5.9080803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 03:35:33PM +0200, Nikolay Aleksandrov wrote:
> On 26/09/14 15:26, Andy Gospodarek wrote:
> >On Fri, Sep 26, 2014 at 10:52:16AM +0200, Nikolay Aleksandrov wrote:
> >>On 25/09/14 15:16, Andy Gospodarek wrote:
> >>>As the code stands today, bonding stats are based simply on the stats
> >>>from the member interfaces.  If a member was to be removed from a bond,
> >>>the stats would instantly drop.  This would be confusing to an admin
> >>>would would suddonly see interface stats drop while traffic is still
> >>>flowing.
> >>>
> >>>In addition to preventing the stats drops mentioned above, new members
> >>>will now be added to the bond and only traffic received after the member
> >>>was added to the bond will be counted as part of bonding stats.
> >>>
> >>>Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> >>>---
> >>Hi Andy,
> >>
> <<<<snip>>>>
> >>>@@ -4258,6 +4274,9 @@ static int bond_init(struct net_device *bond_dev)
> >>>  	    bond_dev->addr_assign_type == NET_ADDR_PERM)
> >>>  		eth_hw_addr_random(bond_dev);
> >>>
> >>>+	/* initialize persistent stats for the bond */
> >>>+	bond->bond_stats = kzalloc(sizeof(struct rtnl_link_stats64),
> >>>+				   GFP_ATOMIC);
> >>^^^^^^^^^^^^^^^^^^^^^^^^
> >>I don't think this will get freed if the bond device is destroyed.
> >Another good catch.  Thanks for the review.  V2 incoming after some
> >testing.
> >
> Great, one more thing I forgot to ask, why the GFP_ATOMIC here ? I believe
> we're allowed to sleep in ndo_init(), and you should probably handle the
ndo_init() can (and likely will) sleep, but since all not skb data
allocated in bonding appears to be GFP_KERNEL, I'll switch to that for
consistency.

> case where the bond_stats allocation fails, too.
Yep, on it! :)

> 
> >>
> >>>  	return 0;
> >>>  }
> >>>
> >>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> >>>index 6140bf0..fe25265 100644
> >>>--- a/drivers/net/bonding/bonding.h
> >>>+++ b/drivers/net/bonding/bonding.h
> >>>@@ -24,6 +24,7 @@
> >>>  #include <linux/inetdevice.h>
> >>>  #include <linux/etherdevice.h>
> >>>  #include <linux/reciprocal_div.h>
> >>>+#include <linux/if_link.h>
> >>>
> >>>  #include "bond_3ad.h"
> >>>  #include "bond_alb.h"
> >>>@@ -175,6 +176,7 @@ struct slave {
> >>>  	struct netpoll *np;
> >>>  #endif
> >>>  	struct kobject kobj;
> >>>+	struct rtnl_link_stats64 *slave_stats;
> >>>  };
> >>>
> >>>  /*
> >>>@@ -224,6 +226,7 @@ struct bonding {
> >>>  	/* debugging support via debugfs */
> >>>  	struct	 dentry *debug_dir;
> >>>  #endif /* CONFIG_DEBUG_FS */
> >>>+	struct rtnl_link_stats64 *bond_stats;
> >>>  };
> >>>
> >>>  #define bond_slave_get_rcu(dev) \
> >>>
> >>
> 
