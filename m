From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel >
 3.10
Date: Thu, 14 Nov 2013 12:54:51 +0100
Message-ID: <20131114115451.GT19702@redhat.com>
References: <52838590.5070806@profihost.ag>
 <20131113141244.GM19702@redhat.com>
 <52838AC8.8070005@profihost.ag>
 <52839540.6020908@gmail.com>
 <5283980D.7020508@profihost.ag>
 <20131113162136.GP19702@redhat.com>
 <5283B500.9040408@gmail.com>
 <5283DC91.1010402@profihost.ag>
 <52843EEA.3020905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Stefan Priebe <s.priebe@profihost.ag>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49865 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752624Ab3KNL5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 06:57:14 -0500
Content-Disposition: inline
In-Reply-To: <52843EEA.3020905@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 10:09:30PM -0500, Vlad Yasevich wrote:
>Can you try out attached patch please.  I ran it in my environment and
>always get promisc link when attaching devices to the bridge.

It's interesting, actually, why do we need to check for IFF_UP at all when
changing flags.

The addition of IFF_UP goes up to:

commit b6c40d68ff6498b7f63ddf97cf0aa818d748dee7
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Oct 7 15:26:48 2008 -0700

     net: only invoke dev->change_rx_flags when device is UP

     Jesper Dangaard Brouer <hawk@comx.dk> reported a bug when setting a VLAN
     device down that is in promiscous mode:

     When the VLAN device is set down, the promiscous count on the real
     device is decremented by one by vlan_dev_stop(). When removing the
     promiscous flag from the VLAN device afterwards, the promiscous
     count on the real device is decremented a second time by the
     vlan_change_rx_flags() callback.

... snip ...

However, I'm not sure that this is still needed, cause:

commit deede2fabe24e00bd7e246eb81cd5767dc6fcfc7
Author: Matthijs Kooijman <matthijs@stdin.nl>
Date:   Mon Oct 31 04:53:13 2011 +0000

     vlan: Don't propagate flag changes on down interfaces.

     When (de)configuring a vlan interface, the IFF_ALLMULTI ans IFF_PROMISC
     flags are cleared or set on the underlying interface. So, if these flags
     are changed on a vlan interface that is not up, the flags underlying
     interface might be set or cleared twice.

     Only propagating flag changes when a device is up makes sure this does
     not happen. It also makes sure that an underlying device is not set to
     promiscuous or allmulti mode for a vlan device that is down.

... snip ...

which fixed completely the initial issue with vlans.

Maybe we should just remove the IFF_UP check in dev_change_rx_flags(), and
let the drivers using it handle its own logic, as vlan does?

Something like this:

diff --git a/net/core/dev.c b/net/core/dev.c
index 8ffc52e..9615cd7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4995,7 +4995,7 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
  {
  	const struct net_device_ops *ops = dev->netdev_ops;
  
-	if ((dev->flags & IFF_UP) && ops->ndo_change_rx_flags)
+	if (ops->ndo_change_rx_flags)
  		ops->ndo_change_rx_flags(dev, flags);
  }
  

>
>Thanks
>-vlad
