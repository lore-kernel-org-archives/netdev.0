From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Virtual device lo asks to queue packet! since -git15 II
Date: Sat, 21 Jul 2007 20:54:19 +0400
Message-ID: <20070721165419.GA21038@2ka.mipt.ru>
References: <200707210949.22880.ak@suse.de> <200707211849.30469.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47468 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbXGUQyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 12:54:23 -0400
Content-Disposition: inline
In-Reply-To: <200707211849.30469.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 21, 2007 at 06:49:30PM +0200, Andi Kleen (ak@suse.de) wrote:
> On Saturday 21 July 2007 09:49:22 Andi Kleen wrote:
> > 
> > FYI
> > 
> > Since -git15 (probably David's merge) I see a lot of 
> > 
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > 
> > during a LTP run on a nfsroot system
> 
> 
> ... and my firefox just hung itself up trying to connect to localhost:111
> (in -git16 now)
> 
> Network definitely seems to have issues

It should be in David's tree already.
Patrick fixed this with folowing patch:

[NET]: Fix loopback multiqueue bug

The loopback device is not allocated through netdev_alloc_mq and thus
has no room for the subqueue states reserved. Change the net_device
subqueue array to always include at least one element.

Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index da7a13c..bf9399c 100644
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
index 13a0d9f..4af0207 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3619,7 +3619,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	/* ensure 32-byte alignment of both the device and private area */
 	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
-		     (sizeof(struct net_device_subqueue) * queue_count)) &
+		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
 		     ~NETDEV_ALIGN_CONST;
 	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
@@ -3637,7 +3637,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		dev->priv = ((char *)dev +
 			     ((sizeof(struct net_device) +
 			       (sizeof(struct net_device_subqueue) *
-				queue_count) + NETDEV_ALIGN_CONST)
+				(queue_count - 1)) + NETDEV_ALIGN_CONST)
 			      & ~NETDEV_ALIGN_CONST));
 	}
 

> -Andi

-- 
	Evgeniy Polyakov
