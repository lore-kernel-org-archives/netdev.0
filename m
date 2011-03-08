From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Tue, 08 Mar 2011 11:03:52 -0800 (PST)
Message-ID: <20110308.110352.189704727.davem@davemloft.net>
References: <20110307.205815.193699096.davem@davemloft.net>
	<alpine.LFD.2.00.1103081030090.1529@ja.ssi.bg>
	<20110308.103801.193702247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753080Ab1CHTDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 14:03:14 -0500
In-Reply-To: <20110308.103801.193702247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 08 Mar 2011 10:38:01 -0800 (PST)

> From: Julian Anastasov <ja@ssi.bg>
> Date: Tue, 8 Mar 2011 11:57:38 +0200 (EET)
> 
>> 	It means, even if there are addresses on the
>> concerned device it does not mean the routes on this device
>> are required to use prefsrc from this device. We must
>> restrict the scope according to the provided for the
>> route: cfg->fc_scope.
> 
> Simple to fix, I'll remember the fc_scope value in the nexthop
> and use that in the address selection call.

I'll push the following into net-next-2.6, thanks Julian:

--------------------
ipv4: Fix scope value used in route src-address caching.

We have to use cfg->fc_scope not the final nh_scope value.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    1 +
 net/ipv4/fib_semantics.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 0e14083..3f6c943 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -51,6 +51,7 @@ struct fib_nh {
 	struct fib_info		*nh_parent;
 	unsigned		nh_flags;
 	unsigned char		nh_scope;
+	unsigned char		nh_cfg_scope;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			nh_weight;
 	int			nh_power;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 952c737..d73d758 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -854,9 +854,10 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	}
 
 	change_nexthops(fi) {
+		nexthop_nh->nh_cfg_scope = cfg->fc_scope;
 		nexthop_nh->nh_saddr = inet_select_addr(nexthop_nh->nh_dev,
 							nexthop_nh->nh_gw,
-							nexthop_nh->nh_scope);
+							nexthop_nh->nh_cfg_scope);
 	} endfor_nexthops(fi)
 
 link_it:
@@ -1141,7 +1142,7 @@ void fib_update_nh_saddrs(struct net_device *dev)
 			continue;
 		nh->nh_saddr = inet_select_addr(nh->nh_dev,
 						nh->nh_gw,
-						nh->nh_scope);
+						nh->nh_cfg_scope);
 	}
 }
 
-- 
1.7.4.1

