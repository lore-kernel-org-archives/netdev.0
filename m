From: Martin Buck <mb-tmp-ohtmvyyn.xreary.bet@gromit.dyndns.org>
Subject: Re: [patch 17/18] 3c59x: fix duplex configuration
Date: Mon, 20 Aug 2007 17:06:35 +0200
Message-ID: <20070820150635.GA32554@gromit.at.home>
References: <200708102105.l7AL5Q2h008995@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de, protasnb@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail16.bluewin.ch ([195.186.19.63]:56443 "EHLO
	mail16.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbXHTPMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 11:12:38 -0400
Content-Disposition: inline
In-Reply-To: <200708102105.l7AL5Q2h008995@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 02:05:26PM -0700, akpm@linux-foundation.org wrote:
[...]
> diff -puN drivers/net/3c59x.c~3c59x-fix-duplex-configuration drivers/net/3c59x.c
> --- a/drivers/net/3c59x.c~3c59x-fix-duplex-configuration
> +++ a/drivers/net/3c59x.c
> @@ -1559,6 +1559,7 @@ vortex_up(struct net_device *dev)
>  		mii_reg1 = mdio_read(dev, vp->phys[0], MII_BMSR);
>  		mii_reg5 = mdio_read(dev, vp->phys[0], MII_LPA);
>  		vp->partner_flow_ctrl = ((mii_reg5 & 0x0400) != 0);
> +		vp->mii.full_duplex = vp->full_duplex;
>  
>  		vortex_check_media(dev, 1);
>  	}
> _


Sorry for the late reply. I finally managed to get my notebook fixed so
that I could actually test this patch. I can confirm that it fixes my
duplex configuration problem. The steps described in
http://bugzilla.kernel.org/show_bug.cgi?id=8575
now result in a Ethernet chip properly configured for full duplex. Thanks
for the fix!

The only remaining issue I have the 3c59x driver is the time required until
it detects link loss when unplugging the Ethernet cable. At the moment,
this needs up to 60 seconds which makes this feature pretty useless. Other
drivers need 2-5 seconds for this which is roughly what I would have
expected. I've been using the patch below sucessfully for a few weeks now
which brings down this time to 5 seconds. Would be nice if somebody could
apply it.

Thanks,
Martin


--- drivers/net/3c59x.c.orig	2007-08-20 17:01:06.000000000 +0200
+++ drivers/net/3c59x.c	2007-08-20 17:02:38.000000000 +0200
@@ -1726,7 +1726,7 @@
 	struct net_device *dev = (struct net_device *)data;
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
-	int next_tick = 60*HZ;
+	int next_tick = 5*HZ;
 	int ok = 0;
 	int media_status, old_window;
 
@@ -1771,9 +1771,6 @@
 		ok = 1;
 	}
 
-	if (!netif_carrier_ok(dev))
-		next_tick = 5*HZ;
-
 	if (vp->medialock)
 		goto leave_media_alone;
 
