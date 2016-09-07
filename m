From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Minimum MTU Mess
Date: Wed, 7 Sep 2016 15:53:56 -0400
Message-ID: <20160907195356.GX33916@redhat.com>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:32873 "EHLO
        mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753998AbcIGTyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 15:54:08 -0400
Received: by mail-yw0-f182.google.com with SMTP id l8so15787772ywb.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 12:53:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160906.165529.496766310703537877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 04:55:29PM -0700, David Miller wrote:
> From: Jarod Wilson <jarod@redhat.com>
> Date: Fri, 2 Sep 2016 13:07:42 -0400
> 
> > In any case, the number of "mtu < 68" and "#define FOO_MIN_MTU 68", or
> > variations thereof, under drivers/net/ is kind of crazy.
> 
> Agreed, we can have a default and let the different cases provide
> overrides.
> 
> Mostly what to do here is a function of the hardware though.

So I've been tinkering with this some, and it looks like having both
centralized min and max checking could be useful here. I'm hacking away at
drivers now, but the basis of all this would potentially look about like
the patch below, and each device would have to set dev->m{in,ax}_mtu one
way or another. Drivers using alloc_etherdev and/or ether_setup would get
the "default" values, and then they can be overridden. Probably need
something to make sure dev->max_mtu isn't set to 0 though...

Possibly on the right track here, or might there be a better way to
approach this?

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 117d02e..864d6f2 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -35,6 +35,8 @@
 #define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
 #define ETH_FCS_LEN	4		/* Octets in the FCS		 */
 
+#define ETH_MIN_MTU	68		/* Min IPv4 MTU per RFC791	*/
+
 /*
  *	These are the defined Ethernet Protocol ID's.
  */
diff --git a/net/core/dev.c b/net/core/dev.c
index dd6ce59..d20fd5d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6466,9 +6466,17 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 	if (new_mtu == dev->mtu)
 		return 0;
 
-	/*	MTU must be positive.	 */
-	if (new_mtu < 0)
+	if (new_mtu < dev->min_mtu) {
+		netdev_err(dev, "Invalid MTU %d requested, hw min %d\n",
+			   new_mtu, dev->min_mtu);
 		return -EINVAL;
+	}
+
+	if (new_mtu > dev->max_mtu) {
+		netdev_err(dev, "Invalid MTU %d requested, hw max %d\n",
+			   new_mtu, dev->min_mtu);
+		return -EINVAL;
+	}
 
 	if (!netif_device_present(dev))
 		return -ENODEV;
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 66dff5e..2be0203 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -322,8 +322,6 @@ EXPORT_SYMBOL(eth_mac_addr);
  */
 int eth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu < 68 || new_mtu > ETH_DATA_LEN)
-		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
 }
@@ -357,6 +355,8 @@ void ether_setup(struct net_device *dev)
 	dev->type		= ARPHRD_ETHER;
 	dev->hard_header_len 	= ETH_HLEN;
 	dev->mtu		= ETH_DATA_LEN;
+	dev->min_mtu		= ETH_MIN_MTU;
+	dev->max_mtu		= ETH_DATA_LEN;
 	dev->addr_len		= ETH_ALEN;
 	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;

-- 
Jarod Wilson
jarod@redhat.com
