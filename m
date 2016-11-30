From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] tipc: check minimum bearer MTU
Date: Wed, 30 Nov 2016 14:23:33 +0100
Message-ID: <20161130132333.GD19119@unicorn.suse.cz>
References: <20161130095702.DD033A0F14@unicorn.suse.cz>
 <4a2da388-d798-11cf-bf2c-84207cae6159@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Maloy <jon.maloy@ericsson.com>,
        "David S. Miller" <davem@davemloft.net>,
        tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
        Qian Zhang <zhangqian-c@360.cn>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50250 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750749AbcK3NXj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:23:39 -0500
Content-Disposition: inline
In-Reply-To: <4a2da388-d798-11cf-bf2c-84207cae6159@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 06:28:14PM +0800, Ying Xue wrote:
...
> >diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
> >index 78892e2f53e3..1a0b7434ec24 100644
> >--- a/net/tipc/bearer.h
> >+++ b/net/tipc/bearer.h
> >@@ -39,6 +39,7 @@
> >
> > #include "netlink.h"
> > #include "core.h"
> >+#include "msg.h"
> > #include <net/genetlink.h>
> >
> > #define MAX_MEDIA	3
> >@@ -59,6 +60,9 @@
> > #define TIPC_MEDIA_TYPE_IB	2
> > #define TIPC_MEDIA_TYPE_UDP	3
> >
> >+/* minimum bearer MTU */
> >+#define TIPC_MIN_BEARER_MTU	(MAX_H_SIZE + INT_H_SIZE)
> >+
> > /**
> >  * struct tipc_media_addr - destination address used by TIPC bearers
> >  * @value: address info (format defined by media)
> >@@ -215,4 +219,13 @@ void tipc_bearer_xmit(struct net *net, u32 bearer_id,
> > void tipc_bearer_bc_xmit(struct net *net, u32 bearer_id,
> > 			 struct sk_buff_head *xmitq);
> >
> >+/* check if device MTU is sufficient for tipc headers */
> >+inline bool tipc_check_mtu(struct net_device *dev, unsigned int reserve)
> 
> It's unnecessary to explicitly declare a function as inline, instead
> please let GCC smartly decide this.

This is a header file. But I just noticed the last change (adding
missing "static" keyword) is missing in the version I sent.

> 
> >+{
> >+	if (dev->mtu >= TIPC_MIN_BEARER_MTU + reserve)
> >+		return false;
> >+	netdev_warn(dev, "MTU too low for tipc bearer\n");
> >+	return true;
> >+}
> >+
> > #endif	/* _TIPC_BEARER_H */
> >diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
> >index 78cab9c5a445..376ed3e3ed46 100644
> >--- a/net/tipc/udp_media.c
> >+++ b/net/tipc/udp_media.c
> >@@ -697,6 +697,11 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
> > 		udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
> > 		udp_conf.use_udp_checksums = false;
> > 		ub->ifindex = dev->ifindex;
> >+		if (tipc_check_mtu(dev, sizeof(struct iphdr) +
> >+					sizeof(struct udphdr))) {
> >+			err = -EINVAL;
> >+			goto err;
> >+		}
> 
> For UDP bearer, it seems insufficient for us to check MTU size only
> when UDP bearer is enabled. Meanwhile, we should update MTU size for
> UDP bearer with Path MTU discovery protocol once MTU size is changed
> after bearer is enabled.

I should admit I'm not that familiar with tipc. Do you mean updating
b->mtu in response to PMTU updates of the route used for ub->ubsock?
The way I understand it, it would be certainly useful but it's not
directly related to the security issue this patch addresses as if there
are no updates, b->mtu cannot get too low and there is no risk of
a buffer overflow. In other words, reflecting PMTU updates is something
that can be IMHO left for later.

                                                      Michal Kubecek
