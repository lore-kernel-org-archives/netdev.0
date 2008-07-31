From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 14:37:31 +0200
Message-ID: <20080731123731.GB29176@xi.wantstofly.org>
References: <20080730235004.GC21999@xi.wantstofly.org> <20080730.165621.211366535.davem@davemloft.net> <20080731004123.GB22826@xi.wantstofly.org> <20080730.181047.39922732.davem@davemloft.net> <20080731014506.GA23402@xi.wantstofly.org> <20080731035410.GA4893@gondor.apana.org.au> <20080731094536.GC23814@xi.wantstofly.org> <20080731105522.GB7601@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57921 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbYGaMhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 08:37:33 -0400
Content-Disposition: inline
In-Reply-To: <20080731105522.GB7601@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 06:55:22PM +0800, Herbert Xu wrote:

> > From: Lennert Buytenhek <buytenh@wantstofly.org>
> > Subject: [NET] use software GSO for SG+CSUM capable netdevices
> > 
> > If a netdevice does not support hardware GSO, allowing the stack to
> > use GSO anyway and then splitting the GSO skb into MSS-sized pieces
> > as it is handed to the netdevice for transmitting is likely still
> > a win at least as far as CPU usage is concerned, since it reduces
> > the number of trips through the output path.
> > 
> > This patch enables the use of GSO on any netdevice that supports SG
> > and hardware checksumming.  If a GSO skb is then sent to a netdevice
> > that supports SG and checksumming but does not support hardware GSO,
> > net/core/dev.c:dev_hard_start_xmit() will take care of doing the
> > necessary GSO segmentation in software.
> > 
> > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> > 
> > Index: linux-2.6.27-rc1/include/net/sock.h
> > ===================================================================
> > --- linux-2.6.27-rc1.orig/include/net/sock.h
> > +++ linux-2.6.27-rc1/include/net/sock.h
> > @@ -1085,7 +1085,12 @@ extern struct dst_entry *sk_dst_check(st
> >  
> >  static inline int sk_can_gso(const struct sock *sk)
> >  {
> > -	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
> > +	int caps = sk->sk_route_caps;
> > +	int type = sk->sk_gso_type;
> > +
> > +	return (caps & NETIF_F_SG) &&
> > +		 ((type == SKB_GSO_TCPV4 && (caps & NETIF_F_V4_CSUM)) ||
> > +		  (type == SKB_GSO_TCPV6 && (caps & NETIF_F_V6_CSUM)));
> 
> I think you've lost the hardware UFO support.
> 
> In any case, this is really the wrong place to do this as the
> user will no longer be able to disable it.
> 
> Please do it in the netdev registration function instead.  The code
> should enable NETIF_F_GSO if NETIF_F_SG is on.

Like this?




From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [NET] use software GSO for SG+CSUM capable netdevices

If a netdevice does not support hardware GSO, allowing the stack to
use GSO anyway and then splitting the GSO skb into MSS-sized pieces
as it is handed to the netdevice for transmitting is likely still
a win as far as throughput and/or CPU usage are concerned, since it
reduces the number of trips through the output path.

This patch enables the use of GSO on any netdevice that supports SG.
If a GSO skb is then sent to a netdevice that supports SG but does not
support hardware GSO, net/core/dev.c:dev_hard_start_xmit() will take
care of doing the necessary GSO segmentation in software.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.27-rc1/net/core/dev.c
===================================================================
--- linux-2.6.27-rc1.orig/net/core/dev.c
+++ linux-2.6.27-rc1/net/core/dev.c
@@ -3988,6 +3988,10 @@ int register_netdevice(struct net_device
 		}
 	}
 
+	/* Enable software GSO if SG is supported. */
+	if (dev->features & NETIF_F_SG)
+		dev->features |= NETIF_F_GSO;
+
 	netdev_initialize_kobject(dev);
 	ret = netdev_register_kobject(dev);
 	if (ret)
