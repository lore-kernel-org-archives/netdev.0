From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Thu, 07 Apr 2005 14:35:55 -0700
Message-ID: <200504072135.j37LZt4f004009@death.nxdomain.ibm.com>
References: <davem@davemloft.net>
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: Message from "David S. Miller" <davem@davemloft.net>
   of "Thu, 07 Apr 2005 13:57:56 PDT." <20050407135756.2df03aaa.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:

>> 	My presumption is that the above would be unacceptable, if for
>> no other reason than other notifiers could be attached that also make
>> sleepable memory allocations.
>
>You could change it instead to just use gfp_any().
>
>Would that work?  The problematic case occurs from softirq
>not hardirq right?

	Yes, that works, and yes, the troublesome calls come from
softirq (timers).  In that case, the rtnetlink patch would be:

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
--- linux-2.6.12-rc2-virgin/net/core/rtnetlink.c	2005-03-03 15:53:48.000000000 -0800
+++ linux-2.6.12-rc2-setmac/net/core/rtnetlink.c	2005-04-07 14:05:29.000000000 -0700
@@ -441,7 +441,7 @@
 			       sizeof(struct rtnl_link_ifmap) +
 			       sizeof(struct rtnl_link_stats) + 128);
 
-	skb = alloc_skb(size, GFP_KERNEL);
+	skb = alloc_skb(size, gfp_any());
 	if (!skb)
 		return;
 
@@ -450,7 +450,7 @@
 		return;
 	}
 	NETLINK_CB(skb).dst_groups = RTMGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTMGRP_LINK, GFP_KERNEL);
+	netlink_broadcast(rtnl, skb, 0, RTMGRP_LINK, gfp_any());
 }
 
 static int rtnetlink_done(struct netlink_callback *cb)



	This doesn't do anything about other event handlers that might
also have potential sleeps.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
