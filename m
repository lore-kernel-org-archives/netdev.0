From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH net-next-2.6 3/3] vmxnet3: Remove incorrect
 implementation of ethtool_ops::get_flags()
Date: Wed, 30 Jun 2010 09:46:51 -0700
Message-ID: <8B1F619C9F5F454E81D90D3C161698D7033625111F@EXCH-MBX-3.vmware.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	 <1277902060.2082.13.camel@achroite.uk.solarflarecom.com>
	 <8B1F619C9F5F454E81D90D3C161698D703362510AE@EXCH-MBX-3.vmware.com>
 <1277913534.2082.28.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:32715 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754235Ab0F3Qqy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 12:46:54 -0400
In-Reply-To: <1277913534.2082.28.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> Sent: Wednesday, June 30, 2010 8:59 AM
> 
> On Wed, 2010-06-30 at 08:44 -0700, Bhavesh Davda wrote:
> > Thanks for fixing this, Ben! Had to look at ethtool-2.6.34 src to
> > convince myself of the correctness. Looks good to me.
> >
> > Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> >
> > ps: I do wonder, however, why not always use ethtool_op_get_flags for
> > all drivers, and mask whatever is returned by the driver specific
> > dev->ethtool_ops->get_flags with flags_dup_features instead of this
> > approach?
> 
> I think you're right that ethtool_op_get_flags could be the implicit
> default (i.e. used if ethtool_ops::get_flags is NULL) and drivers
> should
> not have to set it.  Following this change, no drivers in net-next-2.6
> will be using any other implementation.  However, I don't think
> ethtool_ops::get_flags should be removed - in future there are likely
> to
> be additional ethtool flags that do not correspond to net device
> feature
> flags, and some drivers will need a different implementation.
> 
> Ben.
> 

Hi Ben,

I'm not suggesting nuking ethtool_ops::get_flags. What I was suggesting is *always* calling ethtool_ops_get_flags from dev_ethtool for case ETHTOOL_GFLAGS, but doing something like this simple patch:

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a0f4964..f5da6ed 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -139,8 +139,9 @@ u32 ethtool_op_get_flags(struct net_device *dev)
         * handling for flags which are not so easily handled
         * by a simple masking operation
         */
-
-       return dev->features & flags_dup_features;
+       return (dev->ethtool_ops->get_flags ?
+               dev->ethtool_ops->get_flags(dev) :
+               dev->features) & flags_dup_features;
 }
 EXPORT_SYMBOL(ethtool_op_get_flags);

@@ -1495,9 +1496,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
                break;
        case ETHTOOL_GFLAGS:
                rc = ethtool_get_value(dev, useraddr, ethcmd,
-                                      (dev->ethtool_ops->get_flags ?
-                                       dev->ethtool_ops->get_flags :
-                                       ethtool_op_get_flags));
+                                       ethtool_op_get_flags);
                break;
        case ETHTOOL_SFLAGS:
                rc = ethtool_set_value(dev, useraddr,

Plus nuking all such code in the netdev drivers:
        .get_flags              = ethtool_op_get_flags,

This is still pretty fragile and could lead to infinite recursion if some drivers are missed. But you get the idea.

Thanks

- Bhavesh
