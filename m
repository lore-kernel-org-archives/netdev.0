From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 2/5] swdevice: add new api to set and del
 bridge port attributes
Date: Fri, 23 Jan 2015 17:06:36 +0100
Message-ID: <20150123160636.GM2065@nanopsycho.orion>
References: <1421987606-10884-3-git-send-email-roopa@cumulusnetworks.com>
 <20150123104127.GC2065@nanopsycho.orion>
 <54C26FC1.70605@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	vyasevic@redhat.com, ronen.arad@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:54957 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbAWQGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 11:06:39 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so3863073wib.5
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 08:06:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54C26FC1.70605@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 23, 2015 at 04:58:57PM CET, roopa@cumulusnetworks.com wrote:
>On 1/23/15, 2:41 AM, Jiri Pirko wrote:
>
><snip..>
>>
>>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>>index d162b21..bf0be98 100644
>>--- a/net/switchdev/switchdev.c
>>+++ b/net/switchdev/switchdev.c
>>@@ -50,3 +50,73 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>>	return ops->ndo_switch_port_stp_update(dev, state);
>>}
>>EXPORT_SYMBOL(netdev_switch_port_stp_update);
>>+
>>+/**
>>+ *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
>>+ *	port attributes
>>+ *
>>+ *	@dev: port device
>>+ *	@nlh: netlink msg with bridge port attributes
>>+ *
>>+ *	Notify switch device port of bridge port attributes
>>+ */
>>+int netdev_switch_port_bridge_setlink(struct net_device *dev,
>>+				      struct nlmsghdr *nlh, u16 flags)
>>+{
>>+	const struct net_device_ops *ops = dev->netdev_ops;
>>+	struct net_device *lower_dev;
>>+	struct list_head *iter;
>>+	int ret = 0, err = 0;
>>+
>>+	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
>>+		return err;
>>+
>>+	if (ops->ndo_bridge_setlink) {
>>+		WARN_ON(!ops->ndo_switch_parent_id_get);
>>+		return ops->ndo_bridge_setlink(dev, nlh, flags);
>>+	}
>>+
>>+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>+		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
>>+		if (err)
>>+			ret = err;
>>+	}
>>+
>>+	return ret;
>>+}
>>+EXPORT_SYMBOL(netdev_switch_port_bridge_setlink);
>>+
>>+/**
>>+ *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
>>+ *	attribute delete
>>+ *
>>+ *	@dev: port device
>>+ *	@nlh: netlink msg with bridge port attributes
>>+ *
>>+ *	Notify switch device port of bridge port attribute delete
>>+ */
>>+int netdev_switch_port_bridge_dellink(struct net_device *dev,
>>+				      struct nlmsghdr *nlh, u16 flags)
>>+{
>>+	const struct net_device_ops *ops = dev->netdev_ops;
>>+	struct net_device *lower_dev;
>>+	struct list_head *iter;
>>+	int ret = 0, err = 0;
>>+
>>+	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
>>+		return err;
>>+
>>+	if (ops->ndo_bridge_dellink) {
>>+		WARN_ON(!ops->ndo_switch_parent_id_get);
>>+		return ops->ndo_bridge_dellink(dev, nlh, flags);
>>+	}
>>+
>>+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>+		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
>>+		if (err)
>>+			ret = err;
>>+	}
>>+
>>+	return ret;
>>+}
>>+EXPORT_SYMBOL(netdev_switch_port_bridge_dellink);
>>-- 
>>1.7.10.4
>>
>>Is there any other place, other than bridge code, this functions are
>>suppored to be called from?
>No other place today. Its usually the master that implements
>ndo_bridge_setlink/dellink.
>
>>If not, which I consider likely, it would
>>make more sense to me to:
>>
>>- move netdev_for_each_lower_dev iterations directly to bridge code
>>- let the masters (bond, team, ..) implement ndo_bridge_*link and do
>>   the traversing there (can be in a form of pre-prepared default
>>   ndo callback (ndo_dflt_netdev_switch_port_bridge_*link)
>But, i am still not understanding why i would modify bond, team and other
>slaves

Well, that is the usual way to propagate ndo calls. People are used to
this. It is visible right away in bonding/other code that is propagated
some ndo call to slaves. With your code, that is somehow hidden and only
dependent on NETIF_F_HW_NETFUNC_OFFLOAD flag.

Note that there are only couple of "master drivers" (for this, most likely
only bond and team modifications are needed).
 

>to offload bridge attributes. They could independently do so in the future if
>they
>want to do something more than what this default api provides.
>The api's setlink/dellink provided by this patch are the default api's.
>The drivers can override them if needed in the future (which aligns with what
>you want as well).
>
>Thanks,
>Roopa
>
>
>
>
