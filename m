From: Patrick McHardy <kaber@trash.net>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Thu, 19 Jul 2007 12:11:10 +0200
Message-ID: <469F38BE.4030401@trash.net>
References: <200707182218.13548.arekm@maven.pl> <469E9CF7.1040403@trash.net> <200707190819.53364.arekm@maven.pl> <469F2E14.9050200@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000503090809010205040105"
Cc: Arkadiusz Miskiewicz <arekm@maven.pl>, netdev@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62971 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937831AbXGSKMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 06:12:05 -0400
In-Reply-To: <469F2E14.9050200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000503090809010205040105
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Arkadiusz Miskiewicz wrote:
> 
>>>>CONFIG_NETDEVICES_MULTIQUEUE=y
>>>
>>>Does it go away if you disable this option?
>>
>>
>>Yes, it goes away after disabling this.
> 
> 
> I don't see a bug in the code itself, maybe the queue_mapping points
> to an invalid subqueue. Could you please try this patch and post the
> output?


OK I see what the problem is. The loopback device is statically
allocated, so it doesn't have any room for the subqueues reserved.

The easiest fix would be to use egress_subqueue[1] in struct
net_device, but I think that may cause warnings with newer gccs
when using a constant index that is > 0. OTOH using constant
indices doesn't seem to make much sense for the subqueue array.

Arkadiusz, does this patch fix the problem?

--------------000503090809010205040105
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

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
 

--------------000503090809010205040105--
