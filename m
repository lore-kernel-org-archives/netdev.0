From: Patrick McHardy <kaber@trash.net>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Thu, 19 Jul 2007 15:13:37 +0200
Message-ID: <469F6381.9090206@trash.net>
References: <200707182218.13548.arekm@maven.pl> <469F2E14.9050200@trash.net> <469F38BE.4030401@trash.net> <200707191352.52707.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010507090905030306060906"
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arkadiusz Miskiewicz <arekm@maven.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34226 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbXGSNRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 09:17:02 -0400
In-Reply-To: <200707191352.52707.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010507090905030306060906
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit

Arkadiusz Miskiewicz wrote:
> On Thursday 19 of July 2007, Patrick McHardy wrote:
>   
>> OK I see what the problem is. The loopback device is statically
>> allocated, so it doesn't have any room for the subqueues reserved.
>>
>> The easiest fix would be to use egress_subqueue[1] in struct
>> net_device, but I think that may cause warnings with newer gccs
>> when using a constant index that is > 0. OTOH using constant
>> indices doesn't seem to make much sense for the subqueue array.
>>
>> Arkadiusz, does this patch fix the problem?
>>     
>
> It fixes the problem for me.
>   

Thanks for testing. Dave, please apply.



--------------010507090905030306060906
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

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
 

--------------010507090905030306060906--
