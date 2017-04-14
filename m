From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/1 v3] drivers: net: rmnet: Initial
 implementation
Date: Fri, 14 Apr 2017 09:10:30 -0700
Message-ID: <20170414091030.2a657c9f@xeon-e3>
References: <1492146329-4304-1-git-send-email-subashab@codeaurora.org>
        <1492146329-4304-2-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34716 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbdDNQKe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 12:10:34 -0400
Received: by mail-pf0-f173.google.com with SMTP id c198so42366562pfc.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 09:10:34 -0700 (PDT)
In-Reply-To: <1492146329-4304-2-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Apr 2017 23:05:29 -0600
Subash Abhinov Kasiviswanathan <subashab@codeaurora.org> wrote:

> RmNet driver provides a transport agnostic MAP (multiplexing and
> aggregation protocol) support in embedded module. Module provides
> virtual network devices which can be attached to any IP-mode
> physical device. This will be used to provide all MAP functionality
> on future hardware in a single consistent location.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

> 
> diff --git a/Documentation/networking/rmnet.txt b/Documentation/networking/rmnet.txt
> new file mode 100644
> index 0000000..58d3ea2
> --- /dev/null
> +++ b/Documentation/networking/rmnet.txt
>
...

> +3. Userspace configuration
> +
> +rmnet userspace configuration is done through netlink library librmnetctl
> +and command line utility rmnetcli. Utility is hosted in codeaurora forum git.
> +The driver uses rtnl_link_ops for communication.
> +
> +https://source.codeaurora.org/quic/la/platform/vendor/qcom-opensource/\
> +dataservices/tree/rmnetctl

Don't split URL better to have long line.


> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 98ed4d9..29b3945 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -74,3 +74,4 @@ obj-$(CONFIG_HYPERV_NET) += hyperv/
>  obj-$(CONFIG_NTB_NETDEV) += ntb_netdev.o
>  
>  obj-$(CONFIG_FUJITSU_ES) += fjes/
> +obj-$(CONFIG_RMNET) += rmnet/
> diff --git a/drivers/net/rmnet/Kconfig b/drivers/net/rmnet/Kconfig

Since this is Qualcomm and Ethernet specific, maybe better to put
in drivers/net/ethernet/qualcom/rmnet


> new file mode 100644
> index 0000000..63cd477
> --- /dev/null
> +++ b/drivers/net/rmnet/Kconfig
> @@ -0,0 +1,23 @@
> +#
> +# RMNET MAP driver
> +#
> +
> +menuconfig RMNET
> +	depends on NETDEVICES
> +	bool "RmNet MAP driver"
> +	default n
> +	---help---
> +	  If you say Y here, then the rmnet module will be statically
> +	  compiled into the kernel. The rmnet module provides MAP
> +	  functionality for embedded and bridged traffic.
> +if RMNET
> +
> +config RMNET_DEBUG
> +	bool "RmNet Debug Logging"
> +	default n
> +	---help---
> +	  Say Y here if you want RmNet to be able to log packets in main
> +	  system log. This should not be enabled on production builds as it can
> +	  impact system performance. Note that simply enabling it here will not
> +	  enable the logging; it must be enabled at run-time as well.


Please use network device standard debug mechanism.
netif_msg_XXX

> +endif # RMNET
> diff --git a/drivers/net/rmnet/Makefile b/drivers/net/rmnet/Makefile
> new file mode 100644
> index 0000000..2b6c9cf
> --- /dev/null
> +++ b/drivers/net/rmnet/Makefile
> @@ -0,0 +1,14 @@
> +#
> +# Makefile for the RMNET module
> +#
> +
> +rmnet-y		 := rmnet_main.o
> +rmnet-y		 += rmnet_config.o
> +rmnet-y		 += rmnet_vnd.o
> +rmnet-y		 += rmnet_handlers.o
> +rmnet-y		 += rmnet_map_data.o
> +rmnet-y		 += rmnet_map_command.o
> +rmnet-y		 += rmnet_stats.o
> +obj-$(CONFIG_RMNET) += rmnet.o
> +
> +CFLAGS_rmnet_main.o := -I$(src)
> diff --git a/drivers/net/rmnet/rmnet_config.c b/drivers/net/rmnet/rmnet_config.c
> new file mode 100644
> index 0000000..a4bc76b
> --- /dev/null
> +++ b/drivers/net/rmnet/rmnet_config.c
> @@ -0,0 +1,592 @@
> +/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * RMNET configuration engine
> + *
> + */
> +
> +#include <net/sock.h>
> +#include <linux/module.h>
> +#include <linux/netlink.h>
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/spinlock.h>
> +#include <linux/rmnet.h>
> +#include "rmnet_config.h"
> +#include "rmnet_handlers.h"
> +#include "rmnet_vnd.h"
> +#include "rmnet_private.h"
> +
> +RMNET_LOG_MODULE(RMNET_LOGMASK_CONFIG);
> +
> +/* Local Definitions and Declarations */
> +#define RMNET_LOCAL_LOGICAL_ENDPOINT -1
> +
> +/* _rmnet_is_physical_endpoint_associated() - Determines if device is associated
> + * @dev:      Device to get check
> + *
> + * Compares device rx_handler callback pointer against known function
> + */
> +static inline int _rmnet_is_physical_endpoint_associated(struct net_device *dev)
> +{
> +	rx_handler_func_t *rx_handler;
> +
> +	rx_handler = rcu_dereference(dev->rx_handler);
> +
> +	if (rx_handler == rmnet_rx_handler)
> +		return 1;
> +	else
> +		return 0;
> +}

Could just be:

static inline int _rmnet_is_physical_endpoint_associated(const struct net_device *dev)
{
	rx_handler_func_t *rx_handler
		= rcu_dereference(dev->rx_handler);

	return rx_handler == rmet_rx_handler;
}

But standard practice is to use ndo_ops to identify self in network drivers.
I.e
	return dev->netdev_ops == &rmnet_device_ops;


> +/* _rmnet_get_phys_ep_config() - Get physical ep config for an associated device
> + * @dev:      Device to get endpoint configuration from
> + */
> +static inline struct rmnet_phys_ep_conf_s *_rmnet_get_phys_ep_config
> +						(struct net_device *dev)
awkward line break.
dev could be const

> +{
> +	if (_rmnet_is_physical_endpoint_associated(dev))
> +		return (struct rmnet_phys_ep_conf_s *)
> +			rcu_dereference(dev->rx_handler_data);
> +	else
> +		return 0;
> +}
> +
> +struct rmnet_free_vnd_work {
> +	struct work_struct work;
> +	int vnd_id[RMNET_MAX_VND];
> +	int count;
> +};
> +
> +/* _rmnet_get_logical_ep() - Gets the logical end point configuration
> + * structure for a network device
> + * @dev:             Device to get endpoint configuration from
> + * @config_id:       Logical endpoint id on device
> + * Retrieves the logical_endpoint_config structure.
> + */
> +static struct rmnet_logical_ep_conf_s *_rmnet_get_logical_ep
> +	(struct net_device *dev, int config_id)
> +{
> +	struct rmnet_phys_ep_conf_s *config;
> +	struct rmnet_logical_ep_conf_s *epconfig_l;
> +
> +	if (rmnet_vnd_is_vnd(dev)) {
> +		epconfig_l = rmnet_vnd_get_le_config(dev);
> +	} else {
> +		config = _rmnet_get_phys_ep_config(dev);
> +
> +		if (!config)
> +			return NULL;
> +
> +		if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
> +			epconfig_l = &config->local_ep;
> +		else
> +			epconfig_l = &config->muxed_ep[config_id];
> +	}
> +
> +	return epconfig_l;
> +}
> +
> +/* rmnet_unassociate_network_device() - Unassociate network device
> + * @dev:      Device to unassociate
> + *
> + * Frees all structures generate for device. Unregisters rx_handler
> + */
> +static int rmnet_unassociate_network_device(struct net_device *dev)
> +{
> +	struct rmnet_phys_ep_conf_s *config;
> +	int config_id = RMNET_LOCAL_LOGICAL_ENDPOINT;
> +	struct rmnet_logical_ep_conf_s *epconfig_l;
> +
> +	ASSERT_RTNL();
> +
> +	LOGL("(%s);", dev->name);
> +
> +	if (!dev || !_rmnet_is_physical_endpoint_associated(dev))
> +		return -EINVAL;
> +
> +	for (; config_id < RMNET_MAX_LOGICAL_EP; config_id++) {
> +		epconfig_l = _rmnet_get_logical_ep(dev, config_id);
> +		if (epconfig_l && epconfig_l->refcount)
> +			return -EINVAL;
> +	}
> +
> +	config = (struct rmnet_phys_ep_conf_s *)
> +		  rcu_dereference(dev->rx_handler_data);

Please don't directly reference rx_handler. There is already functions
like netdev_is_rx_handler_busy() to abstract that API.

> +
> +	if (!config)
> +		return -EINVAL;
> +
> +	kfree(config);
> +
> +	netdev_rx_handler_unregister(dev);
> +
> +	dev_put(dev);
> +	return 0;
> +}
> +
> +/* rmnet_set_ingress_data_format() - Set ingress data format on network device
> + * @dev:                 Device to ingress data format on
> + * @egress_data_format:  32-bit unsigned bitmask of ingress format
> + *
> + * Network device must already have association with RmNet Data driver
> + */
> +static int rmnet_set_ingress_data_format(struct net_device *dev,
> +					 u32 ingress_data_format)
> +{
> +	struct rmnet_phys_ep_conf_s *config;
> +
> +	ASSERT_RTNL();
> +
> +	LOGL("(%s,0x%08X);", dev->name, ingress_data_format);
> +
> +	if (!dev)
> +		return -EINVAL;
> +
> +	config = _rmnet_get_phys_ep_config(dev);
> +	if (!config)
> +		return -EINVAL;
> +
> +	config->ingress_data_format = ingress_data_format;
> +
> +	return 0;
> +}
> +
> +/* rmnet_set_egress_data_format() - Set egress data format on network device
> + * @dev:                 Device to egress data format on
> + * @egress_data_format:  32-bit unsigned bitmask of egress format
> + *
> + * Network device must already have association with RmNet Data driver
> + */
> +static int rmnet_set_egress_data_format(struct net_device *dev,
> +					u32 egress_data_format,
> +					u16 agg_size,
> +					u16 agg_count)
> +{
> +	struct rmnet_phys_ep_conf_s *config;
> +
> +	ASSERT_RTNL();
> +
> +	LOGL("(%s,0x%08X, %d, %d);",
> +	     dev->name, egress_data_format, agg_size, agg_count);
> +
> +	if (!dev)
> +		return -EINVAL;
> +
> +	config = _rmnet_get_phys_ep_config(dev);
> +	if (!config)
> +		return -EINVAL;
> +
> +	config->egress_data_format = egress_data_format;
> +
> +	return 0;
> +}
> +
> +/* rmnet_associate_network_device() - Associate network device
> + * @dev:      Device to register with RmNet data
> + *
> + * Typically used on physical network devices. Registers RX handler and private
> + * metadata structures.
> + */
> +static int rmnet_associate_network_device(struct net_device *dev)
> +{
> +	struct rmnet_phys_ep_conf_s *config;
> +	int rc;
> +
> +	ASSERT_RTNL();
> +
> +	LOGL("(%s);\n", dev->name);
> +
> +	if (!dev || _rmnet_is_physical_endpoint_associated(dev) ||
> +	    rmnet_vnd_is_vnd(dev)) {
> +		LOGM("cannot register with this dev");
> +		return -EINVAL;
> +	}
> +
> +	config = kmalloc(sizeof(*config), GFP_ATOMIC);
> +	if (!config)
> +		return -ENOMEM;
> +
> +	memset(config, 0, sizeof(struct rmnet_phys_ep_conf_s));
> +	config->dev = dev;
> +
> +	rc = netdev_rx_handler_register(dev, rmnet_rx_handler, config);
> +
> +	if (rc) {
> +		LOGM("netdev_rx_handler_register returns %d", rc);
> +		kfree(config);
> +		return -EBUSY;
> +	}
> +
> +	dev_hold(dev);
> +	return 0;
> +}
> +
> +/* __rmnet_set_logical_endpoint_config() - Set logical endpoing config on device
> + * @dev:         Device to set endpoint configuration on
> + * @config_id:   logical endpoint id on device
> + * @epconfig:    endpoint configuration structure to set
> + */

You are using docbook format here, but this is not a docbook comment.
ie.
/**
 * function - This is a docbook comment
 * @dev: this is a param
 */

Plus these are static functions so there is no point in documentating
internal API with docbook.

> +static int __rmnet_set_logical_endpoint_config
> +	(struct net_device *dev,
> +	 int config_id,
> +	 struct rmnet_logical_ep_conf_s *epconfig)
> +{
> +	struct rmnet_logical_ep_conf_s *epconfig_l;
> +
> +	ASSERT_RTNL();
> +
> +	if (!dev || config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
> +	    config_id >= RMNET_MAX_LOGICAL_EP)
> +		return -EINVAL;

For internal API's you should validate parmeters at the external
entry point not in each call. Otherwise you have a multitude of
impossible error checks and dead code paths.

> +
> +	epconfig_l = _rmnet_get_logical_ep(dev, config_id);
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
> +	/* Explicitly hold a reference to the egress device */
> +	dev_hold(epconfig_l->egress_dev);
> +	return 0;
> +}
> +
...

> +
> +static struct notifier_block rmnet_dev_notifier = {
> +	.notifier_call = rmnet_config_notify_cb,
> +	.next = 0,
> +	.priority = 0
> +};
Don't initialize fields that are not used or should be zero.


> +
> +static int rmnet_newlink(struct net *src_net, struct net_device *dev,
> +			 struct nlattr *tb[], struct nlattr *data[])
> +{
> +	int ingress_format = RMNET_INGRESS_FORMAT_DEMUXING |
> +			     RMNET_INGRESS_FORMAT_DEAGGREGATION |
> +			     RMNET_INGRESS_FORMAT_MAP;
> +	int egress_format = RMNET_EGRESS_FORMAT_MUXING |
> +			    RMNET_EGRESS_FORMAT_MAP;
> +	struct net_device *real_dev;
> +	int mode = RMNET_EPMODE_VND;
> +	u16 mux_id;
> +
> +	real_dev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
> +	if (!real_dev)
> +		return -ENODEV;
> +
> +	if (!data[IFLA_RMNET_MUX_ID])
> +		return -EINVAL;

So you are inventing private link netlink attributes.
Why? Why can't you use device switch, bridge, or other master/slave model.

> +
> +	mux_id = nla_get_u16(data[IFLA_VLAN_ID]);
> +	if (rmnet_vnd_newlink(mux_id, dev))
> +		return -EINVAL;
> +
> +	rmnet_associate_network_device(real_dev);
> +	rmnet_set_egress_data_format(real_dev, egress_format, 0, 0);
> +	rmnet_set_ingress_data_format(real_dev, ingress_format);
> +	rmnet_set_logical_endpoint_config(real_dev, mux_id, mode, dev);
> +	rmnet_set_logical_endpoint_config(dev, mux_id, mode, real_dev);
> +	return 0;
> +}
> +
> +static void rmnet_delink(struct net_device *dev, struct list_head *head)
> +{
> +	struct rmnet_logical_ep_conf_s *cfg;
> +	int mux_id;
> +
> +	mux_id = rmnet_vnd_is_vnd(dev);
> +	if (!mux_id)
> +		return;
> +
> +/* rmnet_vnd_is_vnd() gives mux_id + 1, so subtract 1 to get the correct mux_id
> + */
> +	mux_id--;
> +	cfg = rmnet_vnd_get_le_config(dev);
> +
> +	if (cfg && cfg->refcount) {
> +		_rmnet_unset_logical_endpoint_config(cfg->egress_dev, mux_id);
> +		_rmnet_unset_logical_endpoint_config(dev, mux_id);
> +		rmnet_vnd_remove_ref_dev(mux_id);
> +		rmnet_unassociate_network_device(cfg->egress_dev);
> +	}
> +
> +	unregister_netdevice_queue(dev, head);
> +}
> +
> +static int rmnet_rtnl_validate(struct nlattr *tb[], struct nlattr *data[])
> +{
> +	u16 mux_id;
> +
> +	if (!data || !data[IFLA_RMNET_MUX_ID])
> +		return -EINVAL;
> +
> +	mux_id = nla_get_u16(data[IFLA_RMNET_MUX_ID]);
> +	if (!mux_id || mux_id > (RMNET_MAX_LOGICAL_EP - 1))
> +		return -ERANGE;
> +
> +	return 0;
> +}
> +
> +static size_t rmnet_get_size(const struct net_device *dev)
> +{
> +	return nla_total_size(2); /* IFLA_RMNET_MUX_ID */
> +}
> +
> +struct rtnl_link_ops rmnet_link_ops __read_mostly = {
> +	.kind		= "rmnet",
> +	.maxtype	= __IFLA_RMNET_MAX,
> +	.priv_size	= sizeof(struct rmnet_vnd_private_s),
> +	.setup		= rmnet_vnd_setup,
> +	.validate	= rmnet_rtnl_validate,
> +	.newlink	= rmnet_newlink,
> +	.dellink	= rmnet_delink,
> +	.get_size	= rmnet_get_size,
> +};
> +
> +int rmnet_config_init(void)
> +{
> +	int rc;
> +
> +	rc = register_netdevice_notifier(&rmnet_dev_notifier);
> +	if (rc != 0) {
> +		LOGE("Failed to register device notifier; rc=%d", rc);
> +		return rc;
> +	}
> +
> +	rc = rtnl_link_register(&rmnet_link_ops);
> +	if (rc != 0) {
> +		unregister_netdevice_notifier(&rmnet_dev_notifier);
> +		LOGE("Failed to register netlink handler; rc=%d", rc);
> +		return rc;
> +	}
> +	return rc;
> +}
> +
> +void rmnet_config_exit(void)
> +{
> +	unregister_netdevice_notifier(&rmnet_dev_notifier);
> +	rtnl_link_unregister(&rmnet_link_ops);
> +}
> diff --git a/drivers/net/rmnet/rmnet_config.h b/drivers/net/rmnet/rmnet_config.h
> new file mode 100644
> index 0000000..0ef58e8
> --- /dev/null
> +++ b/drivers/net/rmnet/rmnet_config.h
> @@ -0,0 +1,79 @@
> +/* Copyright (c) 2013-2014, 2016-2017 The Linux Foundation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * RMNET Data configuration engine
> + *
> + */
> +
> +#include <linux/types.h>
> +#include <linux/time.h>
> +#include <linux/skbuff.h>
> +
> +#ifndef _RMNET_CONFIG_H_
> +#define _RMNET_CONFIG_H_
> +
> +#define RMNET_MAX_LOGICAL_EP 255
> +
> +/* struct rmnet_logical_ep_conf_s - Logical end-point configuration
> + *
> + * @refcount: Reference count for this endpoint. 0 signifies the endpoint is not
> + *            configured for use
> + * @rmnet_mode: Specifies how the traffic should be finally delivered. Possible
> + *            options are available in enum rmnet_config_endpoint_modes_e
> + * @mux_id: Virtual channel ID used by MAP protocol
> + * @egress_dev: Next device to deliver the packet to. Exact usage of this
> + *            parmeter depends on the rmnet_mode
> + */
> +struct rmnet_logical_ep_conf_s {
> +	u8 refcount;
> +	u8 rmnet_mode;
> +	u8 mux_id;
> +	struct timespec flush_time;
> +	struct net_device *egress_dev;
> +};
> +
> +/* struct rmnet_phys_ep_conf_s - Physical endpoint configuration
> + * One instance of this structure is instantiated for each net_device associated
> + * with rmnet.
> + *
> + * @dev: The device which is associated with rmnet. Corresponds to this
> + *       specific instance of rmnet_phys_ep_conf_s
> + * @local_ep: Default non-muxed endpoint. Used for non-MAP protocols/formats
> + * @muxed_ep: All multiplexed logical endpoints associated with this device
> + * @ingress_data_format: RMNET_INGRESS_FORMAT_* flags from rmnet.h
> + * @egress_data_format: RMNET_EGRESS_FORMAT_* flags from rmnet.h
> + *
> + * @egress_agg_size: Maximum size (bytes) of data which should be aggregated
> + * @egress_agg_count: Maximum count (packets) of data which should be aggregated
> + *                  Smaller of the two parameters above are chosen for
> + *                  aggregation
> + * @tail_spacing: Guaranteed padding (bytes) when de-aggregating ingress frames
> + * @agg_time: Wall clock time when aggregated frame was created
> + * @agg_last: Last time the aggregation routing was invoked
> + */
> +struct rmnet_phys_ep_conf_s {
> +	struct net_device *dev;
> +	struct rmnet_logical_ep_conf_s local_ep;
> +	struct rmnet_logical_ep_conf_s muxed_ep[RMNET_MAX_LOGICAL_EP];
> +	u32 ingress_data_format;
> +	u32 egress_data_format;
> +};
> +
> +int rmnet_config_init(void);
> +void rmnet_config_exit(void);
> +int rmnet_free_vnd(int id);
> +
> +extern struct rtnl_link_ops rmnet_link_ops;
> +
> +struct rmnet_vnd_private_s {
> +	struct rmnet_logical_ep_conf_s local_ep;
> +};
> +#endif /* _RMNET_CONFIG_H_ */
> diff --git a/drivers/net/rmnet/rmnet_handlers.c b/drivers/net/rmnet/rmnet_handlers.c
> new file mode 100644
> index 0000000..bf8b3bb
> --- /dev/null
> +++ b/drivers/net/rmnet/rmnet_handlers.c
> @@ -0,0 +1,517 @@
> +/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * RMNET Data ingress/egress handler
> + *
> + */
> +
> +#include <linux/skbuff.h>
> +#include <linux/netdevice.h>
> +#include <linux/module.h>
> +#include <linux/rmnet.h>
> +#include <linux/netdev_features.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include "rmnet_private.h"
> +#include "rmnet_config.h"
> +#include "rmnet_vnd.h"
> +#include "rmnet_map.h"
> +#include "rmnet_stats.h"
> +#include "rmnet_handlers.h"
> +
> +RMNET_LOG_MODULE(RMNET_LOGMASK_HANDLER);
> +
> +#ifdef CONFIG_RMNET_DEBUG
> +unsigned int dump_pkt_rx;
> +module_param(dump_pkt_rx, uint, 0644);
> +MODULE_PARM_DESC(dump_pkt_rx, "Dump packets entering ingress handler");
> +
> +unsigned int dump_pkt_tx;
> +module_param(dump_pkt_tx, uint, 0644);
> +MODULE_PARM_DESC(dump_pkt_tx, "Dump packets exiting egress handler");
> +#endif /* CONFIG_RMNET_DEBUG */
> +
> +#define RMNET_IP_VERSION_4 0x40
> +#define RMNET_IP_VERSION_6 0x60
> +
> +/* Helper Functions */
> +
> +/* __rmnet_set_skb_proto() - Set skb->protocol field
> + * @skb:      packet being modified
> + *
> + * Peek at the first byte of the packet and set the protocol. There is not
> + * good way to determine if a packet has a MAP header. As of writing this,
> + * the reserved bit in the MAP frame will prevent it from overlapping with
> + * IPv4/IPv6 frames. This could change in the future!
> + */
> +static inline void __rmnet_set_skb_proto(struct sk_buff *skb)
> +{
> +	switch (skb->data[0] & 0xF0) {
> +	case RMNET_IP_VERSION_4:
> +		skb->protocol = htons(ETH_P_IP);
> +		break;
> +	case RMNET_IP_VERSION_6:
> +		skb->protocol = htons(ETH_P_IPV6);
> +		break;
> +	default:
> +		skb->protocol = htons(ETH_P_MAP);
> +		break;
> +	}
> +}
> +
> +#ifdef CONFIG_RMNET_DEBUG
> +/* rmnet_print_packet() - Print packet / diagnostics
> + * @skb:      Packet to print
> + * @printlen: Number of bytes to print
> + * @dev:      Name of interface
> + * @dir:      Character representing direction (e.g.. 'r' for receive)
> + *
> + * This function prints out raw bytes in an SKB. Use of this will have major
> + * performance impacts and may even trigger watchdog resets if too much is being
> + * printed. Hence, this should always be compiled out unless absolutely needed.
> + */
> +void rmnet_print_packet(const struct sk_buff *skb, const char *dev, char dir)
> +{
> +	char buffer[200];
> +	unsigned int len, printlen;
> +	int i, buffloc = 0;
> +
> +	switch (dir) {
> +	case 'r':
> +		printlen = dump_pkt_rx;
> +		break;
> +
> +	case 't':
> +		printlen = dump_pkt_tx;
> +		break;
> +
> +	default:
> +		printlen = 0;
> +		break;
> +	}
> +
> +	if (!printlen)
> +		return;
> +
> +	pr_err("[%s][%c] - PKT skb->len=%d skb->head=%pK skb->data=%pK\n",
> +	       dev, dir, skb->len, (void *)skb->head, (void *)skb->data);
> +	pr_err("[%s][%c] - PKT skb->tail=%pK skb->end=%pK\n",
> +	       dev, dir, skb_tail_pointer(skb), skb_end_pointer(skb));
> +
> +	if (skb->len > 0)
> +		len = skb->len;
> +	else
> +		len = ((unsigned int)(uintptr_t)skb->end) -
> +		      ((unsigned int)(uintptr_t)skb->data);
> +
> +	pr_err("[%s][%c] - PKT len: %d, printing first %d bytes\n",
> +	       dev, dir, len, printlen);
> +
> +	memset(buffer, 0, sizeof(buffer));
> +	for (i = 0; (i < printlen) && (i < len); i++) {
> +		if ((i % 16) == 0) {
> +			pr_err("[%s][%c] - PKT%s\n", dev, dir, buffer);
> +			memset(buffer, 0, sizeof(buffer));
> +			buffloc = 0;
> +			buffloc += snprintf(&buffer[buffloc],
> +					sizeof(buffer) - buffloc, "%04X:",
> +					i);
> +		}
> +
> +		buffloc += snprintf(&buffer[buffloc], sizeof(buffer) - buffloc,
> +					" %02x", skb->data[i]);

If you really have to do this. Use hex_dump_bytes API.

> +	}
> +	pr_err("[%s][%c] - PKT%s\n", dev, dir, buffer);
> +}
> +#else
> +void rmnet_print_packet(const struct sk_buff *skb, const char *dev, char dir)
> +{
> +}
> +#endif /* CONFIG_RMNET_DEBUG */
> +
> +/* Generic handler */
> +
> +/* rmnet_bridge_handler() - Bridge related functionality
> + */
> +static rx_handler_result_t rmnet_bridge_handler
> +	(struct sk_buff *skb, struct rmnet_logical_ep_conf_s *ep)
> +{
> +	if (!ep->egress_dev) {
> +		LOGD("Missing egress device for packet arriving on %s",
> +		     skb->dev->name);
> +		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_BRDG_NO_EGRESS);
> +	} else {
> +		rmnet_egress_handler(skb, ep);
> +	}
> +
> +	return RX_HANDLER_CONSUMED;
> +}
> +
> +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +static void rmnet_reset_mac_header(struct sk_buff *skb)
> +{
> +	skb->mac_header = 0;
> +	skb->mac_len = 0;
> +}

Why not use sbk_set_mac_header(skb, 0)?

> +#else
> +static void rmnet_reset_mac_header(struct sk_buff *skb)
> +{
> +	skb->mac_header = skb->network_header;
> +	skb->mac_len = 0;
> +}
> +#endif /*NET_SKBUFF_DATA_USES_OFFSET*/
> +
> +/* __rmnet_deliver_skb() - Deliver skb
> + *
> + * Determines where to deliver skb. Options are: consume by network stack,
> + * pass to bridge handler, or pass to virtual network device
> + */
> +static rx_handler_result_t __rmnet_deliver_skb
> +	(struct sk_buff *skb, struct rmnet_logical_ep_conf_s *ep)
> +{
> +	switch (ep->rmnet_mode) {
> +	case RMNET_EPMODE_NONE:
> +		return RX_HANDLER_PASS;
> +
> +	case RMNET_EPMODE_BRIDGE:
> +		return rmnet_bridge_handler(skb, ep);
> +
> +	case RMNET_EPMODE_VND:
> +		skb_reset_transport_header(skb);
> +		skb_reset_network_header(skb);
> +		switch (rmnet_vnd_rx_fixup(skb, skb->dev)) {
> +		case RX_HANDLER_CONSUMED:
> +			return RX_HANDLER_CONSUMED;
> +
> +		case RX_HANDLER_PASS:
> +			skb->pkt_type = PACKET_HOST;
> +			rmnet_reset_mac_header(skb);
> +			netif_receive_skb(skb);
> +			return RX_HANDLER_CONSUMED;
> +		}
> +		return RX_HANDLER_PASS;
> +
> +	default:
> +		LOGD("Unknown ep mode %d", ep->rmnet_mode);
> +		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_DELIVER_NO_EP);
> +		return RX_HANDLER_CONSUMED;
> +	}
> +}
> +
> +/* rmnet_ingress_deliver_packet() - Ingress handler for raw IP and bridged
> + *                                  MAP packets.
> + * @skb:     Packet needing a destination.
> + * @config:  Physical end point configuration that the packet arrived on.
> + */
> +static rx_handler_result_t rmnet_ingress_deliver_packet
> +	(struct sk_buff *skb, struct rmnet_phys_ep_conf_s *config)
> +{
> +	if (!config) {
> +		LOGD("%s", "NULL physical EP provided");
> +		kfree_skb(skb);
> +		return RX_HANDLER_CONSUMED;
> +	}
> +
> +	if (!(config->local_ep.refcount)) {
> +		LOGD("Packet on %s has no local endpoint configuration",
> +		     skb->dev->name);
> +		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_IPINGRESS_NO_EP);
> +		return RX_HANDLER_CONSUMED;
> +	}
> +
> +	skb->dev = config->local_ep.egress_dev;
> +
> +	return __rmnet_deliver_skb(skb, &config->local_ep);
> +}
> +
> +/* MAP handler */
