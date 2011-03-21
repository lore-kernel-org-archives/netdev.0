From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Mon, 21 Mar 2011 14:46:48 +0100
Message-ID: <20110321134647.GA3126@redhat.com>
References: <1300446743.11985.317.camel@firesoul.comx.local>
 <4D8385CE.1060205@intel.com>
 <1300699294.10934.63.camel@firesoul.comx.local>
 <1300700708.2884.10.camel@edumazet-laptop>
 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8429@MNEXMB2.qlogic.org>
 <20110321123406.GA2376@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19053 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab1CUNrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 09:47:16 -0400
Content-Disposition: inline
In-Reply-To: <20110321123406.GA2376@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2011 at 01:34:06PM +0100, Stanislaw Gruszka wrote:
> On Mon, Mar 21, 2011 at 05:00:31AM -0500, Amit Salecha wrote:
> > > Well, this warning can be ignored since these NIC dont receive packets
> > > to be forwarded in your setup.
> > >
> > > I would say netxen_nic_set_flags() is buggy : It rejects data if other
> > > flag than ETH_FLAG_LRO is set.
> > >
> > > if (data & ~ETH_FLAG_LRO)
> > >       return -EINVAL;
> > >
> > > Brought by commit ef2519b1dd39940 (netxen: fail when try to setup
> > > unsupported features) later corrected by commit 97d1935a61b7fe7a65f98f
> > > (Make ethtool_ops::set_flags() return -EINVAL for unsupported flags)
> > >
> > > Since this drivers asserts NETIF_F_HW_VLAN_TX (mirroring
> > > ETH_FLAG_TXVLAN), ethtool_op_get_flags() can return more than
> > > ETH_FLAG_LRO.
> > >
> > > dev_disable_lro() then calls netxen_nic_set_flags() with
> > > ETH_FLAG_TXVLAN
> > > -> -EINVAL, and ETH_FLAG_LRO stay ORed in dev->features -> WARNING
> > >
> > >
> > Thanks Eric.
> > 
> > Instead of
> >         if (data & ~ETH_FLAG_LRO)
> >                 return -EINVAL;
> > 
> > check should be like this:
> > 
> > +    if ((ethtool_op_get_flags(netdev) & ~ETH_FLAG_LRO) !=
> > +                                       (data & ~ETH_FLAG_LRO))
> >                 return -EINVAL;
> > 
> > Will provide patch soon.
> 
> Yep, that should fix issue in netxen.
> 
> I'm afraid some other drivers can have similar problem after
> adding ETH_FLAG_{TX,RX}VLAN. I think we need to distinguish features
> that are configurable at runtime from features that are hardcoded.
> I'm going to look at that.

Other drivers have this bug too. I'm going to prepare patch with similar fix
like Amit proposed, but also for other drivers. Something like below:

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..38fd0cb 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -141,9 +141,17 @@ u32 ethtool_op_get_flags(struct net_device *dev)
 }
 EXPORT_SYMBOL(ethtool_op_get_flags);
 
+bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported)
+{
+	if ((dev->features & ~supported) != (data & ~supported))
+		return true;
+	else
+		return false;
+}
+
 int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
 {
-	if (data & ~supported)
+	if (ethtool_invalid_flags(dev, data, supported);
 		return -EINVAL;
 
 	dev->features = ((dev->features & ~flags_dup_features) |
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 81254be..7a662f1 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -304,8 +304,8 @@ vmxnet3_set_flags(struct net_device *netdev, u32 data)
 	u8 lro_present = (netdev->features & NETIF_F_LRO) == 0 ? 0 : 1;
 	unsigned long flags;
 
-	if (data & ~ETH_FLAG_LRO)
-		return -EOPNOTSUPP;
+	if (ethtool_invalid_flags(netdev, data, ETH_FLAG_LRO))
+		return -EINVAL;
 
 	if (lro_requested ^ lro_present) {
 		/* toggle the LRO feature*/
