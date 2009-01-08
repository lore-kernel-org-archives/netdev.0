From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] hdlc: fix compile problem
Date: Wed, 7 Jan 2009 17:08:42 -0800
Message-ID: <20090107170842.6ee4eb77@extreme>
References: <20090107141343.3e256119@extreme>
	<m3d4eyvh28.fsf@maximus.localdomain>
	<20090107152858.6fb8ac5d@extreme>
	<m3tz8atxwv.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38576 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753525AbZAHBIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 20:08:44 -0500
In-Reply-To: <m3tz8atxwv.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Jan 2009 02:00:00 +0100
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
> > It was introduced (by me) in previous patch. Since that isn't applied yet,
> > I'll go back and fix.
> 
> I can see it now, I must have missed it because of the "synclink"
> subject.
> 
> @@ -106,7 +98,7 @@ static int hdlc_device_event(struct noti
>         if (dev_net(dev) != &init_net)
>                 return NOTIFY_DONE;
>  
> -       if (dev->get_stats != hdlc_get_stats)
> +       if (dev->header_ops != &hdlc_null_ops)
>                 return NOTIFY_DONE; /* not an HDLC device */
> 
> This won't work because hdlc_null_ops may be substituted by
> cisco_header_ops or ppp_header_ops. Current test works for now but is
> wrong, too, at least for wanxl driver (it tries to use its
> get_stats()).
> 
> Perhaps some
> +       if (dev->header_ops->something != &something)
> would do? Alternatively we can return to hdlc_carrier_on|off() and
> hdlc_device_event() won't be needed.
> 
> Essentially, it's a bit hard to check if the device is one of ours if
> we are the middle layer.
> 
> 
> There are two layers here:
> - hardware drivers (10+)
> - protocol drivers (5 - hdlc* files)
> 
> Protocol drivers want to define things like:
> - dev->header_ops (no problem)
> - dev->change_mtu (perhaps)
> - dev->hard_start_xmit
> 
> Hardware drivers need to define the rest of NDO.
> 
> Hmm, not much, only hard_start_xmit() is really problematic. I think
> we need a trampoline: hw driver will define the NDO and set
> hard_start_xmit and possibly change_mtu to (exported by hdlc.c)
> hdlc_xmit (hdlc_change_mtu), and hdlc_start_xmit will just call
> protocol's xmit().
> We could also use it for the test in hdlc_device_event:
> 	if (dev->netdev_ops->start_hard_xmit != hdlc_xmit)
> 
> If we could then get rid of this special xmit() and do all header and
> TX preparations in hard_header(), it would be even better (cleaner)
> though IIRC it requires some changes to Ethernet(?) code.
> 
> 
> The changes have to be applied to the 4 synclink drivers and to most
> .c files in drivers/net/wan simultaneously, perhaps it's more practical
> if I do it?

Alternatively, how about this:

--- a/drivers/net/wan/hdlc.c	2009-01-07 17:04:52.002497019 -0800
+++ b/drivers/net/wan/hdlc.c	2009-01-07 17:07:02.874497531 -0800
@@ -40,8 +40,6 @@
 
 static const char* version = "HDLC support module revision 1.22";
 
-static const struct header_ops hdlc_null_ops;
-
 #undef DEBUG_LINK
 
 static struct hdlc_proto *first_proto;
@@ -100,7 +98,7 @@ static int hdlc_device_event(struct noti
 	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
-	if (dev->header_ops != &hdlc_null_ops)
+	if (dev->priv_flags & IFF_WAN_HDLC)
 		return NOTIFY_DONE; /* not an HDLC device */
 
 	if (event != NETDEV_CHANGE)
@@ -220,12 +218,15 @@ int hdlc_ioctl(struct net_device *dev, s
 	return -EINVAL;
 }
 
+static const struct header_ops hdlc_null_ops;
+
 static void hdlc_setup_dev(struct net_device *dev)
 {
 	/* Re-init all variables changed by HDLC protocol drivers,
 	 * including ether_setup() called from hdlc_raw_eth.c.
 	 */
 	dev->flags		 = IFF_POINTOPOINT | IFF_NOARP;
+	dev->priv_flags		 = IFF_WAN_HDLC;
 	dev->mtu		 = HDLC_MAX_MTU;
 	dev->type		 = ARPHRD_RAWHDLC;
 	dev->hard_header_len	 = 16;
--- a/include/linux/if.h	2009-01-07 17:03:04.397497564 -0800
+++ b/include/linux/if.h	2009-01-07 17:07:42.499169960 -0800
@@ -66,6 +66,7 @@
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
 #define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
 #define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
+#define IFF_WAN_HDLC	0x200		/* WAN HDLC device              */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002


