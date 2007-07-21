From: David Miller <davem@davemloft.net>
Subject: Re: Virtual device lo asks to queue packet! since -git15
Date: Sat, 21 Jul 2007 11:53:04 -0700 (PDT)
Message-ID: <20070721.115304.112624318.davem@davemloft.net>
References: <200707210949.22880.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753134AbXGUSxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 14:53:06 -0400
In-Reply-To: <200707210949.22880.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sat, 21 Jul 2007 09:49:22 +0200

> Since -git15 (probably David's merge) I see a lot of 
> 
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> 
> during a LTP run on a nfsroot system

Yes I have a fix pending in my tree for this.

commit 31ce72a6b1c7635259cf522459539c0611f2c50c
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 20 19:45:45 2007 -0700

    [NET]: Fix loopback crashes when multiqueue is enabled.
    
    From: Patrick McHardy <kaber@trash.net>
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9820ca1..4a616d7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -575,7 +575,7 @@ struct net_device
 
 	/* The TX queue control structures */
 	unsigned int			egress_subqueue_count;
-	struct net_device_subqueue	egress_subqueue[0];
+	struct net_device_subqueue	egress_subqueue[1];
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 38212c3..ee40355 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3624,7 +3624,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	/* ensure 32-byte alignment of both the device and private area */
 	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
-		     (sizeof(struct net_device_subqueue) * queue_count)) &
+		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
 		     ~NETDEV_ALIGN_CONST;
 	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
@@ -3642,7 +3642,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		dev->priv = ((char *)dev +
 			     ((sizeof(struct net_device) +
 			       (sizeof(struct net_device_subqueue) *
-				queue_count) + NETDEV_ALIGN_CONST)
+				(queue_count - 1)) + NETDEV_ALIGN_CONST)
 			      & ~NETDEV_ALIGN_CONST));
 	}
 
