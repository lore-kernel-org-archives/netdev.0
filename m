From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Thu, 07 Apr 2005 13:55:33 -0700
Message-ID: <200504072055.j37KtXDf003795@death.nxdomain.ibm.com>
References: <davem@davemloft.net>
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: Message from "David S. Miller" <davem@davemloft.net>
   of "Thu, 07 Apr 2005 13:31:51 PDT." <20050407133151.5887c946.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:

>On Thu, 07 Apr 2005 12:59:35 -0700
>Jay Vosburgh <fubar@us.ibm.com> wrote:
[...]
>> 	Rearranging the bonding driver to not call this way is a fairly
>> involved change; this patch merely reverts one part of bonding to the
>> way it used to be.
>
>You can't remove that notifier call, you will break ipv4 ARP,
>ipv6 neighbour discovery, and bridging if you do that.

	Only as they relate to bonding slave device MAC changes in the
ALB and TLB modes (the "no notifier" version is only called by MAC
changes that occur in those circumstances, all of which are in
bond_alb.c).

	Until a month ago, none of the bonding calls that change MAC
addresses issued notifiers, this reverts to that behavior only for ALB
and TLB modes.  Is that worse than going forward with a potential sleep
from a timer context with a lock held?

	Another alternative would be to change the rtnetlink handler to
not use a sleepable memory allocation, e.g.,

--- linux-2.6.12-rc2-virgin/net/core/rtnetlink.c	2005-03-03 15:53:48.000000000 -0800
+++ linux-2.6.12-rc2-setmac/net/core/rtnetlink.c	2005-04-07 09:30:03.000000000 -0700
@@ -441,7 +441,7 @@
 			       sizeof(struct rtnl_link_ifmap) +
 			       sizeof(struct rtnl_link_stats) + 128);
 
-	skb = alloc_skb(size, GFP_KERNEL);
+	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -450,7 +450,7 @@
 		return;
 	}
 	NETLINK_CB(skb).dst_groups = RTMGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTMGRP_LINK, GFP_KERNEL);
+	netlink_broadcast(rtnl, skb, 0, RTMGRP_LINK, GFP_ATOMIC);
 }
 
 static int rtnetlink_done(struct netlink_callback *cb)



	My presumption is that the above would be unacceptable, if for
no other reason than other notifiers could be attached that also make
sleepable memory allocations.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
