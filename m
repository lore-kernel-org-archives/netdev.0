From: Ben Greear <greearb@candelatech.com>
Subject: Re: [patch] add net_device_stats support to ethtool
Date: Wed, 16 Jan 2008 10:46:58 -0800
Message-ID: <478E5122.1060009@candelatech.com>
References: <200801161529.m0GFTfYR005096@sallyv1.ics.uci.edu>	<478E46F6.4070901@candelatech.com> <200801161834.m0GIYCIr027613@sallyv1.ics.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Nicolaescu <dann@ics.uci.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33610 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750986AbYAPSqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 13:46:54 -0500
In-Reply-To: <200801161834.m0GIYCIr027613@sallyv1.ics.uci.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Nicolaescu wrote:
> Ben Greear <greearb@candelatech.com> writes:
>
>   > Dan Nicolaescu wrote:
>   > > Hi,
>   > >
>   > > I have posted this patch in the past with absolutely no reply.
>   > > I would appreciate some sort of feedback of the form interested/not
>   > > interested.  Should I just drop it?
>   > >
>   > >   
>   > I like it, but why not offer this for all devices since they all have
>   > these stats.
>   >
>   > Could add new handlers called something like .get_strings_generic, or
>   > just add this to the higher-level ethtool handling before it looks for
>   > handlers.
>
> If I get your point, then the difference would be that drivers would add
> to the initialization of the ethtool structure something like:
>   
I meant something more like this (this will not apply..I hand-edited it 
to remove
some extraneous crap from my patch...and I'm sure it's white-space damaged).

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c5e0593..095d1eb 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c

+/* Handle some generic ethtool commands here */
+static int ethtool_get_netdev_stats(struct net_device *dev, void 
*useraddr) {
+   
+    struct ethtool_ndstats* nds = (struct ethtool_ndstats*)(useraddr);
+     
+    struct net_device_stats *stats = dev->get_stats(dev);
+    if (stats) {
+        if (copy_to_user(nds->data, stats, sizeof(*stats))) {
+            return -EFAULT;
+        }
+    }
+    else {
+        return -EOPNOTSUPP;
+    }
+    return 0;
+}
+
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct ifreq *ifr)
@@ -796,9 +884,6 @@ int dev_ethtool(struct ifreq *ifr)
     if (!dev || !netif_device_present(dev))
         return -ENODEV;
 
-    if (!dev->ethtool_ops)
-        return -EOPNOTSUPP;
-
     if (copy_from_user(&ethcmd, useraddr, sizeof (ethcmd)))
         return -EFAULT;
 
@@ -823,12 +908,25 @@ int dev_ethtool(struct ifreq *ifr)
             return -EPERM;
     }
 
-    if (dev->ethtool_ops->begin)
+    if (dev->ethtool_ops && dev->ethtool_ops->begin)
         if ((rc = dev->ethtool_ops->begin(dev)) < 0)
             return rc;
 
     old_features = dev->features;
 
+    /* Handle some generic operations that do not require specific
+     * ethtool handlers.
+     */
+    switch (ethcmd) {
+    case ETHTOOL_GNDSTATS:
+        return ethtool_get_netdev_stats(dev, useraddr);
+    default:
+        break;
+    }
+
+    if (!dev->ethtool_ops)
+        return -EOPNOTSUPP;
+
     switch (ethcmd) {
     case ETHTOOL_GSET:
         rc = ethtool_get_settings(dev, useraddr);


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


