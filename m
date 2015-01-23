From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 2/5] swdevice: add new api to set and del
 bridge port attributes
Date: Fri, 23 Jan 2015 11:41:27 +0100
Message-ID: <20150123104127.GC2065@nanopsycho.orion>
References: <1421987606-10884-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	vyasevic@redhat.com, ronen.arad@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:52069 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbbAWKlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 05:41:31 -0500
Received: by mail-wi0-f181.google.com with SMTP id fb4so1836036wid.2
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 02:41:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1421987606-10884-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 23, 2015 at 05:33:23AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This patch adds two new api's netdev_switch_port_bridge_setlink
>and netdev_switch_port_bridge_dellink to offload bridge port attributes
>to switch asic
>
>(The names of the apis look odd with 'switch_port_bridge',
>but am more inclined to change the prefix of the api to something else.
>Will take any suggestions).
>
>The api's look at the NETIF_F_HW_NETFUNC_OFFLOAD feature flag to
>pass bridge port attributes to the port device.
>
>If the device has the NETIF_F_HW_NETFUNC_OFFLOAD, but does not support
>the bridge port attribute offload ndo, call bridge port attribute ndo's on
>the lowerdevs if supported. This is one way to pass bridge port attributes
>through stacked netdevs (example when bridge port is a bond and bond slaves
>are switch ports).
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>---
> include/net/switchdev.h   |   17 ++++++++++-
> net/switchdev/switchdev.c |   70 +++++++++++++++++++++++++++++++++++++++++++++
> 2 files changed, 86 insertions(+), 1 deletion(-)
>
>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>index 8a6d164..362f53a 100644
>--- a/include/net/switchdev.h
>+++ b/include/net/switchdev.h
>@@ -17,7 +17,10 @@
> int netdev_switch_parent_id_get(struct net_device *dev,
> 				struct netdev_phys_item_id *psid);
> int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
>-
>+int netdev_switch_port_bridge_setlink(struct net_device *dev,
>+				struct nlmsghdr *nlh, u16 flags);
>+int netdev_switch_port_bridge_dellink(struct net_device *dev,
>+				struct nlmsghdr *nlh, u16 flags);
> #else
> 
> static inline int netdev_switch_parent_id_get(struct net_device *dev,
>@@ -32,6 +35,18 @@ static inline int netdev_switch_port_stp_update(struct net_device *dev,
> 	return -EOPNOTSUPP;
> }
> 
>+int netdev_switch_port_bridge_setlink(struct net_device *dev,
>+				      struct nlmsghdr *nlh, u16 flags)
>+{
>+	return -EOPNOTSUPP;
>+}
>+
>+int netdev_switch_port_bridge_dellink(struct net_device *dev,
>+				      struct nlmsghdr *nlh, u16 flags)
>+{
>+	return -EOPNOTSUPP;
>+}
>+
> #endif
> 
> #endif /* _LINUX_SWITCHDEV_H_ */
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index d162b21..bf0be98 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -50,3 +50,73 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
> 	return ops->ndo_switch_port_stp_update(dev, state);
> }
> EXPORT_SYMBOL(netdev_switch_port_stp_update);
>+
>+/**
>+ *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
>+ *	port attributes
>+ *
>+ *	@dev: port device
>+ *	@nlh: netlink msg with bridge port attributes
>+ *
>+ *	Notify switch device port of bridge port attributes
>+ */
>+int netdev_switch_port_bridge_setlink(struct net_device *dev,
>+				      struct nlmsghdr *nlh, u16 flags)
>+{
>+	const struct net_device_ops *ops = dev->netdev_ops;
>+	struct net_device *lower_dev;
>+	struct list_head *iter;
>+	int ret = 0, err = 0;
>+
>+	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
>+		return err;
>+
>+	if (ops->ndo_bridge_setlink) {
>+		WARN_ON(!ops->ndo_switch_parent_id_get);
>+		return ops->ndo_bridge_setlink(dev, nlh, flags);
>+	}
>+
>+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>+		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
>+		if (err)
>+			ret = err;
>+	}
>+
>+	return ret;
>+}
>+EXPORT_SYMBOL(netdev_switch_port_bridge_setlink);
>+
>+/**
>+ *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
>+ *	attribute delete
>+ *
>+ *	@dev: port device
>+ *	@nlh: netlink msg with bridge port attributes
>+ *
>+ *	Notify switch device port of bridge port attribute delete
>+ */
>+int netdev_switch_port_bridge_dellink(struct net_device *dev,
>+				      struct nlmsghdr *nlh, u16 flags)
>+{
>+	const struct net_device_ops *ops = dev->netdev_ops;
>+	struct net_device *lower_dev;
>+	struct list_head *iter;
>+	int ret = 0, err = 0;
>+
>+	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
>+		return err;
>+
>+	if (ops->ndo_bridge_dellink) {
>+		WARN_ON(!ops->ndo_switch_parent_id_get);
>+		return ops->ndo_bridge_dellink(dev, nlh, flags);
>+	}
>+
>+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>+		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
>+		if (err)
>+			ret = err;
>+	}
>+
>+	return ret;
>+}
>+EXPORT_SYMBOL(netdev_switch_port_bridge_dellink);
>-- 
>1.7.10.4
>

Is there any other place, other than bridge code, this functions are
suppored to be called from? If not, which I consider likely, it would
make more sense to me to:

- move netdev_for_each_lower_dev iterations directly to bridge code
- let the masters (bond, team, ..) implement ndo_bridge_*link and do
  the traversing there (can be in a form of pre-prepared default
  ndo callback (ndo_dflt_netdev_switch_port_bridge_*link)
