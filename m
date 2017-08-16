From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3 v4] drivers: net: ethernet: qualcomm:
 rmnet: Initial implementation
Date: Tue, 15 Aug 2017 21:24:14 -0700 (PDT)
Message-ID: <20170815.212414.71937112074428743.davem@davemloft.net>
References: <1502856953-30321-1-git-send-email-subashab@codeaurora.org>
        <1502856953-30321-4-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbdHPEYP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 00:24:15 -0400
In-Reply-To: <1502856953-30321-4-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Tue, 15 Aug 2017 22:15:53 -0600

> +static int rmnet_unregister_real_device(struct net_device *dev)
> +{
> +	int config_id = RMNET_LOCAL_LOGICAL_ENDPOINT;
> +	struct rmnet_logical_ep_conf_s *epconfig_l;
> +	struct rmnet_phys_ep_conf_s *config;
> +
> +	ASSERT_RTNL();
> +
> +	netdev_info(dev, "Removing device %s\n", dev->name);
> +
> +	if (!rmnet_is_real_dev_registered(dev))
> +		return -EINVAL;
> +
> +	for (; config_id < RMNET_MAX_LOGICAL_EP; config_id++) {

This loop is so much harder to understand because you initialize
the loop index several lines above the for() statement.  Just
initialize it here at the beginning of the for() loop and deal
with the fact that this will have to therefore be a multi-line
for() statement the best you can.

> +static int rmnet_set_egress_data_format(struct net_device *dev,	u32 edf,
> +					u16 agg_size, u16 agg_count)

Use a space instead of a TAB character before the "u32 edf," argument.

> +static int
> +__rmnet_set_logical_endpoint_config(struct net_device *dev,
> +				    int config_id,
> +				    struct rmnet_logical_ep_conf_s *epconfig)
> +{
> +	struct rmnet_logical_ep_conf_s *epconfig_l;
> +
> +	ASSERT_RTNL();
> +
> +	epconfig_l = rmnet_get_logical_ep(dev, config_id);
> +
> +	if (!epconfig_l || epconfig_l->refcount)
> +		return -EINVAL;
> +
> +	memcpy(epconfig_l, epconfig, sizeof(struct rmnet_logical_ep_conf_s));
> +	if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
> +		epconfig_l->mux_id = 0;
> +	else
> +		epconfig_l->mux_id = config_id;
> +
> +	dev_hold(epconfig_l->egress_dev);
> +	return 0;
> +}

This looks really messy.

One invariant that must hold is that if I try to take down netdev
"X", all resources holding a reference to X will be immediately
(or quickly) dropped when that request comes in via notifiers.

Will this happen properly for this egress_dev reference counting?

> +static int rmnet_config_notify_cb(struct notifier_block *nb,
> +				  unsigned long event, void *data)
> +{
> +	struct net_device *dev = netdev_notifier_info_to_dev(data);
> +
> +	if (!dev)
> +		return NOTIFY_DONE;
> +
> +	switch (event) {
> +	case NETDEV_UNREGISTER_FINAL:
> +	case NETDEV_UNREGISTER:
> +		netdev_info(dev, "Kernel unregister\n");
> +		rmnet_force_unassociate_device(dev);
> +		break;

So I guess it happens here?
