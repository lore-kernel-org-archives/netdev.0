From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 5/8] switchdev: implement IPv4 fib ndo
 wrappers
Date: Fri, 6 Mar 2015 08:24:00 +0100
Message-ID: <20150306072400.GB2011@nanopsycho.orion>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
 <1425619280-27492-6-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	roopa@cumulusnetworks.com, alexander.h.duyck@redhat.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:39355 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbbCFHYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 02:24:03 -0500
Received: by wesu56 with SMTP id u56so14197135wes.6
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 23:24:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425619280-27492-6-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 06, 2015 at 06:21:17AM CET, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Flesh out ndo wrappers to call into device driver.  To call into device driver,
>the wrapper must interate over route's nexthops to ensure all nexthop devs
>belong to the same switch device.  Currently, there is no support for route's
>nexthops spanning offloaded and non-offloaded devices, or spanning ports of
>multiple offload devices.
>
>Since switch device ports may be stacked under virtual interfaces (bonds and/or
>bridges), and the route's nexthop may be on the virtual interface, the wrapper
>will traverse the nexthop dev down to the base dev.  It's the base dev that's
>passed to the switchdev driver's ndo ops.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> net/switchdev/switchdev.c |   98 ++++++++++++++++++++++++++++++++++++++++++++-
> 1 file changed, 96 insertions(+), 2 deletions(-)
>
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index 81c4c02..99907d8 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -227,6 +227,65 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
> }
> EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_dellink);
> 
>+static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
>+{
>+	const struct net_device_ops *ops = dev->netdev_ops;
>+	struct net_device *lower_dev;
>+	struct net_device *port_dev;
>+	struct list_head *iter;
>+
>+	/* Recusively search down until we find a sw port dev.
>+	 * (A sw port dev supports ndo_switch_parent_id_get).
>+	 */
>+
>+	if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD &&
>+	    ops->ndo_switch_parent_id_get)
>+		return dev;
>+
>+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>+		port_dev = netdev_switch_get_lowest_dev(lower_dev);
>+		if (port_dev)
>+			return port_dev;
>+	}


I think we should proparate through stacked devices properly as we do in
case of netdev_switch_port_bridge_setlink and netdev_switch_port_bridge_dellink
(and also with roopa's new patchset in case of
netdev_switch_port_stp_update)

Other than this I like this patchset. Great work! Thanks.

Jiri

>+
>+	return NULL;
>+}
>+
>+static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
>+{
>+	struct netdev_phys_item_id psid;
>+	struct netdev_phys_item_id prev_psid;
>+	struct net_device *dev = NULL;
>+	int nhsel;
>+
>+	/* For this route, all nexthop devs must be on the same switch. */
>+
>+	for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
>+		const struct fib_nh *nh = &fi->fib_nh[nhsel];
>+
>+		if (!nh->nh_dev)
>+			return NULL;
>+
>+		dev = netdev_switch_get_lowest_dev(nh->nh_dev);
>+		if (!dev)
>+			return NULL;
>+
>+		if (netdev_switch_parent_id_get(dev, &psid))
>+			return NULL;
>+
>+		if (nhsel > 0) {
>+			if (prev_psid.id_len != psid.id_len)
>+				return NULL;
>+			if (memcmp(prev_psid.id, psid.id, psid.id_len))
>+				return NULL;
>+		}
>+
>+		prev_psid = psid;
>+	}
>+
>+	return dev;
>+}
>+
> /**
>  *	netdev_switch_fib_ipv4_add - Add IPv4 route entry to switch
>  *
>@@ -242,11 +301,27 @@ EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_dellink);
> int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
> 			       u8 tos, u8 type, u32 tb_id)
> {
>+	struct net_device *dev;
>+	const struct net_device_ops *ops;
>+	int err = 0;
>+
> 	/* Don't offload route if using custom ip rules */
> 	if (fi->fib_net->ipv4.fib_has_custom_rules)
> 		return 0;
> 
>-	return 0;
>+	dev = netdev_switch_get_dev_by_nhs(fi);
>+	if (!dev)
>+		return 0;
>+	ops = dev->netdev_ops;
>+
>+	if (ops->ndo_switch_fib_ipv4_add) {
>+		err = ops->ndo_switch_fib_ipv4_add(dev, htonl(dst), dst_len,
>+						   fi, tos, type, tb_id);
>+		if (!err)
>+			fi->fib_flags |= RTNH_F_EXTERNAL;
>+	}
>+
>+	return err;
> }
> EXPORT_SYMBOL(netdev_switch_fib_ipv4_add);
> 
>@@ -265,6 +340,25 @@ EXPORT_SYMBOL(netdev_switch_fib_ipv4_add);
> int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
> 			       u8 tos, u8 type, u32 tb_id)
> {
>-	return 0;
>+	struct net_device *dev;
>+	const struct net_device_ops *ops;
>+	int err = 0;
>+
>+	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
>+		return 0;
>+
>+	dev = netdev_switch_get_dev_by_nhs(fi);
>+	if (!dev)
>+		return 0;
>+	ops = dev->netdev_ops;
>+
>+	if (ops->ndo_switch_fib_ipv4_del) {
>+		err = ops->ndo_switch_fib_ipv4_del(dev, htonl(dst), dst_len,
>+						   fi, tos, type, tb_id);
>+		if (!err)
>+			fi->fib_flags &= ~RTNH_F_EXTERNAL;
>+	}
>+
>+	return err;
> }
> EXPORT_SYMBOL(netdev_switch_fib_ipv4_del);
>-- 
>1.7.10.4
>
