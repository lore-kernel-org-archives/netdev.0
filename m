From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [PATCH] net: drop NETIF_F_GSO from hw_features without
 NETIF_F_SG
Date: Sun, 20 Mar 2011 19:56:54 +0100
Message-ID: <20110320185654.GA14223@core.hellgate.ch>
References: <20110318195030.GA22350@core.hellgate.ch>
 <AANLkTim1_+GdURWxk=+N+5xCFTF1L27BD=+Uu+BY4jWF@mail.gmail.com>
 <20110319074653.GA12820@core.hellgate.ch>
 <AANLkTinCdaEs=G=AC45ePA-J99Vik9fYE+ZyF1miCiVy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Micha? Miros?aw <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail18.bluewin.ch ([195.186.19.64]:12747 "EHLO
	mail18.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318Ab1CTS4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 14:56:54 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinCdaEs=G=AC45ePA-J99Vik9fYE+ZyF1miCiVy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Mar 2011 17:18:17 +0100, Micha? Miros?aw wrote:
> > However, I still think the current, unpatched behavior is confusing users.
> > ethtool_get_features() will happily tell the user that GSO is available for
> > a NIC even if it is not (because the NIC does not support SG). Then, if the
> > user tries to enable GSO, the operation fails silently: ethtool won't get
> > an error code, so it looks as if the operation succeeded. The user needs to
> > look into the kernel log or actually verify the offload settings to realize
> > that something went wrong.
> 
> Do you want to prepare a patch for this? Please remember about
> compatibility with per-offload ethtool ops if you do - this needs to
> be there until all drivers are converted to hw_features.

Something like this?

diff --git a/net/core/dev.c b/net/core/dev.c
index 0b88eba..5861a59 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5442,6 +5442,9 @@ int register_netdevice(struct net_device *dev)
 	if (!(dev->wanted_features & NETIF_F_SG)) {
 		dev->wanted_features &= ~NETIF_F_GSO;
 		dev->features &= ~NETIF_F_GSO;
+		if (!(dev->hw_features & NETIF_F_SG) &&
+		    (!dev->ethtool_ops || !dev->ethtool_ops->set_sg))
+			dev->hw_features &= ~NETIF_F_GSO;
 	}
 
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
